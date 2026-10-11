import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Marca de AjíLimo: emblema circular (ají + lima + ola) y wordmark opcional.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 40, this.showWordmark = false, this.wordmarkColor});

  final double size;
  final bool showWordmark;
  final Color? wordmarkColor;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _Emblem(size: size),
          if (showWordmark) ...<Widget>[
            SizedBox(width: size * 0.28),
            Text(
              'AJÍ LIMO',
              style: TextStyle(
                fontSize: size * 0.55,
                fontWeight: FontWeight.w800,
                letterSpacing: size * 0.02,
                color: wordmarkColor ?? Palette.maroon,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Emblem extends StatelessWidget {
  const _Emblem({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _EmblemPainter(),
    );
  }
}

class _EmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final Offset c = Offset(s / 2, s / 2);
    final double r = s / 2;

    // Fondo crema con aro degradado (rojo → teal).
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFFBF3E6));
    canvas.drawCircle(
      c,
      r - s * 0.02,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.05
        ..shader = const LinearGradient(
          colors: <Color>[Palette.orange, Palette.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    // Ola (teal) en la parte inferior.
    final Path wave = Path()
      ..moveTo(s * 0.16, s * 0.66)
      ..quadraticBezierTo(s * 0.38, s * 0.52, s * 0.52, s * 0.70)
      ..quadraticBezierTo(s * 0.66, s * 0.88, s * 0.86, s * 0.72);
    canvas.drawPath(
      wave,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.06
        ..strokeCap = StrokeCap.round
        ..color = Palette.teal,
    );

    // Ají (rojo → naranja) con degradado.
    final Path chili = Path()
      ..moveTo(s * 0.44, s * 0.20)
      ..quadraticBezierTo(s * 0.74, s * 0.30, s * 0.66, s * 0.66)
      ..quadraticBezierTo(s * 0.60, s * 0.82, s * 0.46, s * 0.74)
      ..quadraticBezierTo(s * 0.30, s * 0.62, s * 0.36, s * 0.34)
      ..quadraticBezierTo(s * 0.40, s * 0.24, s * 0.44, s * 0.20)
      ..close();
    canvas.drawPath(
      chili,
      Paint()
        ..shader = const LinearGradient(
          colors: <Color>[Palette.orangeHover, Palette.orange, Color(0xFFF08A24)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, s, s)),
    );

    // Rabito verde del ají.
    final Path stem = Path()
      ..moveTo(s * 0.44, s * 0.22)
      ..quadraticBezierTo(s * 0.40, s * 0.10, s * 0.54, s * 0.12);
    canvas.drawPath(
      stem,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.06
        ..strokeCap = StrokeCap.round
        ..color = Palette.lime,
    );

    // Lima (círculo verde) arriba a la izquierda.
    final Offset lime = Offset(s * 0.24, s * 0.30);
    canvas.drawCircle(lime, s * 0.10, Paint()..color = Palette.lime);
    canvas.drawLine(
      lime,
      lime + Offset(s * 0.10, -s * 0.06),
      Paint()
        ..color = Colors.white
        ..strokeWidth = s * 0.02,
    );

    // Puntitos decorativos.
    final Paint dot = Paint()..color = Palette.orange.withValues(alpha: 0.6);
    canvas.drawCircle(Offset(s * 0.80, s * 0.34), s * 0.03, dot);
    canvas.drawCircle(Offset(s * 0.22, s * 0.62), s * 0.02, dot);

    // Leyenda circular sutil (marca de agua).
    final Path ring = Path()
      ..addArc(Rect.fromCircle(center: c, radius: r - s * 0.10), -math.pi * 0.15, math.pi * 0.3);
    canvas.drawPath(
      ring,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.025
        ..color = Palette.orange.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
