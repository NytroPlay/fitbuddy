import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/exercise.dart';
import '../utils/app_theme.dart';

class ExecuteRoutineScreen extends StatefulWidget {
  final String routineName;
  final List<Exercise> exercises;
  final void Function(int completed, int total)? onFinish;

  const ExecuteRoutineScreen({
    super.key,
    required this.routineName,
    required this.exercises,
    this.onFinish,
  });

  @override
  State<ExecuteRoutineScreen> createState() => _ExecuteRoutineScreenState();
}

class _ExecuteRoutineScreenState extends State<ExecuteRoutineScreen> {
  late List<bool> _completed;
  late List<TextEditingController> _repsControllers;
  late List<TextEditingController> _weightControllers;

  @override
  void initState() {
    super.initState();
    _completed = List.generate(widget.exercises.length, (_) => false);
    _repsControllers = List.generate(
      widget.exercises.length,
      (_) => TextEditingController(),
    );
    _weightControllers = List.generate(
      widget.exercises.length,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var c in _repsControllers) {
      c.dispose();
    }
    for (var c in _weightControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _finishRoutine() {
    final completados = _completed.where((c) => c).length;
    widget.onFinish?.call(completados, widget.exercises.length);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('¡Rutina completada!'),
        content: Text(
          'Completaste $completados de ${widget.exercises.length} ejercicios.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el dialog
              Navigator.pop(context); // Vuelve a la pantalla anterior
            },
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.exercises.length;
    final completados = _completed.where((c) => c).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routineName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Progreso visual
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : completados / total,
                    // ignore: deprecated_member_use
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    color: AppColors.success,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  '$completados/$total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: widget.exercises.length,
              itemBuilder: (context, index) {
                final exercise = widget.exercises[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Animación Lottie con fondo decorativo
                        if (exercise.lottieAsset != null) ...[
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    // ignore: deprecated_member_use
                                    AppColors.primary.withOpacity(0.15),
                                    Colors.white,
                                  ],
                                ),
                              ),
                              padding: EdgeInsets.all(16),
                              child: Lottie.asset(
                                exercise.lottieAsset!,
                                height: 140,
                                repeat: true,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.fitness_center,
                                      size: 100,
                                      color: Colors.grey,
                                    ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                        // Nombre y grupo muscular
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                exercise.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                exercise.muscleGroup,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Checkbox y descripción
                        Row(
                          children: [
                            Checkbox(
                              value: _completed[index],
                              onChanged: (val) {
                                setState(() {
                                  _completed[index] = val ?? false;
                                });
                              },
                              activeColor: AppColors.success,
                            ),
                            Expanded(
                              child: Text(
                                exercise.description,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        // Inputs modernos
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _repsControllers[index],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Repeticiones',
                                  prefixIcon: Icon(Icons.repeat),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _weightControllers[index],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Peso (kg)',
                                  prefixIcon: Icon(Icons.fitness_center),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton.icon(
          icon: Icon(Icons.check_circle, size: 28),
          label: Text('Finalizar Rutina', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: Size(double.infinity, 56),
          ),
          onPressed: _finishRoutine,
        ),
      ),
    );
  }
}
