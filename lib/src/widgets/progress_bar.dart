import 'dart:math' as math;

import 'package:flutter/material.dart' as m;

import 'package:pavlok_technical_challenge/src/constants.dart' as c;
import 'package:pavlok_technical_challenge/src/shared.dart' as s;

/// Paints the rounded rectangles representing the progress bar for the current
/// step.
class ProgressBarPainter extends m.CustomPainter {
  ProgressBarPainter({
    m.Listenable? repaint,
    required double easeProgress,
    required int steps,
  })  : _easeProgress = easeProgress,
        _steps = steps,
        super(
          repaint: repaint,
        );

  final double _easeProgress;
  final int _steps;

  /// Given an [m.Canvas], [m.Size] and a [double] that is half the height of
  /// the progress bar, return a [Function] that takes a width and color and
  /// draws a rounded rectangle.
  void Function(
    double,
    m.Color,
  ) _drawBarClosure(m.Canvas canvas, m.Size size, double halfSize) {
    return (double width, m.Color color) {
      canvas.drawRRect(
        m.RRect.fromRectAndRadius(
          m.Rect.fromLTWH(
            0.0,
            size.height * 0.5 - halfSize,
            width,
            halfSize * 2.0,
          ),
          m.Radius.circular(
            halfSize,
          ),
        ),
        m.Paint()..color = color,
      );
    };
  }

  /// Draws two rounded rectangles with a corner radius that is half the height
  /// of the rectangle.  Draws a [c.lightGray] background and [c.yellow]
  /// foreground.
  @override
  void paint(m.Canvas canvas, m.Size size) {
    final drawBar = _drawBarClosure(
      canvas,
      size,
      size.height / 8.0,
    );
    drawBar(
      size.width,
      c.lightGray,
    );
    drawBar(
      _easeProgress * size.width / _steps,
      c.yellow,
    );
  }

  @override
  bool shouldRepaint(covariant m.CustomPainter oldDelegate) => false;
}

/// A progress bar representing the current step.  Has children of an
/// [m.CustomPaint] to draw the bar and an [m.Text] with the text 'X of X'.
///
/// The progress bar parameterized by the number of steps and the current step.
/// Additionally upon mount it animates the yellow foreground from 0 width to
/// the width that represents the current step.
class ProgressBar extends m.StatefulWidget {
  const ProgressBar({
    m.Key? key,
    required int steps,
    int currentStep = 0,
  })  : _steps = steps,
        _currentStep = currentStep,
        super(
          key: key,
        );

  final int _steps;
  final int _currentStep;

  @override
  m.State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends m.State<ProgressBar>
    with m.SingleTickerProviderStateMixin {
  late final m.AnimationController _easeController;
  late final m.Animation<double> _easeAnimation;

  late int _currentStep;
  double _easeProgress = 0.0;

  m.Size _screenSize = m.Size.zero;

  void _setupEaseAnimation() {
    _easeController = m.AnimationController(
      vsync: this,
      duration: c.oneSecond,
    )..addListener(
        () {
          setState(
            () {
              _easeProgress = _easeController.value;
            },
          );
        },
      );
    _easeAnimation = m.Tween<double>(
      begin: widget._currentStep.toDouble(),
      end: math.max(
        widget._steps.toDouble(),
        widget._currentStep + 1.0,
      ),
    ).animate(
      m.CurvedAnimation(
        curve: m.Curves.easeInOut,
        parent: _easeController,
      ),
    );
  }

  void _startAnimation() async {
    try {
      await _easeController.forward().orCancel;
      // ignore: empty_catches
    } on m.TickerCanceled {}
    setState(
      () {
        _currentStep = _easeController.value.round();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _currentStep = widget._currentStep;
    _setupEaseAnimation();
    _startAnimation();
  }

  @override
  void dispose() {
    _easeController.dispose();
    super.dispose();
  }

  m.Text _buildStepsLabel() {
    return m.Text(
      '$_currentStep of ${widget._steps}',
      style: m.TextStyle(
        fontSize: s.fromScreenSize(
          14.0,
          _screenSize,
        ),
        fontWeight: m.FontWeight.w500,
      ),
    );
  }

  m.LayoutBuilder _buildProgressBar() {
    return m.LayoutBuilder(
      builder: (context, constraints) => m.CustomPaint(
        size: m.Size(
          constraints.maxWidth,
          constraints.maxHeight,
        ),
        painter: ProgressBarPainter(
          easeProgress: _easeProgress,
          steps: widget._steps,
        ),
      ),
    );
  }

  @override
  m.Widget build(
    m.BuildContext context,
  ) {
    _screenSize = m.MediaQuery.of(context).size;
    return m.Row(
      children: [
        const m.Spacer(
          flex: 4,
        ),
        m.Expanded(
          flex: 16,
          child: _buildProgressBar(),
        ),
        const m.Spacer(
          flex: 1,
        ),
        m.Expanded(
          flex: 3,
          child: _buildStepsLabel(),
        ),
      ],
    );
  }
}
