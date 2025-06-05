import 'package:flutter/material.dart';
import '../models/routine_history.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  final List<RoutineHistory> history;

  const HistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Rutinas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: history.isEmpty
          ? Center(child: Text('Aún no tienes rutinas completadas.'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item =
                    history[history.length - 1 - index]; // Más reciente arriba
                return ListTile(
                  leading: Icon(Icons.history, color: AppColors.primary),
                  title: Text(item.routineName),
                  subtitle: Text(
                    '${DateFormat('dd/MM/yyyy – HH:mm').format(item.date)}\n'
                    'Ejercicios completados: ${item.completedExercises}/${item.totalExercises}',
                  ),
                  isThreeLine: true,
                );
              },
            ),
    );
  }
}
