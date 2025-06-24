class WeeklyChallenge {
  final String id;
  final String title;
  final String description;
  final String type;
  final int targetValue;
  final int currentValue;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final String? badgeIcon;

  WeeklyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
    this.badgeIcon,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isCompleted': isCompleted,
      'badgeIcon': badgeIcon,
    };
  }

  factory WeeklyChallenge.fromJson(Map<String, dynamic> json) {
    return WeeklyChallenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      targetValue: json['targetValue'],
      currentValue: json['currentValue'] ?? 0,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isCompleted: json['isCompleted'] ?? false,
      badgeIcon: json['badgeIcon'],
    );
  }

  WeeklyChallenge copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    int? targetValue,
    int? currentValue,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
    String? badgeIcon,
  }) {
    return WeeklyChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      badgeIcon: badgeIcon ?? this.badgeIcon,
    );
  }

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
  
  bool get isActive => DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }
}

class ChallengeHistory {
  final String challengeId;
  final DateTime completedDate;
  final String badgeEarned;

  ChallengeHistory({
    required this.challengeId,
    required this.completedDate,
    required this.badgeEarned,
  });

  Map<String, dynamic> toJson() {
    return {
      'challengeId': challengeId,
      'completedDate': completedDate.toIso8601String(),
      'badgeEarned': badgeEarned,
    };
  }

  factory ChallengeHistory.fromJson(Map<String, dynamic> json) {
    return ChallengeHistory(
      challengeId: json['challengeId'],
      completedDate: DateTime.parse(json['completedDate']),
      badgeEarned: json['badgeEarned'],
    );
  }
}