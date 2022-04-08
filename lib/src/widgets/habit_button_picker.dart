import 'package:flutter/material.dart' as m;
import 'package:collection/collection.dart';

import 'package:pavlok_technical_challenge/src/shared.dart' as s;
import 'package:pavlok_technical_challenge/src/widgets/habit_button.dart' as hb;


/// Represents a list of either good or bad [hb.HabitButton]s.  This widget
/// takes a single [s.HabitType] constructor argument that determines whether a
/// list of good or bad habits should be built as the children of this widget.
///
/// The fixed state of the different [hb.HabitButton]s is contained in this
/// class.  Additionally the logic mutually exclusive selection is implemented
/// here.
class HabitButtonPicker extends m.StatefulWidget {
  const HabitButtonPicker({
    m.Key? key,
    required s.HabitType habitType,
  })  : _selectedHabitType = habitType,
        super(
          key: key,
        );

  final s.HabitType _selectedHabitType;

  @override
  m.State<HabitButtonPicker> createState() => _HabitButtonPickerState();
}

class _HabitButtonPickerState extends m.State<HabitButtonPicker> {
  late final List<hb.HabitButton> _goodHabitButtons;
  late final List<hb.HabitButton> _badHabitButtons;

  late final List<m.Padding> _paddedGoodHabitButtons;
  late final List<m.Padding> _paddedBadHabitButtons;

  /// Whenever a [hb.HabitButton] is pressed this function deselects all buttons
  /// including the one pressed.  The button that was pressed contains logic
  /// within its onPressed callback reselect the pressed habit button and this
  /// results in mutual exclusion for selection.
  void _onGoodHabitButtonPress() {
    for (hb.HabitButton habitButton in _goodHabitButtons) {
      habitButton.selected.value = false;
    }
  }

  /// See [_onGoodHabitButtonPress]
  void _onBadHabitButtonPress() {
    for (hb.HabitButton habitButton in _badHabitButtons) {
      habitButton.selected.value = false;
    }
  }

  /// Initialize the fixed state of the bad habit buttons and populates the
  /// [_paddedBadHabitButtons] field.
  void _setupAndPadBadHabitButtons() {
    _badHabitButtons = [
      hb.HabitButton(
        onPressed: _onBadHabitButtonPress,
        text: "Can't wake up",
        svgAssetPath: 'assets/svg/sleep.svg',
        position: const m.Offset(
          2.0,
          6.0,
        ),
      ),
      hb.HabitButton(
        onPressed: _onBadHabitButtonPress,
        text: 'Getting lazy for workout',
        svgAssetPath: 'assets/svg/boot.svg',
        position: const m.Offset(
          -8.0,
          4.0,
        ),
      ),
      hb.HabitButton(
        onPressed: _onBadHabitButtonPress,
        text: 'Forgetting to drink water',
        svgAssetPath: 'assets/svg/bottle.svg',
        position: const m.Offset(
          8.0,
          4.0,
        ),
      ),
      hb.HabitButton(
        onPressed: _onBadHabitButtonPress,
        text: 'Spending on credit cards',
        svgAssetPath: 'assets/svg/donate.svg',
        position: const m.Offset(
          -2.0,
          6.0,
        ),
      ),
    ];

    _paddedBadHabitButtons = _badHabitButtons
        .mapIndexed(
          addBottomPaddingToAllButLast(
            _badHabitButtons.length,
          ),
        )
        .toList();
  }

  /// Initialize the fixed state of the good habit buttons and populates the
  /// [_paddedGoodHabitButtons] field.
  void _setupAndPadGoodHabitButtons() {
    _goodHabitButtons = [
      hb.HabitButton(
        onPressed: _onGoodHabitButtonPress,
        text: 'Set bedtime and wake up',
        svgAssetPath: 'assets/svg/sleep.svg',
        position: const m.Offset(
          2.0,
          6.0,
        ),
      ),
      hb.HabitButton(
        onPressed: _onGoodHabitButtonPress,
        text: 'Take a walk',
        svgAssetPath: 'assets/svg/boot.svg',
        position: const m.Offset(
          -8.0,
          4.0,
        ),
      ),
      hb.HabitButton(
        onPressed: _onGoodHabitButtonPress,
        text: 'Stay hydrated',
        svgAssetPath: 'assets/svg/bottle.svg',
        position: const m.Offset(
          8.0,
          4.0,
        ),
      ),
      hb.HabitButton(
        onPressed: _onGoodHabitButtonPress,
        text: 'Call parents',
        svgAssetPath: 'assets/svg/phone.svg',
        position: const m.Offset(
          8.0,
          4.0,
        ),
      ),
      hb.HabitButton(
        onPressed: _onGoodHabitButtonPress,
        text: 'Donate to charity',
        svgAssetPath: 'assets/svg/donate.svg',
        position: const m.Offset(
          -2.0,
          6.0,
        ),
      ),
    ];

    _paddedGoodHabitButtons = _goodHabitButtons
        .mapIndexed(
          addBottomPaddingToAllButLast(
            _goodHabitButtons.length,
          ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _setupAndPadGoodHabitButtons();
    _setupAndPadBadHabitButtons();
  }

  ///Adds padding around a habit button.
  m.Padding Function(
    int,
    hb.HabitButton,
  ) addBottomPaddingToAllButLast(
    int numHabitButtons,
  ) =>
      (index, habitButton) => index == numHabitButtons - 1
          ? m.Padding(
              padding: m.EdgeInsets.zero,
              child: habitButton,
            )
          : m.Padding(
              padding: const m.EdgeInsets.only(
                bottom: 16.0,
              ),
              child: habitButton,
            );

  @override
  m.Widget build(m.BuildContext context) {
    return m.Column(
      mainAxisAlignment: m.MainAxisAlignment.start,
      crossAxisAlignment: m.CrossAxisAlignment.stretch,
      children: widget._selectedHabitType == s.HabitType.good
          ? _paddedGoodHabitButtons
          : _paddedBadHabitButtons,
    );
  }
}
