enum TipCategory {
  hydration,
  motivation,
  technique,
  nutrition,
  recovery,
  mindset,
  beginner,
}

class MotivationalTip {
  final String id;
  final String title;
  final String message;
  final TipCategory category;
  final String icon;
  final bool isForBeginners;

  MotivationalTip({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.icon,
    this.isForBeginners = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'category': category.name,
      'icon': icon,
      'isForBeginners': isForBeginners,
    };
  }

  factory MotivationalTip.fromJson(Map<String, dynamic> json) {
    return MotivationalTip(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      category: TipCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TipCategory.motivation,
      ),
      icon: json['icon'],
      isForBeginners: json['isForBeginners'] ?? true,
    );
  }
}