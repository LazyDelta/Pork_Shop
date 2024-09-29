import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:pork_shop/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  String username = '';
  String telNumber = '';
  String? imagePath;
  XFile? _selectedImage;

  final TextEditingController _telNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');

    if (storedUsername != null) {
      String url = "http://10.0.2.2/porkshop_php/user/get_user_detail.php";
      final response = await http.post(
        Uri.parse(url),
        body: {'username': storedUsername},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            username = data[0]['username'];
            telNumber = data[0]['tel_number'];
            imagePath = data[0]['image']; // Get image path from backend
            _telNumberController.text = telNumber; // Pre-fill the tel number
          });
        }
      } else {
        _showErrorDialog("Failed to load user data.");
      }
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
    );
  }

  Future<void> _saveUserData() async {
    String url = "http://10.0.2.2/porkshop_php/user/add_user_detail.php";
    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.fields['username'] = username; // Use stored username
    request.fields['tel_number'] = _telNumberController.text;

    if (_selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      _fetchUserData(); // Refresh user data after saving
      Navigator.of(context).pop();
    } else {
      _showErrorDialog("Failed to save user data.");
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = image;
    });
  }

  void _showEditForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _telNumberController,
                decoration: const InputDecoration(labelText: 'Tel Number'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Select Image'),
              ),
              const SizedBox(height: 10),
              _selectedImage != null
                  ? Image.file(
                      File(_selectedImage!.path),
                      height: 100,
                    )
                  : const Text("No image selected"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUserData,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (imagePath != null && imagePath!.isNotEmpty) 
                  Image.network(
                    'http://10.0.2.2/porkshop_php/uploads/$imagePath',
                    height: 250,
                    width: 300,
                    fit: BoxFit.cover,
                  )
                else
                  const Icon(
                    Icons.person,
                    size: 150,
                  ),
                const SizedBox(height: 20),
                if (username.isNotEmpty && telNumber.isNotEmpty) ...[
                  Text(
                    username,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    telNumber,
                    style: const TextStyle(fontSize: 20),
                  ),
                ] else ...[
                  const CircularProgressIndicator(),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showEditForm,
                    child: const Text('Edit Tel Number & Image'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _logout,
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
