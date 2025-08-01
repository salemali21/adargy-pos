class Customer {
  final String id;
  final String name;
  final String type; // 'customer' or 'supplier'
  final double balance;
  final String phone;
  final String? notes;
  final String? category; // منتظم – متأخر – VIP
  final String? imagePath;
  final int loyaltyPoints;

  Customer({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.phone,
    this.notes,
    this.category,
    this.imagePath,
    this.loyaltyPoints = 0,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? type,
    double? balance,
    String? phone,
    String? notes,
    String? category,
    String? imagePath,
    int? loyaltyPoints,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'phone': phone,
      'notes': notes,
      'category': category,
      'imagePath': imagePath,
      'loyaltyPoints': loyaltyPoints,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      balance: (map['balance'] is int)
          ? (map['balance'] as int).toDouble()
          : map['balance'],
      phone: map['phone'],
      notes: map['notes'],
      category: map['category'],
      imagePath: map['imagePath'],
      loyaltyPoints: map['loyaltyPoints'] ?? 0,
    );
  }
}
