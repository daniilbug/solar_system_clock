// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'solar_system_clock.dart';
import 'customizer.dart';
import 'model.dart';

void main() {
  runApp(ClockCustomizer((ClockModel model) => SolarSystemClock(model, switchPeriod: Duration(seconds: 6))));
}
