// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:analog_clock/planets_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'model.dart';
import 'stars_background.dart';

/// A basic analog clock.
///
/// You can do better than this!
class SolarSystemClock extends StatefulWidget {
  const SolarSystemClock(this.model, {@required this.switchPeriod});

  final Duration switchPeriod;
  final ClockModel model;

  @override
  _SolarSystemClockState createState() => _SolarSystemClockState();
}

class _SolarSystemClockState extends State<SolarSystemClock> with TickerProviderStateMixin {
  var _now = DateTime.now();
  var _temperature = '';
  var _condition = WeatherCondition.sunny;
  Timer _timer;
  bool _isShown = false;
  int _lastShowTime = 0;
  AnimationController _controller;
  Animation<double> _animatedCirclesRadius;
  Animation<double> _animatedDistanceBetween;
  Animation<Color> _animatedGradient;
  Animation<double> _animatedGradientRadius;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
    _initAnimations();
  }

  @override
  void didUpdateWidget(SolarSystemClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    _controller.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _condition = widget.model.weatherCondition;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(milliseconds: 1000 ~/ 60) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
      _checkDateTime();
    });
  }

  void _initAnimations() {
    _controller = AnimationController(duration: Duration(milliseconds: 400), vsync: this);
    _animatedCirclesRadius = Tween<double>(begin: 8, end: 0.0).animate(_controller);
    _animatedDistanceBetween = Tween<double>(begin: 16.0, end: 0.0).animate(_controller);
    _animatedGradient = ColorTween(begin: Colors.orangeAccent, end: Colors.grey).animate(_controller);
    _animatedGradientRadius = Tween<double>(begin: 0.8, end: 0.5).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hms().format(DateTime.now());

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Solar system clock with time $time',
        value: time,
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final radius = min(size.width, size.height) / 3;

        return Stack(children: <Widget>[
              Container(color: Colors.black),
              _stars(size),
              _mainCircle(Theme.of(context), radius),
              _circles(radius, size),
            ]
        );
      }
    ));
  }

  Widget _mainCircle(ThemeData theme, double radius){
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
        decoration: BoxDecoration(
            gradient: RadialGradient(colors: [
              _animatedGradient.value, Colors.transparent
            ], radius: _animatedGradientRadius.value)
        ),
        child: Center(
          child: AnimatedCrossFade(
            duration: Duration(milliseconds: 400),
              crossFadeState: _isShown ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: CircleAvatar(
                backgroundColor: Colors.orangeAccent,
                radius:  (radius - 14),
                child: Container(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0.7, sigmaY: 0.7),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
                    ),
                  ),
                ),
              ),
              secondChild: CircleAvatar(
                  backgroundImage: isDarkMode ? AssetImage("assets/images/earth_night.png") : AssetImage("assets/images/earth.png"),
                  radius: radius - 14,
                  child: _detailInformation(radius)
              )
          )
        )
    );
  }

  Widget _detailInformation(double radius) {
    final timeFormat = widget.model.is24HourFormat ? DateFormat("HH:mm") : DateFormat("hh:mm");
    return  DefaultTextStyle(
      style: TextStyle(fontSize: radius / 6),
      child: Container(
        margin: EdgeInsets.only(top: radius / 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(_temperature),
            Text(timeFormat.format(DateTime.now()), style: TextStyle(fontSize: radius / 3)),
            Container(height: radius / 3, child: _iconByWeather(_condition))
          ],
        ),
      )
    );
  }

  Widget _circles(double radius, Size size) {

    return CustomPaint(
        size: Size(size.width, size.height),
        painter: PlanetsPainter(
            colors: TimeColors(
                second: Color(0xFF669DF6),
                minute: Color(0xFFC47C41),
                hour: Color(0xFFDBAD88)
            ),
            time: DateTime.now(),
            radius: radius,
            circleRadius: _animatedCirclesRadius.value,
            distanceBetween: _animatedDistanceBetween.value
        ),
    );
  }

  Widget _iconByWeather(WeatherCondition weather) {
    switch(weather) {
      case WeatherCondition.sunny: return Image.asset("assets/images/sunny.png");
      case WeatherCondition.cloudy: return Image.asset("assets/images/cloudy.png");
      case WeatherCondition.foggy: return Image.asset("assets/images/foggy.png");
      case WeatherCondition.rainy: return Image.asset("assets/images/rainy.png");
      case WeatherCondition.snowy: return Image.asset("assets/images/snowy.png");
      case WeatherCondition.windy: return Image.asset("assets/images/windy.png");
      case WeatherCondition.thunderstorm: return Image.asset("assets/images/thunderstorm.png");
      default: return Container();
    }
  }

  void _checkDateTime() {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastShowTime >= widget.switchPeriod.inMilliseconds && _controller != null) {
      _turnClock();
    }
  }

  void _turnClock() {
    if (_isShown) {
      _hide();
    } else {
      _show();
    }
    _lastShowTime = DateTime.now().millisecondsSinceEpoch;
  }

  void _hide() {
    setState(() {
      _isShown = false;
      _controller.forward();
      _controller.reverse();
    });
  }

  void _show() {
    setState(() {
      _isShown = true;
      _controller.forward();
    });
  }

  Widget _stars(Size size) {
    return StarsBackground(size: size, starCount: 30);
  }
}
