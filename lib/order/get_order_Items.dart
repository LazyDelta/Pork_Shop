import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:pork_shop/line_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderItemsScreen extends StatefulWidget {
  const OrderItemsScreen({super.key});

  @override
  _OrderItemsScreenState createState() => _OrderItemsScreenState();
}

class _OrderItemsScreenState extends State<OrderItemsScreen> {
  String? permission; // Variable to hold permission level
  // final LineService _lineService = LineService(); // Instantiate LineService

  @override
  void initState() {
    super.initState();
    _fetchPermission(); // Fetch the permission level when the screen is initialized
  }

  Future<List<dynamic>> _fetchOrderItems() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? orderGroupId = prefs.getString('order_group_id');

      if (orderGroupId == null || orderGroupId.isEmpty) {
        throw Exception('Order group ID not found in SharedPreferences');
      }

      final response = await http.post(
        Uri.parse("http://10.0.2.2/porkshop_php/order/get_order_items.php"),
        body: {'order_group_id': orderGroupId},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load order items. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching order items: $e');
    }
  }

  Future<void> _fetchPermission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      permission = prefs.getString('permission'); // Store the permission level
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Items'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchOrderItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items found.'));
          } else {
            final items = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      var item = items[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Product: ${item['productName']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Quantity: ${item['amount']} kg',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Total: \$${item['total_price']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // if (permission == '2')
                //   Padding(
                //     padding: const EdgeInsets.all(16.0),
                //     child: ElevatedButton.icon(
                //       onPressed: () => _lineService.sendOrderDetailsToLine(items),
                //       icon: const Icon(Icons.send),
                //       label: const Text('Send to Line'),
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: const Color.fromARGB(255, 13, 255, 0),
                //         padding: const EdgeInsets.symmetric(
                //             vertical: 14.0, horizontal: 20.0),
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(12),
                //         ),
                //         textStyle: const TextStyle(
                //             fontSize: 16, fontWeight: FontWeight.bold),
                //       ),
                //     ),
                //   ),
              ],
            );
          }
        },
      ),
    );
  }
}
