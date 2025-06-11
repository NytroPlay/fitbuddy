// ignore: library_prefixes
import 'package:fitbudd/utils/exercise_data.dart' as ExerciseData;
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/exercise.dart';
import 'execute_routine_screen.dart';
import '../models/routine_history.dart';
import 'history_screen.dart';
// ignore: depend_on_referenced_packages

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RoutinesScreenState createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen>
    with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Map<String, dynamic>> _routines = [
    {
      'name': 'Rutina de Pecho',
      'exercises': 8,
      'exerciseList': ExerciseData.exercises.take(8).toList(),
      'duration': '45 min',
      'difficulty': 'Intermedio',
      'icon': Icons.fitness_center,
      'color': AppColors.primary,
    },
    {
      'name': 'Cardio HIIT',
      'exercises': 6,
      'exerciseList': ExerciseData.exercises.take(6).toList(),
      'duration': '30 min',
      'difficulty': 'Avanzado',
      'icon': Icons.directions_run,
      'color': AppColors.secondary,
    },
    {
      'name': 'Yoga Matutino',
      'exercises': 10,
      'exerciseList': ExerciseData.exercises.take(10).toList(),
      'duration': '20 min',
      'difficulty': 'Principiante',
      'icon': Icons.self_improvement,
      'color': AppColors.accent,
    },
  ];

  final List<RoutineHistory> _history = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mis Rutinas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(history: _history),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Función de búsqueda próximamente'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header con estadísticas
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Rutinas',
                  '${_routines.length}',
                  Icons.fitness_center,
                ),
                _buildStatItem('Esta semana', _getNumberOfExercisesInTheWeek(), Icons.calendar_today),
                _buildStatItem('Tiempo total', _getTotalTime(), Icons.timer),
              ],
            ),
          ),

          // Lista de rutinas
          Expanded(
            child: AnimatedList(
              key: _listKey,
              initialItemCount: _routines.length,
              itemBuilder: (context, index, animation) {
                return _buildRoutineItem(_routines[index], index, animation);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateRoutineSheet(context);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text('Nueva Rutina'),
      ),
    );
  }

  String _getNumberOfExercisesInTheWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day - 7);
    final firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
    return _history.where((element) => !DateTime(element.date.year, element.date.month, element.date.day).isBefore(firstDayOfWeek)).length.toString();
  }

  String _getTotalTime() {
    return _history.fold<int>(0, (previousValue, element) {
      return previousValue + element.duration;
    }).toString();
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          // ignore: deprecated_member_use
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRoutineItem(
    Map<String, dynamic> routine,
    int index,
    Animation<double> animation,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween(
          begin: Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut)),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: routine['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(routine['icon'], color: routine['color'], size: 24),
          ),
          title: Text(
            routine['name'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.fitness_center,
                    '${routine['exercises']} ejercicios',
                  ),
                  SizedBox(width: 8),
                  _buildInfoChip(Icons.timer, routine['duration']),
                ],
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(
                    routine['difficulty'],
                    // ignore: deprecated_member_use
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  routine['difficulty'],
                  style: TextStyle(
                    color: _getDifficultyColor(routine['difficulty']),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditRoutineDialog(index);
              } else if (value == 'delete') {
                _deleteRoutine(index);
              } else if (value == 'start') {
                _startRoutine(routine);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'start',
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, color: AppColors.success),
                    SizedBox(width: 8),
                    Text('Iniciar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.info),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Eliminar'),
                  ],
                ),
              ),
            ],
          ),
          onTap: () => _startRoutine(routine),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Principiante':
        return AppColors.success;
      case 'Intermedio':
        return AppColors.warning;
      case 'Avanzado':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showEditRoutineDialog(int index) {
    final routine = _routines[index];
    final nameController = TextEditingController(text: routine['name']);
    final exercisesController = TextEditingController(
      text: routine['exercises'].toString(),
    );
    final durationController = TextEditingController(text: routine['duration']);
    String selectedDifficulty = routine['difficulty'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.edit, color: AppColors.info),
                  SizedBox(width: 8),
                  Text(
                    'Editar Rutina',
                    style: TextStyle(color: AppColors.info),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la rutina',
                        prefixIcon: Icon(Icons.title, color: AppColors.primary),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: exercisesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Número de ejercicios',
                        prefixIcon: Icon(
                          Icons.fitness_center,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: durationController,
                      decoration: InputDecoration(
                        labelText: 'Duración',
                        prefixIcon: Icon(Icons.timer, color: AppColors.primary),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedDifficulty,
                      decoration: InputDecoration(
                        labelText: 'Dificultad',
                        prefixIcon: Icon(
                          Icons.trending_up,
                          color: AppColors.primary,
                        ),
                      ),
                      items: ['Principiante', 'Intermedio', 'Avanzado'].map((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDifficulty = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      setState(() {
                        _routines[index] = {
                          'name': nameController.text,
                          'exercises':
                              int.tryParse(exercisesController.text) ??
                              routine['exercises'],
                          'exerciseList': routine['exerciseList'],
                          'duration': durationController.text,
                          'difficulty': selectedDifficulty,
                          'icon': routine['icon'],
                          'color': routine['color'],
                        };
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Rutina actualizada'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteRoutine(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: AppColors.error),
              SizedBox(width: 8),
              Text('Confirmar eliminación'),
            ],
          ),
          content: Text('¿Estás seguro de que quieres eliminar esta rutina?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final removedRoutine = _routines[index];
                setState(() {
                  _routines.removeAt(index);
                  _listKey.currentState?.removeItem(
                    index,
                    (context, animation) =>
                        _buildRoutineItem(removedRoutine, index, animation),
                  );
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rutina eliminada'),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _startRoutine(Map<String, dynamic> routine) {
    if (routine['exerciseList'] == null ||
        (routine['exerciseList'] as List).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Esta rutina no tiene ejercicios asignados.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExecuteRoutineScreen(
          routineName: routine['name'],
          exercises: List<Exercise>.from(routine['exerciseList']),
          onFinish: (completed, total) {
            setState(() {
              _history.add(
                RoutineHistory(
                  routineName: routine['name'],
                  date: DateTime.now(),
                  duration: _getRoutineDuration(routine['duration'], total, completed),
                  completedExercises: completed,
                  totalExercises: total,
                ),
              );
            });
          },
        ),
      ),
    );
  }

  int _getRoutineDuration(String duration, int total, int completed) {
    return ((int.parse(duration.split(' ')[0]) / total) * completed).round();
  }

  Future<void> _showCreateRoutineSheet(BuildContext context) async {
    final newRoutine = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: CreateRoutineSheet(),
        );
      },
    );

    if (newRoutine != null) {
      setState(() {
        _routines.add(newRoutine);
        _listKey.currentState?.insertItem(_routines.length - 1);
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rutina agregada exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

class CreateRoutineSheet extends StatefulWidget {
  const CreateRoutineSheet({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateRoutineSheetState createState() => _CreateRoutineSheetState();
}

class _CreateRoutineSheetState extends State<CreateRoutineSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String _selectedDifficulty = 'Principiante';
  List<Exercise> _selectedExercises = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Crear Nueva Rutina',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la rutina',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingresa un nombre';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: InputDecoration(
                labelText: 'Dificultad',
                border: OutlineInputBorder(),
              ),
              items: ['Principiante', 'Intermedio', 'Avanzado'].map((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDifficulty = newValue!;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseSelectionScreen(
                      selectedExercises: _selectedExercises,
                    ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _selectedExercises = result as List<Exercise>;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Seleccionar Ejercicios (${_selectedExercises.length} seleccionados)',
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newRoutine = {
                      'name': _nameController.text,
                      'exercises': _selectedExercises.length,
                      'exerciseList': _selectedExercises,
                      'duration': '0 min',
                      'difficulty': _selectedDifficulty,
                      'icon': Icons.fitness_center,
                      'color': AppColors.primary,
                    };
                    Navigator.pop(context, newRoutine);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
                child: Text('Crear Rutina'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseSelectionScreen extends StatefulWidget {
  final List<Exercise> selectedExercises;

  const ExerciseSelectionScreen({super.key, required this.selectedExercises});

  @override
  // ignore: library_private_types_in_public_api
  _ExerciseSelectionScreenState createState() =>
      _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen> {
  List<Exercise> _selectedExercises = [];

  @override
  void initState() {
    super.initState();
    _selectedExercises = List.from(widget.selectedExercises);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Ejercicios'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: ExerciseData.exercises.length,
        itemBuilder: (context, index) {
          final exercise = ExerciseData.exercises[index];
          final isSelected = _selectedExercises.contains(exercise);
          return CheckboxListTile(
            title: Text(exercise.name),
            subtitle: Text(exercise.muscleGroup),
            value: isSelected,
            onChanged: (bool? newValue) {
              setState(() {
                if (newValue == true) {
                  _selectedExercises.add(exercise);
                } else {
                  _selectedExercises.remove(exercise);
                }
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context, _selectedExercises);
        },
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        label: Text('Guardar Ejercicios'),
        icon: Icon(Icons.save),
      ),
    );
  }
}
