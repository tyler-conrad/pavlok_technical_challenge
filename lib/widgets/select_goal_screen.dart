import 'package:flutter/material.dart' as m;
import 'package:flutter_svg/flutter_svg.dart' as svg;

import 'package:pavlok_technical_challenge/constants.dart' as c;
import 'package:pavlok_technical_challenge/shared.dart' as s;
import 'package:pavlok_technical_challenge/widgets/screen_padding.dart'
    as sp;
import 'package:pavlok_technical_challenge/widgets/progress_bar.dart'
    as bar;
import 'package:pavlok_technical_challenge/widgets/habit_button_picker.dart'
    as hbp;
import 'package:pavlok_technical_challenge/widgets/purple_button.dart'
    as pb;

/// A screen displaying tabs that select between lists of good and bad habit
/// buttons.
class SelectGoalScreen extends m.StatefulWidget {
  const SelectGoalScreen({m.Key? key}) : super(key: key);

  @override
  m.State<SelectGoalScreen> createState() => _SelectGoalScreenState();
}

class _SelectGoalScreenState extends m.State<SelectGoalScreen>
    with m.SingleTickerProviderStateMixin {
  /// The page controller for the good and bad habit button lists that are
  /// toggled between using tabs.
  final _habitPageController = m.PageController();

  /// The page of habit buttons that should be displayed based on the tapping
  /// of the habit type tab header.
  s.HabitType _selectedHabitType = s.HabitType.good;

  @override
  void dispose() {
    _habitPageController.dispose();
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
          vertical: s.r(
            6.0,
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
            s.r(
              4.0,
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
                    fontSize: s.r(13.0),
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

  @override
  m.Widget build(m.BuildContext context) {
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
                        fontSize: s.r(
                          26.0,
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
                      fontSize: s.r(17.0,),
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
                m.Navigator.pushNamed(
                  context,
                  '/sleep',
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
