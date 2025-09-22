import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../utils/switch_colors.dart';

/// Custom painter for network pattern background
class NetworkPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SwitchColors.switchBlue.withOpacity(0.1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = SwitchColors.switchBlue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Create network pattern
    const nodeCount = 15;
    final nodes = <Offset>[];

    // Generate random nodes
    final random = math.Random(42); // Fixed seed for consistent pattern
    for (int i = 0; i < nodeCount; i++) {
      nodes.add(Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      ));
    }

    // Draw connections between nearby nodes
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final distance = (nodes[i] - nodes[j]).distance;
        if (distance < 150) {
          final opacity = (150 - distance) / 150;
          paint.color = SwitchColors.switchBlue.withOpacity(opacity * 0.2);
          canvas.drawLine(nodes[i], nodes[j], paint);
        }
      }
    }

    // Draw nodes
    for (final node in nodes) {
      canvas.drawCircle(node, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
