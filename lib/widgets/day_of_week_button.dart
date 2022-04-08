import 'package:flutter/material.dart' as m;

import 'package:pavlok_technical_challenge/constants.dart' as c;
import 'package:pavlok_technical_challenge/shared.dart' as s;

/// A circular [m.TextButton] button with a single child [m.Text] that draws a
/// single letter representing the day of the week.
///
/// When pressed the color of the text and background are animated from gray to
/// purple and the elevation is animated showing a purple shadow.  When already
/// selected previously then pressed it animates back to the original colors.
class DayOfWeekButton extends m.StatefulWidget {
  const DayOfWeekButton({
    m.Key? key,
    required String letter,
  })  : _letter = letter,
        super(
          key: key,
        );

  final String _letter;

  @override
  m.State<DayOfWeekButton> createState() => _DayOfWeekButtonState();
}

class _DayOfWeekButtonState extends m.State<DayOfWeekButton>
    with m.TickerProviderStateMixin {
  final _selected = m.ValueNotifier<bool>(
    false,
  );

  late final m.AnimationController _backgroundColorAnimationController;
  late final m.Animation<m.Color?> _backgroundColorAnimation;

  late final m.AnimationController _textColorAnimationController;
  late final m.Animation<m.Color?> _textColorAnimation;

  late final m.AnimationController _elevationAnimationController;
  late final m.Animation<double> _elevationAnimation;

  void _setupBackgroundColorAnimation() {
    _backgroundColorAnimationController = m.AnimationController(
      vsync: this,
      duration: c.quarterSecond,
    )..addListener(
        () {
          setState(
            () {},
          );
        },
      );

    _backgroundColorAnimation = m.ColorTween(
      begin: c.extraLightGray,
      end: c.purple,
    ).animate(
      m.CurvedAnimation(
        parent: _backgroundColorAnimationController,
        curve: m.Curves.easeInOut,
      ),
    );
  }

  void _setupTextColorAnimation() {
    _textColorAnimationController = m.AnimationController(
      vsync: this,
      duration: c.quarterSecond,
    )..addListener(
        () {
          setState(
            () {},
          );
        },
      );

    _textColorAnimation = m.ColorTween(
      begin: m.Colors.black,
      end: m.Colors.white,
    ).animate(
      m.CurvedAnimation(
        parent: _textColorAnimationController,
        curve: m.Curves.easeInOut,
      ),
    );
  }

  void _setupElevationAnimation() {
    _elevationAnimationController = m.AnimationController(
      vsync: this,
      duration: c.quarterSecond,
    );

    _elevationAnimation = m.Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(
      m.CurvedAnimation(
        parent: _backgroundColorAnimationController,
        curve: m.Curves.easeInOut,
      ),
    );
  }

  void _setupSelectedListener() {
    _selected.addListener(
      () {
        if (_selected.value) {
          _backgroundColorAnimationController.forward(
            from: _backgroundColorAnimationController.value,
          );
          _textColorAnimationController.forward(
            from: _textColorAnimationController.value,
          );
          _elevationAnimationController.forward(
            from: _elevationAnimationController.value,
          );
        } else {
          _backgroundColorAnimationController.reverse(
            from: _backgroundColorAnimationController.value,
          );
          _textColorAnimationController.reverse(
            from: _textColorAnimationController.value,
          );
          _elevationAnimationController.reverse(
            from: _elevationAnimationController.value,
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _setupBackgroundColorAnimation();
    _setupTextColorAnimation();
    _setupElevationAnimation();
    _setupSelectedListener();
  }

  @override
  m.Widget build(m.BuildContext context) {
    final screenSize = m.MediaQuery.of(context).size;
    return m.TextButton(
      style: m.ButtonStyle(
        elevation: m.MaterialStateProperty.all(
          _elevationAnimation.value,
        ),
        shadowColor: m.MaterialStateProperty.all(
          _backgroundColorAnimation.value,
        ),
        shape: m.MaterialStateProperty.all(
          const m.CircleBorder(),
        ),
        backgroundColor: m.MaterialStateProperty.all(
          _backgroundColorAnimation.value,
        ),
      ),
      child: m.Text(
        widget._letter,
        style: m.TextStyle(
          color: _textColorAnimation.value,
          fontSize: s.fromScreenSize(
            16.0,
            screenSize,
          ),
          fontWeight: m.FontWeight.w600,
        ),
      ),
      onPressed: () {
        _selected.value = !_selected.value;
      },
    );
  }
}
