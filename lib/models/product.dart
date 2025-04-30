class Product {
  final int? id;
  final String name;
  final double price;
  final double gstPercentage;
  final String? description;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.gstPercentage,
    this.description,
  });

  double get cgst => (price * gstPercentage / 200);
  double get sgst => (price * gstPercentage / 200);
  double get totalGst => cgst + sgst;
  double get totalPrice => price + totalGst;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'gstPercentage': gstPercentage,
      'description': description,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: map['price'] as double,
      gstPercentage: map['gstPercentage'] as double,
      description: map['description'] as String?,
    );
  }

  Product copyWith({
    int? id,
    String? name,
    double? price,
    double? gstPercentage,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      description: description ?? this.description,
    );
  }
}
