import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a StateProvider to manage the current index of the bottom navigation bar
final bottomNavigationProvider = StateProvider<int>((ref) => 0);
