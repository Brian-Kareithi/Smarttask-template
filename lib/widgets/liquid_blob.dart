import 'dart:math';
import 'package:flutter/material.dart';

class LiquidBlob extends StatefulWidget {
  final double height;
  final bool reverse;

  const LiquidBlob({super.key, this.height = 300, this.reverse = false});

  @override
  State<LiquidBlob> createState() => _LiquidBlobState();
}

class _LiquidBlobState extends State<LiquidBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _BlobPainter(
            animation: _controller.value,
            reverse: widget.reverse,
          ),
        );
      },
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double animation;
  final bool reverse;

  _BlobPainter({required this.animation, this.reverse = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF6C63FF).withValues(alpha: 0.3),
          const Color(0xFFFF6584).withValues(alpha: 0.2),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final wave = animation * 2 * 3.14159;
    final reverseWave = reverse ? -wave : wave;

    path.moveTo(0, size.height * 0.7);

    for (double i = 0; i <= size.width; i += 1) {
      final y = size.height * 0.7 +
          (size.height * 0.15) *
              (reverse ? 1 : -1) *
               (0.5 * (i / size.width) +
                  0.3 * (i / size.width) * sin(wave * 0.5) +
                  0.2 * sin(i / size.width * 3 + reverseWave));
      path.lineTo(i, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          const Color(0xFFFF6584).withValues(alpha: 0.2),
          const Color(0xFF6C63FF).withValues(alpha: 0.15),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.6);

    for (double i = 0; i <= size.width; i += 1) {
      final y = size.height * 0.6 +
          (size.height * 0.12) *
              (reverse ? -1 : 1) *
               (0.4 * (i / size.width) +
                  0.35 * sin(i / size.width * 2 + wave) +
                  0.25 * cos(i / size.width * 4 - reverseWave));
      path2.lineTo(i, y);
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_BlobPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
