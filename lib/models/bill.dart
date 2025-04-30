import 'package:gst_billing_app/models/product.dart';

class BillItem {
  final Product product;
  final int quantity;

  BillItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;
  double get totalCgst => product.cgst * quantity;
  double get totalSgst => product.sgst * quantity;
  double get finalAmount => product.totalPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'unitPrice': product.price,
      'gstPercentage': product.gstPercentage,
    };
  }
}

class Bill {
  final int? id;
  final String billNumber;
  final DateTime dateTime;
  final List<BillItem> items;
  final String? customerName;
  final String? customerPhone;

  Bill({
    this.id,
    required this.billNumber,
    required this.dateTime,
    required this.items,
    this.customerName,
    this.customerPhone,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  double get totalCgst => items.fold(0, (sum, item) => sum + item.totalCgst);
  double get totalSgst => items.fold(0, (sum, item) => sum + item.totalSgst);
  double get totalAmount =>
      items.fold(0, (sum, item) => sum + item.finalAmount);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'billNumber': billNumber,
      'dateTime': dateTime.toIso8601String(),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'subtotal': subtotal,
      'totalCgst': totalCgst,
      'totalSgst': totalSgst,
      'totalAmount': totalAmount,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map, List<BillItem> items) {
    return Bill(
      id: map['id'] as int?,
      billNumber: map['billNumber'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      items: items,
      customerName: map['customerName'] as String?,
      customerPhone: map['customerPhone'] as String?,
    );
  }
}
