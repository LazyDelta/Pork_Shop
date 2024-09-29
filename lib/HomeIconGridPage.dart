import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'provider.dart';

class HomeIconGridPage extends ConsumerWidget {
  const HomeIconGridPage({super.key});
  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        automaticallyImplyLeading: false, // Removes the back button if any
      ),
      body: Center(
        child: Wrap(
          
          alignment: WrapAlignment.center,
          spacing: 20, // Space between buttons horizontally
          runSpacing: 20, // Space between buttons vertically
          children: [
            _buildIconButton(
              context,
              icon: Icons.shopping_cart,
              label: 'Product',
              onPressed: () {
                ref.read(bottomNavigationProvider.notifier).state = 1;
              },
            ),
            _buildIconButton(
              context,
              icon: Icons.shopping_cart_checkout,
              label: 'Order',
              onPressed: () {
                // Update bottomNavigationProvider to show OrderPage
                ref.read(bottomNavigationProvider.notifier).state = 2;
              },
            ),
            _buildIconButton(
              context,
              icon: Icons.list,
              label: 'My Order',
              onPressed: () {
                // Update bottomNavigationProvider to show My Order page
                ref.read(bottomNavigationProvider.notifier).state = 3;
              },
            ),
            _buildIconButton(
              context,
              icon: Icons.person,
              label: 'Profile',
              onPressed: () {
                // Update bottomNavigationProvider to show Profile page
                ref.read(bottomNavigationProvider.notifier).state = 4;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: 150, // Set the width of the button
      height: 150, // Set the height of the button
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
