from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity

from app.extensions import db
from app.models import (
    User,
    Recipe,
    RecipeDiet,
    RecipeNutrientsPer100g,
    Diet,
    Product,
    UserExcludedProduct
)

from app.services.recommendations import get_recommendations_for_user

main = Blueprint("main", __name__)


# -------------------- BASIC --------------------

@main.route("/")
def home():
    return jsonify({"message": "Flask works!"})


# -------------------- RECOMMENDATIONS --------------------

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


# -------------------- RECIPES --------------------

@main.route("/recipes")
def get_recipes():

    recipes = Recipe.query.all()

    return jsonify([
        {
            "id": r.id,
            "title": r.title,
            "cooking_method": r.cooking_method,
            "description": r.description,
        }
        for r in recipes
    ])


@main.route("/recipes/<int:recipe_id>")
def get_recipe_by_id(recipe_id: int):

    recipe = db.session.get(Recipe, recipe_id)

    if not recipe:
        return {"error": "Recipe not found"}, 404

    nutrients = db.session.get(RecipeNutrientsPer100g, recipe_id)

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


# -------------------- USER --------------------

@main.route("/users/me")
@jwt_required()
def get_current_user():

    user_id = int(get_jwt_identity())
    user = db.session.get(User, user_id)

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

    diet = db.session.get(Diet, diet_id)
    if not diet:
        return {"error": "Diet not found"}, 404

    user = db.session.get(User, user_id)
    if not user:
        return {"error": "User not found"}, 404

    user.selected_diet_id = diet_id
    db.session.commit()

    return {
        "message": "Diet selected",
        "diet_id": diet_id
    }


# -------------------- DIETS --------------------

@main.route("/diets")
def get_diets():

    diets = Diet.query.all()

    return jsonify([
        {
            "id": d.id,
            "name": d.name,
            "description": d.description
        }
        for d in diets
    ])


# -------------------- PRODUCTS --------------------

@main.route("/products")
def get_products():

    products = Product.query.all()

    return jsonify([
        {
            "id": p.id,
            "name": p.name,
            "category": p.category
        }
        for p in products
    ])


# -------------------- EXCLUDED PRODUCTS --------------------

@main.route("/users/me/excluded-products", methods=["POST"])
@jwt_required()
def add_excluded_product():

    user_id = int(get_jwt_identity())
    data = request.get_json()

    product_id = data.get("product_id")
    if not product_id:
        return {"error": "product_id required"}, 400

    existing = UserExcludedProduct.query.filter_by(
        user_id=user_id,
        product_id=product_id
    ).first()

    if existing:
        return {"message": "Already excluded"}

    record = UserExcludedProduct(
        user_id=user_id,
        product_id=product_id
    )

    db.session.add(record)
    db.session.commit()

    return {"message": "Product excluded"}


@main.route("/users/me/excluded-products", methods=["GET"])
@jwt_required()
def get_excluded_products():

    user_id = int(get_jwt_identity())

    records = UserExcludedProduct.query.filter_by(user_id=user_id).all()

    return jsonify([
        {"product_id": r.product_id}
        for r in records
    ])


@main.route("/users/me/excluded-products/<int:product_id>", methods=["DELETE"])
@jwt_required()
def remove_excluded_product(product_id):

    user_id = int(get_jwt_identity())

    record = UserExcludedProduct.query.filter_by(
        user_id=user_id,
        product_id=product_id
    ).first()

    if not record:
        return {"error": "Not found"}, 404

    db.session.delete(record)
    db.session.commit()

    return {"message": "Removed"}