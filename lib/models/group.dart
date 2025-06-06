class Group {
  final String name;
  final String description;

  Group({required this.name, required this.description});

  Map<String, dynamic> toJson() => {'name': name, 'description': description};

  factory Group.fromJson(Map<String, dynamic> json) =>
      Group(name: json['name'], description: json['description']);
}
