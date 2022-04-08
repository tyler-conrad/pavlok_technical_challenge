import 'package:flutter/material.dart' as m;

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
      padding: const m.EdgeInsets.only(
        left: _screenPadding,
        top: _screenPadding,
        right: _screenPadding,
      ),
      child: _child,
    );
  }
}
