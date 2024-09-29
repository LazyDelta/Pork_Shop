import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pork_shop/line_service.dart';
import 'package:pork_shop/order/edit_order.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CartScreen extends StatefulWidget {
  final String userId;
  const CartScreen({super.key, required this.userId});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late String userId;
  late String username = ''; // Add username
  double totalPrice = 0.0;
  final LineService _lineService = LineService(); // Instantiate LineService

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    _fetchUsername(); // Fetch the username
    _fetchTotalPrice();
  }

  // Fetch the username from SharedPreferences
  Future<void> _fetchUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? ''; // Get stored username
    });
  }

  Future<void> _fetchTotalPrice() async {
    if (userId.isNotEmpty) {
      final ordersResponse = await http.post(
        Uri.parse("http://10.0.2.2/porkshop_php/order/get_order.php"),
        body: {'userId': userId},
      );

      if (ordersResponse.statusCode == 200) {
        final orders = json.decode(ordersResponse.body);

        if (orders.isNotEmpty) {
          final response = await http.post(
            Uri.parse("http://10.0.2.2/porkshop_php/order/get_total_price.php"),
            body: {'userId': userId},
          );

          if (response.statusCode == 200) {
            setState(() {
              totalPrice = double.parse(response.body);
            });
          } else {
            print('Failed to load total price');
          }
        } else {
          setState(() {
            totalPrice = 0.0;
          });
        }
      } else {
        print('Failed to load orders');
      }
    }
  }

  Future<List<dynamic>> _fetchOrders() async {
    if (userId.isEmpty) {
      throw Exception('User ID not found');
    }

    final response = await http.post(
      Uri.parse("http://10.0.2.2/porkshop_php/order/get_order.php"),
      body: {'userId': userId},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<void> _confirmOrder() async {
    final orders = await _fetchOrders();
    final now = DateTime.now();
    final formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final response = await http.post(
      Uri.parse("http://10.0.2.2/porkshop_php/order/confirm_order.php"),
      body: {
        'userId': userId,
        'totalPrice': totalPrice.toString(),
        'orders': json.encode(orders),
        'dateTime': formattedDateTime,
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order confirmed successfully!')),
      );

      // Send order details to Line with username
      await _lineService.sendOrderDetailsToLine(orders, username);

      setState(() {
        totalPrice = 0.0;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to confirm order.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _fetchOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No orders found.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var order = snapshot.data![index];
                      return Card(
                        child: ListTile(
                          title: Text('Product Name: ${order['productName']}'),
                          subtitle: Text('Amount: ${order['amount']}'),
                          trailing: Text('Price: ${order['price']}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditOrderScreen(
                                  orderId: order['orderId'],
                                  productName: order['productName'],
                                  amount: order['amount'],
                                  price: order['price'],
                                ),
                              ),
                            ).then((value) {
                              _fetchTotalPrice();
                            });
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: totalPrice > 0.0 ? _confirmOrder : null,
                  child: const Text('Confirm Order'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
