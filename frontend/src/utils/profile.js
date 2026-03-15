export const createBlankProfile = () => ({
  excludedProducts: [],
  medicalFlags: {
    gentleDigestion: false,
    strictLowSugar: false,
    strictLowSodium: false,
    reducedFat: false,
  },
  targetsDaily: {
    kcal: '',
    protein: '',
    fat: '',
    carbs: '',
    sugar: '',
    sodium: '',
  },
  preferences: ['vegetables', 'quick'],
  topN: 8,
});
