class MenuProduct {
  MenuProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.emoji = '🍰',
    this.hasToppings = false,
    this.available = true,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String emoji;
  final bool hasToppings;
  bool available;
}

class MenuCategory {
  MenuCategory({required this.name, required this.products, this.incomplete = false});

  final String name;
  final List<MenuProduct> products;
  final bool incomplete;
}
