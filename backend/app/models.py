from datetime import datetime

from app.extensions import db


class Diet(db.Model):
    __tablename__ = "diets"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    max_fat_percent = db.Column(db.Float)
    max_carbs_percent = db.Column(db.Float)
    max_salt_mg = db.Column(db.Float)
    max_calories = db.Column(db.Float)


class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(150), unique=True, nullable=False)
    password_hash = db.Column(db.Text, nullable=False)
    selected_diet_id = db.Column(db.Integer, db.ForeignKey("diets.id"), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    selected_diet = db.relationship("Diet")
    profile = db.relationship(
        "UserProfile",
        back_populates="user",
        uselist=False,
        cascade="all, delete-orphan",
    )
    excluded_products = db.relationship(
        "UserExcludedProduct",
        cascade="all, delete-orphan",
        lazy="selectin",
    )
    favorite_products = db.relationship(
        "UserFavoriteProduct",
        cascade="all, delete-orphan",
        lazy="selectin",
    )


class UserProfile(db.Model):
    __tablename__ = "user_profiles"

    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), primary_key=True)
    low_sodium = db.Column(db.Boolean, nullable=False, default=False)
    low_sugar = db.Column(db.Boolean, nullable=False, default=False)
    low_fat = db.Column(db.Boolean, nullable=False, default=False)
    no_spicy = db.Column(db.Boolean, nullable=False, default=False)
    no_acidic = db.Column(db.Boolean, nullable=False, default=False)
    no_saturated_fat = db.Column(db.Boolean, nullable=False, default=False)
    target_kcal = db.Column(db.Float)
    target_protein = db.Column(db.Float)
    target_fat = db.Column(db.Float)
    target_carbs = db.Column(db.Float)
    target_sugar = db.Column(db.Float)
    target_sodium_mg = db.Column(db.Float)
    reference_mass_g_per_day = db.Column(db.Float, default=2000)

    user = db.relationship("User", back_populates="profile")


class Product(db.Model):
    __tablename__ = "products"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(150), unique=True, nullable=False)
    category = db.Column(db.String(100))


class Ingredient(db.Model):
    __tablename__ = "ingredients"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(150), nullable=False)
    category = db.Column(db.String(100))
    calories_per_100g = db.Column(db.Float)
    protein_per_100g = db.Column(db.Float)
    fat_per_100g = db.Column(db.Float)
    carbs_per_100g = db.Column(db.Float)
    salt_mg_per_100g = db.Column(db.Float)
    glycemic_index = db.Column(db.Float)
    is_spicy = db.Column(db.Boolean, default=False)
    is_acidic = db.Column(db.Boolean, default=False)
    is_saturated_fat = db.Column(db.Boolean, default=False)
    product_id = db.Column(db.Integer, db.ForeignKey("products.id"), nullable=False)

    product = db.relationship("Product")


class Recipe(db.Model):
    __tablename__ = "recipes"

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    cooking_method = db.Column(db.String(100))
    cooking_time = db.Column(db.Integer)
    servings = db.Column(db.Integer)
    instructions = db.Column(db.Text)

    nutrients = db.relationship(
        "RecipeNutrientsPer100g",
        uselist=False,
        back_populates="recipe",
    )


class RecipeIngredient(db.Model):
    __tablename__ = "recipe_ingredients"

    id = db.Column(db.Integer, primary_key=True)
    recipe_id = db.Column(db.Integer, db.ForeignKey("recipes.id"), nullable=False)
    ingredient_id = db.Column(db.Integer, db.ForeignKey("ingredients.id"), nullable=False)
    quantity = db.Column(db.Float, nullable=False)
    unit = db.Column(db.String(50))

    recipe = db.relationship("Recipe")
    ingredient = db.relationship("Ingredient")

    __table_args__ = (
        db.UniqueConstraint(
            "recipe_id",
            "ingredient_id",
            name="recipe_ingredients_recipe_id_ingredient_id_uk",
        ),
    )


class RecipeDiet(db.Model):
    __tablename__ = "recipe_diets"

    recipe_id = db.Column(db.Integer, db.ForeignKey("recipes.id"), primary_key=True)
    diet_id = db.Column(db.Integer, db.ForeignKey("diets.id"), primary_key=True)


class RecipeNutrientsPer100g(db.Model):
    __tablename__ = "recipe_nutrients_per_100g"

    recipe_id = db.Column(db.Integer, db.ForeignKey("recipes.id"), primary_key=True)
    kcal = db.Column(db.Float)
    protein = db.Column(db.Float)
    fat = db.Column(db.Float)
    carbs = db.Column(db.Float)
    sugar = db.Column(db.Float)
    sodium_mg = db.Column(db.Float)

    recipe = db.relationship("Recipe", back_populates="nutrients")


class UserExcludedProduct(db.Model):
    __tablename__ = "user_excluded_products"

    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), primary_key=True)
    product_id = db.Column(db.Integer, db.ForeignKey("products.id"), primary_key=True)


class UserFavoriteProduct(db.Model):
    __tablename__ = "user_favorite_products"

    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), primary_key=True)
    product_id = db.Column(db.Integer, db.ForeignKey("products.id"), primary_key=True)


class DietProductRule(db.Model):
    __tablename__ = "diet_product_rules"

    diet_id = db.Column(db.Integer, db.ForeignKey("diets.id"), primary_key=True)
    product_id = db.Column(db.Integer, db.ForeignKey("products.id"), primary_key=True)
    status = db.Column(db.String(20), nullable=False)


class DietCookingMethodRestriction(db.Model):
    __tablename__ = "diet_cooking_method_restrictions"

    id = db.Column(db.Integer, primary_key=True)
    diet_id = db.Column(db.Integer, db.ForeignKey("diets.id"))
    cooking_method = db.Column(db.String(50))
    status = db.Column(db.String(20), nullable=False)