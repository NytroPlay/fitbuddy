import 'package:flutter/material.dart';

import '../utils/user_prefs.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Map<String, bool> _logros = {
    'primer_rutina': false,
    '7_dias_mes': false,
    'primer_comunidad': false,
    'primer_feedback': false,
  };

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final prefs = await UserPrefs.loadAchievements();
    setState(() {
      _logros = {..._logros, ...prefs}; // Mezcla defaults y guardados
    });
  }

  Widget _buildBadge({
    required String title,
    required bool unlocked,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      color: unlocked ? Colors.white : Colors.grey[200],
      child: ListTile(
        leading: Icon(
          icon,
          color: unlocked ? Colors.orange : Colors.grey,
          size: 36,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: unlocked ? Colors.black : Colors.grey,
          ),
        ),
        trailing: unlocked
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.lock_outline, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logros')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildBadge(
            title: 'Primer registro de rutina',
            unlocked: _logros['primer_rutina'] ?? false,
            icon: Icons.fitness_center,
          ),
          _buildBadge(
            title: '7 días de entrenamiento en un mes',
            unlocked: _logros['7_dias_mes'] ?? false,
            icon: Icons.calendar_month,
          ),
          _buildBadge(
            title: 'Primera participación en comunidad',
            unlocked: _logros['primer_comunidad'] ?? false,
            icon: Icons.people,
          ),
          _buildBadge(
            title: 'Primer feedback enviado',
            unlocked: _logros['primer_feedback'] ?? false,
            icon: Icons.feedback,
          ),
        ],
      ),
    );
  }
}
