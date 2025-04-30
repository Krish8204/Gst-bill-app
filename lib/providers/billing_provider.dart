import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/bill.dart';
import '../services/database_service.dart';

class BillingProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  List<Product> _products = [];
  List<BillItem> _currentBillItems = [];
  String? _customerName;
  String? _customerPhone;

  List<Product> get products => _products;
  List<BillItem> get currentBillItems => _currentBillItems;
  String? get customerName => _customerName;
  String? get customerPhone => _customerPhone;

  double get subtotal =>
      _currentBillItems.fold(0, (sum, item) => sum + item.totalPrice);
  double get totalCgst =>
      _currentBillItems.fold(0, (sum, item) => sum + item.totalCgst);
  double get totalSgst =>
      _currentBillItems.fold(0, (sum, item) => sum + item.totalSgst);
  double get totalAmount =>
      _currentBillItems.fold(0, (sum, item) => sum + item.finalAmount);

  Future<void> loadProducts() async {
    _products = await _db.getAllProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final newProduct = await _db.insertProduct(product);
    _products.add(newProduct);
    notifyListeners();
  }

  Future<void> removeProduct(int productId) async {
    await _db.deleteProduct(productId);
    _products.removeWhere((product) => product.id == productId);
    // Also remove any items in the current bill that use this product
    _currentBillItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void addItemToBill(Product product, int quantity) {
    final existingItemIndex = _currentBillItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingItemIndex != -1) {
      _currentBillItems[existingItemIndex] = BillItem(
        product: product,
        quantity: _currentBillItems[existingItemIndex].quantity + quantity,
      );
    } else {
      _currentBillItems.add(BillItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void removeItemFromBill(int index) {
    _currentBillItems.removeAt(index);
    notifyListeners();
  }

  void updateItemQuantity(int index, int quantity) {
    if (quantity > 0) {
      _currentBillItems[index] = BillItem(
        product: _currentBillItems[index].product,
        quantity: quantity,
      );
      notifyListeners();
    } else {
      removeItemFromBill(index);
    }
  }

  void setCustomerDetails(String? name, String? phone) {
    _customerName = name;
    _customerPhone = phone;
    notifyListeners();
  }

  Future<Bill> generateBill() async {
    final now = DateTime.now();
    final billNumber = 'BILL${now.millisecondsSinceEpoch}';

    final bill = Bill(
      billNumber: billNumber,
      dateTime: now,
      items: List.from(_currentBillItems),
      customerName: _customerName,
      customerPhone: _customerPhone,
    );

    await _db.insertBill(bill);
    clearBill();
    return bill;
  }

  void clearBill() {
    _currentBillItems.clear();
    _customerName = null;
    _customerPhone = null;
    notifyListeners();
  }

  Future<List<Bill>> getBillsByDateRange(DateTime start, DateTime end) async {
    return await _db.getBillsByDateRange(start, end);
  }
}
