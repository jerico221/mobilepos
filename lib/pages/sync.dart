import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobilepos/api/pos.dart';
import 'package:mobilepos/model/apiresponce.dart';
import 'package:mobilepos/pages/login.dart';
import 'package:mobilepos/repository/helper.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  final Helper helper = Helper.instance;
  final POSAPI posAPI = POSAPI.instance;
  final TextEditingController domainController = TextEditingController();
  final TextEditingController posIDController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    createJsonFiles();
    check();
    super.initState();
  }

  Future<void> createJsonFiles() async {
    await helper.createJsonFileAndroid('domain.json');
    await helper.createJsonFileAndroid('pos.json');
    await helper.createJsonFileAndroid('user.json');
    await helper.createJsonFileAndroid('product.json');
    await helper.createJsonFileAndroid('payment.json');
  }

  Future<void> sync() async {
    try {
      String domain = domainController.text;
      String posID = posIDController.text;

      if (domain.isEmpty || posID.isEmpty) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Error'),
                  content: const Text('Please enter domain and POS ID'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('OK'))
                  ],
                ));
      } else {
        List<Map<String, dynamic>> domainJson = [
          {
            "domain": domain,
          }
        ];

        await helper.jsonListToFileWriteAndroid(domainJson, 'domain.json');

        final ResponseModel res = await posAPI.getPOS(posID);
        if (res.status == 200) {
          if (kDebugMode) {
            print(res.data);
          }
          final dynamic data = res.data[0];
          List<Map<String, dynamic>> posJson = [
            {
              "id": data['id'],
              "name": data['name'],
              "serial": data['serial'],
              "status": data['status']
            }
          ];
          await helper.jsonListToFileWriteAndroid(posJson, 'pos.json');

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginPage()));
        }
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

  Future<void> check() async {
    try {
      List<dynamic> domainJson = await helper.jsonListToFileReadAndroid(
        'domain.json',
      );

      if (kDebugMode) {
        print(domainJson[0]['domain']);
      }

      if (domainJson.isEmpty || domainJson[0]['domain'] == null) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Error'),
                  content: const Text('Please enter domain'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('OK'))
                  ],
                ));
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: domainController,
              decoration: InputDecoration(
                labelText: 'Enter your domain',
              ),
              keyboardType: TextInputType.url,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: posIDController,
              decoration: InputDecoration(
                labelText: 'Enter POS ID',
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: 240,
                child: ElevatedButton(
                    onPressed: () {
                      sync();
                    },
                    child: Text('Sync'))),
          )
        ],
      ),
    ));
  }
}
