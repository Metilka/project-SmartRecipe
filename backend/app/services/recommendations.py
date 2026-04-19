from collections import defaultdict

from sqlalchemy.orm import joinedload

from app import db
from app.models import (
    DietCookingMethodRestriction,
    DietProductRule,
    Product,
    Recipe,
    RecipeDiet,
    RecipeIngredient,
    User,
    UserProductPreference,
)
from app.services.scoring import (
    MEDICAL_LIMITS_PER_100G,
    build_effective_targets,
    build_explain_summary,
    build_fit_reasons,
    build_penalties,
    calculate_cooking_method_score_from_rules,
    calculate_final_score,
    calculate_ingredient_score_from_rows,
    calculate_nutrient_score_from_recipe,
    calculate_personal_score_details,
)


def get_allowed_product_ids_for_diet(diet_id: int):
    rows = (
        db.session.query(DietProductRule.product_id)
        .filter(
            DietProductRule.diet_id == diet_id,
            DietProductRule.status.in_(["allowed", "recommended"]),
        )
        .all()
    )
    return {row[0] for row in rows}


def _load_scoring_context(user_id):
    user = (
        db.session.query(User)
        .options(
            joinedload(User.profile),
            joinedload(User.selected_diet),
        )
        .filter(User.id == user_id)
        .first()
    )
    if not user:
        return None, ({"error": "User not found"}, 404)
    if not user.selected_diet_id:
        return None, ({"error": "User has no selected diet"}, 400)

    diet_id = user.selected_diet_id

    prefs = (
        db.session.query(UserProductPreference)
        .filter(UserProductPreference.user_id == user_id)
        .all()
    )
    excluded_product_ids = {p.product_id for p in prefs if p.preference_type == "excluded"}
    favorite_product_ids = {p.product_id for p in prefs if p.preference_type == "favorite"}

    product_rules = {
        row.product_id: row
        for row in DietProductRule.query.filter_by(diet_id=diet_id).all()
    }
    hard_banned_product_ids = {
        pid for pid, rule in product_rules.items()
        if rule.is_hard and rule.status == "forbidden"
    }

    cooking_rules = {
        row.cooking_method: row
        for row in DietCookingMethodRestriction.query.filter_by(diet_id=diet_id).all()
    }
    hard_banned_methods = {
        m for m, rule in cooking_rules.items()
        if rule.is_hard and rule.status == "forbidden"
    }

    preference_tags = []
    if user.profile and user.profile.preference_tags:
        preference_tags = list(user.profile.preference_tags)

    ctx = {
        "user": user,
        "diet_id": diet_id,
        "diet": user.selected_diet,
        "profile": user.profile,
        "excluded_product_ids": excluded_product_ids,
        "favorite_product_ids": favorite_product_ids,
        "product_rules": product_rules,
        "hard_banned_product_ids": hard_banned_product_ids,
        "cooking_rules": cooking_rules,
        "hard_banned_methods": hard_banned_methods,
        "preference_tags": preference_tags,
    }
    return ctx, None


def _ingredients_map_for_recipes(recipe_ids):
    if not recipe_ids:
        return {}

    rows = (
        db.session.query(RecipeIngredient, Product)
        .join(Product, Product.id == RecipeIngredient.product_id)
        .filter(RecipeIngredient.recipe_id.in_(recipe_ids))
        .all()
    )
    out = defaultdict(list)
    for ri, product in rows:
        out[ri.recipe_id].append((ri, product))
    return out


def _medical_hard_filter_reasons(profile, ingredients, recipe):
    reasons = []
    if not profile:
        return reasons

    if profile.no_spicy and any(p.is_spicy for _, p in ingredients):
        reasons.append("contains_spicy_product")
    if profile.no_acidic and any(p.is_acidic for _, p in ingredients):
        reasons.append("contains_acidic_product")
    if profile.no_saturated_fat and any(p.is_saturated_fat for _, p in ingredients):
        reasons.append("contains_saturated_fat_product")

    if recipe:
        for flag_name, limits in MEDICAL_LIMITS_PER_100G.items():
            if not getattr(profile, flag_name, False):
                continue
            for nutrient_name, hard_limit in limits.items():
                value = getattr(recipe, nutrient_name, None)
                if value is not None and value > hard_limit:
                    reasons.append(f"medical_flag_{flag_name}_{nutrient_name}_exceeded")

    return reasons


def _humanize_hard_filter_reason(reason_code):
    mapping = {
        "contains_spicy_product": "В составе есть острые продукты.",
        "contains_acidic_product": "В составе есть кислые продукты.",
        "contains_saturated_fat_product": "В составе есть выраженные насыщенные жиры.",
        "medical_flag_low_sodium_sodium_mg_exceeded": "Превышен персональный лимит по натрию.",
        "medical_flag_low_sugar_sugar_exceeded": "Превышен персональный лимит по сахару.",
        "medical_flag_low_fat_fat_exceeded": "Превышен персональный лимит по жирам.",
    }
    return mapping.get(reason_code, reason_code)


def _serialize_nutrients(recipe):
    if not recipe:
        return None
    return {
        "kcal": recipe.kcal,
        "protein": recipe.protein,
        "fat": recipe.fat,
        "carbs": recipe.carbs,
        "sugar": recipe.sugar,
        "sodium_mg": recipe.sodium_mg,
    }


def _serialize_recipe_with_ingredients(recipe, ingredients):
    return {
        "id": recipe.id,
        "title": recipe.title,
        "description": recipe.description,
        "cooking_method": recipe.cooking_method,
        "cooking_time": recipe.cooking_time,
        "servings": recipe.servings,
        "instructions": recipe.instructions,
        "nutrients_per_100g": _serialize_nutrients(recipe),
        "ingredients": [
            {
                "product_id": ri.product_id,
                "ingredient_name": (ri.display_name or (product.name if product else None)),
                "product_name": product.name if product else None,
                "product_category": product.category if product else None,
                "quantity": ri.quantity,
                "unit": ri.unit,
            }
            for ri, product in ingredients
        ],
    }


def get_recommendations_for_user(user_id: int, limit: int = 20):
    ctx, err = _load_scoring_context(user_id)
    if err:
        return err

    user = ctx["user"]
    diet_id = ctx["diet_id"]
    diet = ctx["diet"]
    profile = ctx["profile"]

    excluded_product_ids = ctx["excluded_product_ids"]
    favorite_product_ids = ctx["favorite_product_ids"]
    product_rules = ctx["product_rules"]
    hard_banned_product_ids = ctx["hard_banned_product_ids"]
    cooking_rules = ctx["cooking_rules"]
    hard_banned_methods = ctx["hard_banned_methods"]
    preference_tags = ctx["preference_tags"]

    query = (
        db.session.query(Recipe)
        .join(RecipeDiet, RecipeDiet.recipe_id == Recipe.id)
        .filter(RecipeDiet.diet_id == diet_id)
    )

    if hard_banned_methods:
        query = query.filter(~Recipe.cooking_method.in_(hard_banned_methods))

    blocked_product_ids = excluded_product_ids | hard_banned_product_ids
    if blocked_product_ids:
        query = query.filter(
            ~db.session.query(RecipeIngredient.id)
            .filter(
                RecipeIngredient.recipe_id == Recipe.id,
                RecipeIngredient.product_id.in_(blocked_product_ids),
            )
            .exists()
        )

    recipe_rows = query.order_by(Recipe.id.asc()).all()

    if not recipe_rows:
        return {"user_id": user_id, "diet_id": diet_id, "count": 0, "recipes": []}, 200

    recipe_ids = [r.id for r in recipe_rows]
    ing_map = _ingredients_map_for_recipes(recipe_ids)
    effective_targets = build_effective_targets(user, diet)

    result = []
    for recipe in recipe_rows:
        ingredients = ing_map.get(recipe.id, [])

        hard_reasons = _medical_hard_filter_reasons(profile, ingredients, recipe)
        if hard_reasons:
            continue

        ingredient_score = calculate_ingredient_score_from_rows(ingredients, product_rules)
        nutrient_score = calculate_nutrient_score_from_recipe(recipe, effective_targets, user, diet)
        cooking_method_score = calculate_cooking_method_score_from_rules(recipe.cooking_method, cooking_rules)
        personal_details = calculate_personal_score_details(recipe, ingredients, favorite_product_ids, preference_tags)
        personal_score = personal_details["score"]

        final_score = calculate_final_score(ingredient_score, nutrient_score, cooking_method_score, personal_score)

        breakdown = {
            "ingredient_score": round(ingredient_score, 3),
            "nutrient_score": round(nutrient_score, 3),
            "cooking_method_score": round(cooking_method_score, 3),
            "personal_score": round(personal_score, 3),
        }

        matched_tags = personal_details["matched_tags"]
        fit_reasons = build_fit_reasons(recipe, breakdown, matched_tags, user)
        penalties = build_penalties(recipe, effective_targets, breakdown, user, diet)
        explain = build_explain_summary(breakdown, matched_tags)

        result.append({
            "recipe_id": recipe.id,
            "title": recipe.title,
            "description": recipe.description,
            "cooking_method": recipe.cooking_method,
            "cooking_time": recipe.cooking_time,
            "servings": recipe.servings,
            "nutrients_per_100g": _serialize_nutrients(recipe),
            "final_score": round(final_score, 2),
            "breakdown": breakdown,
            "effective_targets_per_100g": effective_targets,
            "matched_preference_tags": matched_tags,
            "fit_reasons": fit_reasons,
            "penalties": penalties,
            "explain": explain,
        })

    result.sort(key=lambda row: row["final_score"], reverse=True)
    result = result[:limit]

    return {
        "user_id": user_id,
        "diet_id": diet_id,
        "count": len(result),
        "recipes": result,
    }, 200


def get_personalized_recipe_for_user(user_id: int, recipe_id: int):
    ctx, err = _load_scoring_context(user_id)
    if err:
        return err

    user = ctx["user"]
    diet = ctx["diet"]
    diet_id = ctx["diet_id"]
    profile = ctx["profile"]
    product_rules = ctx["product_rules"]
    cooking_rules = ctx["cooking_rules"]
    hard_banned_product_ids = ctx["hard_banned_product_ids"]
    hard_banned_methods = ctx["hard_banned_methods"]
    excluded_product_ids = ctx["excluded_product_ids"]
    favorite_product_ids = ctx["favorite_product_ids"]
    preference_tags = ctx["preference_tags"]

    recipe = db.session.get(Recipe, recipe_id)
    if not recipe:
        return {"error": "Recipe not found"}, 404

    ingredients = (
        db.session.query(RecipeIngredient, Product)
        .join(Product, Product.id == RecipeIngredient.product_id)
        .filter(RecipeIngredient.recipe_id == recipe_id)
        .all()
    )
    recipe_product_ids = {ri.product_id for ri, _ in ingredients}

    blocking_reasons = []

    in_diet = db.session.query(RecipeDiet).filter_by(recipe_id=recipe_id, diet_id=diet_id).first()
    if not in_diet:
        blocking_reasons.append("Рецепт не относится к выбранной диете.")

    if recipe_product_ids & excluded_product_ids:
        blocking_reasons.append("В составе есть исключённые пользователем продукты.")
    if recipe_product_ids & hard_banned_product_ids:
        blocking_reasons.append("В составе есть продукты, запрещённые выбранной диетой.")
    if recipe.cooking_method in hard_banned_methods:
        blocking_reasons.append("Способ приготовления запрещён правилами диеты.")

    for code in _medical_hard_filter_reasons(profile, ingredients, recipe):
        blocking_reasons.append(_humanize_hard_filter_reason(code))

    seen = set()
    blocking_reasons = [r for r in blocking_reasons if not (r in seen or seen.add(r))]

    recipe_payload = _serialize_recipe_with_ingredients(recipe, ingredients)

    if blocking_reasons:
        return {
            "blocked": True,
            "reasons": blocking_reasons,
            "recipe": recipe_payload,
        }, 200

    effective_targets = build_effective_targets(user, diet)
    ingredient_score = calculate_ingredient_score_from_rows(ingredients, product_rules)
    nutrient_score = calculate_nutrient_score_from_recipe(recipe, effective_targets, user, diet)
    cooking_method_score = calculate_cooking_method_score_from_rules(recipe.cooking_method, cooking_rules)
    personal_details = calculate_personal_score_details(recipe, ingredients, favorite_product_ids, preference_tags)
    personal_score = personal_details["score"]
    final_score = calculate_final_score(ingredient_score, nutrient_score, cooking_method_score, personal_score)

    breakdown = {
        "ingredient_score": round(ingredient_score, 3),
        "nutrient_score": round(nutrient_score, 3),
        "cooking_method_score": round(cooking_method_score, 3),
        "personal_score": round(personal_score, 3),
    }
    matched_tags = personal_details["matched_tags"]

    return {
        "blocked": False,
        "final_score": round(final_score, 2),
        "breakdown": breakdown,
        "effective_targets_per_100g": effective_targets,
        "matched_preference_tags": matched_tags,
        "fit_reasons": build_fit_reasons(recipe, breakdown, matched_tags, user),
        "penalties": build_penalties(recipe, effective_targets, breakdown, user, diet),
        "explain": build_explain_summary(breakdown, matched_tags),
        "recipe": recipe_payload,
    }, 200