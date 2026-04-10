from app import db
from app.models import (
    DietHardCookingBan,
    DietHardProductBan,
    DietProductRule,
    Ingredient,
    Recipe,
    RecipeDiet,
    RecipeIngredient,
    RecipeNutrientsPer100g,
    User,
    UserExcludedProduct,
)
from app.services.scoring import (
    MEDICAL_LIMITS_PER_100G,
    build_effective_targets,
    calculate_cooking_method_score,
    calculate_final_score,
    calculate_ingredient_score,
    calculate_nutrient_score,
    calculate_personal_score,
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


def get_hard_filter_reasons(user, recipe, nutrients):
    reasons = []
    profile = user.profile

    if not profile:
        return reasons

    if profile.no_spicy:
        spicy_exists = (
            db.session.query(RecipeIngredient.id)
            .join(Ingredient, Ingredient.id == RecipeIngredient.ingredient_id)
            .filter(
                RecipeIngredient.recipe_id == recipe.id,
                Ingredient.is_spicy.is_(True),
            )
            .first()
        )
        if spicy_exists:
            reasons.append("contains_spicy_ingredient")

    if profile.no_acidic:
        acidic_exists = (
            db.session.query(RecipeIngredient.id)
            .join(Ingredient, Ingredient.id == RecipeIngredient.ingredient_id)
            .filter(
                RecipeIngredient.recipe_id == recipe.id,
                Ingredient.is_acidic.is_(True),
            )
            .first()
        )
        if acidic_exists:
            reasons.append("contains_acidic_ingredient")

    if profile.no_saturated_fat:
        sat_exists = (
            db.session.query(RecipeIngredient.id)
            .join(Ingredient, Ingredient.id == RecipeIngredient.ingredient_id)
            .filter(
                RecipeIngredient.recipe_id == recipe.id,
                Ingredient.is_saturated_fat.is_(True),
            )
            .first()
        )
        if sat_exists:
            reasons.append("contains_saturated_fat_ingredient")

    if nutrients:
        for flag_name, limits in MEDICAL_LIMITS_PER_100G.items():
            if not getattr(profile, flag_name, False):
                continue

            for nutrient_name, hard_limit in limits.items():
                value = getattr(nutrients, nutrient_name, None)
                if value is not None and value > hard_limit:
                    reasons.append(
                        f"medical_flag_{flag_name}_{nutrient_name}_exceeded"
                    )

    return reasons


def get_recommendations_for_user(user_id: int, limit: int = 20):
    user = db.session.get(User, user_id)
    if not user:
        return {"error": "User not found"}, 404

    if not user.selected_diet_id:
        return {"error": "User has no selected diet"}, 400

    diet_id = user.selected_diet_id
    allowed_product_ids = get_allowed_product_ids_for_diet(diet_id)

    excluded_product_ids = {
        row[0]
        for row in db.session.query(UserExcludedProduct.product_id)
        .filter(UserExcludedProduct.user_id == user_id)
        .all()
    }

    invalid_excluded = excluded_product_ids - allowed_product_ids if allowed_product_ids else set()
    if invalid_excluded:
        return {
            "error": "Excluded products must belong to allowed products of selected diet",
            "invalid_product_ids": sorted(invalid_excluded),
        }, 400

    hard_banned_products_subquery = (
        db.select(DietHardProductBan.product_id)
        .where(DietHardProductBan.diet_id == diet_id)
    )

    hard_banned_methods_subquery = (
        db.select(DietHardCookingBan.cooking_method)
        .where(DietHardCookingBan.diet_id == diet_id)
    )

    query = (
        db.session.query(Recipe, RecipeNutrientsPer100g)
        .join(RecipeDiet, RecipeDiet.recipe_id == Recipe.id)
        .outerjoin(
            RecipeNutrientsPer100g,
            RecipeNutrientsPer100g.recipe_id == Recipe.id,
        )
        .filter(RecipeDiet.diet_id == diet_id)
        .filter(~Recipe.cooking_method.in_(hard_banned_methods_subquery))
        .filter(
            ~db.exists().where(
                (RecipeIngredient.recipe_id == Recipe.id)
                & (RecipeIngredient.ingredient_id == Ingredient.id)
                & (Ingredient.product_id.in_(excluded_product_ids))
            )
        )
        .filter(
            ~db.exists().where(
                (RecipeIngredient.recipe_id == Recipe.id)
                & (RecipeIngredient.ingredient_id == Ingredient.id)
                & (Ingredient.product_id.in_(hard_banned_products_subquery))
            )
        )
        .order_by(Recipe.id.asc())
    )

    recipes = []

    for recipe, nutrients in query.all():
        hard_filter_reasons = get_hard_filter_reasons(user, recipe, nutrients)
        if hard_filter_reasons:
            continue

        ingredient_score = calculate_ingredient_score(recipe.id, diet_id)
        nutrient_score = calculate_nutrient_score(recipe.id, user)
        cooking_method_score = calculate_cooking_method_score(recipe, diet_id)
        personal_score = calculate_personal_score(user_id, recipe)
        final_score = calculate_final_score(
            ingredient_score,
            nutrient_score,
            cooking_method_score,
            personal_score,
        )

        effective_targets = build_effective_targets(user, user.selected_diet)

        recipes.append(
            {
                "recipe_id": recipe.id,
                "title": recipe.title,
                "description": recipe.description,
                "cooking_method": recipe.cooking_method,
                "cooking_time": recipe.cooking_time,
                "servings": recipe.servings,
                "nutrients_per_100g": {
                    "kcal": nutrients.kcal if nutrients else None,
                    "protein": nutrients.protein if nutrients else None,
                    "fat": nutrients.fat if nutrients else None,
                    "carbs": nutrients.carbs if nutrients else None,
                    "sugar": nutrients.sugar if nutrients else None,
                    "sodium_mg": nutrients.sodium_mg if nutrients else None,
                },
                "final_score": round(final_score, 2),
                "breakdown": {
                    "ingredient_score": round(ingredient_score, 3),
                    "nutrient_score": round(nutrient_score, 3),
                    "cooking_method_score": round(cooking_method_score, 3),
                    "personal_score": round(personal_score, 3),
                },
                "effective_targets_per_100g": effective_targets,
                "explain": {
                    "hard_filter_reasons": [],
                    "notes": [],
                },
            }
        )

    recipes.sort(key=lambda r: r["final_score"], reverse=True)
    recipes = recipes[:limit]

    return {
        "user_id": user_id,
        "diet_id": diet_id,
        "count": len(recipes),
        "recipes": recipes,
    }, 200