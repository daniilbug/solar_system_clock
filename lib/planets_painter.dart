import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeColors {
  final Color second;
  final Color minute;
  final Color hour;
  TimeColors({@required this.second, @required this.minute, @required this.hour});
}

class PlanetsPainter extends CustomPainter {

  final TimeColors colors;
  final double radius;
  final double _secondsAngle;
  final double _minutesAngle;
  final double _hoursAngle;
  final double circleRadius;
  final double distanceBetween;
  final _paint = Paint()..style = PaintingStyle.stroke;

  PlanetsPainter({@required this.colors, @required DateTime time, this.radius, this.circleRadius, this.distanceBetween}):
        _secondsAngle = _secondsOrMinutesInAngle(time.second + time.millisecond / 1000),
        _minutesAngle = _secondsOrMinutesInAngle(time.minute + time.second / 60 + time.millisecond / 60 / 1000),
        _hoursAngle = _hourInAngle(time.hour + time.minute / 60 + time.second / 60 / 60 + time.millisecond / 60 / 60 / 1000.0);

  static double _secondsOrMinutesInAngle(double value) {
    return (value * 6 - 90) * pi / 180;
  }

  static double _hourInAngle(double hour) {
    return ((hour % 12) * 30 - 90) * pi / 180;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height / 2);

    canvas.drawCircle(center, radius + 2 * distanceBetween, _paint..color = colors.second.withAlpha(100));
    canvas.drawCircle(center, radius + distanceBetween, _paint..color = colors.minute.withAlpha(100));
    canvas.drawCircle(center, radius, _paint..color = colors.hour.withAlpha(100));

    _paint.style = PaintingStyle.fill;
    canvas.drawCircle(_pointForAngle(center, _secondsAngle, 2 * distanceBetween), circleRadius, _paint..color = colors.second);
    canvas.drawCircle(_pointForAngle(center, _minutesAngle, distanceBetween), circleRadius, _paint..color = colors.minute);
    canvas.drawCircle(_pointForAngle(center, _hoursAngle, 0.0), circleRadius, _paint..color = colors.hour);
  }

  Offset _pointForAngle(Offset center, double angle, double distance) {
    final x = center.dx;
    final y = center.dy;
    final dx = (radius + distance) * cos(angle);
    final dy = (radius + distance) * sin(angle);
    return Offset(x + dx, y + dy);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}