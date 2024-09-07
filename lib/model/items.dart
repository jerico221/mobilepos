class ItemsModel {
  final int id;
  final String name;
  final double price;
  int quantity;

  ItemsModel(
    this.id,
    this.name,
    this.price,
    this.quantity,
  );

  factory ItemsModel.fromJson(Map<String, dynamic> json) {
    return ItemsModel(
        json['id'], json['name'], json['price'], json['quantity']);
  }

  static List<ItemsModel> fromJsonList(json) {
    return json.map<ItemsModel>((item) => ItemsModel.fromJson(item)).toList();
  }
}
