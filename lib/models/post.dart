// lib/models/post.dart

class Post {
  final String userName;
  final String content;
  final DateTime date;
  final String? group; // null si es feed general o grupo
  final String? avatar; // ruta local o “avatar:😊”
  final String? email;
  int likes;
  bool liked; // nuevo flag
  List<String> comments;

  Post({
    required this.userName,
    required this.content,
    required this.date,
    this.group,
    this.avatar,
    this.email,
    this.likes = 0,
    this.liked = false, // inicializa en false
    List<String>? comments,
  }) : comments = comments ?? [];

  Map<String, dynamic> toJson() => {
    'userName': userName,
    'content': content,
    'date': date.toIso8601String(),
    'group': group,
    'avatar': avatar,
    'email': email,
    'likes': likes,
    'liked': liked,
    'comments': comments,
  };

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    userName: json['userName'],
    content: json['content'],
    date: DateTime.parse(json['date']),
    group: json['group'],
    avatar: json['avatar'],
    email: json['email'],
    likes: json['likes'] ?? 0,
    liked: json['liked'] ?? false,
    comments: List<String>.from(json['comments'] ?? []),
  );
}
