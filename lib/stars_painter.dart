import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class StarsPainter extends CustomPainter {
  final Paint _starsPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  final Gradient _gradient = new RadialGradient(
    colors: <Color>[Colors.white, Colors.transparent],
  );

  final DateTime date;
  final Random random;
  final int starCount;
  Offset fallenPoint;
  final double superNovaExplodeRadius;
  final Offset superNovaPoint;

  StarsPainter({
    @required this.date,
    @required this.random,
    @required this.fallenPoint,
    @required this.starCount,
    @required this.superNovaExplodeRadius,
    @required this.superNovaPoint
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fallenPoint != null) {
      _fall(canvas, size);
    }
    if (superNovaPoint != null) {
      _superNova(canvas);
    }
    for (int i = 1; i < starCount; i++) {
      _drawRandomStar(canvas, size, random, random);
    }
  }

  void _drawRandomStar(Canvas canvas, Size size, Random positionRandom, Random radiusRandom) {
    final point = Offset(positionRandom.nextDouble() * size.width, positionRandom.nextDouble() * size.height);
    final radius = radiusRandom.nextInt(7);
    _drawStar(canvas, point, radius.toDouble());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  void _fall(Canvas canvas, Size size) {
    _drawStar(canvas, fallenPoint, 4);
  }

  void _drawStar(Canvas canvas, Offset point, double radius) {
    Rect rect = new Rect.fromCircle(
      center: point,
      radius: radius,
    );
    _starsPaint.shader = _gradient.createShader(rect);
    canvas.drawCircle(point, radius, _starsPaint);
  }

  void _superNova(Canvas canvas) {
    _drawStar(canvas, superNovaPoint, superNovaExplodeRadius);
  }

}