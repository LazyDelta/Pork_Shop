import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pork_shop/home_page.dart';
import 'package:pork_shop/product/edit_product.dart';
import 'package:pork_shop/order/add_order.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Detail extends StatefulWidget {
  final List list;
  final int index;

  const Detail({super.key, required this.index, required this.list});

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  String? permission;

  @override
  void initState() {
    super.initState();
    _fetchPermission();
  }

  Future<void> _fetchPermission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      permission = prefs.getString('permission');
    });
  }

  void deleteData() async {
    var url = Uri.parse("http://10.0.2.2/porkshop_php/product/del_product.php");
    final response = await http.post(
      url,
      body: {'productId': widget.list[widget.index]['productId']},
    );
    if (response.statusCode == 200) {
      print('Deleted successfully');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => const HomePage()),
      );
    } else {
      print('Failed to delete');
    }
  }

  void confirm() {
    AlertDialog alertDialog = AlertDialog(
      content: Text(
          "Are you sure you want to delete '${widget.list[widget.index]['productName']}'?"),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            deleteData();
          },
          child: const Text(
            "OK DELETE!",
            style: TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "CANCEL",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) => alertDialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    Center(
                      child: widget.list[widget.index]['image'] != null &&
                              widget.list[widget.index]['image'].isNotEmpty
                          ? Image.network(
                              "http://10.0.2.2/porkshop_php/uploads/${widget.list[widget.index]['image']}",
                              height: 200,
                              width: 300,
                              fit: BoxFit.cover,
                            )
                          : const Text(
                              "No Image Available",
                              style: TextStyle(fontSize: 18.0),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Product Type: ${widget.list[widget.index]['productType']}",
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Product Name: ${widget.list[widget.index]['productName']}",
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Price: ${widget.list[widget.index]['price']}",
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (permission == '2') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => EditData(
                          list: widget.list,
                          index: widget.index,
                        ),
                      ),
                    ),
                    child: const Text("EDIT"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                    ),
                    onPressed: () => confirm(),
                    child: const Text("DELETE"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            
            if (permission != '2') // Show the button if permission is not '2'
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 13, 255, 0),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => AddOrder(
                    productId: widget.list[widget.index]['productId'],
                  ),
                ),
              ),
                child: const Text("ORDER PRODUCT"),
              ),
          ],
        ),
      ),
    );
  }
}
