import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class BillsListScreen extends StatefulWidget {
  const BillsListScreen({super.key});

  @override
  State<BillsListScreen> createState() => _BillsListScreenState();
}

class _BillsListScreenState extends State<BillsListScreen> {
  List<Bill> _bills = [];
  bool _isLoading = true;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy hh:mm a');

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    setState(() => _isLoading = true);
    try {
      final DateTime now = DateTime.now();
      final DateTime thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final bills = await DatabaseService.instance.getBillsByDateRange(
        thirtyDaysAgo,
        now,
      );
      setState(() => _bills = bills);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading bills: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
        title: const Text(
          'Generated Bills',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadBills,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade50,
              Colors.white,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                ),
              )
            : _bills.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bills found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _bills.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final bill = _bills[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            'Bill #${bill.billNumber}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _dateFormat.format(bill.dateTime),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              if (bill.customerName != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      bill.customerName!,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '₹${bill.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (bill.customerPhone != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.phone_outlined,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            bill.customerPhone!,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Items:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...bill.items.map(
                                    (item) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${item.quantity} × ₹${item.product.price}',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        _buildBillRow(
                                          'Subtotal:',
                                          '₹${bill.subtotal.toStringAsFixed(2)}',
                                        ),
                                        _buildBillRow(
                                          'CGST:',
                                          '₹${bill.totalCgst.toStringAsFixed(2)}',
                                        ),
                                        _buildBillRow(
                                          'SGST:',
                                          '₹${bill.totalSgst.toStringAsFixed(2)}',
                                        ),
                                        const Divider(),
                                        _buildBillRow(
                                          'Total:',
                                          '₹${bill.totalAmount.toStringAsFixed(2)}',
                                          isTotal: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.indigo : null,
            ),
          ),
        ],
      ),
    );
  }
}
