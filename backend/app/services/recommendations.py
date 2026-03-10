from app import db
from app.models import (
    User,
    Recipe,
    RecipeDiet,
    RecipeIngredient,
    Ingredient,
    UserExcludedProduct,
    DietProductRule,
    DietCookingMethodRestriction,
    RecipeNutrientsPer100g,
)
from app.services.scoring import (
    calculate_ingredient_score,
    calculate_nutrient_score,
    calculate_cooking_method_score,
    calculate_personal_score,
    calculate_final_score
)
def get_recommendations_for_user(user_id: int, limit: int = 20):
    user = db.session.get(User, user_id)

    if not user:
        return {"error": "User not found"}, 404

    if not user.selected_diet_id:
        return {"error": "User has no selected diet"}, 400

    diet_id = user.selected_diet_id

    excluded_subquery = (
        db.select(UserExcludedProduct.product_id)
        .where(UserExcludedProduct.user_id == user_id)
    )

    forbidden_products_subquery = (
        db.select(DietProductRule.product_id)
        .where(
            DietProductRule.diet_id == diet_id,
            DietProductRule.status == "forbidden"
        )
    )

    forbidden_methods_subquery = (
        db.select(DietCookingMethodRestriction.cooking_method)
        .where(
            DietCookingMethodRestriction.diet_id == diet_id,
            DietCookingMethodRestriction.status == "forbidden"
        )
    )

    query = (
        db.session.query(Recipe, RecipeNutrientsPer100g)
        .join(RecipeDiet, RecipeDiet.recipe_id == Recipe.id)
        .outerjoin(RecipeNutrientsPer100g, RecipeNutrientsPer100g.recipe_id == Recipe.id)
        .filter(RecipeDiet.diet_id == diet_id)
        .filter(~Recipe.cooking_method.in_(forbidden_methods_subquery))
        .filter(
            ~db.exists().where(
                (RecipeIngredient.recipe_id == Recipe.id)
                & (RecipeIngredient.ingredient_id == Ingredient.id)
                & (Ingredient.product_id.in_(excluded_subquery))
            )
        )
        .filter(
            ~db.exists().where(
                (RecipeIngredient.recipe_id == Recipe.id)
                & (RecipeIngredient.ingredient_id == Ingredient.id)
                & (Ingredient.product_id.in_(forbidden_products_subquery))
            )
        )
        .order_by(Recipe.id.asc())
    )

    recipes = []

    for recipe, nutrients in query.all():
        ingredient_score = calculate_ingredient_score(recipe.id, diet_id)

        nutrient_score = calculate_nutrient_score(recipe.id, diet_id)

        cooking_method_score = calculate_cooking_method_score(recipe, diet_id)

        personal_score = calculate_personal_score(user_id, recipe)

        final_score = calculate_final_score(
            ingredient_score,
            nutrient_score,
            cooking_method_score,
            personal_score
        )

        recipes.append({
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
                "nutrient_score": nutrient_score,
                "cooking_method_score": cooking_method_score,
                "personal_score": personal_score
            }
        })
    recipes = sorted(recipes, key=lambda r: r["final_score"], reverse=True)
    recipes = recipes[:limit]

    return {
        "user_id": user_id,
        "diet_id": diet_id,
        "recipes": recipes
    }, 200