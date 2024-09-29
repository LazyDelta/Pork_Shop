import 'dart:convert';
import 'dart:io'; // Import for File handling
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Import for image picking
import 'package:pork_shop/home_page.dart';

class EditData extends StatefulWidget {
  final List list;
  final int index;

  const EditData({super.key, required this.list, required this.index});

  @override
  _EditDataState createState() => _EditDataState();
}

class _EditDataState extends State<EditData> {
  final TextEditingController _productIDController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  File? _image; // To store the selected image

  // List of product types for dropdown
  final List<String> _productTypes = ['Porkchop', 'Organs', 'Bacon', 'Sausage'];
  String? _selectedProductType;

  @override
  void initState() {
    super.initState();
    _productIDController.text = widget.list[widget.index]['productId'];
    _selectedProductType = widget.list[widget.index]['productType'];
    _productNameController.text = widget.list[widget.index]['productName'];
    _priceController.text = widget.list[widget.index]['price'];
  }

  // Function to pick image
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _editProduct() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("http://10.0.2.2/porkshop_php/product/edit_product.php"),
      );

      request.fields['productId'] = _productIDController.text;
      request.fields['productType'] = _selectedProductType ?? '';
      request.fields['productName'] = _productNameController.text;
      request.fields['price'] = _priceController.text;

      // If an image is selected, add it to the request
      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path,
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = json.decode(responseData);
        if (data == 'Succeed') {
          print('Product updated successfully');
          Navigator.of(context).pop(true); // Return true to indicate success
        } else {
          print('Failed to update product');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update product: $data')),
          );
        }
      } else {
        print('Server error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('An error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            TextField(
              controller: _productIDController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Product ID',
                filled: true,
                fillColor: Colors.grey, // Set the background color to gray
              ),
            ),
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
            widget.list[widget.index]['image'] != null &&
                    widget.list[widget.index]['image'].isNotEmpty
                ? Image.network(
                    "http://10.0.2.2/porkshop_php/uploads/${widget.list[widget.index]['image']}",
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : const Text("No Image Available"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Change Image'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await _editProduct();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (BuildContext context) => const HomePage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('Edit Product'),
            ),
          ],
        ),
      ),
    );
  }
}
