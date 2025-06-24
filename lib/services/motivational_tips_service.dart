import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/motivational_tip.dart';
import '../data/motivational_tips_data.dart';

class MotivationalTipsService {
  static const String _keyLastTipDate = 'last_tip_date';
  static const String _keyDailyTipId = 'daily_tip_id';
  static const String _keyDismissedTips = 'dismissed_tips';
  static const String _keyTipPreferences = 'tip_preferences';

  static Future<MotivationalTip?> getDailyTip() async {
    final today = DateTime.now();
    final todayString = _formatDate(today);
    
    final prefs = await SharedPreferences.getInstance();
    final lastTipDate = prefs.getString(_keyLastTipDate);
    final savedTipId = prefs.getString(_keyDailyTipId);

    // If it's the same day and we have a saved tip, return it
    if (lastTipDate == todayString && savedTipId != null) {
      final tip = MotivationalTipsData.getTipById(savedTipId);
      if (tip != null) {
        // Check if tip was dismissed today
        final dismissed = await _wasTipDismissedToday(tip.id);
        return dismissed ? null : tip;
      }
    }

    // Generate new tip for today
    final newTip = await _selectTipForToday();
    if (newTip != null) {
      await prefs.setString(_keyLastTipDate, todayString);
      await prefs.setString(_keyDailyTipId, newTip.id);
    }

    return newTip;
  }

  static Future<MotivationalTip?> getRandomTip({TipCategory? category}) async {
    final tips = category != null 
        ? MotivationalTipsData.getTipsByCategory(category)
        : MotivationalTipsData.getBeginnerTips();

    if (tips.isEmpty) return null;

    final random = Random();
    return tips[random.nextInt(tips.length)];
  }

  static Future<MotivationalTip?> getPostWorkoutTip() async {
    // Focus on recovery, motivation, and achievement tips after workout
    final categories = [
      TipCategory.recovery,
      TipCategory.motivation,
      TipCategory.mindset,
    ];
    
    final category = categories[Random().nextInt(categories.length)];
    return getRandomTip(category: category);
  }

  static Future<void> dismissTip(String tipId) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _formatDate(DateTime.now());
    final dismissedKey = '${_keyDismissedTips}_$today';
    
    final dismissedList = prefs.getStringList(dismissedKey) ?? [];
    if (!dismissedList.contains(tipId)) {
      dismissedList.add(tipId);
      await prefs.setStringList(dismissedKey, dismissedList);
    }
  }

  static Future<bool> _wasTipDismissedToday(String tipId) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _formatDate(DateTime.now());
    final dismissedKey = '${_keyDismissedTips}_$today';
    
    final dismissedList = prefs.getStringList(dismissedKey) ?? [];
    return dismissedList.contains(tipId);
  }

  static Future<MotivationalTip?> _selectTipForToday() async {
    final today = DateTime.now();
    final tips = MotivationalTipsData.getBeginnerTips();
    
    if (tips.isEmpty) return null;

    // Use date as seed for consistent daily selection
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final random = Random(seed);
    
    // Get recently shown tips to avoid repetition
    final recentTips = await _getRecentlyShownTips();
    final availableTips = tips.where((tip) => !recentTips.contains(tip.id)).toList();
    
    // If all tips have been shown recently, reset and use all tips
    final tipsToChooseFrom = availableTips.isNotEmpty ? availableTips : tips;
    
    final selectedTip = tipsToChooseFrom[random.nextInt(tipsToChooseFrom.length)];
    
    // Track this tip as shown
    await _addToRecentlyShown(selectedTip.id);
    
    return selectedTip;
  }

  static Future<List<String>> _getRecentlyShownTips() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recently_shown_tips') ?? [];
  }

  static Future<void> _addToRecentlyShown(String tipId) async {
    final prefs = await SharedPreferences.getInstance();
    final recentTips = await _getRecentlyShownTips();
    
    recentTips.add(tipId);
    
    // Keep only last 7 tips to avoid excessive repetition
    if (recentTips.length > 7) {
      recentTips.removeAt(0);
    }
    
    await prefs.setStringList('recently_shown_tips', recentTips);
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static Future<Map<String, bool>> getTipPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsString = prefs.getString(_keyTipPreferences);
    if (prefsString == null) {
      return {
        'showDailyTips': true,
        'showPostWorkoutTips': true,
        'showBeginnerTips': true,
      };
    }
    
    final Map<String, dynamic> decoded = Map<String, dynamic>.from(
      Uri.splitQueryString(prefsString)
    );
    return decoded.map((k, v) => MapEntry(k, v == 'true'));
  }

  static Future<void> updateTipPreferences(Map<String, bool> preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = preferences.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    await prefs.setString(_keyTipPreferences, encoded);
  }

  // Clean up old dismissed tips (call this periodically)
  static Future<void> cleanupOldDismissedTips() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    final today = DateTime.now();
    final cutoffDate = today.subtract(const Duration(days: 7));
    
    for (final key in allKeys) {
      if (key.startsWith(_keyDismissedTips)) {
        final dateString = key.split('_').last;
        try {
          final date = DateTime.parse(dateString);
          if (date.isBefore(cutoffDate)) {
            await prefs.remove(key);
          }
        } catch (_) {
          // Invalid date format, remove key
          await prefs.remove(key);
        }
      }
    }
  }
}