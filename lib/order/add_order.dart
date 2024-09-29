import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pork_shop/product/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddOrder extends StatefulWidget {
  final String productId;
  const AddOrder({super.key, required this.productId});

  @override
  _AddOrderState createState() => _AddOrderState();
}

class _AddOrderState extends State<AddOrder> {
  final TextEditingController _amountController = TextEditingController();
  late String userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
    });
  }

  Future<void> _addOrder() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://10.0.2.2/porkshop_php/order/add_order.php"),
    );

    request.fields['productId'] = widget.productId;
    request.fields['amount'] = _amountController.text;
    request.fields['userId'] = userId; // Use the stored userId

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      var data = json.decode(responseData.body);
      if (data == 'Succeed') {
        print('Order added successfully');

        // Instead of pushing a new page, return to the previous ProductPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProductPage(),
          ),
        ); // This will take you back to ProductPage
      } else {
        print('Failed to add order');
      }
    } else {
      print('Server error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Order Product'),
              
            ),
          ],
        ),
      ),
    );
  }
}
