// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:imin_printer/column_maker.dart';
import 'package:imin_printer/imin_style.dart';
import 'package:mobilepos/api/sales.dart';
import 'package:mobilepos/model/apiresponce.dart';

import 'package:mobilepos/model/items.dart';
import 'package:mobilepos/model/payment.dart';
import 'package:mobilepos/repository/helper.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import 'package:imin_printer/imin_printer.dart';
import 'package:imin_printer/enums.dart';

class CartPage extends StatefulWidget {
  List<ItemsModel> items;
  Function updateCart;
  Function clearCart;
  int totalCartItems;
  int posid;
  String employeeid;

  CartPage({
    super.key,
    required this.items,
    required this.updateCart,
    required this.clearCart,
    required this.totalCartItems,
    required this.posid,
    required this.employeeid,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final iminPrinter = IminPrinter();
  final Helper helper = Helper.instance;
  final SalesAPI salesAPI = SalesAPI.instance;
  double total = 0;
  double subtotal = 0;
  double change = 0;
  double cashtender = 0;
  int cartcount = 0;

  final TextEditingController cashtenderController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    cashtenderController.dispose();

    super.dispose();
  }

  Future<bool> confirmAndRemove(int index) async {
    bool shouldRemove = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Removal'),
          content: const Text(
              'Are you sure you want to remove this item from the list?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel removal
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm removal
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (shouldRemove == true) {
      setState(() {
        widget.totalCartItems = 0;
        widget.items.removeAt(index);
        widget.clearCart();
      });

      return true;
    }
    return false;
  }

  Future<bool> confirmAndClear() async {
    bool shouldRemove = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Clear'),
          content:
              const Text('Are you sure you want to clear items from the list?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel removal
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm removal
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (shouldRemove == true) {
      setState(() {
        widget.totalCartItems = 0;
        widget.items.clear();
      });

      return true;
    }
    return false;
  }

  Future<void> transaction(
      String paymnetid,
      int posid,
      String employeeid,
      String total,
      String change,
      String cashtender,
      String status,
      String items) async {
    try {
      ResponseModel res = await salesAPI.salesTransaction(paymnetid, posid,
          employeeid, total, change, cashtender, json.encode(items));

      if (res.status == 200) {
        await printerReceipt(double.parse(cashtender), double.parse(change));
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Success'),
                  content: Text(
                      'Transaction Successful\n\nTotal: $total\nCash Tender: $cashtender\nChange: $change'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: const Text('OK'))
                  ],
                ));
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

  Future<void> checkout() async {
    try {
      final dynamic paymentJson =
          await helper.jsonListToFileReadAndroid('payment.json');
      List<PaymentModel> payments = [];
      paymentJson.forEach((p) {
        payments.add(PaymentModel.fromJson(p));
      });
      final List<Widget> paymentList = List<Widget>.generate(
        payments.length,
        (int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 50,
              width: 100,
              child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                                'Payment ${helper.formatAsCurrency(total)}'),
                            content: TextField(
                              controller: cashtenderController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [CurrencyInputFormatter()],
                              onChanged: (value) {
                                // Remove currency symbols and commas to get the numeric value
                                String numericValue = value.replaceAll(
                                  RegExp('[,]'),
                                  '',
                                );

                                setState(() {
                                  cashtender =
                                      double.tryParse(numericValue) ?? 0;
                                  print(cashtender);
                                });
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Amount',
                              ),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Back')),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      List<Map<String, dynamic>> items = [];
                                      change = cashtender - total;

                                      widget.items.forEach((i) {
                                        items.add({
                                          'id': i.id,
                                          'name': i.name,
                                          'price': i.price,
                                          'quantity': i.quantity
                                        });
                                      });

                                      print(total);

                                      transaction(
                                          payments[index].id.toString(),
                                          widget.posid,
                                          widget.employeeid,
                                          total.toString(),
                                          change.toString(),
                                          cashtender.toString(),
                                          'SOLD',
                                          jsonEncode(items));
                                    });
                                  },
                                  child: const Text('Pay'))
                            ],
                          );
                        });
                  },
                  child: Text(payments[index].name)),
            ),
          );
        },
      );

      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Payment Method',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: paymentList,
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'))
              ],
            );
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

  void GetTotal() {
    total = 0;
    subtotal = 0;
    widget.items.forEach((i) {
      setState(() {
        total += double.parse('${i.price * i.quantity}');
      });
    });
  }

  void printerOrder() async {
    double total = 0;

    iminPrinter.printColumnsText(cols: [
      ColumnMaker(
        text: 'Order List',
        fontSize: 48,
        align: IminPrintAlign.center,
        width: 12,
      ),
    ]);

    iminPrinter.printColumnsText(cols: [
      ColumnMaker(
        text: '------------------------------------------------------',
        fontSize: 26,
        align: IminPrintAlign.center,
        width: 12,
      ),
    ]);

    iminPrinter.printColumnsText(cols: [
      ColumnMaker(
        text: 'Items',
        fontSize: 26,
        align: IminPrintAlign.left,
        width: 7,
      ),
      ColumnMaker(
          text: 'Subt ', fontSize: 26, align: IminPrintAlign.right, width: 5)
    ]);
    iminPrinter.printColumnsText(cols: [
      ColumnMaker(
        text: '------------------------------------------------------',
        fontSize: 26,
        align: IminPrintAlign.center,
        width: 12,
      ),
    ]);
    for (var i in widget.items) {
      total += i.price * i.quantity;
      iminPrinter.printColumnsText(cols: [
        ColumnMaker(
            text: i.name, fontSize: 26, align: IminPrintAlign.left, width: 7),
        ColumnMaker(
            text: '${i.quantity}',
            fontSize: 26,
            align: IminPrintAlign.right,
            width: 5)
      ]);
    }

    iminPrinter.printAndFeedPaper(100);
  }

  Future<void> printerReceipt(double cashtender, double change) async {
    double total = 0;

    await iminPrinter.printColumnsText(cols: [
      ColumnMaker(
        text: 'Nava`s Kitchen',
        fontSize: 48,
        align: IminPrintAlign.center,
        width: 12,
      ),
    ]);

    await iminPrinter.printColumnsText(cols: [
      ColumnMaker(
        text: '------------------------------------------------------',
        fontSize: 26,
        align: IminPrintAlign.center,
        width: 12,
      ),
    ]);

    await iminPrinter.printColumnsText(cols: [
      ColumnMaker(
        text: 'Items',
        fontSize: 26,
        align: IminPrintAlign.left,
        width: 7,
      ),
      ColumnMaker(
          text: 'Subt ', fontSize: 26, align: IminPrintAlign.right, width: 5)
    ]);
    await iminPrinter.printColumnsText(cols: [
      ColumnMaker(
        text: '------------------------------------------------------',
        fontSize: 26,
        align: IminPrintAlign.center,
        width: 12,
      ),
    ]);
    for (var i in widget.items) {
      total += i.price * i.quantity;
      await iminPrinter.printColumnsText(cols: [
        ColumnMaker(
            text: '${i.name} ${i.price}x${i.quantity}',
            fontSize: 26,
            align: IminPrintAlign.left,
            width: 7),
        ColumnMaker(
            text: '${i.price * i.quantity} ',
            fontSize: 26,
            align: IminPrintAlign.right,
            width: 5)
      ]);
    }
    await iminPrinter.printColumnsText(cols: [
      ColumnMaker(
        text: '------------------------------------------------------',
        fontSize: 26,
        align: IminPrintAlign.center,
        width: 12,
      ),
    ]);

    await iminPrinter.printColumnsText(cols: [
      ColumnMaker(
          text: 'Total', fontSize: 26, align: IminPrintAlign.left, width: 7),
      ColumnMaker(
          text: '${helper.formatAsCurrency(total)}',
          fontSize: 26,
          align: IminPrintAlign.right,
          width: 5)
    ]);

    await iminPrinter.printColumnsText(cols: [
      ColumnMaker(
          text: 'Cash Tender',
          fontSize: 26,
          align: IminPrintAlign.left,
          width: 7),
      ColumnMaker(
          text: '${helper.formatAsCurrency(cashtender)}',
          fontSize: 26,
          align: IminPrintAlign.right,
          width: 5)
    ]);

    await iminPrinter.printColumnsText(cols: [
      ColumnMaker(
          text: 'Change', fontSize: 26, align: IminPrintAlign.left, width: 7),
      ColumnMaker(
          text: '${helper.formatAsCurrency(change)}',
          fontSize: 26,
          align: IminPrintAlign.right,
          width: 5)
    ]);

    iminPrinter.printAndFeedPaper(100);
  }

  @override
  Widget build(BuildContext context) {
    GetTotal();
    final List<Widget> cartitems = List<Widget>.generate(
      widget.items.length,
      (int index) {
        setState(() {
          subtotal = double.parse(
              '${widget.items[index].price * widget.items[index].quantity}');
          cartcount = widget.totalCartItems;
        });

        return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                    title: Text(
                      widget.items[index].name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        ' ${widget.items[index].price} x ${widget.items[index].quantity}\nTotal: ${helper.formatAsCurrency(subtotal)}'),
                    trailing: SizedBox(
                      width: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  widget.updateCart(index,
                                      widget.items[index].quantity + 1, 1);
                                });
                              },
                              icon: const Icon(Icons.add)),
                          SizedBox(
                              width: 40,
                              child: TextField(
                                onSubmitted: (value) {
                                  setState(() {
                                    int? newValue = int.tryParse(value) ?? 0;
                                    int cartNewValue = 0;

                                    cartNewValue =
                                        newValue - widget.items[index].quantity;

                                    widget.updateCart(
                                        index, newValue, cartNewValue);
                                  });
                                },
                                style: TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                                controller: TextEditingController(
                                    text: widget.items[index].quantity
                                        .toString()),
                                keyboardType: TextInputType.number,
                              )),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  int currentQuantity =
                                      widget.items[index].quantity - 1;
                                  widget.updateCart(index, currentQuantity, -1);

                                  if (currentQuantity < 1) {
                                    confirmAndRemove(index);
                                  }
                                });
                              },
                              icon: const Icon(Icons.remove)),
                        ],
                      ),
                    ))));
      },
    );

    print(total);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Total: ${helper.formatAsCurrency(total)}'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.rotate_left),
              onPressed: () {
                confirmAndClear();
              },
            ),
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: () {
                printerOrder();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: (widget.totalCartItems < 1)
                  ? [
                      const Text(
                        'Cart is empty',
                        style: TextStyle(
                            fontSize: 36, fontWeight: FontWeight.bold),
                      )
                    ]
                  : cartitems,
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: ElevatedButton(
              onPressed: () {
                checkout();
              },
              child: const Text('Checkout')),
        ),
      ),
    );
  }
}
