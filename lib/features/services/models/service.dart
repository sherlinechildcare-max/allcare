class Service {
  final String id;
  final String name;
  final String category;
  final String subCategory;
  final List<String> tags;
  final double price;

  Service({
    required this.id,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.tags,
    required this.price,
  });
}
