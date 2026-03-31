class ExerciseReferenceMedia {
  final String muscle;
  final String title;
  final String assetPath;
  final String note;

  const ExerciseReferenceMedia({
    required this.muscle,
    required this.title,
    required this.assetPath,
    required this.note,
  });
}

class ExerciseReferenceData {
  static const List<ExerciseReferenceMedia> library = [
    ExerciseReferenceMedia(
      muscle: 'Peito',
      title: 'Mapa de peito',
      assetPath: 'assets/images/muscle.png',
      note: 'Referencia visual geral para exercicios de peito.',
    ),
    ExerciseReferenceMedia(
      muscle: 'Ombros',
      title: 'Mapa de ombros',
      assetPath: 'assets/images/body.png',
      note: 'Referencia visual geral para ombros e parte superior.',
    ),
    ExerciseReferenceMedia(
      muscle: 'Costas',
      title: 'Mapa de costas',
      assetPath: 'assets/images/body.png',
      note: 'Referencia visual geral para costas.',
    ),
    ExerciseReferenceMedia(
      muscle: 'Biceps',
      title: 'Mapa de biceps',
      assetPath: 'assets/images/body.png',
      note: 'Referencia visual geral para biceps.',
    ),
    ExerciseReferenceMedia(
      muscle: 'Triceps',
      title: 'Mapa de triceps',
      assetPath: 'assets/images/body.png',
      note: 'Referencia visual geral para triceps.',
    ),
    ExerciseReferenceMedia(
      muscle: 'Pernas',
      title: 'Mapa de pernas',
      assetPath: 'assets/images/leg_1.jpg',
      note: 'Referencia visual geral para quadriceps e gluteos.',
    ),
    ExerciseReferenceMedia(
      muscle: 'Posterior',
      title: 'Mapa da cadeia posterior',
      assetPath: 'assets/images/leg_1.jpg',
      note: 'Referencia visual para posterior de coxa e gluteos.',
    ),
    ExerciseReferenceMedia(
      muscle: 'Panturrilhas',
      title: 'Mapa de panturrilhas',
      assetPath: 'assets/images/leg_1.jpg',
      note: 'Referencia visual para panturrilhas.',
    ),
    ExerciseReferenceMedia(
      muscle: 'Abdomen',
      title: 'Mapa de abdomen',
      assetPath: 'assets/images/body.png',
      note: 'Referencia visual para abdomen.',
    ),
    ExerciseReferenceMedia(
      muscle: 'Core',
      title: 'Mapa de core',
      assetPath: 'assets/images/body.png',
      note: 'Referencia visual para core e estabilidade.',
    ),
  ];

  static List<ExerciseReferenceMedia> forMuscle(String muscle) {
    return library.where((item) => item.muscle == muscle).toList();
  }
}
