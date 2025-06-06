class User {
  final String name;
  final String email;
  final String
  password; // En apps reales, nunca guardes contraseñas en texto plano
  final String? phone;
  final int? age;
  final double? height;
  final double? weight;

  User({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.age,
    this.height,
    this.weight,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'phone': phone,
    'age': age,
    'height': height,
    'weight': weight,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json['name'],
    email: json['email'],
    password: json['password'],
    phone: json['phone'],
    age: json['age'],
    height: (json['height'] as num?)?.toDouble(),
    weight: (json['weight'] as num?)?.toDouble(),
  );
}
