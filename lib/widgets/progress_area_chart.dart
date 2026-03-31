import 'package:flutter/material.dart';

class ProgressAreaChart extends StatelessWidget {
  final List<Map<String, dynamic>> progress;
  final double height;

  const ProgressAreaChart({
    super.key,
    required this.progress,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    if (progress.isEmpty) {
      return Container(
        height: height,
        alignment: Alignment.center,
        child: const Text('Sem dados para o grafico'),
      );
    }

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _SingleAreaChartPainter(
          progress: progress.take(7).toList(),
          lineColor: const Color(0xFF36B5D8),
          textColor: Theme.of(context).colorScheme.onSurface,
          gridColor: Theme.of(context).dividerColor,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _SingleAreaChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> progress;
  final Color lineColor;
  final Color textColor;
  final Color gridColor;

  _SingleAreaChartPainter({
    required this.progress,
    required this.lineColor,
    required this.textColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 34.0;
    const rightPad = 8.0;
    const topPad = 12.0;
    const bottomPad = 24.0;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;
    if (chartWidth <= 0 || chartHeight <= 0 || progress.isEmpty) return;

    final values = progress
        .map((item) => (item['weight'] ?? 0).toDouble())
        .toList(growable: false);
    final maxValue = (values.reduce((a, b) => a > b ? a : b) + 1).toDouble();

    final gridPaint = Paint()
      ..color = gridColor.withOpacity(0.35)
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = topPad + (chartHeight / 3) * i;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        gridPaint,
      );
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < progress.length; i++) {
      final label = (progress[i]['title'] ?? '').toString();
      final x = leftPad +
          (progress.length == 1
              ? chartWidth / 2
              : (chartWidth / (progress.length - 1)) * i);

      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(color: textColor.withOpacity(0.75), fontSize: 10),
      );
      textPainter.layout(maxWidth: 40);
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - bottomPad + 6),
      );
    }

    final points = List.generate(progress.length, (index) {
      final x = leftPad +
          (progress.length == 1
              ? chartWidth / 2
              : (chartWidth / (progress.length - 1)) * index);
      final normalized = (values[index] / maxValue).clamp(0.0, 1.0).toDouble();
      final y = topPad + chartHeight - (chartHeight * normalized);
      return Offset(x, y);
    });

    if (points.length < 2) return;

    final fillPath = Path()..moveTo(points.first.dx, size.height - bottomPad);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(points.last.dx, size.height - bottomPad);
    fillPath.close();

    final fillPaint = Paint()
      ..color = lineColor.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SingleAreaChartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
