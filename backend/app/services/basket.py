from datetime import date

# Хранилище в памяти: {user_id: {"date": "2026-04-25", "entries": [...]}}
_basket = {}


def get_basket(user_id: int):
    today = str(date.today())
    entry = _basket.get(user_id)
    if not entry or entry["date"] != today:
        _basket[user_id] = {"date": today, "entries": []}
    return _basket[user_id]["entries"]


def add_to_basket(user_id: int, recipe, servings: float):
    entries = get_basket(user_id)
    entries.append({
        "recipe_id": recipe.id,
        "title": recipe.title,
        "servings": servings,
        "kcal": round(recipe.kcal * servings, 1) if recipe.kcal else None,
        "protein": round(recipe.protein * servings, 1) if recipe.protein else None,
        "fat": round(recipe.fat * servings, 1) if recipe.fat else None,
        "carbs": round(recipe.carbs * servings, 1) if recipe.carbs else None,
        "sugar": round(recipe.sugar * servings, 1) if recipe.sugar else None,
        "sodium_mg": round(recipe.sodium_mg * servings, 1) if recipe.sodium_mg else None,
    })


def clear_basket(user_id: int):
    _basket[user_id] = {"date": str(date.today()), "entries": []}


def get_totals(user_id: int):
    entries = get_basket(user_id)
    totals = {"kcal": 0, "protein": 0, "fat": 0, "carbs": 0, "sugar": 0, "sodium_mg": 0}
    for e in entries:
        for key in totals:
            if e.get(key) is not None:
                totals[key] += e[key]
    return {k: round(v, 1) for k, v in totals.items()}