from flask import Blueprint, jsonify, request
from app.models import Recipe, RecipeNutrientsPer100g
from app.services.recommendations import get_recommendations_for_user

main = Blueprint("main", __name__)


@main.route("/")
def home():
    return jsonify({"message": "Flask works!"})


@main.route("/recommendations/<int:user_id>")
def recommendations(user_id: int):
    limit = request.args.get("limit", default=20, type=int)
    payload, status = get_recommendations_for_user(user_id=user_id, limit=limit)
    return jsonify(payload), status


@main.route("/recipes")
def get_recipes():
    recipes = Recipe.query.all()

    result = []
    for recipe in recipes:
        result.append({
            "id": recipe.id,
            "title": recipe.title,
            "cooking_method": recipe.cooking_method,
            "description": recipe.description,
        })

    return jsonify(result)


@main.route("/recipes/<int:recipe_id>")
def get_recipe_by_id(recipe_id: int):
    recipe = Recipe.query.get(recipe_id)

    if not recipe:
        return jsonify({"error": "Recipe not found"}), 404

    nutrients = RecipeNutrientsPer100g.query.get(recipe_id)

    return jsonify({
        "id": recipe.id,
        "title": recipe.title,
        "description": recipe.description,
        "cooking_method": recipe.cooking_method,
        "cooking_time": recipe.cooking_time,
        "servings": recipe.servings,
        "instructions": recipe.instructions,
        "nutrients_per_100g": {
            "kcal": nutrients.kcal if nutrients else None,
            "protein": nutrients.protein if nutrients else None,
            "fat": nutrients.fat if nutrients else None,
            "carbs": nutrients.carbs if nutrients else None,
            "sugar": nutrients.sugar if nutrients else None,
            "sodium_mg": nutrients.sodium_mg if nutrients else None,
        }
    })