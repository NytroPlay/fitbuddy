import '../models/motivational_tip.dart';

class MotivationalTipsData {
  static final List<MotivationalTip> tips = [
    // Hydration Tips
    MotivationalTip(
      id: 'hydration_001',
      title: 'Hidratación es clave',
      message: 'Recuerda beber agua antes, durante y después de entrenar. Tu cuerpo te lo agradecerá.',
      category: TipCategory.hydration,
      icon: '💧',
    ),
    MotivationalTip(
      id: 'hydration_002',
      title: 'Agua = Energía',
      message: 'Una buena hidratación mejora tu rendimiento y reduce la fatiga. ¡Mantén tu botella cerca!',
      category: TipCategory.hydration,
      icon: '🚰',
    ),

    // Motivation Tips
    MotivationalTip(
      id: 'motivation_001',
      title: 'Progreso, no perfección',
      message: '¡No tienes que ser perfecto, solo constante! Cada pequeño paso cuenta hacia tu meta.',
      category: TipCategory.motivation,
      icon: '💪',
    ),
    MotivationalTip(
      id: 'motivation_002',
      title: 'Celebra tus logros',
      message: 'Cada entrenamiento completado es una victoria. ¡Celebra tu progreso, por pequeño que sea!',
      category: TipCategory.motivation,
      icon: '🎉',
    ),
    MotivationalTip(
      id: 'motivation_003',
      title: 'Tu ritmo es perfecto',
      message: 'No te compares con otros. Tu único competidor eres tú mismo de ayer.',
      category: TipCategory.motivation,
      icon: '🌟',
    ),
    MotivationalTip(
      id: 'motivation_004',
      title: 'Cada día es una nueva oportunidad',
      message: 'Si ayer no fue tu mejor día, hoy puedes empezar de nuevo. ¡Tú puedes!',
      category: TipCategory.motivation,
      icon: '🌅',
    ),

    // Technique Tips
    MotivationalTip(
      id: 'technique_001',
      title: 'Calidad sobre cantidad',
      message: 'Es mejor hacer 5 repeticiones correctas que 15 mal hechas. La técnica es tu prioridad.',
      category: TipCategory.technique,
      icon: '🎯',
    ),
    MotivationalTip(
      id: 'technique_002',
      title: 'Respiración consciente',
      message: 'Inhala en la fase fácil del ejercicio, exhala en el esfuerzo. Tu respiración es tu aliada.',
      category: TipCategory.technique,
      icon: '🫁',
    ),
    MotivationalTip(
      id: 'technique_003',
      title: 'Postura correcta',
      message: 'Mantén la espalda recta y el core activo. Una buena postura previene lesiones.',
      category: TipCategory.technique,
      icon: '🧘',
    ),

    // Beginner Tips
    MotivationalTip(
      id: 'beginner_001',
      title: 'Comienza despacio',
      message: 'Tu cuerpo necesita tiempo para adaptarse. Empieza con rutinas cortas y ve aumentando gradualmente.',
      category: TipCategory.beginner,
      icon: '🐣',
    ),
    MotivationalTip(
      id: 'beginner_002',
      title: 'Escucha tu cuerpo',
      message: 'Si sientes dolor, para. Si sientes cansancio normal, continúa. Aprende la diferencia.',
      category: TipCategory.beginner,
      icon: '👂',
    ),
    MotivationalTip(
      id: 'beginner_003',
      title: 'La constancia es tu superpoder',
      message: '15 minutos diarios son mejor que 2 horas una vez por semana. ¡La constancia transforma!',
      category: TipCategory.beginner,
      icon: '⚡',
    ),

    // Recovery Tips
    MotivationalTip(
      id: 'recovery_001',
      title: 'El descanso es parte del entrenamiento',
      message: 'Tus músculos crecen cuando descansan, no cuando entrenan. Programa días de recuperación.',
      category: TipCategory.recovery,
      icon: '😴',
    ),
    MotivationalTip(
      id: 'recovery_002',
      title: 'Estiramiento post-entrenamiento',
      message: 'Dedica 5-10 minutos a estirar después de entrenar. Tu flexibilidad y recuperación mejorarán.',
      category: TipCategory.recovery,
      icon: '🤸',
    ),

    // Nutrition Tips
    MotivationalTip(
      id: 'nutrition_001',
      title: 'Combustible para tu motor',
      message: 'Come algo ligero 30-60 minutos antes de entrenar. Tu cuerpo necesita energía para rendir.',
      category: TipCategory.nutrition,
      icon: '🍎',
    ),
    MotivationalTip(
      id: 'nutrition_002',
      title: 'Proteína para recuperar',
      message: 'Después del entrenamiento, incluye proteína en tu comida. Ayuda a reparar y fortalecer tus músculos.',
      category: TipCategory.nutrition,
      icon: '🥗',
    ),

    // Mindset Tips
    MotivationalTip(
      id: 'mindset_001',
      title: 'Disfruta el proceso',
      message: 'No solo te enfoques en el destino. Disfruta cada entrenamiento, cada mejora, cada desafío.',
      category: TipCategory.mindset,
      icon: '😊',
    ),
    MotivationalTip(
      id: 'mindset_002',
      title: 'Paciencia contigo mismo',
      message: 'Los cambios reales toman tiempo. Sé paciente y bondadoso contigo mismo en este proceso.',
      category: TipCategory.mindset,
      icon: '🌱',
    ),
    MotivationalTip(
      id: 'mindset_003',
      title: 'Tu mentalidad lo es todo',
      message: 'Cree en ti mismo. Si piensas que puedes, ya estás a medio camino de lograrlo.',
      category: TipCategory.mindset,
      icon: '🧠',
    ),

    // Additional Beginner-Friendly Tips
    MotivationalTip(
      id: 'beginner_004',
      title: 'Equipamiento básico',
      message: 'No necesitas equipo costoso para empezar. Tu peso corporal es suficiente para muchos ejercicios.',
      category: TipCategory.beginner,
      icon: '🏠',
    ),
    MotivationalTip(
      id: 'beginner_005',
      title: 'Encuentra tu momento',
      message: 'Algunas personas rinden mejor en la mañana, otras en la tarde. Descubre cuál es tu mejor momento.',
      category: TipCategory.beginner,
      icon: '⏰',
    ),
  ];

  static List<MotivationalTip> getBeginnerTips() {
    return tips.where((tip) => tip.isForBeginners).toList();
  }

  static List<MotivationalTip> getTipsByCategory(TipCategory category) {
    return tips.where((tip) => tip.category == category).toList();
  }

  static MotivationalTip? getTipById(String id) {
    try {
      return tips.firstWhere((tip) => tip.id == id);
    } catch (_) {
      return null;
    }
  }
}