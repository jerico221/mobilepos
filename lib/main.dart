import 'package:flutter/material.dart';
import 'package:mobilepos/pages/cart.dart';
import 'package:mobilepos/pages/home.dart';
import 'package:mobilepos/pages/login.dart';
import 'package:mobilepos/pages/sync.dart';
import 'package:mobilepos/repository/helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            foregroundColor: Colors.black,
            iconColor: Color(Colors.black.value),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.greenAccent,
          foregroundColor: Colors.black,
          iconTheme: IconThemeData(
            color: Color(Colors.black.value),
          ),
        ),
        useMaterial3: true,
      ),
      home: SyncPage(),
      initialRoute: '/',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => const HomePage(
              employeeid: '',
              posid: 0,
            ),
        '/cart': (context) => CartPage(
              items: [],
              updateCart: () {},
              clearCart: () {},
              totalCartItems: 0,
              posid: 0,
              employeeid: '',
            ),
      },
    );
  }
}
