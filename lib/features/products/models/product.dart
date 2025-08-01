class Product {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? category;
  final String? imagePath;
  final int alertThreshold;
  final String? notes;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.category,
    this.imagePath,
    this.alertThreshold = 1,
    this.notes,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? category,
    String? imagePath,
    int? alertThreshold,
    String? notes,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'category': category,
      'imagePath': imagePath,
      'alertThreshold': alertThreshold,
      'notes': notes,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : map['price'],
      quantity: map['quantity'],
      category: map['category'],
      imagePath: map['imagePath'],
      alertThreshold: map['alertThreshold'] ?? 1,
      notes: map['notes'],
    );
  }
}
