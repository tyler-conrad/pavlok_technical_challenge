import 'dart:math' as math;

import 'package:flutter/material.dart' as m;

const purple = m.Color(
  0xFF8338EC,
);

const mediumPurple = m.Color(
  0xFF997DFF,
);

const lightPurple = m.Color(
  0xFFF8F3FF,
);

const purpleHighlight = m.Color(
  0xFFA692EF,
);

const yellow = m.Color(
  0xFFFFB706,
);

const gray = m.Color(
  0xFF939295,
);

const lightGray = m.Color(
  0xFFE9E9E9,
);

const extraLightGray = m.Color(
  0xFFF6F7FB,
);

const backgroundColor = m.Color(
  0xFFFCFBFF,
);

const black = m.Color(
  0xFF0D0E0F,
);

const black2 = m.Color(
  0xFF383E53,
);

const oneSecond = Duration(
  seconds: 1,
);

const quarterSecond = Duration(
  milliseconds: 250,
);

const numHoursInDay = 24;
const numHoursInHalfDay = numHoursInDay / 2;
const numMinutesInHour = 60;
const numMinutesInDay = numHoursInDay * numMinutesInHour;
const numFiveMinuteIntervalsInADay = numMinutesInDay / 5;
const circularDurationPickerHandleStartRadians = 2.0 * math.pi * 0.75;
const durationPickerInsideRadiusFactor = 0.38;
const defaultBorderRadius = 16.0;
const defaultElevation = 16.0;
const defaultHighElevation = 128.0;