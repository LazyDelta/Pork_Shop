import 'dart:convert';
import 'package:http/http.dart' as http;

class LineService {
  final String _lineToken = 'BZVdQpaKEm7PhIYWrAQrKaE3l3bFF2Sk46U3bWiPzKw'; // Your Line Notify token

  Future<void> sendOrderDetailsToLine(List<dynamic> items, String username) async {
    String message = '\nOrder confirmed by $username\n';

    // Add order details to the message
    for (var item in items) {
      message += "ชื่อสินค้า: ${item['productName']}, จำนวน: ${item['amount']} กิโล\n";
    }

    // Encode the message to make it URL-safe
    String encodedMessage = Uri.encodeComponent(message);

    try {
      var response = await http.post(
        Uri.parse('https://notify-api.line.me/api/notify'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $_lineToken',
        },
        body: 'message=$encodedMessage',
      );

      if (response.statusCode == 200) {
        print('Message sent to Line successfully');
      } else {
        print('Failed to send message to Line: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending message to Line: $e');
    }
  }
}
