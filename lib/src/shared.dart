import 'dart:math' as math;

import 'package:pavlok_technical_challenge/src/constants.dart' as c;

/// Returns a [double] in the range \[-1.0, 1.0\] based on an input angle in
/// radians.
double _normalizedAngle(double angle) => angle / (2.0 * math.pi);

/// Returns a [Duration] that is a factor of 5 minutes based on the input of an
/// angle in radians.
Duration durationRoundedToFiveMinutesFromAngle(
  double angle,
) =>
    Duration(
        minutes:
            (_normalizedAngle(angle) * c.numFiveMinuteIntervalsInADay).round() *
                5);

/// By default the [m.Offset.direction] returns a value in the range
/// \[-math.pi, math.pi\].
///
/// In order to correctly calculate intervals and draw
/// arcs with the correct sweep angle this function is used to return an
/// equivalent positive angle.
double convertToPositiveDirection(double direction) =>
    direction < 0.0 ? (2.0 * math.pi + direction) % (2.0 * math.pi) : direction;

/// The number of hours represented by an angle in radians.
///
/// Used in the calculation of Durations represented by the angular difference
/// between to the two handle positions.
int sweepAngleHours(double angle) => durationRoundedToFiveMinutesFromAngle(
      convertToPositiveDirection(
        angle,
      ),
    ).inHours.floor();

/// The number of minutes over an hour represented by an angle in radians.
int sweepAngleMinutes(double angle) => (durationRoundedToFiveMinutesFromAngle(
          convertToPositiveDirection(
            angle,
          ),
        ) -
        Duration(
          hours: sweepAngleHours(
            angle,
          ),
        ))
    .inMinutes;

enum HabitType {
  good,
  bad,
}
