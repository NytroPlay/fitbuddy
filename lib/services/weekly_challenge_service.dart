import 'dart:math';
import '../models/weekly_challenge.dart';
import '../utils/user_prefs.dart';

class WeeklyChallengeService {
  static const List<Map<String, dynamic>> _challengeTemplates = [
    {
      'type': 'workout_frequency',
      'title': 'Entrena 3 veces esta semana',
      'description': 'Completa cualquier rutina 3 días de esta semana',
      'targetValue': 3,
      'badgeIcon': '💪',
    },
    {
      'type': 'routine_completion',
      'title': 'Completa 2 rutinas completas',
      'description': 'Termina 2 rutinas sin saltarte ejercicios',
      'targetValue': 2,
      'badgeIcon': '🎯',
    },
    {
      'type': 'consistency',
      'title': 'Entrena 5 días seguidos',
      'description': 'Mantén una racha de 5 días entrenando',
      'targetValue': 5,
      'badgeIcon': '🔥',
    },
    {
      'type': 'community_engagement',
      'title': 'Participa en la comunidad',
      'description': 'Haz 3 publicaciones o comentarios esta semana',
      'targetValue': 3,
      'badgeIcon': '🤝',
    },
    {
      'type': 'weekly_minutes',
      'title': 'Entrena 150 minutos',
      'description': 'Acumula 150 minutos de ejercicio esta semana',
      'targetValue': 150,
      'badgeIcon': '⏱️',
    },
  ];

  static Future<WeeklyChallenge> generateWeeklyChallenge() async {
    await UserPrefs.clearExpiredChallenge();
    
    final existing = await UserPrefs.loadCurrentChallenge();
    if (existing != null && existing.isActive) {
      return existing;
    }

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));

    final template = _challengeTemplates[Random().nextInt(_challengeTemplates.length)];
    
    final challenge = WeeklyChallenge(
      id: 'challenge_${startOfWeek.millisecondsSinceEpoch}',
      title: template['title'],
      description: template['description'],
      type: template['type'],
      targetValue: template['targetValue'],
      startDate: startOfWeek,
      endDate: endOfWeek,
      badgeIcon: template['badgeIcon'],
    );

    await UserPrefs.saveCurrentChallenge(challenge);
    return challenge;
  }

  static Future<void> updateChallengeProgress(String challengeType, {int increment = 1}) async {
    final challenge = await UserPrefs.loadCurrentChallenge();
    if (challenge == null || !challenge.isActive || challenge.type != challengeType) {
      return;
    }

    final newValue = challenge.currentValue + increment;
    await UserPrefs.updateChallengeProgress(challenge.id, newValue);
  }

  static Future<void> onWorkoutCompleted() async {
    await updateChallengeProgress('workout_frequency');
    await updateChallengeProgress('routine_completion');
  }

  static Future<void> onCommunityAction() async {
    await updateChallengeProgress('community_engagement');
  }

  static Future<void> onWorkoutMinutes(int minutes) async {
    await updateChallengeProgress('weekly_minutes', increment: minutes);
  }

  static Future<void> onConsistencyStreak() async {
    await updateChallengeProgress('consistency');
  }

  static Future<bool> isChallengeCompleted() async {
    final challenge = await UserPrefs.loadCurrentChallenge();
    return challenge?.isCompleted ?? false;
  }

  static Future<WeeklyChallenge?> getCurrentChallenge() async {
    await UserPrefs.clearExpiredChallenge();
    return await UserPrefs.loadCurrentChallenge();
  }

  static Future<List<ChallengeHistory>> getChallengeHistory() async {
    return await UserPrefs.loadChallengeHistory();
  }

  static Future<Map<String, int>> getChallengeStats() async {
    final history = await getChallengeHistory();
    final stats = <String, int>{};
    
    stats['totalCompleted'] = history.length;
    stats['thisMonth'] = history.where((h) {
      final now = DateTime.now();
      return h.completedDate.month == now.month && h.completedDate.year == now.year;
    }).length;
    
    final last30Days = DateTime.now().subtract(const Duration(days: 30));
    stats['last30Days'] = history.where((h) => h.completedDate.isAfter(last30Days)).length;
    
    return stats;
  }
}