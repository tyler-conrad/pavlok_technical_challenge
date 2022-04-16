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
    return m.Padding(
      padding: m.EdgeInsets.only(
        left: s.r(
          _screenPadding,
        ),
        top: s.r(
          _screenPadding,
        ),
        right: s.r(
          _screenPadding,
        ),
      ),
      child: _child,
    );
  }
}
