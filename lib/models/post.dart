class Post {
  final String userName;
  final String content;
  final DateTime date;

  Post({required this.userName, required this.content, required this.date});

  Map<String, dynamic> toJson() => {
    'userName': userName,
    'content': content,
    'date': date.toIso8601String(),
  };

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    userName: json['userName'],
    content: json['content'],
    date: DateTime.parse(json['date']),
  );
}
