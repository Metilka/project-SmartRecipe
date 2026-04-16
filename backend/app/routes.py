from flask import Blueprint, jsonify, request
from flask_jwt_extended import get_jwt_identity, jwt_required

from app.extensions import db
from app.models import (
    Diet,
    Product,
    Recipe,
    RecipeDiet,
    RecipeIngredient,
    RecipeNutrientsPer100g,
    User,
    UserProductPreference,
    UserProfile,
)
from app.services.recommendations import (
    get_allowed_product_ids_for_diet,
    get_recommendations_for_user,
)

main = Blueprint("main", __name__)


def get_authenticated_user():
    user_id = int(get_jwt_identity())
    return db.session.get(User, user_id)


def get_user_preference_ids(user, preference_type: str):
    if not user:
        return []
    return sorted(
        [
            item.product_id
            for item in user.product_preferences
            if item.preference_type == preference_type
        ]
    )


def serialize_profile(profile):
    if not profile:
        return {
            "low_sodium": False,
            "low_sugar": False,
            "low_fat": False,
            "no_spicy": False,
            "no_acidic": False,
            "no_saturated_fat": False,
            "target_kcal": None,
            "target_protein": None,
            "target_fat": None,
            "target_carbs": None,
            "target_sugar": None,
            "target_sodium_mg": None,
            "reference_mass_g_per_day": 2000,
        }

    return {
        "low_sodium": profile.low_sodium,
        "low_sugar": profile.low_sugar,
        "low_fat": profile.low_fat,
        "no_spicy": profile.no_spicy,
        "no_acidic": profile.no_acidic,
        "no_saturated_fat": profile.no_saturated_fat,
        "target_kcal": profile.target_kcal,
        "target_protein": profile.target_protein,
        "target_fat": profile.target_fat,
        "target_carbs": profile.target_carbs,
        "target_sugar": profile.target_sugar,
        "target_sodium_mg": profile.target_sodium_mg,
        "reference_mass_g_per_day": profile.reference_mass_g_per_day,
    }


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
        limit=limit,
    )
    return jsonify(payload), status


@main.route("/feed")
def guest_feed():
    diet_id = request.args.get("diet_id", type=int)
    if not diet_id:
        return jsonify({"error": "diet_id query param is required"}), 400

    recipes = (
        db.session.query(Recipe, RecipeNutrientsPer100g)
        .join(RecipeDiet, RecipeDiet.recipe_id == Recipe.id)
        .outerjoin(RecipeNutrientsPer100g, RecipeNutrientsPer100g.recipe_id == Recipe.id)
        .filter(RecipeDiet.diet_id == diet_id)
        .order_by(Recipe.id.asc())
        .all()
    )

    return jsonify(
        [
            {
                "id": recipe.id,
                "title": recipe.title,
                "cooking_method": recipe.cooking_method,
                "description": recipe.description,
                "nutrients_per_100g": {
                    "kcal": nutrients.kcal if nutrients else None,
                    "protein": nutrients.protein if nutrients else None,
                    "fat": nutrients.fat if nutrients else None,
                    "carbs": nutrients.carbs if nutrients else None,
                    "sugar": nutrients.sugar if nutrients else None,
                    "sodium_mg": nutrients.sodium_mg if nutrients else None,
                },
            }
            for recipe, nutrients in recipes
        ]
    )


@main.route("/recipes")
def get_recipes():
    diet_id = request.args.get("diet_id", type=int)

    query = db.session.query(Recipe)
    if diet_id:
        query = (
            query.join(RecipeDiet, RecipeDiet.recipe_id == Recipe.id)
            .filter(RecipeDiet.diet_id == diet_id)
        )

    recipes = query.order_by(Recipe.id.asc()).all()

    return jsonify(
        [
            {
                "id": recipe.id,
                "title": recipe.title,
                "cooking_method": recipe.cooking_method,
                "description": recipe.description,
            }
            for recipe in recipes
        ]
    )


@main.route("/recipes/<int:recipe_id>")
def get_recipe_by_id(recipe_id: int):
    recipe = db.session.get(Recipe, recipe_id)
    if not recipe:
        return jsonify({"error": "Recipe not found"}), 404

    nutrients = db.session.get(RecipeNutrientsPer100g, recipe_id)
    ingredients = (
        db.session.query(RecipeIngredient, Product)
        .join(Product, Product.id == RecipeIngredient.product_id, isouter=True)
        .filter(RecipeIngredient.recipe_id == recipe_id)
        .all()
    )

    return jsonify(
        {
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
            },
            "ingredients": [
                {
                    "product_id": ri.product_id,
                    "ingredient_name": product.name if product else None,
                    "quantity": ri.quantity,
                    "unit": ri.unit,
                }
                for ri, product in ingredients
            ],
        }
    )


@main.route("/users/me")
@jwt_required()
def get_current_user():
    user = get_authenticated_user()
    if not user:
        return {"error": "User not found"}, 404

    return jsonify(
        {
            "id": user.id,
            "email": user.email,
            "selected_diet_id": user.selected_diet_id,
            "profile": serialize_profile(user.profile),
            "excluded_product_ids": get_user_preference_ids(user, "excluded"),
            "favorite_product_ids": get_user_preference_ids(user, "favorite"),
        }
    )


@main.route("/users/me/diet", methods=["POST"])
@jwt_required()
def select_diet():
    user = get_authenticated_user()
    if not user:
        return {"error": "User not found"}, 404

    data = request.get_json() or {}
    diet_id = data.get("diet_id")
    if not diet_id:
        return {"error": "diet_id required"}, 400

    diet = db.session.get(Diet, diet_id)
    if not diet:
        return {"error": "Diet not found"}, 404

    user.selected_diet_id = diet_id
    db.session.commit()

    return jsonify(
        {
            "message": "Diet selected",
            "diet_id": diet_id,
        }
    )


@main.route("/profile", methods=["GET"])
@jwt_required()
def get_profile():
    user = get_authenticated_user()
    if not user:
        return {"error": "User not found"}, 404

    return jsonify(
        {
            "selected_diet_id": user.selected_diet_id,
            "allowed_product_ids": sorted(list(get_allowed_product_ids_for_diet(user.selected_diet_id))),
            "excluded_product_ids": get_user_preference_ids(user, "excluded"),
            "favorite_product_ids": get_user_preference_ids(user, "favorite"),
            "profile": serialize_profile(user.profile),
        }
    )


@main.route("/profile", methods=["PUT"])
@jwt_required()
def update_profile():
    user = get_authenticated_user()
    if not user:
        return {"error": "User not found"}, 404

    data = request.get_json() or {}

    if not user.profile:
        user.profile = UserProfile(user_id=user.id)

    profile = user.profile

    if "selected_diet_id" in data:
        diet_id = data["selected_diet_id"]
        diet = db.session.get(Diet, diet_id)
        if not diet:
            return {"error": "Diet not found"}, 404
        user.selected_diet_id = diet_id

    allowed_product_ids = get_allowed_product_ids_for_diet(user.selected_diet_id)

    excluded_product_ids = set(
        data.get(
            "excluded_product_ids",
            get_user_preference_ids(user, "excluded"),
        )
    )
    favorite_product_ids = set(
        data.get(
            "favorite_product_ids",
            get_user_preference_ids(user, "favorite"),
        )
    )

    invalid_excluded = excluded_product_ids - allowed_product_ids if allowed_product_ids else set()
    invalid_favorites = {
        pid for pid in favorite_product_ids if not db.session.get(Product, pid)
    }

    if invalid_excluded:
        return {
            "error": "Excluded products must belong to allowed products of selected diet",
            "invalid_product_ids": sorted(invalid_excluded),
        }, 400

    if invalid_favorites:
        return {
            "error": "Favorite products must exist",
            "invalid_product_ids": sorted(invalid_favorites),
        }, 400

    for field in [
        "low_sodium",
        "low_sugar",
        "low_fat",
        "no_spicy",
        "no_acidic",
        "no_saturated_fat",
        "target_kcal",
        "target_protein",
        "target_fat",
        "target_carbs",
        "target_sugar",
        "target_sodium_mg",
        "reference_mass_g_per_day",
    ]:
        if field in data:
            setattr(profile, field, data[field])

    UserProductPreference.query.filter_by(user_id=user.id).delete()

    for product_id in sorted(excluded_product_ids):
        db.session.add(
            UserProductPreference(
                user_id=user.id,
                product_id=product_id,
                preference_type="excluded",
            )
        )

    for product_id in sorted(favorite_product_ids):
        db.session.add(
            UserProductPreference(
                user_id=user.id,
                product_id=product_id,
                preference_type="favorite",
            )
        )

    db.session.add(profile)
    db.session.commit()

    return jsonify(
        {
            "message": "Profile updated",
            "selected_diet_id": user.selected_diet_id,
            "allowed_product_ids": sorted(list(allowed_product_ids)),
            "excluded_product_ids": sorted(excluded_product_ids),
            "favorite_product_ids": sorted(favorite_product_ids),
            "profile": serialize_profile(profile),
        }
    )


@main.route("/diets")
def get_diets():
    diets = db.session.query(Diet).order_by(Diet.id.asc()).all()

    return jsonify(
        [
            {
                "id": diet.id,
                "name": diet.name,
                "description": diet.description,
            }
            for diet in diets
        ]
    )


@main.route("/diets/<int:diet_id>/allowed-products")
def get_allowed_products(diet_id: int):
    product_ids = get_allowed_product_ids_for_diet(diet_id)

    products = (
        db.session.query(Product)
        .filter(Product.id.in_(product_ids))
        .order_by(Product.name.asc())
        .all()
        if product_ids
        else []
    )

    return jsonify(
        [
            {
                "id": product.id,
                "name": product.name,
                "category": product.category,
            }
            for product in products
        ]
    )


@main.route("/products")
def get_products():
    products = db.session.query(Product).order_by(Product.name.asc()).all()

    return jsonify(
        [
            {
                "id": product.id,
                "name": product.name,
                "category": product.category,
            }
            for product in products
        ]
    )


@main.route("/users/me/excluded-products", methods=["GET"])
@jwt_required()
def get_excluded_products():
    user = get_authenticated_user()
    if not user:
        return {"error": "User not found"}, 404

    records = (
        db.session.query(UserProductPreference)
        .filter_by(user_id=user.id, preference_type="excluded")
        .order_by(UserProductPreference.product_id.asc())
        .all()
    )

    return jsonify([{"product_id": record.product_id} for record in records])


@main.route("/users/me/excluded-products", methods=["POST"])
@jwt_required()
def add_excluded_product():
    user = get_authenticated_user()
    if not user:
        return {"error": "User not found"}, 404

    data = request.get_json() or {}
    product_id = data.get("product_id")

    if not product_id:
        return {"error": "product_id required"}, 400

    product = db.session.get(Product, product_id)
    if not product:
        return {"error": "Product not found"}, 404

    allowed_product_ids = get_allowed_product_ids_for_diet(user.selected_diet_id)
    if allowed_product_ids and product_id not in allowed_product_ids:
        return {
            "error": "Product must belong to allowed products of selected diet",
            "product_id": product_id,
        }, 400

    existing = (
        db.session.query(UserProductPreference)
        .filter_by(
            user_id=user.id,
            product_id=product_id,
            preference_type="excluded",
        )
        .first()
    )
    if existing:
        return {"message": "Already excluded"}, 200

    record = UserProductPreference(
        user_id=user.id,
        product_id=product_id,
        preference_type="excluded",
    )
    db.session.add(record)
    db.session.commit()

    return {"message": "Product excluded"}, 201


@main.route("/users/me/excluded-products/<int:product_id>", methods=["DELETE"])
@jwt_required()
def remove_excluded_product(product_id):
    user = get_authenticated_user()
    if not user:
        return {"error": "User not found"}, 404

    record = (
        db.session.query(UserProductPreference)
        .filter_by(
            user_id=user.id,
            product_id=product_id,
            preference_type="excluded",
        )
        .first()
    )

    if not record:
        return {"error": "Not found"}, 404

    db.session.delete(record)
    db.session.commit()

    return {"message": "Removed"}


@main.route("/users/me/favorite-products", methods=["GET"])
@jwt_required()
def get_favorite_products():
    user = get_authenticated_user()
    if not user:
        return {"error": "User not found"}, 404

    records = (
        db.session.query(UserProductPreference)
        .filter_by(user_id=user.id, preference_type="favorite")
        .order_by(UserProductPreference.product_id.asc())
        .all()
    )

    return jsonify([{"product_id": record.product_id} for record in records])


@main.route("/users/me/favorite-products", methods=["POST"])
@jwt_required()
def add_favorite_product():
    user = get_authenticated_user()
    if not user:
        return {"error": "User not found"}, 404

    data = request.get_json() or {}
    product_id = data.get("product_id")

    if not product_id:
        return {"error": "product_id required"}, 400

    product = db.session.get(Product, product_id)
    if not product:
        return {"error": "Product not found"}, 404

    existing = (
        db.session.query(UserProductPreference)
        .filter_by(
            user_id=user.id,
            product_id=product_id,
            preference_type="favorite",
        )
        .first()
    )
    if existing:
        return {"message": "Already added"}, 200

    record = UserProductPreference(
        user_id=user.id,
        product_id=product_id,
        preference_type="favorite",
    )
    db.session.add(record)
    db.session.commit()

    return {"message": "Favorite product added"}, 201


@main.route("/users/me/favorite-products/<int:product_id>", methods=["DELETE"])
@jwt_required()
def remove_favorite_product(product_id):
    user = get_authenticated_user()
    if not user:
        return {"error": "User not found"}, 404

    record = (
        db.session.query(UserProductPreference)
        .filter_by(
            user_id=user.id,
            product_id=product_id,
            preference_type="favorite",
        )
        .first()
    )

    if not record:
        return {"error": "Not found"}, 404

    db.session.delete(record)
    db.session.commit()

    return {"message": "Removed"}