
import 'dart:math';
import 'package:flutter/material.dart';

class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Offset> _positions;
  late List<Color> _colors;
  final int _particleCount = 30;
  final List<Color> softColors = [
    Colors.pinkAccent,
    Colors.lightBlueAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
    Colors.purpleAccent,
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();

    final random = Random();
    _positions = List.generate(
        _particleCount,
        (_) => Offset(
              random.nextDouble(),
              random.nextDouble(),
            ));

    _colors = List.generate(
      _particleCount,
      (_) => softColors[random.nextInt(softColors.length)]
          .withOpacity(0.2), // apply transparency
    );
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
      builder: (_, __) {
        return CustomPaint(
          painter: ParticlePainter(_positions, _colors, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Offset> positions;
  final List<Color> colors;
  final double progress;
  final double waveAmplitude = 20;
  final double waveFrequency = 2 * pi;

  ParticlePainter(this.positions, this.colors, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < positions.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final base = positions[i];
      double dx = base.dx * size.width;

      double dy = base.dy * size.height - progress * size.height;
      if (dy < 0) dy += size.height;

      dx += sin((dy / size.height) * waveFrequency + i) * waveAmplitude;

      canvas.drawCircle(Offset(dx, dy), 6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
