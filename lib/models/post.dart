class Post {
  final String userName;
  final String content;
  final DateTime date;
  final String? group; // null si es del feed general

  Post({
    required this.userName,
    required this.content,
    required this.date,
    this.group,
  });

  Map<String, dynamic> toJson() => {
    'userName': userName,
    'content': content,
    'date': date.toIso8601String(),
    'group': group,
  };

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    userName: json['userName'],
    content: json['content'],
    date: DateTime.parse(json['date']),
    group: json['group'],
  );
}
