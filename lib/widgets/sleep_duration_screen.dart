import 'dart:math' as math;

import 'package:flutter/material.dart' as m;
import 'package:flutter_svg/flutter_svg.dart' as svg;

import 'package:pavlok_technical_challenge/constants.dart' as c;
import 'package:pavlok_technical_challenge/shared.dart' as s;
import 'package:pavlok_technical_challenge/widgets/screen_padding.dart' as sp;
import 'package:pavlok_technical_challenge/widgets/circular_duration_picker.dart'
    as cdp;
import 'package:pavlok_technical_challenge/widgets/day_of_week_button.dart'
    as dowb;
import 'package:pavlok_technical_challenge/widgets/reminder_minutes_picker.dart'
    as rmp;
import 'package:pavlok_technical_challenge/widgets/purple_button.dart' as pb;

class SleepDurationScreen extends m.StatefulWidget {
  const SleepDurationScreen({m.Key? key}) : super(key: key);

  @override
  _SleepDurationScreenState createState() => _SleepDurationScreenState();
}

class _SleepDurationScreenState extends m.State<SleepDurationScreen> {
  static const _sleepGoalHours = 8;
  static const _sleepGoalHoursString = '${_sleepGoalHours}hrs';

  /// The position of the bedtime handle in the [cdp.CircularDurationPicker].
  final _bedtime = m.ValueNotifier<m.Offset>(
    m.Offset.fromDirection(
      c.circularDurationPickerHandleStartRadians,
    ),
  );

  /// The position of the wake up handle in the [cdp.CircularDurationPicker].
  final _wakeUp = m.ValueNotifier<m.Offset>(
    m.Offset.fromDirection(
      c.circularDurationPickerHandleStartRadians,
    ),
  );

  /// Used to trigger a setState call whenever the [m.Offset] representing a
  /// handle position change occurs
  late final m.Listenable _onHandleUpdate;

  /// The interval in minutes that the [rmp.ReminderMinutesPicker] should be
  /// initialized to.
  int? _reminderMinutes = 30;

  @override
  void initState() {
    super.initState();

    /// Combine the update events for handle position changes in to a single
    /// [m.Listenable] so setState can be called for all updates.
    _onHandleUpdate = m.Listenable.merge(
      [
        _bedtime,
        _wakeUp,
      ],
    )..addListener(
        () {
          setState(
            () {},
          );
        },
      );
  }

  @override
  void dispose() {
    _wakeUp.dispose();
    _bedtime.dispose();
    super.dispose();
  }

  /// Returns an [m.Text] with text for being either over or under your sleep
  /// goal.
  m.Text _sleepGoalLabel() {
    final bool underSleepGoal = const Duration(
          hours: _sleepGoalHours,
        ) >
        s.durationRoundedToFiveMinutesFromAngle(
          s.convertToPositiveDirection(
            (_wakeUp.value.direction - _bedtime.value.direction),
          ),
        );
    return m.Text(
      underSleepGoal
          ? 'Under your sleep goal ( $_sleepGoalHoursString )'
          : 'Over your sleep goal ( $_sleepGoalHoursString )',
      style: m.TextStyle(
        fontSize: s.r(12.0,),
        fontWeight: m.FontWeight.w500,
      ),
      textAlign: m.TextAlign.center,
    );
  }

  /// Returns of [String] representing the time in a 12 hour format based on the
  /// angle of a handle.
  String _timeFromHandle(m.ValueNotifier<m.Offset> handle) {
    final hours = s.sweepAngleHours(
      handle.value.direction + math.pi * 0.5,
    );

    final hoursWrapped = (hours % c.numHoursInHalfDay).round();

    final hoursString = '${hoursWrapped == 0 ? 12 : hoursWrapped}'.padLeft(
      2,
      '0',
    );

    final minutesString = '${(s.sweepAngleMinutes(
              handle.value.direction + math.pi * 0.5,
            ).round() % c.numMinutesInHour)}'
        .padLeft(
      2,
      '0',
    );

    final roundedHours = hours.round() % c.numHoursInDay;

    return '$hoursString:$minutesString ${roundedHours < 12 && roundedHours >= 0 ? 'AM' : 'PM'}';
  }

  /// Returns an [m.Row] containing an [svg.SvgPicture] and calls
  /// [_sleepGoalLabel] to build an [m.Text].
  m.Row _buildSleepGoalLabel() {
    return m.Row(
      children: [
        const m.Spacer(
          flex: 2,
        ),
        m.Expanded(
          flex: 7,
          child: m.Row(
            mainAxisAlignment: m.MainAxisAlignment.center,
            children: [
              svg.SvgPicture.asset(
                'assets/svg/bulb.svg',
                width: s.r(
                  24.0,
                ),
                height: s.r(
                  24.0,
                ),
              ),
              m.SizedBox(
                width: s.r(
                  8.0,
                ),
              ),
              _sleepGoalLabel(),
            ],
          ),
        ),
        const m.Spacer(
          flex: 2,
        ),
      ],
    );
  }

  /// Builds the widgets for the display of the time represented by eith the
  /// bedtime or wake up handle positions.
  m.Row _buildHandleTimeLabel(
    String svgAssetPath,
    String handleType,
    m.ValueNotifier<m.Offset> handle,
  ) {
    return m.Row(children: [
      m.Expanded(
        flex: 2,
        child: svg.SvgPicture.asset(svgAssetPath),
      ),
      const m.Spacer(
        flex: 1,
      ),
      m.Expanded(
        flex: 7,
        child: m.Column(
          mainAxisAlignment: m.MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: m.CrossAxisAlignment.stretch,
          children: [
            const m.Spacer(
              flex: 3,
            ),
            m.Expanded(
              flex: 3,
              child: m.Text(
                handleType,
                textAlign: m.TextAlign.left,
                style: m.TextStyle(
                  fontSize: s.r(12.0, ),
                  fontWeight: m.FontWeight.w600,
                  color: c.gray,
                ),
              ),
            ),
            m.Expanded(
              flex: 4,
              child: m.Text(
                _timeFromHandle(
                  handle,
                ),
                textAlign: m.TextAlign.left,
                style: m.TextStyle(
                  fontSize: s.r(20.0, ),
                  fontWeight: m.FontWeight.w600,
                ),
              ),
            ),
            const m.Spacer(
              flex: 3,
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  m.Widget build(m.BuildContext context) {
    return sp.ScreenPadding(
      child: m.Column(
        children: [
          m.Expanded(
            flex: 36,
            child: m.Column(
              mainAxisAlignment: m.MainAxisAlignment.spaceBetween,
              children: [
                const m.Spacer(
                  flex: 1,
                ),
                m.Expanded(
                  flex: 4,
                  child: m.Row(
                    children: [
                      m.Expanded(
                        flex: 1,
                        child: m.IconButton(
                          onPressed: () {},
                          padding: const m.EdgeInsets.all(
                            0.0,
                          ),
                          iconSize: s.r(
                            32.0,
                          ),
                          icon: m.Icon(
                            m.Icons.chevron_left_sharp,
                            size: s.r(
                              32.0,
                            ),
                          ),
                        ),
                      ),
                      const m.Spacer(
                        flex: 9,
                      ),
                    ],
                  ),
                ),
                m.Expanded(
                  flex: 4,
                  child: m.Text(
                    'Set bedtime and wake up',
                    style: m.TextStyle(
                      fontSize: s.r(
                        25.0,
                      ),
                      fontWeight: m.FontWeight.w600,
                    ),
                  ),
                ),
                m.Expanded(
                  flex: 18,
                  child: cdp.CircularDurationPicker(
                    bedtime: _bedtime,
                    wakeUp: _wakeUp,
                  ),
                ),
                m.Expanded(
                  flex: 2,
                  child: _buildSleepGoalLabel(),
                ),
                m.Expanded(
                  flex: 8,
                  child: m.Padding(
                    padding: m.EdgeInsets.only(
                      left: s.r(
                        6.0,
                      ),
                      top: s.r(
                        6.0,
                      ),
                      bottom: s.r(
                        18.0,
                      ),
                    ),
                    child: m.Row(
                      children: [
                        m.Expanded(
                          flex: 6,
                          child: _buildHandleTimeLabel(
                            'assets/svg/moon_purple.svg',
                            'Bedtime',
                            _bedtime,
                          ),
                        ),
                        const m.Spacer(flex: 1),
                        m.Expanded(
                          flex: 4,
                          child: _buildHandleTimeLabel(
                            'assets/svg/sun_yellow.svg',
                            'Wake up',
                            _wakeUp,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                m.Expanded(
                  flex: 7,
                  child: m.Card(
                    elevation: c.defaultHighElevation,
                    shape: m.RoundedRectangleBorder(
                      borderRadius: m.BorderRadius.circular(
                        s.r(
                          c.defaultBorderRadius,
                        ),
                      ),
                    ),
                    child: m.Padding(
                      padding: m.EdgeInsets.only(
                        left: s.r(
                          12.0,
                        ),
                        top: s.r(
                          4.0,
                        ),
                        right: s.r(
                          12.0,
                        ),
                        bottom: s.r(
                          8.0,
                        ),
                      ),
                      child: m.Column(
                        crossAxisAlignment: m.CrossAxisAlignment.stretch,
                        children: [
                          const m.Spacer(
                            flex: 1,
                          ),
                          m.Expanded(
                            flex: 4,
                            child: m.Text(
                              'Repeat days',
                              textAlign: m.TextAlign.left,
                              style: m.TextStyle(
                                fontSize: s.r(16.0,),
                                fontWeight: m.FontWeight.w900,
                                letterSpacing: 1.0,
                                color: c.black,
                              ),
                            ),
                          ),
                          const m.Spacer(
                            flex: 1,
                          ),
                          m.Expanded(
                            flex: 6,
                            child: m.Row(
                              crossAxisAlignment: m.CrossAxisAlignment.stretch,
                              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                                  .map(
                                    (letter) => m.Expanded(
                                      flex: 1,
                                      child: dowb.DayOfWeekButton(
                                        letter: letter,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          const m.Spacer(
                            flex: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const m.Spacer(
                  flex: 1,
                ),
                m.Expanded(
                  flex: 5,
                  child: m.ElevatedButton(
                      onPressed: () async {
                        final selectedMinutes =
                            await m.showModalBottomSheet<int>(
                          shape: m.RoundedRectangleBorder(
                            borderRadius: m.BorderRadius.circular(
                              s.r(
                                c.defaultBorderRadius,
                              ),
                            ),
                          ),
                          context: context,
                          builder: (context) {
                            return const rmp.ReminderMinutesPicker();
                          },
                        );
                        if (selectedMinutes != null) {
                          setState(
                            () {
                              _reminderMinutes = selectedMinutes;
                            },
                          );
                        }
                      },
                      style: m.ButtonStyle(
                        shape: m.MaterialStateProperty.all<
                            m.RoundedRectangleBorder>(
                          m.RoundedRectangleBorder(
                            borderRadius: m.BorderRadius.circular(
                              s.r(
                                c.defaultBorderRadius,
                              ),
                            ),
                          ),
                        ),
                        elevation: m.MaterialStateProperty.all(
                          c.defaultHighElevation,
                        ),
                        backgroundColor: m.MaterialStateProperty.all(
                          m.Colors.white,
                        ),
                      ),
                      child: m.Row(
                        children: [
                          m.Expanded(
                            flex: 8,
                            child: m.Text(
                              'Remind me before bed time',
                              textAlign: m.TextAlign.left,
                              style: m.TextStyle(
                                fontSize: s.r(14.0, ),
                                fontWeight: m.FontWeight.w500,
                                color: m.Colors.black,
                              ),
                            ),
                          ),
                          const m.Spacer(
                            flex: 1,
                          ),
                          m.Expanded(
                            flex: 3,
                            child: m.Text(
                              '$_reminderMinutes min',
                              textAlign: m.TextAlign.center,
                              style: m.TextStyle(
                                fontSize: s.r(16.0, ),
                                fontWeight: m.FontWeight.w700,
                                letterSpacing: 1.0,
                                color: m.Colors.black,
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
                const m.Spacer(
                  flex: 2,
                ),
              ],
            ),
          ),
          m.Expanded(
            flex: 4,
            child: pb.PurpleButton(
              text: 'Next',
              onPressed: () {
                m.Navigator.pushNamed(
                  context,
                  '/habit',
                );
              },
            ),
          ),
          const m.Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }
}
