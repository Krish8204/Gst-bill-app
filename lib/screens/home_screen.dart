import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/billing_provider.dart';
import '../models/product.dart';
import 'bills_list_screen.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();
  final Map<int, TextEditingController> _quantityControllers = {};
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  double _selectedGstRate = 5.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillingProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _quantityControllers.values.forEach((controller) => controller.dispose());
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  void _addProduct() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        name: _productNameController.text,
        price: double.parse(_priceController.text),
        gstPercentage: _selectedGstRate,
      );

      context.read<BillingProvider>().addProduct(product);
      _productNameController.clear();
      _priceController.clear();
      Navigator.of(context).pop();
    }
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter product name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter price' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<double>(
                value: _selectedGstRate,
                decoration: const InputDecoration(labelText: 'GST Rate'),
                items: [5.0, 12.0, 18.0, 28.0].map((rate) {
                  return DropdownMenuItem(
                    value: rate,
                    child: Text('$rate%'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGstRate = value!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addProduct,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addToBill(Product product) {
    final controller = _quantityControllers[product.id];
    if (controller != null && controller.text.isNotEmpty) {
      final quantity = int.parse(controller.text);
      context.read<BillingProvider>().addItemToBill(product, quantity);
      controller.clear();
    }
  }

  Future<void> _generateBill() async {
    if (context.read<BillingProvider>().currentBillItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add items to the bill')),
      );
      return;
    }

    context.read<BillingProvider>().setCustomerDetails(
          _customerNameController.text.isEmpty
              ? null
              : _customerNameController.text,
          _customerPhoneController.text.isEmpty
              ? null
              : _customerPhoneController.text,
        );

    await context.read<BillingProvider>().generateBill();
    _customerNameController.clear();
    _customerPhoneController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill generated successfully')),
      );
    }
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (product.id != null) {
                context.read<BillingProvider>().removeProduct(product.id!);
                // Clean up the quantity controller
                _quantityControllers[product.id!]?.dispose();
                _quantityControllers.remove(product.id!);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TATA Retail Solutions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BillsListScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddProductDialog,
          ),
        ],
      ),
      body: Row(
        children: [
          // Products List
          Expanded(
            flex: 2,
            child: Card(
              margin: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Products',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Consumer<BillingProvider>(
                      builder: (context, provider, child) {
                        return ListView.builder(
                          itemCount: provider.products.length,
                          itemBuilder: (context, index) {
                            final product = provider.products[index];
                            // Create a controller for this product if it doesn't exist
                            if (product.id != null) {
                              _quantityControllers[product.id!] ??=
                                  TextEditingController();
                            }

                            return ListTile(
                              title: Text(product.name),
                              subtitle: Text(
                                'Price: ₹${product.price.toStringAsFixed(2)} | GST: ${product.gstPercentage}%',
                              ),
                              trailing: SizedBox(
                                width: 160,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      child: TextFormField(
                                        controller: product.id != null
                                            ? _quantityControllers[product.id!]
                                            : null,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Qty',
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_shopping_cart),
                                      onPressed: () => _addToBill(product),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: () =>
                                          _showDeleteConfirmation(product),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Current Bill
          Expanded(
            flex: 3,
            child: Card(
              margin: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Current Bill',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _customerNameController,
                            decoration: const InputDecoration(
                              labelText: 'Customer Name',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _customerPhoneController,
                            decoration: const InputDecoration(
                              labelText: 'Customer Phone',
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Consumer<BillingProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: provider.currentBillItems.length,
                                itemBuilder: (context, index) {
                                  final item = provider.currentBillItems[index];
                                  return ListTile(
                                    title: Text(item.product.name),
                                    subtitle: Text(
                                      'Qty: ${item.quantity} | Price: ₹${item.totalPrice.toStringAsFixed(2)}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () =>
                                          provider.removeItemFromBill(index),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Subtotal:'),
                                      Text(
                                        '₹${provider.subtotal.toStringAsFixed(2)}',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('CGST:'),
                                      Text(
                                        '₹${provider.totalCgst.toStringAsFixed(2)}',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('SGST:'),
                                      Text(
                                        '₹${provider.totalSgst.toStringAsFixed(2)}',
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total Amount:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '₹${provider.totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: _generateBill,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                      ),
                      child: const Text('Generate Bill'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
