import 'package:flutter/material.dart';
import 'package:powerank/models/workout_post.dart';
import 'package:powerank/utils/workout_metrics.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkoutDetailsPage extends StatelessWidget {
  final WorkoutPost post;

  const WorkoutDetailsPage({super.key, required this.post});

  Future<void> _openVideoUrl(BuildContext context, String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);

    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O link do video esta invalido.')),
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nao foi possivel abrir o video.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = textColor.withOpacity(0.7);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do treino')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    post.user.isNotEmpty ? post.user[0].toUpperCase() : '?',
                    style: TextStyle(color: theme.colorScheme.onPrimary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.user,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        post.time,
                        style: TextStyle(color: mutedColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              post.title,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _DetailChip(
                  label: 'Exercicios',
                  value: '${post.exercises.length}',
                ),
                _DetailChip(
                  label: 'Peso total',
                  value: '${WorkoutMetrics.formatWeight(post.totalWeight)} kg',
                ),
                _DetailChip(label: 'Likes', value: '${post.likes}'),
              ],
            ),
            if (post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 22),
              Text(
                'Imagens',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.imageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        post.imageUrls[index],
                        width: MediaQuery.of(context).size.width * 0.72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: MediaQuery.of(context).size.width * 0.72,
                          color: Colors.black12,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (post.videoUrls.isNotEmpty) ...[
              const SizedBox(height: 22),
              Text(
                'Videos',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: theme.cardColor,
                child: Column(
                  children: List.generate(post.videoUrls.length, (index) {
                    return ListTile(
                      leading: Icon(
                        Icons.play_circle_outline,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        'Abrir video ${index + 1}',
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: Text(
                        'Toca para abrir o video fora do app',
                        style: TextStyle(color: mutedColor),
                      ),
                      trailing: Icon(
                        Icons.open_in_new,
                        color: theme.colorScheme.primary,
                      ),
                      onTap: () =>
                          _openVideoUrl(context, post.videoUrls[index]),
                    );
                  }),
                ),
              ),
            ],
            const SizedBox(height: 22),
            Text(
              'Exercicios do treino',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: theme.cardColor,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: post.exercises.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: theme.dividerColor.withOpacity(0.3),
                ),
                itemBuilder: (context, index) {
                  final exercise = post.exercises[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.12,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      (exercise['name'] ?? 'Exercicio').toString(),
                      style: TextStyle(color: textColor),
                    ),
                    subtitle: Text(
                      '${WorkoutMetrics.formatWeight(WorkoutMetrics.parseNumber(exercise['weight']))}kg - ${WorkoutMetrics.parseCount(exercise['sets'])} series - ${WorkoutMetrics.parseCount(exercise['reps'])} reps',
                      style: TextStyle(color: mutedColor),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final String value;

  const _DetailChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
