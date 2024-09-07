class UserModel {
  final int id;
  final int employeeid;
  final int access;
  final String username;
  final String password;
  final String status;

  UserModel(
    this.id,
    this.employeeid,
    this.access,
    this.username,
    this.password,
    this.status,
  );
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      json['id'],
      json['employeeid'],
      json['access'],
      json['username'],
      json['password'],
      json['status'],
    );
  }
}
