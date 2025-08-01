class InvoiceItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;

  InvoiceItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': name,
        'price': price,
        'quantity': quantity,
      };

  factory InvoiceItem.fromMap(Map<String, dynamic> map) => InvoiceItem(
        productId: map['productId'],
        name: map['name'],
        price: (map['price'] is int)
            ? (map['price'] as int).toDouble()
            : map['price'],
        quantity: map['quantity'],
      );

  InvoiceItem copyWith({
    String? productId,
    String? name,
    double? price,
    int? quantity,
  }) {
    return InvoiceItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}

class Invoice {
  final String id;
  final DateTime date;
  final List<InvoiceItem> items;
  final String? customerId;
  final String? customerName;
  final double total;
  final double discount;
  final double tax;
  final String paymentMethod; // cash, visa, transfer, online
  final String? notes;

  Invoice({
    required this.id,
    required this.date,
    required this.items,
    this.customerId,
    this.customerName,
    required this.total,
    this.discount = 0,
    this.tax = 0,
    required this.paymentMethod,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'items': items.map((e) => e.toMap()).toList(),
        'customerId': customerId,
        'customerName': customerName,
        'total': total,
        'discount': discount,
        'tax': tax,
        'paymentMethod': paymentMethod,
        'notes': notes,
      };

  factory Invoice.fromMap(Map<String, dynamic> map) => Invoice(
        id: map['id'],
        date: DateTime.parse(map['date']),
        items:
            (map['items'] as List).map((e) => InvoiceItem.fromMap(e)).toList(),
        customerId: map['customerId'],
        customerName: map['customerName'],
        total: (map['total'] is int)
            ? (map['total'] as int).toDouble()
            : map['total'],
        discount: (map['discount'] is int)
            ? (map['discount'] as int).toDouble()
            : map['discount'],
        tax: (map['tax'] is int) ? (map['tax'] as int).toDouble() : map['tax'],
        paymentMethod: map['paymentMethod'],
        notes: map['notes'],
      );
}
