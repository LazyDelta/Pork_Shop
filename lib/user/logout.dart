import 'package:flutter/material.dart';
import 'package:pork_shop/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}



class _LogoutScreenState extends State<LogoutScreen> {

   @override
  void initState() {
    super.initState();
    _logoutUser();
  }

  Future<void> _logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
    // Redirect to Home screen
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const HomePage()),
    // );
  }
  
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}