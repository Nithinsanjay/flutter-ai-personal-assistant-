// Copyright 2025 Google LLC
// Flutter adaptation of Categories.kt

class CategoryInfo {
  final String id;
  final String label;

  const CategoryInfo({required this.id, required this.label});
}

class Category {
  static const CategoryInfo llm = CategoryInfo(id: 'llm', label: 'LLM');
  static const CategoryInfo classicalML = CategoryInfo(
    id: 'classical_ml',
    label: 'Classical ML',
  );
  static const CategoryInfo experimental = CategoryInfo(
    id: 'experimental',
    label: 'Experimental',
  );

  static const List<CategoryInfo> all = [llm, classicalML, experimental];
}
