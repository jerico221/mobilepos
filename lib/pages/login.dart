import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobilepos/api/login.dart';
import 'package:mobilepos/model/apiresponce.dart';
import 'package:mobilepos/pages/home.dart';
import 'package:mobilepos/repository/helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Helper helper = Helper.instance;
  final LoginAPI loginAPI = LoginAPI.instance;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

  String employeeid = '';
  int posid = 0;
  void togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> login() async {
    try {
      String username = usernameController.text;
      String password = passwordController.text;

      if (username.isEmpty || password.isEmpty) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Error'),
                  content: const Text('Please enter username and password'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('OK'))
                  ],
                ));
      } else {
        ResponseModel res = await loginAPI.login(username, password);
        if (kDebugMode) {
          print(res.data);
        }
        if (res.data.isNotEmpty) {
          final dynamic data = res.data[0];
          List<dynamic> pos = [];
          List<Map<String, dynamic>> userJson = [
            {
              "id": data['id'],
              "employeeid": data['employeeid'],
              "access": data['access'],
              "username": data['username'],
              "password": data['password'],
              "status": data['status']
            }
          ];

          await helper.jsonListToFileWriteAndroid(userJson, 'user.json');
          pos = await helper.jsonListToFileReadAndroid('pos.json');

          setState(() {
            employeeid = data['employeeid'].toString();
            posid = pos[0]['id'];
          });

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        employeeid: employeeid,
                        posid: posid,
                      )));
        } else {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text('Error'),
                    content: const Text('Incorrect username or password'),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
                prefix: Icon(Icons.person),
                hintText: 'Enter your username',
              ),
              keyboardType: TextInputType.text,
              obscureText: false,
              autofocus: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: passwordController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                    onPressed: togglePasswordVisibility,
                    icon: Icon(_obscureText
                        ? Icons.visibility_off
                        : Icons.visibility)),
                border: OutlineInputBorder(),
                labelText: 'Password',
                prefixIcon: Icon(Icons.password),
                hintText: 'Enter your password',
              ),
              keyboardType: TextInputType.text,
              obscureText: _obscureText,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: 240,
                child: ElevatedButton.icon(
                  onPressed: () {
                    login();
                  },
                  label: Text('Login'),
                  icon: Icon(Icons.login),
                  iconAlignment: IconAlignment.end,
                )),
          )
        ],
      ),
    ));
  }
}
