import unittest
from types import SimpleNamespace

from app.services.scoring import (
    build_effective_targets,
    build_explain_summary,
    build_fit_reasons,
    build_penalties,
    calculate_final_score,
    calculate_ingredient_score_from_rows,
    calculate_nutrient_score_from_recipe,
    normalized_upper_bound_score,
)


def obj(**kwargs):
    return SimpleNamespace(**kwargs)


def recipe(**overrides):
    data = {
        "title": "Овощной суп",
        "description": "Лёгкий суп",
        "cooking_method": "варка",
        "cooking_time": 20,
        "kcal": 100,
        "protein": 6,
        "fat": 3,
        "carbs": 14,
        "sugar": 4,
        "sodium_mg": 80,
    }
    data.update(overrides)
    return obj(**data)


class ScoringTests(unittest.TestCase):
    def test_normalized_upper_bound_score(self):
        self.assertEqual(normalized_upper_bound_score(50, 100), 1.0)
        self.assertEqual(normalized_upper_bound_score(200, 100), 0.5)
        self.assertEqual(normalized_upper_bound_score(None, 100), 1.0)
        self.assertEqual(normalized_upper_bound_score(100, 0), 1.0)

    def test_ingredient_score_uses_quantity_weights(self):
        ingredients = [
            (obj(product_id=1, quantity=100), None),
            (obj(product_id=2, quantity=100), None),
        ]
        rules = {
            1: obj(status="recommended"),
            2: obj(status="forbidden"),
        }

        score = calculate_ingredient_score_from_rows(ingredients, rules)

        self.assertAlmostEqual(score, 0.65)

    def test_nutrient_score_penalizes_values_above_targets(self):
        score = calculate_nutrient_score_from_recipe(
            recipe(sugar=20, sodium_mg=300),
            {"sugar": 10, "sodium_mg": 150},
        )

        self.assertEqual(score, 0.5)

    def test_effective_targets_use_strictest_diet_and_profile_limits(self):
        profile = obj(
            target_kcal=None,
            target_protein=None,
            target_sugar=80,
            target_sodium_mg=3000,
            low_sodium=True,
            low_sugar=True,
            low_fat=False,
        )
        user = obj(profile=profile)
        diet = obj(
            reference_mass_g_per_day=2000,
            max_calories=2000,
            max_salt_mg=2000,
        )

        targets = build_effective_targets(user, diet)

        self.assertEqual(targets["kcal"], 100)
        self.assertEqual(targets["sodium_mg"], 100)
        self.assertEqual(targets["sugar"], 4)

    def test_final_score_uses_weighted_components(self):
        self.assertEqual(calculate_final_score(1, 1, 1, 1), 100)
        self.assertEqual(calculate_final_score(0, 0, 0, 0), 0)
        self.assertEqual(calculate_final_score(1, 0, 0, 0), 50)

    def test_penalties_describe_major_target_misses(self):
        penalties = build_penalties(
            recipe(sugar=20, sodium_mg=300),
            {"sugar": 10, "sodium_mg": 150},
            {"ingredient_score": 0.5, "cooking_method_score": 0.3},
            user=None,
            diet=None,
        )

        self.assertIn("Сахар выше допустимого лимита.", penalties)
        self.assertIn("Натрий превышает безопасный порог.", penalties)
        self.assertIn(
            "Состав рецепта допустим, но не самый подходящий для этой диеты.",
            penalties,
        )
        self.assertIn(
            "Способ приготовления допустим, но не самый предпочтительный.",
            penalties,
        )

    def test_fit_reasons_fallback_for_filtered_recipe(self):
        reasons = build_fit_reasons(
            recipe(),
            {"nutrient_score": 0.4, "cooking_method_score": 0.5},
            matched_tags=[],
            user=None,
        )

        self.assertEqual(
            reasons,
            ["Рецепт прошёл фильтрацию и не нарушает выбранные ограничения."],
        )

    def test_explain_summary_mentions_strong_matches(self):
        summary = build_explain_summary(
            {
                "ingredient_score": 0.9,
                "nutrient_score": 0.85,
                "cooking_method_score": 1.0,
            },
            matched_tags=["quick"],
        )

        self.assertIn("сильное соответствие составу диеты", summary)
        self.assertIn("совпадение с персональными предпочтениями", summary)


if __name__ == "__main__":
    unittest.main()
