class ExerciseSuggestionItem {
  final String name;
  final String muscle;
  final String assetPath;
  final String description;

  const ExerciseSuggestionItem({
    required this.name,
    required this.muscle,
    required this.assetPath,
    required this.description,
  });
}

class ExerciseSuggestions {
  static const List<ExerciseSuggestionItem> all = [
    ExerciseSuggestionItem(
      name: 'Supino reto',
      muscle: 'Peito',
      assetPath: 'assets/images/muscle.png',
      description: 'Trabalha peito, ombros anteriores e triceps.',
    ),
    ExerciseSuggestionItem(
      name: 'Supino inclinado',
      muscle: 'Peito',
      assetPath: 'assets/images/muscle.png',
      description: 'Foco maior na parte superior do peito.',
    ),
    ExerciseSuggestionItem(
      name: 'Crucifixo',
      muscle: 'Peito',
      assetPath: 'assets/images/muscle.png',
      description: 'Isolamento de peito com boa amplitude.',
    ),
    ExerciseSuggestionItem(
      name: 'Flexao',
      muscle: 'Peito',
      assetPath: 'assets/images/body.png',
      description: 'Exercicio corporal para peito, ombros e core.',
    ),
    ExerciseSuggestionItem(
      name: 'Desenvolvimento militar',
      muscle: 'Ombros',
      assetPath: 'assets/images/body.png',
      description: 'Exercicio base para deltoides e triceps.',
    ),
    ExerciseSuggestionItem(
      name: 'Elevacao lateral',
      muscle: 'Ombros',
      assetPath: 'assets/images/body.png',
      description: 'Foco na cabeca lateral do ombro.',
    ),
    ExerciseSuggestionItem(
      name: 'Elevacao frontal',
      muscle: 'Ombros',
      assetPath: 'assets/images/body.png',
      description: 'Ativa a parte frontal do ombro.',
    ),
    ExerciseSuggestionItem(
      name: 'Remada alta',
      muscle: 'Ombros',
      assetPath: 'assets/images/body.png',
      description: 'Mistura deltoides e trapezio.',
    ),
    ExerciseSuggestionItem(
      name: 'Remada curvada',
      muscle: 'Costas',
      assetPath: 'assets/images/body.png',
      description: 'Trabalha dorsais, romboides e lombar.',
    ),
    ExerciseSuggestionItem(
      name: 'Remada unilateral',
      muscle: 'Costas',
      assetPath: 'assets/images/body.png',
      description: 'Boa para equilibrio e foco em cada lado.',
    ),
    ExerciseSuggestionItem(
      name: 'Remada baixa',
      muscle: 'Costas',
      assetPath: 'assets/images/body.png',
      description: 'Trabalha espessura das costas.',
    ),
    ExerciseSuggestionItem(
      name: 'Puxada frontal',
      muscle: 'Costas',
      assetPath: 'assets/images/body.png',
      description: 'Exercicio classico para dorsais.',
    ),
    ExerciseSuggestionItem(
      name: 'Barra fixa',
      muscle: 'Costas',
      assetPath: 'assets/images/body.png',
      description: 'Exercicio de peso corporal para costas e biceps.',
    ),
    ExerciseSuggestionItem(
      name: 'Levantamento terra',
      muscle: 'Posterior',
      assetPath: 'assets/images/leg_1.jpg',
      description: 'Trabalha cadeia posterior inteira.',
    ),
    ExerciseSuggestionItem(
      name: 'Rosca direta',
      muscle: 'Biceps',
      assetPath: 'assets/images/body.png',
      description: 'Base para desenvolvimento de biceps.',
    ),
    ExerciseSuggestionItem(
      name: 'Rosca martelo',
      muscle: 'Biceps',
      assetPath: 'assets/images/body.png',
      description: 'Foco em braquial e antebraco.',
    ),
    ExerciseSuggestionItem(
      name: 'Rosca concentrada',
      muscle: 'Biceps',
      assetPath: 'assets/images/body.png',
      description: 'Isolamento de biceps.',
    ),
    ExerciseSuggestionItem(
      name: 'Triceps pulley',
      muscle: 'Triceps',
      assetPath: 'assets/images/body.png',
      description: 'Exercicio isolador de triceps.',
    ),
    ExerciseSuggestionItem(
      name: 'Triceps testa',
      muscle: 'Triceps',
      assetPath: 'assets/images/body.png',
      description: 'Boa carga e alongamento para triceps.',
    ),
    ExerciseSuggestionItem(
      name: 'Mergulho',
      muscle: 'Triceps',
      assetPath: 'assets/images/body.png',
      description: 'Pode focar triceps e peito conforme execucao.',
    ),
    ExerciseSuggestionItem(
      name: 'Agachamento livre',
      muscle: 'Pernas',
      assetPath: 'assets/images/leg_1.jpg',
      description: 'Exercicio base para quadriceps e gluteos.',
    ),
    ExerciseSuggestionItem(
      name: 'Leg press',
      muscle: 'Pernas',
      assetPath: 'assets/images/leg_1.jpg',
      description: 'Exercicio forte para quadriceps e gluteos.',
    ),
    ExerciseSuggestionItem(
      name: 'Cadeira extensora',
      muscle: 'Pernas',
      assetPath: 'assets/images/leg_1.jpg',
      description: 'Isolamento de quadriceps.',
    ),
    ExerciseSuggestionItem(
      name: 'Cadeira flexora',
      muscle: 'Posterior',
      assetPath: 'assets/images/leg_1.jpg',
      description: 'Isolamento da parte posterior da coxa.',
    ),
    ExerciseSuggestionItem(
      name: 'Passada',
      muscle: 'Pernas',
      assetPath: 'assets/images/leg_1.jpg',
      description: 'Boa para pernas e equilibrio.',
    ),
    ExerciseSuggestionItem(
      name: 'Stiff',
      muscle: 'Posterior',
      assetPath: 'assets/images/leg_1.jpg',
      description: 'Trabalha posterior e gluteos.',
    ),
    ExerciseSuggestionItem(
      name: 'Elevacao pelvica',
      muscle: 'Gluteos',
      assetPath: 'assets/images/leg_1.jpg',
      description: 'Foco principal em gluteos.',
    ),
    ExerciseSuggestionItem(
      name: 'Panturrilha em pe',
      muscle: 'Panturrilhas',
      assetPath: 'assets/images/leg_1.jpg',
      description: 'Trabalha gastrocnemio.',
    ),
    ExerciseSuggestionItem(
      name: 'Panturrilha sentado',
      muscle: 'Panturrilhas',
      assetPath: 'assets/images/leg_1.jpg',
      description: 'Trabalha mais soleo.',
    ),
    ExerciseSuggestionItem(
      name: 'Abdominal reto',
      muscle: 'Abdomen',
      assetPath: 'assets/images/body.png',
      description: 'Trabalha a regiao central do abdomen.',
    ),
    ExerciseSuggestionItem(
      name: 'Prancha',
      muscle: 'Core',
      assetPath: 'assets/images/body.png',
      description: 'Estabilidade de core e cintura escapular.',
    ),
    ExerciseSuggestionItem(
      name: 'Abdominal infra',
      muscle: 'Abdomen',
      assetPath: 'assets/images/body.png',
      description: 'Foco na parte inferior do abdomen.',
    ),
  ];

  static List<ExerciseSuggestionItem> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    return all.where((item) {
      return item.name.toLowerCase().contains(q) ||
          item.muscle.toLowerCase().contains(q);
    }).take(8).toList();
  }

  static ExerciseSuggestionItem? exactMatch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return null;

    for (final item in all) {
      if (item.name.toLowerCase() == q) {
        return item;
      }
    }
    return null;
  }
}
