import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pork_shop/product/add_product.dart';
import 'package:pork_shop/product/product_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<dynamic> _products = [];
  List<dynamic> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  String? permission;

  @override
  void initState() {
    super.initState();
    _fetchPermission(); // Fetch permission level
    _fetchProducts();
  }

  Future<void> _fetchPermission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      permission = prefs.getString('permission');
    });
  }

  Future<void> _fetchProducts() async {
    final response = await http.get(Uri.parse("http://10.0.2.2/porkshop_php/product/show_product.php"));
    if (response.statusCode == 200) {
      setState(() {
        _products = jsonDecode(response.body);
        _filteredProducts = _products;
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = _products.where((product) {
        return product['productName'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _showProductDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) => const AddProduct()),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Page'),
        automaticallyImplyLeading: false,
        actions: [
          if (permission == '2') // Show Add Product button only if permission == 2
            ElevatedButton(
              onPressed: _showProductDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Add Product'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _filterProducts(value),
              decoration: InputDecoration(
                labelText: 'Search Products',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredProducts.isNotEmpty
                ? ItemList(list: _filteredProducts)
                : const Center(child: Text('No products found.')),
          ),
        ],
      ),
    );
  }
}


class ItemList extends StatelessWidget {
  final List<dynamic> list;

  const ItemList({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => Detail(list: list, index: index),
              ),
            ),
            child: Card(
              child: ListTile(
                title: Text(list[index]['productName']),
                leading: const Icon(Icons.shopping_cart), // Use an appropriate icon
                subtitle: Text('Price: ${list[index]['price']}'),
              ),
            ),
          ),
        );
      },
    );
  }
}
