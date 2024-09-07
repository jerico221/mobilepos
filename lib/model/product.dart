class ProductModel {
  final int id;
  final int name;
  final int image;
  final String price;
  final String category;
  final int isinventory;
  final String status;

  ProductModel(
    this.id,
    this.name,
    this.image,
    this.price,
    this.category,
    this.status,
    this.isinventory,
  );
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      json['id'],
      json['name'],
      json['image'],
      json['price'],
      json['category'],
      json['isinventory'],
      json['status'],
    );
  }
}
