// import 'package:flutter/material.dart';
// import 'package:flutter_line_sdk/flutter_line_sdk.dart';

// class LineLoginPage extends StatefulWidget {
//   const LineLoginPage({super.key});

//   @override
//   State<LineLoginPage> createState() => _LineLoginPageState();
// }

// class _LineLoginPageState extends State<LineLoginPage> {
//   String? _displayName;
//   String? _pictureUrl;
//   String? _statusMessage;

//   Future<void> _loginWithLine() async {
//     try {
//       final loginResult = await LineSDK.instance.login();
//       final profile = loginResult.userProfile;

//       setState(() {
//         _displayName = profile?.displayName;
//         _pictureUrl = profile?.pictureUrl;
//         _statusMessage = profile?.statusMessage;
//       });

//       // Handle successful login, e.g., navigate to another page
//     } catch (e) {
//       // Handle login error
//       print("Error during Line login: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Line Login'),
//       ),
//       body: Center(
//         child: _displayName == null
//             ? Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'Login with Line',
//                     style: TextStyle(fontSize: 24),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _loginWithLine,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                     ),
//                     child: const Text('Login with Line'),
//                   ),
//                 ],
//               )
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text('Welcome, $_displayName!'),
//                   if (_pictureUrl != null) Image.network(_pictureUrl!),
//                   if (_statusMessage != null) Text('Status: $_statusMessage'),
//                 ],
//               ),
//       ),
//     );
//   }
// }
