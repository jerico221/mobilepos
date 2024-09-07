class ResponseModel {
  final String message;
  final dynamic data;
  final int status;

  ResponseModel(this.message, this.data, this.status);
  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      json['msg'],
      json['data'],
      json['status'],
    );
  }
}
