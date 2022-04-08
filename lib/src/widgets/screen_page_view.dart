import 'dart:math' as math;

import 'package:flutter/material.dart' as m;
import 'package:flutter_svg/flutter_svg.dart' as svg;

import 'package:pavlok_technical_challenge/src/constants.dart' as c;
import 'package:pavlok_technical_challenge/src/shared.dart' as s;
import 'package:pavlok_technical_challenge/src/widgets/screen_padding.dart'
    as sp;
import 'package:pavlok_technical_challenge/src/widgets/progress_bar.dart'
    as bar;
import 'package:pavlok_technical_challenge/src/widgets/habit_button_picker.dart'
    as hbp;
import 'package:pavlok_technical_challenge/src/widgets/purple_button.dart'
    as pb;
import 'package:pavlok_technical_challenge/src/widgets/circular_duration_picker.dart'
    as cdp;
import 'package:pavlok_technical_challenge/src/widgets/day_of_week_button.dart'
    as dowb;
import 'package:pavlok_technical_challenge/src/widgets/reminder_minutes_picker.dart'
    as rmp;

/// This widget is a [m.PageView] that contains the layouts for the habit picker
/// and sleep duration screens.  Uses [m.Column] and [m.Row] with
/// the 'flex' parameter to implement a flexible layout that adapts to different
/// screen sizes.
class ScreenPageView extends m.StatefulWidget {
  const ScreenPageView({m.Key? key}) : super(key: key);

  @override
  m.State<ScreenPageView> createState() => _ScreenPageViewState();
}

class _ScreenPageViewState extends m.State<ScreenPageView>
    with m.SingleTickerProviderStateMixin {
  static const _sleepGoalHours = 8;
  static const _sleepGoalHoursString = '${_sleepGoalHours}hrs';

  /// The page controller for the base screens
  final _screenController = m.PageController();

  /// The page controller for the good and bad habit button lists that are
  /// toggled between using tabs.
  final _habitPageController = m.PageController();

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

  /// The page of habit buttons that should be displayed based on the tapping
  /// of the habit type tab header.
  s.HabitType _selectedHabitType = s.HabitType.good;

  /// The interval in minutes that the [rmp.ReminderMinutesPicker] should be
  /// initialized to.
  int? _reminderMinutes = 30;

  m.Size _screenSize = m.Size.zero;

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
    _habitPageController.dispose();
    _screenController.dispose();
    super.dispose();
  }

  /// The path to the SVG image that should be displayed in the habit button
  /// picker list tab header based on which tab is active.
  String _goodHabitTypeSvgPath() => _selectedHabitType == s.HabitType.good
      ? 'assets/svg/leaf_purple.svg'
      : 'assets/svg/leaf_gray.svg';

  /// See [_goodHabitTypeSvgPath].
  String _badHabitTypeSvgPath() => _selectedHabitType == s.HabitType.bad
      ? 'assets/svg/bolt_purple.svg'
      : 'assets/svg/bolt_gray.svg';

  ///  The onPressed callback for the habit button list tab header.
  ///
  /// Animates to the next or previous page of habit buttons based on which tab
  /// is pressed.
  void _onPressed(s.HabitType habitType) {
    setState(
      () {
        _selectedHabitType = habitType;
        if (_selectedHabitType == s.HabitType.bad) {
          _habitPageController.nextPage(
            duration: c.oneSecond,
            curve: m.Curves.easeInOut,
          );
        } else {
          _habitPageController.previousPage(
            duration: c.oneSecond,
            curve: m.Curves.easeInOut,
          );
        }
      },
    );
  }

  /// Builds the tab header for the habit buttton picker list.
  ///
  /// Contains children of a [svg.SvgPicture] and a [m.Text] that change color
  /// based on the selection.
  m.Padding _buildTabHeader({
    required String svgAssetPath,
    required String text,
    required s.HabitType habitType,
  }) =>
      m.Padding(
        padding: m.EdgeInsets.symmetric(
          vertical: s.fromScreenSize(
            6.0,
            _screenSize,
          ),
        ),
        child: m.MaterialButton(
          focusColor: m.Colors.transparent,
          highlightColor: m.Colors.transparent,
          hoverColor: m.Colors.transparent,
          splashColor: m.Colors.transparent,
          shape: m.Border(
            bottom: m.BorderSide(
              color: habitType == _selectedHabitType
                  ? c.purple
                  : m.Colors.transparent,
              width: 2.0,
            ),
          ),
          padding: m.EdgeInsets.all(
            s.fromScreenSize(
              4.0,
              _screenSize,
            ),
          ),
          onPressed: () {
            _onPressed(habitType);
          },
          child: m.Row(
            children: [
              m.Expanded(
                flex: 1,
                child: svg.SvgPicture.asset(
                  svgAssetPath,
                ),
              ),
              m.Expanded(
                flex: 5,
                child: m.Text(
                  text,
                  style: m.TextStyle(
                    fontSize: s.fromScreenSize(14.0, _screenSize),
                    color: habitType == _selectedHabitType ? c.purple : c.gray,
                    fontWeight: m.FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  bool showBackdrop = false; // todo

  /// Calls [_buildTabHeader] with the parameters for a habit type of either
  /// good or bad.
  m.Row _buildHabitTabHeaders() {
    return m.Row(
      crossAxisAlignment: m.CrossAxisAlignment.stretch,
      children: [
        m.Expanded(
          flex: 4,
          child: _buildTabHeader(
            svgAssetPath: _goodHabitTypeSvgPath(),
            text: 'Start a good habit',
            habitType: s.HabitType.good,
          ),
        ),
        const m.Spacer(flex: 1),
        m.Expanded(
          flex: 4,
          child: _buildTabHeader(
            svgAssetPath: _badHabitTypeSvgPath(),
            text: 'Break a bad habit',
            habitType: s.HabitType.bad,
          ),
        ),
      ],
    );
  }

  /// The layout for the main screen containing a list of habit buttons to
  /// choose from.
  sp.ScreenPadding _selectHabitScreen() {
    return sp.ScreenPadding(
      child: m.Column(
        crossAxisAlignment: m.CrossAxisAlignment.stretch,
        children: [
          m.Expanded(
            flex: 36,
            child: m.Column(
              children: [
                const m.Spacer(
                  flex: 5,
                ),
                const m.Expanded(
                  flex: 8,
                  child: bar.ProgressBar(
                    steps: 4,
                  ),
                ),
                const m.Spacer(
                  flex: 4,
                ),
                m.Expanded(
                  flex: 12,
                  child: m.Center(
                    child: m.Text(
                      "What's your main goal?",
                      style: m.TextStyle(
                        fontSize: s.fromScreenSize(
                          26.0,
                          _screenSize,
                        ),
                        fontWeight: m.FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const m.Spacer(
                  flex: 1,
                ),
                m.Expanded(
                  flex: 6,
                  child: m.Text(
                    "Let's start with one of these habits.",
                    style: m.TextStyle(
                      fontSize: s.fromScreenSize(17.0, _screenSize),
                      fontWeight: m.FontWeight.w500,
                    ),
                  ),
                ),
                const m.Spacer(
                  flex: 4,
                ),
                m.Expanded(
                  flex: 16,
                  child: _buildHabitTabHeaders(),
                ),
                const m.Spacer(
                  flex: 8,
                ),
                m.Expanded(
                  flex: 104,
                  child: m.PageView(
                    controller: _habitPageController,
                    children: const [
                      hbp.HabitButtonPicker(
                        habitType: s.HabitType.good,
                      ),
                      hbp.HabitButtonPicker(
                        habitType: s.HabitType.bad,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          m.Expanded(
            flex: 4,
            child: pb.PurpleButton(
              text: 'Next',
              onPressed: () {
                _screenController.nextPage(
                  duration: c.oneSecond,
                  curve: m.Curves.easeInOut,
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
        fontSize: s.fromScreenSize(12.0, _screenSize),
        fontWeight: m.FontWeight.w500,
      ),
      textAlign: m.TextAlign.center,
    );
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
                width: s.fromScreenSize(
                  24.0,
                  _screenSize,
                ),
                height: s.fromScreenSize(
                  24.0,
                  _screenSize,
                ),
              ),
              m.SizedBox(
                width: s.fromScreenSize(
                  8.0,
                  _screenSize,
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
                  fontSize: s.fromScreenSize(12.0, _screenSize),
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
                  fontSize: s.fromScreenSize(20.0, _screenSize),
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

  /// The layout for the sleep duration selection screen
  sp.ScreenPadding _selectSleepDurationScreen() {
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
                          onPressed: () {
                            _screenController.previousPage(
                              duration: c.oneSecond,
                              curve: m.Curves.easeInOut,
                            );
                          },
                          padding: const m.EdgeInsets.all(
                            0.0,
                          ),
                          iconSize: s.fromScreenSize(
                            32.0,
                            _screenSize,
                          ),
                          icon: m.Icon(
                            m.Icons.chevron_left_sharp,
                            size: s.fromScreenSize(
                              32.0,
                              _screenSize,
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
                      fontSize: s.fromScreenSize(
                        25.0,
                        _screenSize,
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
                  flex: 7,
                  child: m.Padding(
                    padding: m.EdgeInsets.only(
                      left: s.fromScreenSize(
                        6.0,
                        _screenSize,
                      ),
                      top: s.fromScreenSize(
                        6.0,
                        _screenSize,
                      ),
                      bottom: s.fromScreenSize(
                        18.0,
                        _screenSize,
                      ),
                    ),
                    child: m.Row(
                      children: [
                        m.Expanded(
                          flex: 4,
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
                        s.fromScreenSize(
                          c.defaultBorderRadius,
                          _screenSize,
                        ),
                      ),
                    ),
                    child: m.Padding(
                      padding: m.EdgeInsets.only(
                        left: s.fromScreenSize(
                          12.0,
                          _screenSize,
                        ),
                        top: s.fromScreenSize(
                          4.0,
                          _screenSize,
                        ),
                        right: s.fromScreenSize(
                          12.0,
                          _screenSize,
                        ),
                        bottom: s.fromScreenSize(
                          8.0,
                          _screenSize,
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
                                fontSize: s.fromScreenSize(16.0, _screenSize),
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
                              s.fromScreenSize(
                                c.defaultBorderRadius,
                                _screenSize,
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
                              s.fromScreenSize(
                                c.defaultBorderRadius,
                                _screenSize,
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
                              textAlign: m.TextAlign.center,
                              style: m.TextStyle(
                                fontSize: s.fromScreenSize(14.0, _screenSize),
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
                                fontSize: s.fromScreenSize(16.0, _screenSize),
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
                _screenController.previousPage(
                  duration: c.oneSecond,
                  curve: m.Curves.easeInOut,
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

  @override
  m.Widget build(m.BuildContext context) {
    _screenSize = m.MediaQuery.of(context).size;
    return
        // m.Stack(
        // children: [
        m.PageView(
      controller: _screenController,
      children: [
        _selectHabitScreen(),
        _selectSleepDurationScreen(),
      ],
    );
  }
}
