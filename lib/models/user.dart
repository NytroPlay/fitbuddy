// lib/models/user.dart

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String? phone;
  final int? age;
  final double? height;
  final double? weight;
  final DateTime? createdAt;
  final String? avatar; // ← ahora genérico (URL o "avatar:😃")

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.age,
    this.height,
    this.weight,
    this.createdAt,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // si el backend usa "avatarUrl" o tu prefs usan "avatar", lo recogemos
    final av = json['avatar'] as String? ?? json['avatarUrl'] as String?;
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phone: json['phone'] as String?,
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
      height: json['height'] != null
          ? double.tryParse(json['height'].toString())
          : null,
      weight: json['weight'] != null
          ? double.tryParse(json['weight'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      avatar: av,
    );
  }

  get avatarUrl => null;

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'age': age,
      'height': height,
      'weight': weight,
      'createdAt': createdAt?.toIso8601String(),
    };
    // guardamos bajo "avatar" para que tus prefs y UI lo lean directamente
    if (avatar != null) {
      m['avatar'] = avatar;
    }
    return m;
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    int? age,
    double? height,
    double? weight,
    DateTime? createdAt,
    String? avatar,
    required String avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      createdAt: createdAt ?? this.createdAt,
      avatar: avatar ?? this.avatar,
    );
  }
}
