MEDICAL_LIMITS_PER_100G = {
    "low_sodium": {"sodium_mg": 120.0},
    "low_sugar": {"sugar": 5.0},
    "low_fat": {"fat": 10.0},
}

INGREDIENT_RULE_WEIGHTS = {
    "recommended": 1.0,
    "allowed": 0.7,
    "forbidden": 0.3,
}

FINAL_SCORE_WEIGHTS = {
    "ingredient": 0.50,
    "nutrient": 0.35,
    "cooking_method": 0.05,
    "personal": 0.10,
}

SUPPORTED_PREFERENCE_TAGS = {
    "breakfast", "quick", "fish", "poultry", "vegetables",
    "soup", "oven", "grain", "light-dinner",
}

PREFERENCE_REASON_LABELS = {
    "breakfast": "Подходит для лёгкого завтрака.",
    "quick": "Рецепт готовится сравнительно быстро.",
    "fish": "В составе есть рыба или морепродукты.",
    "poultry": "В составе есть птица.",
    "vegetables": "Рецепт опирается на овощную основу.",
    "soup": "Это формат супа или крем-супа.",
    "oven": "Метод приготовления совпадает с предпочтением к запеканию.",
    "grain": "В рецепте есть крупы или гарнирная основа.",
    "light-dinner": "Блюдо подходит для лёгкого ужина.",
}

KCAL_PER_G_FAT = 9.0
KCAL_PER_G_CARBS = 4.0


def clamp01(value):
    return max(0.0, min(1.0, value))


def normalized_upper_bound_score(value, target):
    if value is None or target is None or target <= 0:
        return 1.0
    if value <= target:
        return 1.0
    return clamp01(target / value)


def _protein_score(value, target):
    if value is None or target is None or target <= 0:
        return 1.0
    return clamp01(min(value / target, 1.0))


def _get_reference_mass(user, diet):
    if diet and diet.reference_mass_g_per_day:
        return float(diet.reference_mass_g_per_day)
    return 2000.0


def build_effective_targets(user, diet):
    profile = user.profile if user else None
    ref_mass = _get_reference_mass(user, diet)

    targets = {}

    if diet:
        if diet.max_calories is not None:
            targets["kcal"] = diet.max_calories / (ref_mass / 100.0)
        if diet.max_salt_mg is not None:
            targets["sodium_mg"] = diet.max_salt_mg / (ref_mass / 100.0)

    if profile:
        user_daily = {
            "kcal": profile.target_kcal,
            "protein": profile.target_protein,
            "sugar": profile.target_sugar,
            "sodium_mg": profile.target_sodium_mg,
        }
        for key, daily_value in user_daily.items():
            if daily_value is None:
                continue
            per_100g = daily_value / (ref_mass / 100.0)
            if key in targets:
                targets[key] = min(targets[key], per_100g)
            else:
                targets[key] = per_100g

        for flag_name, limits in MEDICAL_LIMITS_PER_100G.items():
            if getattr(profile, flag_name, False):
                for nutrient_name, hard_limit in limits.items():
                    current = targets.get(nutrient_name)
                    targets[nutrient_name] = hard_limit if current is None else min(current, hard_limit)

    return targets


def _effective_fat_target_g_per_100g(user, diet, recipe):
    candidates = []

    if diet and diet.max_fat_percent is not None and recipe and recipe.kcal:
        candidates.append((diet.max_fat_percent / 100.0 * recipe.kcal) / KCAL_PER_G_FAT)

    profile = user.profile if user else None
    if profile and profile.target_fat is not None:
        ref_mass = _get_reference_mass(user, diet)
        candidates.append(profile.target_fat / (ref_mass / 100.0))

    if profile and profile.low_fat:
        candidates.append(MEDICAL_LIMITS_PER_100G["low_fat"]["fat"])

    return min(candidates) if candidates else None


def _effective_carbs_target_g_per_100g(user, diet, recipe):
    candidates = []

    if diet and diet.max_carbs_percent is not None and recipe and recipe.kcal:
        candidates.append((diet.max_carbs_percent / 100.0 * recipe.kcal) / KCAL_PER_G_CARBS)

    profile = user.profile if user else None
    if profile and profile.target_carbs is not None:
        ref_mass = _get_reference_mass(user, diet)
        candidates.append(profile.target_carbs / (ref_mass / 100.0))

    return min(candidates) if candidates else None


def calculate_ingredient_score_from_rows(ingredients, product_rules):
    if not ingredients:
        return 0.0

    weighted = 0.0
    total_w = 0.0

    for ri, _product in ingredients:
        rule = product_rules.get(ri.product_id)
        coeff = INGREDIENT_RULE_WEIGHTS.get(rule.status, 0.7) if rule else 0.7
        weight = ri.quantity if ri.quantity and ri.quantity > 0 else 1.0
        weighted += coeff * weight
        total_w += weight

    return round(clamp01(weighted / total_w), 4) if total_w > 0 else 0.0


def calculate_nutrient_score_from_recipe(recipe, effective_targets, user=None, diet=None):
    if not recipe:
        return 0.5

    component_scores = []

    if "kcal" in effective_targets:
        component_scores.append(normalized_upper_bound_score(recipe.kcal, effective_targets["kcal"]))
    if "protein" in effective_targets:
        component_scores.append(_protein_score(recipe.protein, effective_targets["protein"]))
    if "sugar" in effective_targets:
        component_scores.append(normalized_upper_bound_score(recipe.sugar, effective_targets["sugar"]))
    if "sodium_mg" in effective_targets:
        component_scores.append(normalized_upper_bound_score(recipe.sodium_mg, effective_targets["sodium_mg"]))

    fat_target = _effective_fat_target_g_per_100g(user, diet, recipe) if user else None
    if fat_target is not None:
        component_scores.append(normalized_upper_bound_score(recipe.fat, fat_target))

    carbs_target = _effective_carbs_target_g_per_100g(user, diet, recipe) if user else None
    if carbs_target is not None:
        component_scores.append(normalized_upper_bound_score(recipe.carbs, carbs_target))

    if not component_scores:
        return 0.5

    return round(sum(component_scores) / len(component_scores), 4)


def calculate_cooking_method_score_from_rules(cooking_method, cooking_rules):
    rule = cooking_rules.get(cooking_method)

    if not rule or rule.is_hard:
        return 0.7
    if rule.status == "recommended":
        return 1.0
    if rule.status == "allowed":
        return 0.7
    if rule.status == "forbidden":
        return 0.3
    return 0.7


def _build_recipe_context(ingredients):
    product_names = set()
    product_categories = set()
    for _ri, product in ingredients:
        if product:
            if product.name:
                product_names.add(product.name.lower())
            if product.category:
                product_categories.add(product.category.lower())
    return {"product_names": product_names, "product_categories": product_categories}


def match_preference_tags(recipe, ingredients):
    ctx = _build_recipe_context(ingredients)
    title = (recipe.title or "").lower()
    description = (recipe.description or "").lower()
    method = (recipe.cooking_method or "").lower()
    product_names = ctx["product_names"]
    product_categories = ctx["product_categories"]

    matched = []

    def add(tag):
        if tag not in matched:
            matched.append(tag)

    if (recipe.cooking_time is not None and recipe.cooking_time <= 20) or any(kw in title for kw in ["омлет", "каша", "сырники", "завтрак"]):
        add("breakfast")
    if recipe.cooking_time is not None and recipe.cooking_time <= 25:
        add("quick")
    if "рыба" in product_categories or "морепродукты" in product_categories:
        add("fish")
    if any(marker in name for marker in ["кур", "индей"] for name in product_names):
        add("poultry")
    veg_count = sum(1 for c in product_categories if c == "овощи")
    if veg_count >= 2 or "салат" in title or "овощ" in description:
        add("vegetables")
    if "суп" in title or "суп" in description:
        add("soup")
    if "запек" in method:
        add("oven")
    if "крупы" in product_categories or any(kw in title for kw in ["каша", "булгур", "греч", "рис"]):
        add("grain")
    if recipe.kcal is not None:
        if recipe.kcal <= 180 and (recipe.cooking_time is None or recipe.cooking_time <= 35):
            add("light-dinner")
    elif method == "без обработки":
        add("light-dinner")

    return matched


def calculate_personal_score_details(recipe, ingredients, favorite_product_ids, user_preference_tags):
    recipe_product_ids = {ri.product_id for ri, _ in ingredients}

    favorite_overlap = 0
    favorite_score = 0.5
    if favorite_product_ids and recipe_product_ids:
        favorite_overlap = len(recipe_product_ids & favorite_product_ids)
        favorite_score = clamp01(0.5 + 0.5 * (favorite_overlap / len(recipe_product_ids)))

    matched_tags = []
    tag_score = 0.5
    supported_user_tags = [t for t in (user_preference_tags or []) if t in SUPPORTED_PREFERENCE_TAGS]
    if supported_user_tags:
        available = match_preference_tags(recipe, ingredients)
        matched_tags = [t for t in supported_user_tags if t in available]
        tag_score = clamp01(0.45 + 0.17 * len(matched_tags))

    return {
        "score": round(max(favorite_score, tag_score), 4),
        "matched_tags": matched_tags,
        "favorite_overlap": favorite_overlap,
    }


def build_fit_reasons(recipe, breakdown, matched_tags, user):
    reasons = []

    if breakdown.get("nutrient_score", 0) >= 0.8:
        reasons.append("Нутриенты держатся в рабочем диапазоне для вашего профиля.")
    if breakdown.get("cooking_method_score", 0) >= 0.9:
        reasons.append("Способ приготовления хорошо согласован с диетой.")

    for tag in matched_tags:
        label = PREFERENCE_REASON_LABELS.get(tag)
        if label and label not in reasons:
            reasons.append(label)

    profile = user.profile if user else None
    if profile and recipe:
        limit = MEDICAL_LIMITS_PER_100G
        if profile.low_sugar and recipe.sugar is not None and recipe.sugar <= limit["low_sugar"]["sugar"]:
            reasons.append("Сахар укладывается в строгий персональный лимит.")
        if profile.low_sodium and recipe.sodium_mg is not None and recipe.sodium_mg <= limit["low_sodium"]["sodium_mg"]:
            reasons.append("Натрий остаётся в безопасном диапазоне.")
        if profile.low_fat and recipe.fat is not None and recipe.fat <= limit["low_fat"]["fat"]:
            reasons.append("Жирность соответствует усиленному ограничению.")

    if not reasons:
        reasons.append("Рецепт прошёл фильтрацию и не нарушает выбранные ограничения.")

    return reasons


def build_penalties(recipe, effective_targets, breakdown, user, diet):
    penalties = []

    labels = {
        "kcal": "Калорийность выше рекомендуемой нормы.",
        "protein": "Белок выходит за рамки целевого диапазона.",
        "fat": "Жиры превышают рекомендуемый уровень.",
        "carbs": "Углеводы выше целевого значения.",
        "sugar": "Сахар выше допустимого лимита.",
        "sodium_mg": "Натрий превышает безопасный порог.",
    }

    simple_pairs = [
        ("kcal", recipe.kcal if recipe else None),
        ("sugar", recipe.sugar if recipe else None),
        ("sodium_mg", recipe.sodium_mg if recipe else None),
    ]
    for name, value in simple_pairs:
        target = effective_targets.get(name)
        if value is None or target is None or target <= 0:
            continue
        if value > target * 1.15:
            penalties.append(labels[name])

    protein_target = effective_targets.get("protein")
    if recipe and recipe.protein is not None and protein_target and protein_target > 0:
        if recipe.protein < protein_target * 0.7 or recipe.protein > protein_target * 1.3:
            penalties.append(labels["protein"])

    if recipe and user:
        fat_target = _effective_fat_target_g_per_100g(user, diet, recipe)
        if fat_target is not None and recipe.fat is not None and recipe.fat > fat_target * 1.15:
            penalties.append(labels["fat"])

        carbs_target = _effective_carbs_target_g_per_100g(user, diet, recipe)
        if carbs_target is not None and recipe.carbs is not None and recipe.carbs > carbs_target * 1.15:
            penalties.append(labels["carbs"])

    if breakdown.get("ingredient_score", 1) < 0.78:
        penalties.append("Состав рецепта допустим, но не самый подходящий для этой диеты.")
    if breakdown.get("cooking_method_score", 1) < 0.8:
        penalties.append("Способ приготовления допустим, но не самый предпочтительный.")

    seen = set()
    out = []
    for p in penalties:
        if p not in seen:
            seen.add(p)
            out.append(p)
    return out


def build_explain_summary(breakdown, matched_tags):
    chunks = []
    if breakdown.get("ingredient_score", 0) >= 0.86:
        chunks.append("сильное соответствие составу диеты")
    if breakdown.get("nutrient_score", 0) >= 0.8:
        chunks.append("ровные нутриенты на 100 г")
    if breakdown.get("cooking_method_score", 0) >= 0.95:
        chunks.append("подходящий метод приготовления")
    if matched_tags:
        chunks.append("совпадение с персональными предпочтениями")

    if not chunks:
        return "Рецепт прошёл фильтрацию, но без выраженного персонального преимущества."
    return "Высокая позиция за " + ", ".join(chunks) + "."


def calculate_final_score(ingredient_score, nutrient_score, cooking_method_score, personal_score):
    w = FINAL_SCORE_WEIGHTS
    return 100 * (
        w["ingredient"] * ingredient_score
        + w["nutrient"] * nutrient_score
        + w["cooking_method"] * cooking_method_score
        + w["personal"] * personal_score
    )