import 'package:flutter/material.dart' as m;

import 'package:pavlok_technical_challenge/shared.dart' as s;

/// A widget for the fixed padding around the screens for the habit picker and
/// the sleep duration picker screens.
class ScreenPadding extends m.StatelessWidget {
  const ScreenPadding({
    m.Key? key,
    required m.Widget child,
  })  : _child = child,
        super(
          key: key,
        );

  static const _screenPadding = 24.0;
  final m.Widget _child;

  @override
  m.Widget build(
    m.BuildContext context,
  ) {
    final screenSize = m.MediaQuery.of(context).size;
    return m.Padding(
      padding: m.EdgeInsets.only(
        left: s.fromScreenSize(
          _screenPadding,
          screenSize,
        ),
        top: s.fromScreenSize(
          _screenPadding,
          screenSize,
        ),
        right: s.fromScreenSize(
          _screenPadding,
          screenSize,
        ),
      ),
      child: _child,
    );
  }
}
