import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pork_shop/order/get_order_Items.dart';

class OrderDetailScreen extends StatefulWidget {
  final String userId;

  const OrderDetailScreen({super.key, required this.userId});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List<dynamic> orderDetails = [];
  List<dynamic> filteredOrderDetails = []; // Filtered list for search
  String? permission;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPermission(); // Fetch permission first
  }

  // Fetch permission from SharedPreferences
  Future<void> _fetchPermission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      permission = prefs.getString('permission');
    });
    _fetchOrderDetails(); // Fetch order details after permission is loaded
  }

  // Fetch order details based on permission
  Future<void> _fetchOrderDetails() async {
    try {
      Map<String, String> body = {};

      if (permission == '2') {
        // Fetch all orders if permission is 2
        body = {};
      } else {
        // Fetch orders only for this userId if permission is not 2
        body = {'userId': widget.userId};
      }

      final response = await http.post(
        Uri.parse("http://10.0.2.2/porkshop_php/order/get_order_details.php"),
        body: body,
      );

      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(response.body);

        setState(() {
          orderDetails = decodedData;
          filteredOrderDetails = orderDetails; // Initialize filtered list
        });
      } else {
        print(
            'Failed to load order details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching order details: $e');
    }
  }

  // Search through orders based on user input
  void _filterOrders(String query) {
    setState(() {
      filteredOrderDetails = orderDetails.where((order) {
        final username = order['username']?.toString().toLowerCase() ?? '';
        final orderId = order['orderId']?.toString().toLowerCase() ?? '';
        final orderDate = order['order_date']?.toString().toLowerCase() ?? '';
        final orderStatus = order['status']?.toString().toLowerCase() ?? '';

        return username.contains(query.toLowerCase()) ||
            orderId.contains(query.toLowerCase()) ||
            orderDate.contains(query.toLowerCase()) ||
            orderStatus.contains(query.toLowerCase());
      }).toList();
    });
  }

  // Update status of orders from "Pending" to "Complete"
  Future<void> _updateOrderStatus() async {
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2/porkshop_php/order/update_status.php"),
      );

      if (response.statusCode == 200) {
        // Reload order details to reflect updated statuses
        _fetchOrderDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order statuses updated successfully.')),
        );
      } else {
        print('Failed to update statuses. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating statuses: $e');
    }
  }

  // Save the order_group_id to SharedPreferences when an order is tapped
  Future<void> _saveOrderGroupId(String orderGroupId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('order_group_id', orderGroupId);
    print("Saved order_group_id: $orderGroupId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        automaticallyImplyLeading: false,
        actions: [
          if (permission != "1") // Show this icon if permission is '2'
            IconButton(
            icon: const Icon(Icons.update),
            onPressed: _updateOrderStatus, // Update order statuses when button is pressed
            tooltip: 'Update Status',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _filterOrders(value), // Update search results
              decoration: InputDecoration(
                labelText: 'Search Orders',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredOrderDetails.isEmpty
                ? const Center(child: Text('No order details found.'))
                : ListView.builder(
                    itemCount: filteredOrderDetails.length,
                    itemBuilder: (context, index) {
                      var order = filteredOrderDetails[index];

                      final orderGroupId =
                          order['order_group_id']?.toString() ?? 'N/A';
                      final orderId =
                          order['orderId']?.toString() ?? 'N/A';
                      final username =
                          order['username']?.toString() ?? 'N/A';
                      final totalPrice =
                          order['total_price']?.toString() ?? '0.00';
                      final orderDate =
                          order['order_date']?.toString() ?? 'N/A';
                      final orderStatus =
                          order['status']?.toString() ?? 'N/A'; // Updated to show 'status' from database

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0), // Add spacing between items
                        child: Card(
                          elevation: 2, // Slight elevation for better appearance
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10), // Add padding within each ListTile
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Order ID: $orderId'),
                                Text('Username: $username'),
                                Text('Date: $orderDate'),
                              ],
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Total: \$$totalPrice'),
                                Text('Status: $orderStatus',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(255, 0, 0, 0))),
                              ],
                            ),
                            onTap: () async {
                              // Save the order_group_id to SharedPreferences
                              await _saveOrderGroupId(orderGroupId);

                              // Navigate to OrderItemsScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const OrderItemsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
