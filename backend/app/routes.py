from flask import Blueprint, jsonify
from .models import Ingredient

main = Blueprint("main", __name__)


@main.route("/")
def home():
    return jsonify({"message": "Backend is working!"})


@main.route("/ingredients", methods=["GET"])
def get_ingredients():
    ingredients = Ingredient.query.all()

    result = []

    for ingredient in ingredients:
        result.append({
            "id": ingredient.id,
            "name": ingredient.name,
            "category": ingredient.category,
            "calories_per_100g": ingredient.calories_per_100g
        })

    return jsonify(result)
