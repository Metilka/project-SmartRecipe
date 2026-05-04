import unittest
from types import SimpleNamespace

from app.services import basket


def recipe(**overrides):
    data = {
        "id": 10,
        "title": "Тестовый рецепт",
        "kcal": 120,
        "protein": 8,
        "fat": 3,
        "carbs": 18,
        "sugar": 4,
        "sodium_mg": 90,
    }
    data.update(overrides)
    return SimpleNamespace(**data)


class BasketServiceTests(unittest.TestCase):
    def setUp(self):
        basket._basket.clear()

    def test_add_to_basket_creates_scaled_entry(self):
        basket.add_to_basket(user_id=1, recipe=recipe(), servings=2)

        entries = basket.get_basket(1)

        self.assertEqual(len(entries), 1)
        self.assertEqual(entries[0]["recipe_id"], 10)
        self.assertEqual(entries[0]["servings"], 2)
        self.assertEqual(entries[0]["kcal"], 240)
        self.assertEqual(entries[0]["protein"], 16)
        self.assertEqual(entries[0]["sodium_mg"], 180)

    def test_get_totals_sums_user_entries(self):
        basket.add_to_basket(1, recipe(id=1, kcal=100, protein=5), 1)
        basket.add_to_basket(1, recipe(id=2, kcal=200, protein=10), 1.5)

        totals = basket.get_totals(1)

        self.assertEqual(totals["kcal"], 400)
        self.assertEqual(totals["protein"], 20)

    def test_clear_basket_removes_entries(self):
        basket.add_to_basket(1, recipe(), 1)

        basket.clear_basket(1)

        self.assertEqual(basket.get_basket(1), [])

    def test_baskets_are_separated_by_user_id(self):
        basket.add_to_basket(1, recipe(id=1), 1)
        basket.add_to_basket(2, recipe(id=2), 1)

        self.assertEqual(basket.get_basket(1)[0]["recipe_id"], 1)
        self.assertEqual(basket.get_basket(2)[0]["recipe_id"], 2)


if __name__ == "__main__":
    unittest.main()
