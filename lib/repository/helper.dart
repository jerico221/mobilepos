import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class Helper {
  static final Helper instance = Helper._constructor();

  Helper._constructor();

  Future<void> jsonListToFileWriteAndroid(
      List<Map<String, dynamic>> jsonData, String filename) async {
    try {
      // Get the app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';

      // Write JSON data to file
      final file = File(filePath);

      await file.writeAsString(json.encode(jsonData));

      print('JSON data written to: $filePath');
    } catch (e) {
      print('Error writing JSON data: $e');
    }
  }

  Future<dynamic> jsonListToFileReadAndroid(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);

    print('JSON data read to: $filePath');

    // Check if the file exists
    if (!file.existsSync()) {
      print('File does not exist.');
    }

    // Read the contents of the file
    String jsonString = await file.readAsString();

    // Parse the JSON string into a Map
    dynamic jsonData = jsonDecode(jsonString);

    return jsonData;
  }

  Future<void> createJsonFileAndroid(filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      final File file = File(filePath);
      if (file.existsSync()) {
        return;
      }

      List<Map<String, dynamic>> jsonData = [
        {"key": "value"}
      ];
      String jsonString = jsonEncode(jsonData);
      file.writeAsStringSync(jsonString);

      if (kDebugMode) {
        print('JSON file created successfully at: $filePath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating JSON file: $e');
      }
    }
  }

  String formatAsCurrency(double value) {
    var formatCurrency = NumberFormat.currency(symbol: '', locale: 'en_US');
    return formatCurrency.format(value);
  }
}
