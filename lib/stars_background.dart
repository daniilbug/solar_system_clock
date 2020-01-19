import 'dart:math';

import 'package:analog_clock/stars_painter.dart';
import 'package:flutter/material.dart';

class StarsBackground extends StatefulWidget {
  final Size size;
  final int starCount;
  StarsBackground({@required this.size, @required this.starCount});

  @override
  State<StatefulWidget> createState() {
    return _StarsBackgroundState();
  }
}

class _StarsBackgroundState extends State<StarsBackground> with SingleTickerProviderStateMixin {
  Offset _fallenPoint;
  Offset _fallenVector;
  Offset _superNovaPoint;
  Animation<double> _superNovaExplodedRadius;
  AnimationController _controller;
  var _animationListener;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _superNovaExplodedRadius = TweenSequence<double>([
        TweenSequenceItem(tween: Tween<double>(begin: 4, end: 10), weight: 50),
        TweenSequenceItem(tween: Tween<double>(begin: 10, end: 4), weight: 50),
    ]).animate(_controller);
    _animationListener = (status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _superNovaPoint = null;
        });
        _controller.reverse();
      }
    };
    _superNovaExplodedRadius.addStatusListener(_animationListener);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final date = DateTime.now();
    _buildFall(size);
    _buildSuperNova(size);

    return CustomPaint(
      size: size,
      painter: StarsPainter(
          starCount: widget.starCount,
          date: date,
          fallenPoint: _fallenPoint,
          superNovaPoint: _superNovaPoint,
          superNovaExplodeRadius: _superNovaExplodedRadius.value,
          random:  Random(date.day)
      ),
    );
  }

  void _buildFall(Size size) {
    if (_fallenPoint == null) {
      _fallWithProbability(0.002, size);
    } else {
      _fall(size);
    }
  }

  void _fallWithProbability(double probability, Size size) {
    final random = Random();
    final chance = random.nextDouble();
    if (chance < probability) {
      _fallenPoint = Offset(random.nextDouble()*size.width, 0);
      _fallenVector = Offset(random.nextDouble() * 3, random.nextDouble() * 3);
    }
  }

  void _fall(Size size) {
    _fallenPoint = Offset(_fallenPoint.dx + _fallenVector.dx, _fallenPoint.dy + _fallenVector.dy);
    if (_fallenPoint.dx < 0 || _fallenPoint.dx > size.width || _fallenPoint.dy > size.height)
      _fallenPoint = null;
  }

  void _buildSuperNova(Size size) {
    if (_superNovaPoint == null) {
      _superNovaWithProbability(0.002, size);
    }
  }

  void _superNovaWithProbability(double probability, Size size) {
    final random = Random();
    final chance = random.nextDouble();
    if (chance < probability) {
      _explain(random, size);
    }
  }

  void _explain(Random random, Size size) {
    setState(() {
      _superNovaPoint = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}