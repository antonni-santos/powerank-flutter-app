class WorkoutMetrics {
  const WorkoutMetrics._();

  static double parseNumber(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final normalized = value.replaceAll(',', '.').trim();
      return double.tryParse(normalized) ?? 0;
    }
    return 0;
  }

  static int parseCount(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  static String formatWeight(double value) {
    if ((value - value.roundToDouble()).abs() < 0.001) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  static List<Map<String, dynamic>> parseExercises(dynamic raw) {
    if (raw is! Iterable) return [];

    return raw.map((entry) {
      if (entry is Map) {
        final data = Map<String, dynamic>.from(entry);
        return {
          'name': (data['name'] ?? '').toString(),
          'weight': parseNumber(data['weight']),
          'sets': parseCount(data['sets']),
          'reps': parseCount(data['reps']),
        };
      }

      return {'name': entry.toString(), 'weight': 0.0, 'sets': 0, 'reps': 0};
    }).toList();
  }

  static double calculateTotalWeightFromExercises(dynamic rawExercises) {
    final exercises = parseExercises(rawExercises);
    return exercises.fold<double>(
      0,
      (sum, exercise) => sum + parseNumber(exercise['weight']),
    );
  }

  static double resolveTotalWeight({
    required dynamic exercises,
    required dynamic storedTotalWeight,
  }) {
    final parsedExercises = parseExercises(exercises);
    if (parsedExercises.isNotEmpty) {
      return parsedExercises.fold<double>(
        0,
        (sum, exercise) => sum + parseNumber(exercise['weight']),
      );
    }
    return parseNumber(storedTotalWeight);
  }

  static int calculatePoints({
    required double totalWeight,
    required int checkIns,
    required int totalLikes,
  }) {
    return totalWeight.round() + (checkIns * 50) + (totalLikes * 10);
  }

  static String exerciseDisplay(dynamic exercise) {
    if (exercise is! Map) return exercise.toString();

    final data = Map<String, dynamic>.from(exercise);
    final name = (data['name'] ?? '').toString();
    final weight = formatWeight(parseNumber(data['weight']));
    final sets = parseCount(data['sets']);
    final reps = parseCount(data['reps']);

    return '$name - ${weight}kg x $sets x $reps';
  }
}
