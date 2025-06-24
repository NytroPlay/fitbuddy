class RoutineHistory {
  final String routineName;
  final DateTime date;
  final int duration;
  final int completedExercises;
  final int totalExercises;

  RoutineHistory({
    required this.routineName,
    required this.date,
    required this.duration,
    required this.completedExercises,
    required this.totalExercises,
  });
}
