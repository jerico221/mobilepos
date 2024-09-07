import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobilepos/model/apiresponce.dart';
import 'package:mobilepos/model/items.dart';
import 'package:mobilepos/repository/config.dart';
import 'package:mobilepos/repository/helper.dart';

class SalesAPI {
  static final SalesAPI instance = SalesAPI._constructor();
  SalesAPI._constructor();

  final Helper helper = Helper.instance;
  final APIS config = APIS.instance;
  Future<ResponseModel> salesTransaction(
      String paymnetid,
      int posid,
      String employeeid,
      String total,
      String change,
      String cashtender,
      String items) async {
    List<dynamic> api = [];
    api = await helper.jsonListToFileReadAndroid('domain.json');
    if (kDebugMode) {
      print(api[0]['domain']);
    }
    final url = Uri.parse('${api[0]['domain']}${APIS.salesAPI}');
    final response = await http.post(url, body: {
      'pos': posid.toString(),
      'details': items,
      'total': total,
      'paymenttype': paymnetid,
      'cashreceive': cashtender,
      'change': change,
      'cashier': employeeid
    });

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
