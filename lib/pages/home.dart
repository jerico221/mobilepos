import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobilepos/api/payment.dart';
import 'package:mobilepos/api/product.dart';
import 'package:mobilepos/model/apiresponce.dart';
import 'package:mobilepos/model/items.dart';
import 'package:mobilepos/model/user.dart';
import 'package:mobilepos/pages/cart.dart';
import 'package:mobilepos/repository/helper.dart';

class HomePage extends StatefulWidget {
  final String employeeid;
  final int posid;
  const HomePage({super.key, required this.employeeid, required this.posid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Helper helper = Helper.instance;
  final ProductAPI productAPI = ProductAPI.instance;
  final PaymentAPI paymentAPI = PaymentAPI.instance;
  List<Map<String, dynamic>> productList = [];
  List<Map<String, dynamic>> cartList = [];
  int totalCartItems = 0;
  Map<String, dynamic> itemList = {};
  List<ItemsModel> cartitems = [];

  String employeeid = '';
  int posid = 0;

  @override
  void initState() {
    // TODO: implement initState
    getProduct();
    getPayment();
    getPOSUser();
    super.initState();
  }

  Future<void> getProduct() async {
    try {
      final ResponseModel res = await productAPI.getProductActive();
      if (res.data.isNotEmpty) {
        final dynamic data = res.data;
        List<Map<String, dynamic>> productJson = [];

        setState(() {
          data.forEach((d) {
            if (kDebugMode) {
              print(d);
            }
            productJson.add({
              "id": d['id'],
              "name": d['name'],
              "image": d['image'],
              "price": d['price'],
              "category": d['category'],
              "isinventory": d['isinventory'],
              "status": d['status']
            });
            productList.add({
              "id": d['id'],
              "name": d['name'],
              "image": d['image'],
              "price": d['price'],
              "category": d['category'],
              "isinventory": d['isinventory'],
              "status": d['status']
            });
          });

          helper.jsonListToFileWriteAndroid(productJson, 'product.json');
        });
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Error'),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'))
                ],
              ));
    }
  }

  Future<void> getPayment() async {
    try {
      final ResponseModel res = await paymentAPI.getPaymentActive();
      if (res.data.isNotEmpty) {
        final dynamic data = res.data;
        List<Map<String, dynamic>> paymentJson = [];

        setState(() {
          data.forEach((d) {
            if (kDebugMode) {
              print(d);
            }
            paymentJson
                .add({"id": d['id'], "name": d['name'], "status": d['status']});
          });

          helper.jsonListToFileWriteAndroid(paymentJson, 'payment.json');
        });
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Error'),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'))
                ],
              ));
    }
  }

  Future<void> getPOSUser() async {
    try {
      final user = await helper.jsonListToFileReadAndroid('user.json');
      final pos = await helper.jsonListToFileReadAndroid('pos.json');

      setState(() {
        employeeid = user[0]['employeeid'].toString();
        posid = pos[0]['id'];
      });
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Error'),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'))
                ],
              ));
    }
  }

  void addCart(int id, String name, double price, int quantity) async {
    setState(() {
      if (cartitems.isEmpty) {
        cartitems.add(ItemsModel(id, name, price, quantity));
        totalCartItems += 1;
      } else {
        if (!cartitems.map((e) => e.name == name).contains(true)) {
          cartitems.add(ItemsModel(id, name, price, quantity));
          totalCartItems += 1;
        } else {
          for (var item in cartitems) {
            if (item.name == name) {
              item.quantity += 1;
              totalCartItems += 1;

              print('${item.name} ${item.quantity}');
              break;
            }
          }
        }
      }
    });
  }

  void updateCart(int index, int quantity, int cartcount) {
    setState(() {
      cartitems[index].quantity = quantity;
      totalCartItems += cartcount;
    });
  }

  void clearCart() {
    setState(() {
      totalCartItems = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> items =
        List<Widget>.generate(productList.length, (int index) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(border: Border.all()),
          width: 280,
          height: 120,
          alignment: Alignment.center,
          child: ListTile(
            leading: Image.memory(
                width: 70, base64Decode(productList[index]['image'])),
            title: Text(productList[index]['name'],
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            trailing: Text(
                helper.formatAsCurrency(
                    double.parse(productList[index]['price'].toString())),
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            // trailing: Text(productList[index]['stocks'].toString()),
            onTap: () {
              addCart(productList[index]['id'], productList[index]['name'],
                  double.parse(productList[index]['price'].toString()), 1);
            },
          ),
        ),
      );
    });
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Store Name'),
        actions: <Widget>[
          Container(
            child: Stack(
              children: [
                Badge.count(count: totalCartItems),
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CartPage(
                                  items: cartitems,
                                  updateCart: updateCart,
                                  clearCart: clearCart,
                                  totalCartItems: totalCartItems,
                                  posid: posid,
                                  employeeid: employeeid,
                                )));
                  },
                )
              ],
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: DrawerHeader(
            child: ListView(
          children: [
            ListTile(
                title: Text(
                  'Product',
                ),
                leading: Icon(Icons.inventory_2)),
            ListTile(title: Text('Settings'), leading: Icon(Icons.settings)),
            Divider(
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Version: 1.0.0', textAlign: TextAlign.center),
            ),
          ],
        )),
      ),
      body: SingleChildScrollView(
        child: Wrap(
          alignment: WrapAlignment.center,
          children: items,
        ),
      ),
    ));
  }
}
