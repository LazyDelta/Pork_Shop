import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pork_shop/order/del_order.dart';

class EditOrderScreen extends StatefulWidget {
  final String orderId;
  final String productName;
  final String amount;
  final String price;

  const EditOrderScreen({
    super.key,
    required this.orderId,
    required this.productName,
    required this.amount,
    required this.price,
  });

  @override
  _EditOrderScreenState createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.amount);
  }

  Future<void> _updateOrder() async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2/porkshop_php/order/edit_order.php"),
      body: {
        'orderId': widget.orderId,
        'amount': _amountController.text,
      },
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true); // Return to previous screen and reload
    } else {
      throw Exception('Failed to update order.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.productName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await deleteOrder(widget.orderId, context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateOrder,
              child: const Text('Update Order'),
            ),
          ],
        ),
      ),
    );
  }
}
