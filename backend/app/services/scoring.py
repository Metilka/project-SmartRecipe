from app.models import (
    Diet,
    DietCookingMethodRestriction,
    DietProductRule,
    Product,
    RecipeIngredient,
    RecipeNutrientsPer100g,
    User,
    UserProductPreference,
)


MEDICAL_LIMITS_PER_100G = {
    "low_sodium": {"sodium_mg": 120.0},
    "low_sugar": {"sugar": 5.0},
    "low_fat": {"fat": 10.0},
}

INGREDIENT_RULE_WEIGHTS = {
    "recommended": 1.0,
    "allowed": 0.7,
    "forbidden": 0.3,
}


def clamp01(value):
    return max(0.0, min(1.0, value))


def normalized_upper_bound_score(value, target):
    if value is None or target is None or target <= 0:
        return 1.0
    if value <= target:
        return 1.0
    return clamp01(target / value)


def build_effective_targets(user, diet):
    profile = user.profile
    reference_mass = 2000.0

    if profile and profile.reference_mass_g_per_day:
        reference_mass = profile.reference_mass_g_per_day

    targets = {}

    if diet and diet.max_calories is not None:
        targets["kcal"] = diet.max_calories / (reference_mass / 100.0)
    if diet and diet.max_salt_mg is not None:
        targets["sodium_mg"] = diet.max_salt_mg / (reference_mass / 100.0)
    if diet and diet.max_fat_percent is not None:
        targets["fat"] = diet.max_fat_percent
    if diet and diet.max_carbs_percent is not None:
        targets["carbs"] = diet.max_carbs_percent

    if profile:
        user_targets = {
            "kcal": profile.target_kcal,
            "protein": profile.target_protein,
            "fat": profile.target_fat,
            "carbs": profile.target_carbs,
            "sugar": profile.target_sugar,
            "sodium_mg": profile.target_sodium_mg,
        }

        for key, daily_value in user_targets.items():
            if daily_value is None:
                continue

            per_100g_value = daily_value / (reference_mass / 100.0)

            if key not in targets:
                targets[key] = per_100g_value
            else:
                targets[key] = min(targets[key], per_100g_value)

        for flag_name, limits in MEDICAL_LIMITS_PER_100G.items():
            if getattr(profile, flag_name, False):
                for nutrient_name, hard_limit in limits.items():
                    current = targets.get(nutrient_name)
                    if current is None:
                        targets[nutrient_name] = hard_limit
                    else:
                        targets[nutrient_name] = min(current, hard_limit)

    return targets


def calculate_ingredient_score(recipe_id, diet_id):
    recipe_products = (
        RecipeIngredient.query.join(Product, Product.id == RecipeIngredient.product_id)
        .filter(RecipeIngredient.recipe_id == recipe_id)
        .all()
    )

    if not recipe_products:
        return 0.0

    rules = {
        row.product_id: row
        for row in DietProductRule.query.filter_by(diet_id=diet_id).all()
    }

    weighted_score = 0.0
    total_weight = 0.0

    for ri in recipe_products:
        rule = rules.get(ri.product_id)

        if not rule:
            coeff = 0.7
        else:
            coeff = INGREDIENT_RULE_WEIGHTS.get(rule.status, 0.7)

        weight = ri.quantity if ri.quantity and ri.quantity > 0 else 1.0

        weighted_score += coeff * weight
        total_weight += weight

    if total_weight <= 0:
        return 0.0

    return round(clamp01(weighted_score / total_weight), 4)


def calculate_nutrient_score(recipe_id, user):
    nutrients = RecipeNutrientsPer100g.query.get(recipe_id)
    diet = Diet.query.get(user.selected_diet_id) if user.selected_diet_id else None

    if not nutrients:
        return 0.5

    targets = build_effective_targets(user, diet)
    component_scores = []

    comparable = {
        "kcal": nutrients.kcal,
        "protein": nutrients.protein,
        "fat": nutrients.fat,
        "carbs": nutrients.carbs,
        "sugar": nutrients.sugar,
        "sodium_mg": nutrients.sodium_mg,
    }

    for nutrient_name, target in targets.items():
        if nutrient_name == "protein":
            value = comparable.get(nutrient_name)
            if value is None or target is None or target <= 0:
                component_scores.append(1.0)
            else:
                component_scores.append(clamp01(min(value / target, 1.0)))
        else:
            component_scores.append(
                normalized_upper_bound_score(
                    comparable.get(nutrient_name),
                    target,
                )
            )

    if not component_scores:
        return 0.5

    return round(sum(component_scores) / len(component_scores), 4)


def calculate_cooking_method_score(recipe, diet_id):
    rule = DietCookingMethodRestriction.query.filter_by(
        diet_id=diet_id,
        cooking_method=recipe.cooking_method,
        is_hard=False,
    ).first()

    if not rule:
        return 0.7
    if rule.status == "recommended":
        return 1.0
    if rule.status == "allowed":
        return 0.7
    if rule.status == "forbidden":
        return 0.3

    return 0.7


def calculate_personal_score(user_id, recipe):
    favorite_product_ids = {
        row.product_id
        for row in UserProductPreference.query.filter_by(
            user_id=user_id,
            preference_type="favorite",
        ).all()
    }

    if not favorite_product_ids:
        return 0.5

    recipe_product_ids = {
        row.product_id
        for row in RecipeIngredient.query.filter_by(recipe_id=recipe.id).all()
    }

    if not recipe_product_ids:
        return 0.5

    overlap = len(recipe_product_ids & favorite_product_ids)
    score = 0.5 + 0.5 * (overlap / len(recipe_product_ids))

    return round(clamp01(score), 4)


def calculate_final_score(
    ingredient_score,
    nutrient_score,
    cooking_method_score,
    personal_score,
):
    return 100 * (
        0.50 * ingredient_score
        + 0.35 * nutrient_score
        + 0.05 * cooking_method_score
        + 0.10 * personal_score
    )