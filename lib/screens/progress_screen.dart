// lib/screens/progress_screen.dart

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/user_prefs.dart';
// Asegúrate de que tu modelo User tenga `double weight`

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  double? _currentWeight;

  // Datos de ejemplo para historial
  final List<Map<String, dynamic>> _workouts = [
    {
      'date': '2024-06-04',
      'type': 'Pecho y Tríceps',
      'duration': 45,
      'calories': 320,
      'exercises': 8,
    },
    {
      'date': '2024-06-03',
      'type': 'Cardio HIIT',
      'duration': 30,
      'calories': 280,
      'exercises': 6,
    },
    {
      'date': '2024-06-02',
      'type': 'Espalda y Bíceps',
      'duration': 50,
      'calories': 350,
      'exercises': 9,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserWeight();
  }

  Future<void> _loadUserWeight() async {
    final user = await UserPrefs.loadUser();
    setState(() => _currentWeight = user?.weight);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi Progreso'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          // ignore: deprecated_member_use
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'Estadísticas'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSummaryTab(), _buildStatsTab(), _buildHistoryTab()],
      ),
    );
  }

  // -------------------
  // PESTAÑA RESUMEN
  // -------------------
  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primera fila de tarjetas
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Entrenamientos',
                  '12',
                  'Esta semana',
                  Icons.fitness_center,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Calorías',
                  '2,450',
                  'Quemadas',
                  Icons.local_fire_department,
                  AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Segunda fila de tarjetas
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Tiempo',
                  '8h 30m',
                  'Total',
                  Icons.timer,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Racha',
                  '7 días',
                  'Consecutivos',
                  Icons.flag,
                  AppColors.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Progreso semanal
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progreso Semanal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.trending_up, color: AppColors.success),
                  ],
                ),
                const SizedBox(height: 16),
                _buildWeeklyProgress(),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Objetivos del mes
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Objetivos del Mes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildGoalProgress('Entrenamientos', 12, 20),
                const SizedBox(height: 12),
                _buildGoalProgress('Calorías quemadas', 2450, 4000),
                const SizedBox(height: 12),
                _buildGoalProgress('Horas de ejercicio', 8.5, 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final completed = [true, true, false, true, true, false, true];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        return Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: completed[i] ? AppColors.success : AppColors.inputBorder,
                shape: BoxShape.circle,
              ),
              child: Icon(
                completed[i] ? Icons.check : Icons.close,
                size: 16,
                color: completed[i] ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              days[i],
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildGoalProgress(String title, double current, double target) {
    final progress = current / target;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(
              '${current.toStringAsFixed(current % 1 == 0 ? 0 : 1)}/'
              '${target.toStringAsFixed(target % 1 == 0 ? 0 : 1)}',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: AppColors.inputBorder,
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1 ? AppColors.success : AppColors.primary,
          ),
        ),
      ],
    );
  }

  // -------------------
  // PESTAÑA ESTADÍSTICAS
  // -------------------
  Widget _buildStatsTab() {
    if (_currentWeight == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Evolución de peso
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Evolución del Peso',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.show_chart,
                        size: 60,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gráfico de evolución',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Peso actual: ${_currentWeight!.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Entrenamientos por categoría
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Entrenamientos por Categoría',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildCategoryStats('Fuerza', 8, AppColors.primary),
                _buildCategoryStats('Cardio', 4, AppColors.error),
                _buildCategoryStats('Flexibilidad', 2, AppColors.success),
                _buildCategoryStats('Funcional', 3, AppColors.warning),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStats(String category, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(category)),
          Text(
            '$count entrenamientos',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // -------------------
  // PESTAÑA HISTORIAL
  // -------------------
  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _workouts.length,
      itemBuilder: (_, index) {
        final w = _workouts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.fitness_center, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      w['type'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      w['date'],
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildWorkoutStat(Icons.timer, '${w['duration']} min'),
                        const SizedBox(width: 16),
                        _buildWorkoutStat(
                          Icons.local_fire_department,
                          '${w['calories']} cal',
                        ),
                        const SizedBox(width: 16),
                        _buildWorkoutStat(
                          Icons.fitness_center,
                          '${w['exercises']} ej',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}
