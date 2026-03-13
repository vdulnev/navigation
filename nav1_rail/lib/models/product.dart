class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
    required this.description,
  });

  final String id;
  final String name;
  final double price;
  final String emoji;
  final String description;
}

const List<Product> kProducts = [
  Product(
    id: '1',
    name: 'Running Shoes',
    price: 89.99,
    emoji: '👟',
    description: 'Lightweight running shoes for everyday training.',
  ),
  Product(
    id: '2',
    name: 'Backpack',
    price: 49.99,
    emoji: '🎒',
    description: 'Durable 30 L backpack with laptop compartment.',
  ),
  Product(
    id: '3',
    name: 'Sunglasses',
    price: 29.99,
    emoji: '🕶️',
    description: 'UV400 polarized lenses in a lightweight frame.',
  ),
  Product(
    id: '4',
    name: 'Water Bottle',
    price: 19.99,
    emoji: '🍶',
    description: 'Insulated 750 ml stainless steel bottle.',
  ),
  Product(
    id: '5',
    name: 'Hoodie',
    price: 59.99,
    emoji: '👕',
    description: 'Warm fleece hoodie, available in multiple colours.',
  ),
  Product(
    id: '6',
    name: 'Headphones',
    price: 129.99,
    emoji: '🎧',
    description: 'Over-ear wireless headphones with noise cancelling.',
  ),
  Product(
    id: '7',
    name: 'Notebook',
    price: 12.99,
    emoji: '📓',
    description: 'A5 dot-grid notebook, 160 pages.',
  ),
  Product(
    id: '8',
    name: 'Coffee Mug',
    price: 14.99,
    emoji: '☕',
    description: 'Ceramic mug with heat-resistant handle, 350 ml.',
  ),
];
