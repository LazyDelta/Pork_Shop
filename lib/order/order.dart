// import 'package:flutter/material.dart';
// import 'package:pork_shop/order/add_order.dart';

// class OrderPage extends StatelessWidget {
//   final String productId;
//   final String productType;
//   final String productName;
//   final String price;

//   const OrderPage({
//     super.key,
//     required this.productId,
//     required this.productType,
//     required this.productName,
//     required this.price,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Order Product')),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text("Product ID: $productId", style: const TextStyle(fontSize: 18)),
//             Text("Product Type: $productType", style: const TextStyle(fontSize: 18)),
//             Text("Product Name: $productName", style: const TextStyle(fontSize: 18)),
//             Text("Price: $price", style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 20),
//             Center(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                 onPressed: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => AddOrder(productId: productId),
//                     ),
//                   );
//                 },
//                 child: const Text('Proceed to Order'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
