class APIS {
  static final APIS instance = APIS._constructor();
  APIS._constructor();

  static const String posAPI = '/pos/sync';
  static const String loginAPI = '/login/loginpos';
  static const String productAPI = '/product/load';
  static const String paymentAPI = '/payment/load';
  static const String salesAPI = '/sales/save';
}
