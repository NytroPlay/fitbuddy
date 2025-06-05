class Exercise {
  final String name;
  final String muscleGroup;
  final String description;
  final String? lottieAsset; // <-- Nuevo campo

  Exercise({
    required this.name,
    required this.muscleGroup,
    required this.description,
    this.lottieAsset,
    required String imageUrl,
    required String difficulty,
  });
}
