import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> deleteOrder(String orderId, BuildContext context) async {
  final response = await http.post(
    Uri.parse("http://10.0.2.2/porkshop_php/order/del_order.php"),
    body: {
      'orderId': orderId,
    },
  );

  if (response.statusCode == 200) {
    Navigator.pop(context, true); // Return to previous screen and reload
  } else {
    throw Exception('Failed to delete order.');
  }
}
