from flask import Blueprint, jsonify, request
from app.models import User, Recipe, RecipeDiet, RecipeNutrientsPer100g, Diet
from app.services.recommendations import get_recommendations_for_user
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.extensions import db

main = Blueprint("main", __name__)


@main.route("/")
def home():
    return jsonify({"message": "Flask works!"})


@main.route("/recommendations")
@jwt_required()
def recommendations():

    user_id = int(get_jwt_identity())

    limit = request.args.get("limit", default=20, type=int)

    payload, status = get_recommendations_for_user(
        user_id=user_id,
        limit=limit
    )

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
    
@main.route("/users/me")
@jwt_required()
def get_current_user():

    user_id = int(get_jwt_identity())

    user = User.query.get(user_id)

    if not user:
        return {"error": "User not found"}, 404

    return {
        "id": user.id,
        "email": user.email,
        "selected_diet_id": user.selected_diet_id
    }
    
@main.route("/users/me/diet", methods=["POST"])
@jwt_required()
def select_diet():

    user_id = int(get_jwt_identity())

    data = request.get_json()

    diet_id = data.get("diet_id")
    if not diet_id:
        return {"error": "diet_id required"}, 400

    
    diet = Diet.query.get(diet_id)
    
    if not diet:
        return {"error": "Diet not found"}, 404

    
    user = User.query.get(user_id)

    if not user:
        return {"error": "User not found"}, 404

    user.selected_diet_id = diet_id

    db.session.commit()

    return {
        "message": "Diet selected",
        "diet_id": diet_id
    }
    
@main.route("/diets")
def get_diets():

    diets = Diet.query.all()

    result = []

    for diet in diets:
        result.append({
            "id": diet.id,
            "name": diet.name,
            "description": diet.description
        })

    return jsonify(result)