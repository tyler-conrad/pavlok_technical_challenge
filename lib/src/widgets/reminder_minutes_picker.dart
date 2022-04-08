import 'dart:math' as math;

import 'package:flutter/material.dart' as m;

import 'package:pavlok_technical_challenge/src/constants.dart' as c;
import 'package:pavlok_technical_challenge/src/widgets/purple_button.dart'
    as pb;


/// Paints the [c.lightGray] handle at the top of the bottom sheet.
class ReminderMinutesPickerDragHandlePainter extends m.CustomPainter {
  @override
  void paint(m.Canvas canvas, m.Size size) {
    canvas.drawRRect(
      m.RRect.fromRectAndRadius(
        m.Rect.fromLTWH(
          size.width * 0.45,
          size.height * 0.25,
          size.width * 0.1,
          size.height * 0.5,
        ),
        m.Radius.circular(
          size.height * 0.25,
        ),
      ),
      m.Paint()..color = c.lightGray,
    );
  }

  @override
  bool shouldRepaint(covariant m.CustomPainter oldDelegate) => false;
}

/// Implements a custom widget similar to the CupertinoPicker.
///
/// Uses a [m.ListView] with children that are [m.Text] widgets that display
/// [String]s that are numbers divisible by five in the range \[5, 55\].
/// Selection is implemented by tracking the scroll state contained in an
/// [m.ScrollController].  There are 5 visible [m.Text]x at any one time and the
/// beginning and end of the list of children for the [m.ListView] is padded
/// with [m.Text]s with empty strings - this allows for the [m.Text] at the
/// center of the widget to represent the current duration selection.
///
/// Uses an [m.NotificationListener] internally to react to scroll events.  This
/// allows for the size and opacity of the children to be dependent on the
/// current scroll offset.  Additionally the widget snaps to the scroll offsets
/// of the center of the [m.Text] children.
class ReminderMinutesPicker extends m.StatefulWidget {
  const ReminderMinutesPicker({m.Key? key}) : super(key: key);

  @override
  m.State<ReminderMinutesPicker> createState() => _ReminderMinutesPickerState();
}

class _ReminderMinutesPickerState extends m.State<ReminderMinutesPicker> {

  /// The number of intervals divisible by 5 in the range [5, 55];
  static const _numItems = 11;
  /// There are 5 widgets visible at any one time, so in order to center the
  /// currently selection when scrolled to the beginning or end 2 blank
  /// [m.Text]s are added to the beginning and end of the list of children.
  static const _numSpacersPerSide = 2;
  static const _numItemsIncludingSpacers = _numItems + _numSpacersPerSide * 2;
  static const _numVisibleItems = 5;
  static const _fiveMinutes = 5;

  /// Used to set the interval between the current and destination scroll offset
  /// for which the snapping effect animation isc considered complete.
  static const _scrollAnimationEpsilon = 0.01;

  final _scrollController = m.ScrollController();

  /// The height of a child [m.Text].
  double _itemHeight = 0.0;

  /// The integer index converted to absolute scroll offset to animate towards
  /// on a [m.ScrollEndNotification].
  int _scrollSnapTo = 0;
  double _scrollPosInItemHeightUnits = _numVisibleItems.toDouble();

  @override
  void initState() {
    super.initState();

    /// Use a [Future.delayed] with the minimum duration value in order to snap
    /// to the 30 minute interval initial centered state.
    ///
    /// A Future is required to be used here because the [_scrollController] has
    /// not been assigned to a [m.ListView] until the build method has been
    /// called.
    Future.delayed(
      const Duration(microseconds: 1),
      () {
        _scrollController.jumpTo(
          _itemHeight * _numVisibleItems,
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  m.Row _buildListView() {
    return m.Row(
      crossAxisAlignment: m.CrossAxisAlignment.stretch,
      children: [
        const m.Spacer(
          flex: 2,
        ),
        m.Expanded(
          flex: 3,
          child: m.LayoutBuilder(
            builder: (context, constraints) {
              _itemHeight = constraints.maxHeight / _numVisibleItems;
              return m.NotificationListener(
                onNotification: (n) {
                  if (n is m.ScrollUpdateNotification) {
                    /// Call setState on each scroll update in order to smoothly
                    /// update the size and opacity of the list items.
                    setState(() {
                      _scrollPosInItemHeightUnits =
                          _scrollController.position.pixels / _itemHeight;
                    });
                  } else if (n is m.ScrollEndNotification) {
                    setState(() {
                      _scrollPosInItemHeightUnits =
                          _scrollController.position.pixels / _itemHeight;
                    });

                    _scrollSnapTo = _scrollPosInItemHeightUnits.round();

                    if ((_scrollPosInItemHeightUnits - _scrollSnapTo).abs() <
                        _scrollAnimationEpsilon) {
                      return true;
                    }

                    Future.delayed(
                      const Duration(microseconds: 1),
                      () {
                        _scrollController.animateTo(
                          _scrollSnapTo * _itemHeight,
                          duration: c.quarterSecond,
                          curve: m.Curves.easeOut,
                        );
                      },
                    );
                    return true;
                  }
                  return false;
                },
                child: m.ListView.builder(
                  controller: _scrollController,
                  itemCount: _numItemsIncludingSpacers,
                  padding: m.EdgeInsets.zero,
                  itemBuilder: (_context, index) {
                    String minutes;
                    if ((index - _numSpacersPerSide < 0) ||
                        (index >=
                            _numItemsIncludingSpacers - _numSpacersPerSide)) {
                      minutes = '';
                    } else {
                      minutes =
                          '${index * _numVisibleItems - _numVisibleItems}';
                    }

                    /// The value to be used as a factor in the calculation of
                    /// the [m.Text]s fontSize and opacity.
                    final fadeFactor = math
                        .cos(((_scrollPosInItemHeightUnits - index + 2.0) /
                                3.4) *
                            math.pi)
                        .abs();

                    return m.SizedBox(
                      width: constraints.maxWidth,
                      height: _itemHeight,
                      child: m.Center(
                        child: m.Text(
                          minutes,
                          style: m.TextStyle(
                            fontSize: 6.0 * fadeFactor + 18.0,
                            fontWeight: m.FontWeight.w500,
                            color: c.black2.withOpacity(
                              // math.min(1.0, fadeFactor * 1.5),
                              fadeFactor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const m.Expanded(
          flex: 1,
          child: m.Center(
            child: m.Text(
              'min',
              style: m.TextStyle(
                fontSize: 24.0,
                fontWeight: m.FontWeight.w500,
                color: c.black2,
              ),
            ),
          ),
        ),
        const m.Spacer(
          flex: 1,
        ),
      ],
    );
  }

  @override
  m.Widget build(m.BuildContext context) {
    final screenSize = m.MediaQuery.of(
      context,
    ).size;
    return m.SizedBox(
      height: screenSize.height * 0.5,
      child: m.Padding(
        padding: const m.EdgeInsets.only(
          left: 24.0,
          top: 8.0,
          right: 24.0,
          bottom: 18.0,
        ),
        child: m.Column(
          crossAxisAlignment: m.CrossAxisAlignment.stretch,
          children: [
            m.Expanded(
              flex: 1,
              child: m.CustomPaint(
                painter: ReminderMinutesPickerDragHandlePainter(),
              ),
            ),
            const m.Spacer(
              flex: 1,
            ),
            const m.Expanded(
              flex: 4,
              child: m.Text(
                'Reminder',
                textAlign: m.TextAlign.center,
                style: m.TextStyle(
                  fontSize: 23.0,
                  fontWeight: m.FontWeight.w600,
                  color: c.black2,
                ),
              ),
            ),
            const m.Spacer(
              flex: 1,
            ),
            m.Expanded(flex: 20, child: _buildListView()),
            const m.Spacer(
              flex: 1,
            ),
            m.Expanded(
              flex: 7,
              child: pb.PurpleButton(
                text: 'Done',
                onPressed: () {
                  m.Navigator.pop(
                    context,
                    math.min(
                      _numItems * _fiveMinutes,
                      math.max(
                        0,
                        _scrollSnapTo * _fiveMinutes + _fiveMinutes,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
