class UserModel {
  String message;
  String email;
  String name;
  int role;
  String token;
  String? image;

  UserModel({
    required this.message,
    required this.email,
    required this.name,
    required this.role,
    required this.token,
    this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      message: json['message'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as int,
      token: json['token'] as String,
      image: json['image'] as String?,
    );
  }
}
