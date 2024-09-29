import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pork_shop/HomeIconGridPage.dart';
import 'package:pork_shop/order/cart_screen.dart';
import 'package:pork_shop/order/order_detail.dart';
import 'package:pork_shop/product/product.dart';
import 'package:pork_shop/user/user_detail.dart';
import 'provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  // Method to retrieve the userId from SharedPreferences
  Future<String> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the bottomNavigationProvider to get the current index
    final currentIndex = ref.watch(bottomNavigationProvider);

    return FutureBuilder<String>(
      future: _getUserId(),
      builder: (context, snapshot) {
        // Show a loading spinner while the Future is resolving
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Handle errors or missing userId
        else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return const Center(child: Text('Failed to load user ID.'));
        }
        // Once userId is available, build the UI
        else {
          final userId = snapshot.data!;

          // List of pages corresponding to each bottom navigation item
          final List<Widget> pages = [
            const HomeIconGridPage(), // Home page
            const ProductPage(), // Product page
            CartScreen(userId: userId), // Cart page
            OrderDetailScreen(userId: userId), // Order details page
            const MyProfilePage(), // Profile page
          ];

          return Scaffold(
            body: IndexedStack(
              index:
                  currentIndex, // Keeps the state of the currently selected page
              children: pages,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex, // Indicates the selected tab
              onTap: (index) {
                ref.read(bottomNavigationProvider.notifier).state = index;
              },
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.black,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Product',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_checkout),
                  label: 'Order',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'My Order',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
