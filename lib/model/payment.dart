class PaymentModel {
  final int id;
  final String name;
  final String status;

  PaymentModel(
    this.id,
    this.name,
    this.status,
  );

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      json['id'],
      json['name'],
      json['status'],
    );
  }

  static List<PaymentModel> fromJsonList(json) {
    return json
        .map<PaymentModel>((item) => PaymentModel.fromJson(item))
        .toList();
  }
}
