from datetime import datetime

from sqlalchemy.dialects.postgresql import ARRAY

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
    reference_mass_g_per_day = db.Column(db.Float, nullable=False, default=2000)


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
    product_preferences = db.relationship(
        "UserProductPreference",
        cascade="all, delete-orphan",
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

    preference_tags = db.Column(
        ARRAY(db.String(50)),
        nullable=False,
        default=list,
        server_default="{}",
    )

    # Deprecated, kept for backward compatibility only. Scoring ignores it.
    reference_mass_g_per_day = db.Column(db.Float, default=2000)

    user = db.relationship("User", back_populates="profile")


class Product(db.Model):
    __tablename__ = "products"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(150), unique=True, nullable=False)
    category = db.Column(db.String(100))
    calories_per_100g = db.Column(db.Float)
    protein_per_100g = db.Column(db.Float)
    fat_per_100g = db.Column(db.Float)
    carbs_per_100g = db.Column(db.Float)
    salt_mg_per_100g = db.Column(db.Float)
    glycemic_index = db.Column(db.Float)
    is_spicy = db.Column(db.Boolean, nullable=False, default=False)
    is_acidic = db.Column(db.Boolean, nullable=False, default=False)
    is_saturated_fat = db.Column(db.Boolean, nullable=False, default=False)


class Recipe(db.Model):
    __tablename__ = "recipes"

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    cooking_method = db.Column(db.String(100), nullable=False)
    cooking_time = db.Column(db.Integer)
    servings = db.Column(db.Integer)
    instructions = db.Column(db.Text)

    # Nutrients are stored directly on recipes to keep schema at 10 tables
    kcal = db.Column(db.Float, nullable=False)
    protein = db.Column(db.Float, nullable=False)
    fat = db.Column(db.Float, nullable=False)
    carbs = db.Column(db.Float, nullable=False)
    sugar = db.Column(db.Float, nullable=False)
    sodium_mg = db.Column(db.Float, nullable=False)


class RecipeIngredient(db.Model):
    __tablename__ = "recipe_ingredients"

    id = db.Column(db.Integer, primary_key=True)
    recipe_id = db.Column(db.Integer, db.ForeignKey("recipes.id"), nullable=False)
    product_id = db.Column(db.Integer, db.ForeignKey("products.id"), nullable=False)
    quantity = db.Column(db.Float, nullable=False)
    unit = db.Column(db.String(50))
    display_name = db.Column(db.String(150))

    recipe = db.relationship("Recipe")
    product = db.relationship("Product")

    __table_args__ = (
        db.UniqueConstraint(
            "recipe_id", "product_id",
            name="recipe_ingredients_recipe_id_product_id_uk",
        ),
        db.CheckConstraint("quantity > 0", name="recipe_ingredients_quantity_positive"),
    )


class RecipeDiet(db.Model):
    __tablename__ = "recipe_diets"

    recipe_id = db.Column(db.Integer, db.ForeignKey("recipes.id"), primary_key=True)
    diet_id = db.Column(db.Integer, db.ForeignKey("diets.id"), primary_key=True)


class UserProductPreference(db.Model):
    __tablename__ = "user_product_preferences"

    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), primary_key=True)
    product_id = db.Column(db.Integer, db.ForeignKey("products.id"), primary_key=True)
    preference_type = db.Column(db.String(20), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    __table_args__ = (
        db.CheckConstraint(
            "preference_type IN ('excluded', 'favorite')",
            name="user_product_preferences_preference_type_check",
        ),
    )


class DietProductRule(db.Model):
    __tablename__ = "diet_product_rules"

    diet_id = db.Column(db.Integer, db.ForeignKey("diets.id"), primary_key=True)
    product_id = db.Column(db.Integer, db.ForeignKey("products.id"), primary_key=True)
    status = db.Column(db.String(20), nullable=False)
    is_hard = db.Column(db.Boolean, nullable=False, default=False)
    reason = db.Column(db.Text)

    __table_args__ = (
        db.CheckConstraint(
            "status IN ('allowed', 'recommended', 'forbidden')",
            name="diet_product_rules_status_check",
        ),
    )


class DietCookingMethodRestriction(db.Model):
    __tablename__ = "diet_cooking_method_restrictions"

    id = db.Column(db.Integer, primary_key=True)
    diet_id = db.Column(db.Integer, db.ForeignKey("diets.id"), nullable=False)
    cooking_method = db.Column(db.String(50), nullable=False)
    status = db.Column(db.String(20), nullable=False)
    is_hard = db.Column(db.Boolean, nullable=False, default=False)
    reason = db.Column(db.Text)

    __table_args__ = (
        db.UniqueConstraint(
            "diet_id", "cooking_method",
            name="diet_cooking_method_uk",
        ),
        db.CheckConstraint(
            "status IN ('allowed', 'recommended', 'forbidden')",
            name="diet_cooking_method_status_check",
        ),
    )