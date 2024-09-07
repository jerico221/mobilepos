import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobilepos/model/apiresponce.dart';
import 'package:mobilepos/repository/config.dart';
import 'package:mobilepos/repository/helper.dart';

class ProductAPI {
  static final ProductAPI instance = ProductAPI._constructor();
  ProductAPI._constructor();

  final Helper helper = Helper.instance;
  final APIS config = APIS.instance;
  Future<ResponseModel> getProductActive() async {
    List<dynamic> api = [];
    api = await helper.jsonListToFileReadAndroid('domain.json');
    if (kDebugMode) {
      print(api[0]['domain']);
    }
    final url = Uri.parse('${api[0]['domain']}${APIS.productAPI}');
    final response = await http.get(url);

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {
      'msg': msg,
      'data': results,
      'status': status,
    };

    ResponseModel res = ResponseModel.fromJson(data);

    return res;
  }
}
