class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String image;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      image: json['image'],
    );
  }
}