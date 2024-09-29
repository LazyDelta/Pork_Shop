import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pork_shop/home_page.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final TextEditingController _productIDController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _imageFile;

  // List of product types for dropdown
  final List<String> _productTypes = ['Porkchop', 'Organs', 'etc'];
  String? _selectedProductType;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _addProduct() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://10.0.2.2/porkshop_php/product/add_product.php"),
    );

    request.fields['productId'] = _productIDController.text;
    request.fields['productType'] = _selectedProductType ?? '';
    request.fields['productName'] = _productNameController.text;
    request.fields['price'] = _priceController.text;

    if (_imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _imageFile!.path),
      );
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      var data = json.decode(responseData.body);
      if (data == 'Succeed') {
        print('Product added successfully');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => const HomePage()),
        );
      } else {
        print('Failed to add product');
      }
    } else {
      print('Server error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            // TextField(
            //   controller: _productIDController,
            //   decoration: const InputDecoration(labelText: 'Product ID'),
            // ),
            DropdownButtonFormField<String>(
              value: _selectedProductType,
              items: _productTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedProductType = newValue;
                });
              },
              decoration: const InputDecoration(labelText: 'Product Type'),
            ),
            TextField(
              controller: _productNameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 10),
            if (_imageFile != null)
              Image.file(_imageFile!, height: 150),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
