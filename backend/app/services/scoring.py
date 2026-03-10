
from app.models import (
    RecipeIngredient,
    Ingredient,
    DietProductRule,
    RecipeNutrientsPer100g,
    Diet,
    DietCookingMethodRestriction,
)

def build_effective_targets(diet):
    targets = {}

    if diet.max_calories is not None:
        targets["kcal"] = diet.max_calories

    if diet.max_salt_mg is not None:
        targets["sodium_mg"] = diet.max_salt_mg

    if diet.max_fat_percent is not None:
        targets["fat"] = diet.max_fat_percent

    if diet.max_carbs_percent is not None:
        targets["carbs"] = diet.max_carbs_percent

    return targets

def calculate_ingredient_score(recipe_id, diet_id):

    ingredients = (
        RecipeIngredient.query
        .join(Ingredient)
        .filter(RecipeIngredient.recipe_id == recipe_id)
        .all()
    )

    if not ingredients:
        return 0

    score = 0
    total = len(ingredients)

    for ri in ingredients:

        product_id = ri.ingredient.product_id

        rule = DietProductRule.query.filter_by(
            diet_id=diet_id,
            product_id=product_id
        ).first()

        if not rule:
            score += 0.7
        elif rule.status == "recommended":
            score += 1.0
        elif rule.status == "allowed":
            score += 0.7
        else:
            score += 0

    return score / total
def normalized_upper_bound_score(value, target):
    if value is None or target is None:
        return 1.0

    if value <= target:
        return 1.0

    return max(target / value, 0.0)
def calculate_nutrient_score(recipe_id, diet_id):
    nutrients = RecipeNutrientsPer100g.query.get(recipe_id)
    diet = Diet.query.get(diet_id)

    if not nutrients or not diet:
        return 0.5

    targets = build_effective_targets(diet)

    component_scores = []

    if "kcal" in targets:
        component_scores.append(
            normalized_upper_bound_score(nutrients.kcal, targets["kcal"])
        )

    if "sodium_mg" in targets:
        component_scores.append(
            normalized_upper_bound_score(nutrients.sodium_mg, targets["sodium_mg"])
        )

    if "fat" in targets:
        component_scores.append(
            normalized_upper_bound_score(nutrients.fat, targets["fat"])
        )

    if "carbs" in targets:
        component_scores.append(
            normalized_upper_bound_score(nutrients.carbs, targets["carbs"])
        )

    if not component_scores:
        return 0.5

    return sum(component_scores) / len(component_scores)
def calculate_cooking_method_score(recipe, diet_id):

    rule = DietCookingMethodRestriction.query.filter_by(
        diet_id=diet_id,
        cooking_method=recipe.cooking_method
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
    return 0.5
def calculate_final_score(
    ingredient_score,
    nutrient_score,
    cooking_method_score,
    personal_score
):

    return 100 * (
        0.50 * ingredient_score +
        0.35 * nutrient_score +
        0.05 * cooking_method_score +
        0.10 * personal_score
    )