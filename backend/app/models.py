from . import db


class Diet(db.Model):
    __tablename__ = "diets"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)

    max_fat_percent = db.Column(db.Float)
    max_carbs_percent = db.Column(db.Float)
    max_salt_mg = db.Column(db.Float)
    max_calories = db.Column(db.Float)


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


class Recipe(db.Model):
    __tablename__ = "recipes"

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)

    cooking_method = db.Column(db.String(100))
    cooking_time = db.Column(db.Integer)
    servings = db.Column(db.Integer)

    instructions = db.Column(db.Text)


class RecipeIngredient(db.Model):
    __tablename__ = "recipe_ingredients"

    id = db.Column(db.Integer, primary_key=True)

    recipe_id = db.Column(db.Integer, db.ForeignKey("recipes.id"))
    ingredient_id = db.Column(db.Integer, db.ForeignKey("ingredients.id"))

    quantity = db.Column(db.Float)
    unit = db.Column(db.String(50))


class DietIngredientRestriction(db.Model):
    __tablename__ = "diet_ingredient_restrictions"

    id = db.Column(db.Integer, primary_key=True)
    diet_id = db.Column(db.Integer, db.ForeignKey("diets.id"))
    ingredient_id = db.Column(db.Integer, db.ForeignKey("ingredients.id"))

    status = db.Column(db.String(20))  # allowed / limited / forbidden


class DietCookingMethodRestriction(db.Model):
    __tablename__ = "diet_cooking_method_restrictions"

    id = db.Column(db.Integer, primary_key=True)
    diet_id = db.Column(db.Integer, db.ForeignKey("diets.id"))

    cooking_method = db.Column(db.String(50))
    status = db.Column(db.String(20))  # allowed / limited / forbidden


class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(150), nullable=False)
    password_hash = db.Column(db.Text, nullable=False)

    selected_diet_id = db.Column(db.Integer, db.ForeignKey("diets.id"))
    created_at = db.Column(db.DateTime)


class UserExclusion(db.Model):
    __tablename__ = "user_exclusions"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"))
    ingredient_id = db.Column(db.Integer, db.ForeignKey("ingredients.id"))
    
    