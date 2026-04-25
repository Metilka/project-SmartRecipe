from sqlalchemy import func, or_
from flask import Blueprint, jsonify, request
from flask_jwt_extended import get_jwt_identity, jwt_required
from sqlalchemy.exc import IntegrityError
from app.services.basket import add_to_basket, get_basket, get_totals, clear_basket

from app.extensions import db
from app.models import (
    Diet,
    Product,
    Recipe,
    RecipeDiet,
    RecipeIngredient,
    User,
    UserProductPreference,
    UserProfile,
)
from app.services.recommendations import (
    get_allowed_product_ids_for_diet,
    get_personalized_recipe_for_user,
    get_recommendations_for_user,
)
from app.services.scoring import SUPPORTED_PREFERENCE_TAGS

main = Blueprint("main", __name__)


def get_authenticated_user():
    user_id = int(get_jwt_identity())
    return db.session.get(User, user_id)


def get_user_preference_ids(user, preference_type: str):
    if not user:
        return []

    rows = (
        db.session.query(UserProductPreference.product_id)
        .filter(
            UserProductPreference.user_id == user.id,
            UserProductPreference.preference_type == preference_type,
        )
        .order_by(UserProductPreference.product_id.asc())
        .all()
    )
    return [row[0] for row in rows]


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
            "preference_tags": [],
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
        "preference_tags": list(profile.preference_tags or []),
    }


def _serialize_nutrients(recipe):
    return {
        "kcal": recipe.kcal,
        "protein": recipe.protein,
        "fat": recipe.fat,
        "carbs": recipe.carbs,
        "sugar": recipe.sugar,
        "sodium_mg": recipe.sodium_mg,
    }


@main.route("/")
def home():
    return jsonify({"message": "Flask works!"})


@main.route("/health")
def health():
    try:
        db.session.execute(db.text("SELECT 1"))
        return jsonify({"status": "ok", "database": "up"})
    except Exception as exc:
        return jsonify({"status": "error", "database": "down", "error": str(exc)}), 503


@main.route("/recommendations")
@jwt_required()
def recommendations():
    user_id = int(get_jwt_identity())
    limit = request.args.get("limit", default=20, type=int)
    payload, status = get_recommendations_for_user(user_id=user_id, limit=limit)
    return jsonify(payload), status


@main.route("/feed")
def guest_feed():
    diet_id = request.args.get("diet_id", type=int)
    if not diet_id:
        return jsonify({"error": "diet_id query param is required"}), 400

    recipes = (
        db.session.query(Recipe)
        .join(RecipeDiet, RecipeDiet.recipe_id == Recipe.id)
        .filter(RecipeDiet.diet_id == diet_id)
        .order_by(Recipe.id.asc())
        .all()
    )

    return jsonify([
        {
            "id": recipe.id,
            "title": recipe.title,
            "cooking_method": recipe.cooking_method,
            "description": recipe.description,
            "nutrients_per_100g": _serialize_nutrients(recipe),
        }
        for recipe in recipes
    ])


@main.route("/recipes")
def get_recipes():
    diet_id = request.args.get("diet_id", type=int)
    search = request.args.get("search", type=str)
    cooking_method = request.args.get("cooking_method", type=str)
    max_cooking_time = request.args.get("max_cooking_time", type=int)
    page = max(1, request.args.get("page", default=1, type=int))
    per_page = request.args.get("per_page", default=20, type=int)
    per_page = max(1, min(per_page, 100))

    query = db.session.query(Recipe)

    if diet_id:
        query = (
            query.join(RecipeDiet, RecipeDiet.recipe_id == Recipe.id)
            .filter(RecipeDiet.diet_id == diet_id)
        )
    if search:
        pattern = f"%{search}%"
        query = query.filter(or_(Recipe.title.ilike(pattern), Recipe.description.ilike(pattern)))
    if cooking_method:
        query = query.filter(Recipe.cooking_method == cooking_method)
    if max_cooking_time:
        query = query.filter(Recipe.cooking_time <= max_cooking_time)

    total = query.with_entities(func.count(Recipe.id)).scalar() or 0
    items = (
        query.order_by(Recipe.id.asc())
        .offset((page - 1) * per_page)
        .limit(per_page)
        .all()
    )

    return jsonify({
        "page": page,
        "per_page": per_page,
        "total": total,
        "total_pages": (total + per_page - 1) // per_page if per_page else 1,
        "recipes": [
            {
                "id": recipe.id,
                "title": recipe.title,
                "cooking_method": recipe.cooking_method,
                "cooking_time": recipe.cooking_time,
                "description": recipe.description,
                "nutrients_per_100g": _serialize_nutrients(recipe),
            }
            for recipe in items
        ],
    })


@main.route("/recipes/<int:recipe_id>")
def get_recipe_by_id(recipe_id: int):
    recipe = db.session.get(Recipe, recipe_id)
    if not recipe:
        return jsonify({"error": "Recipe not found"}), 404

    ingredients = (
        db.session.query(RecipeIngredient, Product)
        .join(Product, Product.id == RecipeIngredient.product_id, isouter=True)
        .filter(RecipeIngredient.recipe_id == recipe_id)
        .order_by(RecipeIngredient.id.asc())
        .all()
    )

    return jsonify({
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
    })


@main.route("/recipes/<int:recipe_id>/personal")
@jwt_required()
def get_personal_recipe(recipe_id: int):
    user_id = int(get_jwt_identity())
    payload, status = get_personalized_recipe_for_user(user_id, recipe_id)
    return jsonify(payload), status


@main.route("/users/me")
@jwt_required()
def get_current_user():
    user = get_authenticated_user()
    if not user:
        return jsonify({"error": "User not found"}), 404

    return jsonify({
        "id": user.id,
        "email": user.email,
        "selected_diet_id": user.selected_diet_id,
        "profile": serialize_profile(user.profile),
        "excluded_product_ids": get_user_preference_ids(user, "excluded"),
        "favorite_product_ids": get_user_preference_ids(user, "favorite"),
    })


@main.route("/users/me/diet", methods=["POST"])
@jwt_required()
def select_diet():
    user = get_authenticated_user()
    if not user:
        return jsonify({"error": "User not found"}), 404

    data = request.get_json() or {}
    diet_id = data.get("diet_id")
    if not diet_id:
        return jsonify({"error": "diet_id required"}), 400

    diet = db.session.get(Diet, diet_id)
    if not diet:
        return jsonify({"error": "Diet not found"}), 404

    old_diet_id = user.selected_diet_id
    user.selected_diet_id = diet_id

    if old_diet_id != diet_id:
        new_allowed = get_allowed_product_ids_for_diet(diet_id)
        pruned = 0
        for pref in list(user.product_preferences):
            if pref.preference_type == "excluded" and pref.product_id not in new_allowed:
                db.session.delete(pref)
                pruned += 1
    else:
        pruned = 0

    try:
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        return jsonify({"error": "Could not switch diet"}), 400

    return jsonify({
        "message": "Diet selected",
        "diet_id": diet_id,
        "pruned_excluded_count": pruned,
    })


@main.route("/profile", methods=["GET"])
@jwt_required()
def get_profile():
    user = get_authenticated_user()
    if not user:
        return jsonify({"error": "User not found"}), 404

    allowed_ids = sorted(get_allowed_product_ids_for_diet(user.selected_diet_id))
    allowed_products = (
        db.session.query(Product)
        .filter(Product.id.in_(allowed_ids))
        .order_by(Product.name.asc())
        .all()
        if allowed_ids else []
    )

    return jsonify({
        "selected_diet_id": user.selected_diet_id,
        "allowed_product_ids": allowed_ids,
        "allowed_products": [
            {"id": p.id, "name": p.name, "category": p.category}
            for p in allowed_products
        ],
        "excluded_product_ids": get_user_preference_ids(user, "excluded"),
        "favorite_product_ids": get_user_preference_ids(user, "favorite"),
        "profile": serialize_profile(user.profile),
    })


@main.route("/profile", methods=["PUT"])
@jwt_required()
def update_profile():
    user = get_authenticated_user()
    if not user:
        return jsonify({"error": "User not found"}), 404

    data = request.get_json() or {}

    if not user.profile:
        user.profile = UserProfile(user_id=user.id)
    profile = user.profile

    old_diet_id = user.selected_diet_id
    diet_changed = False

    if "selected_diet_id" in data:
        new_diet_id = data["selected_diet_id"]
        diet = db.session.get(Diet, new_diet_id)
        if not diet:
            return jsonify({"error": "Diet not found"}), 404

        if new_diet_id != old_diet_id:
            user.selected_diet_id = new_diet_id
            diet_changed = True

    db.session.flush()
    allowed_ids = get_allowed_product_ids_for_diet(user.selected_diet_id)

    explicitly_sent_excluded = "excluded_product_ids" in data
    if diet_changed and not explicitly_sent_excluded:
        q = db.session.query(UserProductPreference).filter(
            UserProductPreference.user_id == user.id,
            UserProductPreference.preference_type == "excluded",
        )
        if allowed_ids:
            q = q.filter(~UserProductPreference.product_id.in_(allowed_ids))
        q.delete(synchronize_session=False)
        db.session.flush()

    current_excluded = {
        row[0]
        for row in db.session.query(UserProductPreference.product_id)
        .filter(
            UserProductPreference.user_id == user.id,
            UserProductPreference.preference_type == "excluded",
        )
        .all()
    }
    current_favorite = {
        row[0]
        for row in db.session.query(UserProductPreference.product_id)
        .filter(
            UserProductPreference.user_id == user.id,
            UserProductPreference.preference_type == "favorite",
        )
        .all()
    }

    new_excluded = set(data.get("excluded_product_ids", current_excluded))
    new_favorite = set(data.get("favorite_product_ids", current_favorite))

    invalid_excluded = new_excluded - allowed_ids if allowed_ids else set()
    if invalid_excluded:
        db.session.rollback()
        return jsonify({
            "error": "Excluded products must belong to allowed products of selected diet",
            "invalid_product_ids": sorted(invalid_excluded),
        }), 400

    if new_favorite:
        existing_favs = {
            row[0]
            for row in db.session.query(Product.id)
            .filter(Product.id.in_(new_favorite))
            .all()
        }
        invalid_favorites = new_favorite - existing_favs
        if invalid_favorites:
            db.session.rollback()
            return jsonify({
                "error": "Favorite products must exist",
                "invalid_product_ids": sorted(invalid_favorites),
            }), 400

    new_favorite = new_favorite - new_excluded

    scalar_fields = [
        "low_sodium", "low_sugar", "low_fat",
        "no_spicy", "no_acidic", "no_saturated_fat",
        "target_kcal", "target_protein", "target_fat",
        "target_carbs", "target_sugar", "target_sodium_mg",
    ]
    for field in scalar_fields:
        if field in data:
            setattr(profile, field, data[field])

    if "preference_tags" in data:
        raw_tags = data.get("preference_tags") or []
        cleaned = sorted({
            str(t).strip()
            for t in raw_tags
            if str(t).strip() in SUPPORTED_PREFERENCE_TAGS
        })
        profile.preference_tags = cleaned

    to_add_excluded = new_excluded - current_excluded
    to_remove_excluded = current_excluded - new_excluded
    to_add_favorite = new_favorite - current_favorite
    to_remove_favorite = current_favorite - new_favorite

    if to_remove_excluded:
        db.session.query(UserProductPreference).filter(
            UserProductPreference.user_id == user.id,
            UserProductPreference.preference_type == "excluded",
            UserProductPreference.product_id.in_(to_remove_excluded),
        ).delete(synchronize_session=False)

    if to_remove_favorite:
        db.session.query(UserProductPreference).filter(
            UserProductPreference.user_id == user.id,
            UserProductPreference.preference_type == "favorite",
            UserProductPreference.product_id.in_(to_remove_favorite),
        ).delete(synchronize_session=False)

    existing_rows = {
        row.product_id: row
        for row in db.session.query(UserProductPreference)
        .filter(UserProductPreference.user_id == user.id)
        .all()
    }

    for pid in sorted(to_add_excluded):
        if pid in existing_rows:
            existing_rows[pid].preference_type = "excluded"
        else:
            db.session.add(UserProductPreference(
                user_id=user.id,
                product_id=pid,
                preference_type="excluded",
            ))

    for pid in sorted(to_add_favorite):
        if pid in existing_rows:
            existing_rows[pid].preference_type = "favorite"
        else:
            db.session.add(UserProductPreference(
                user_id=user.id,
                product_id=pid,
                preference_type="favorite",
            ))

    try:
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        return jsonify({"error": "Invalid excluded products for selected diet"}), 400

    return jsonify({
        "message": "Profile updated",
        "selected_diet_id": user.selected_diet_id,
        "allowed_product_ids": sorted(allowed_ids),
        "excluded_product_ids": sorted(new_excluded),
        "favorite_product_ids": sorted(new_favorite),
        "profile": serialize_profile(profile),
    })


@main.route("/diets")
def get_diets():
    diets = db.session.query(Diet).order_by(Diet.id.asc()).all()
    return jsonify([{"id": d.id, "name": d.name, "description": d.description} for d in diets])


@main.route("/diets/<int:diet_id>/allowed-products")
def get_allowed_products(diet_id: int):
    ids = get_allowed_product_ids_for_diet(diet_id)
    products = (
        db.session.query(Product)
        .filter(Product.id.in_(ids))
        .order_by(Product.name.asc())
        .all()
        if ids else []
    )
    return jsonify([{"id": p.id, "name": p.name, "category": p.category} for p in products])


@main.route("/products")
def get_products():
    products = db.session.query(Product).order_by(Product.name.asc()).all()
    return jsonify([{"id": p.id, "name": p.name, "category": p.category} for p in products])


@main.route("/users/me/excluded-products", methods=["GET"])
@jwt_required()
def get_excluded_products():
    user = get_authenticated_user()
    if not user:
        return jsonify({"error": "User not found"}), 404
    return jsonify([{"product_id": pid} for pid in get_user_preference_ids(user, "excluded")])


@main.route("/users/me/excluded-products", methods=["POST"])
@jwt_required()
def add_excluded_product():
    user = get_authenticated_user()
    if not user:
        return jsonify({"error": "User not found"}), 404

    data = request.get_json() or {}
    product_id = data.get("product_id")
    if not product_id:
        return jsonify({"error": "product_id required"}), 400

    product = db.session.get(Product, product_id)
    if not product:
        return jsonify({"error": "Product not found"}), 404

    allowed_ids = get_allowed_product_ids_for_diet(user.selected_diet_id)
    if allowed_ids and product_id not in allowed_ids:
        return jsonify({
            "error": "Product must belong to allowed products of selected diet",
            "product_id": product_id,
        }), 400

    existing = (
        db.session.query(UserProductPreference)
        .filter_by(user_id=user.id, product_id=product_id)
        .first()
    )
    if existing:
        if existing.preference_type == "excluded":
            return jsonify({"message": "Already excluded"}), 200
        existing.preference_type = "excluded"
    else:
        db.session.add(UserProductPreference(user_id=user.id, product_id=product_id, preference_type="excluded"))

    try:
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        return jsonify({"error": "Invalid excluded product for selected diet"}), 400

    return jsonify({"message": "Product excluded"}), 201


@main.route("/users/me/excluded-products/<int:product_id>", methods=["DELETE"])
@jwt_required()
def remove_excluded_product(product_id):
    user = get_authenticated_user()
    if not user:
        return jsonify({"error": "User not found"}), 404

    record = (
        db.session.query(UserProductPreference)
        .filter_by(user_id=user.id, product_id=product_id, preference_type="excluded")
        .first()
    )
    if not record:
        return jsonify({"error": "Not found"}), 404

    db.session.delete(record)
    db.session.commit()
    return jsonify({"message": "Removed"})


@main.route("/users/me/favorite-products", methods=["GET"])
@jwt_required()
def get_favorite_products():
    user = get_authenticated_user()
    if not user:
        return jsonify({"error": "User not found"}), 404
    return jsonify([{"product_id": pid} for pid in get_user_preference_ids(user, "favorite")])


@main.route("/users/me/favorite-products", methods=["POST"])
@jwt_required()
def add_favorite_product():
    user = get_authenticated_user()
    if not user:
        return jsonify({"error": "User not found"}), 404

    data = request.get_json() or {}
    product_id = data.get("product_id")
    if not product_id:
        return jsonify({"error": "product_id required"}), 400

    product = db.session.get(Product, product_id)
    if not product:
        return jsonify({"error": "Product not found"}), 404

    existing = (
        db.session.query(UserProductPreference)
        .filter_by(user_id=user.id, product_id=product_id)
        .first()
    )
    if existing:
        if existing.preference_type == "favorite":
            return jsonify({"message": "Already added"}), 200
        existing.preference_type = "favorite"
    else:
        db.session.add(UserProductPreference(user_id=user.id, product_id=product_id, preference_type="favorite"))

    db.session.commit()
    return jsonify({"message": "Favorite product added"}), 201


@main.route("/users/me/favorite-products/<int:product_id>", methods=["DELETE"])
@jwt_required()
def remove_favorite_product(product_id):
    user = get_authenticated_user()
    if not user:
        return jsonify({"error": "User not found"}), 404

    record = (
        db.session.query(UserProductPreference)
        .filter_by(user_id=user.id, product_id=product_id, preference_type="favorite")
        .first()
    )
    if not record:
        return jsonify({"error": "Not found"}), 404

    db.session.delete(record)
    db.session.commit()
    return jsonify({"message": "Removed"})


@main.route("/basket", methods=["GET"])
@jwt_required()
def get_user_basket():
    user_id = int(get_jwt_identity())
    user = get_authenticated_user()
    if not user:
        return jsonify({"error": "User not found"}), 404

    entries = get_basket(user_id)
    totals = get_totals(user_id)

    warnings = []
    profile = user.profile
    diet = user.selected_diet

    if profile:
        if profile.target_kcal and totals["kcal"] > profile.target_kcal:
            warnings.append(f"Превышен лимит калорий: {totals['kcal']} из {profile.target_kcal} ккал")
        if profile.target_protein and totals["protein"] > profile.target_protein:
            warnings.append(f"Превышен лимит белка: {totals['protein']} из {profile.target_protein} г")
        if profile.target_fat and totals["fat"] > profile.target_fat:
            warnings.append(f"Превышен лимит жиров: {totals['fat']} из {profile.target_fat} г")
        if profile.target_carbs and totals["carbs"] > profile.target_carbs:
            warnings.append(f"Превышен лимит углеводов: {totals['carbs']} из {profile.target_carbs} г")
        if profile.target_sugar and totals["sugar"] > profile.target_sugar:
            warnings.append(f"Превышен лимит сахара: {totals['sugar']} из {profile.target_sugar} г")
        if profile.target_sodium_mg and totals["sodium_mg"] > profile.target_sodium_mg:
            warnings.append(f"Превышен лимит натрия: {totals['sodium_mg']} из {profile.target_sodium_mg} мг")

    if diet:
        if diet.max_calories and totals["kcal"] > diet.max_calories:
            warnings.append(f"Превышена норма калорий по диете: {totals['kcal']} из {diet.max_calories} ккал")
        if diet.max_salt_mg and totals["sodium_mg"] > diet.max_salt_mg:
            warnings.append(f"Превышена норма соли по диете: {totals['sodium_mg']} из {diet.max_salt_mg} мг")

    return jsonify({
        "entries": entries,
        "totals": totals,
        "warnings": warnings,
    })


@main.route("/basket", methods=["POST"])
@jwt_required()
def add_recipe_to_basket():
    user_id = int(get_jwt_identity())
    user = get_authenticated_user()
    if not user:
        return jsonify({"error": "User not found"}), 404

    data = request.get_json() or {}
    recipe_id = data.get("recipe_id")
    servings = data.get("servings", 1)

    if not recipe_id:
        return jsonify({"error": "recipe_id required"}), 400
    if not isinstance(servings, (int, float)) or servings <= 0:
        return jsonify({"error": "servings must be a positive number"}), 400

    recipe = db.session.get(Recipe, recipe_id)
    if not recipe:
        return jsonify({"error": "Recipe not found"}), 404

    add_to_basket(user_id, recipe, servings)

    return jsonify({"message": "Recipe added to basket"}), 201


@main.route("/basket", methods=["DELETE"])
@jwt_required()
def clear_user_basket():
    user_id = int(get_jwt_identity())
    clear_basket(user_id)
    return jsonify({"message": "Basket cleared"})


@main.route("/products/<int:product_id>")
def get_product_by_id(product_id: int):
    product = db.session.get(Product, product_id)
    if not product:
        return jsonify({"error": "Product not found"}), 404

    return jsonify({
        "id": product.id,
        "name": product.name,
        "category": product.category,
        "calories_per_100g": product.calories_per_100g,
        "protein_per_100g": product.protein_per_100g,
        "fat_per_100g": product.fat_per_100g,
        "carbs_per_100g": product.carbs_per_100g,
        "salt_mg_per_100g": product.salt_mg_per_100g,
        "is_spicy": product.is_spicy,
        "is_acidic": product.is_acidic,
        "is_saturated_fat": product.is_saturated_fat,
    })