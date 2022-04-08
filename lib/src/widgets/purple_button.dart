import 'package:flutter/material.dart' as m;

import 'package:pavlok_technical_challenge/src/constants.dart' as c;


/// A [m.ElevatedButton] used at the bottom of the screen for 'Next' and 'Done'
///
/// The width and height of the button are determined by the containing widgets
/// bounds - this allows the button to be scaled to different screen sizes and
/// pixel ratios.
class PurpleButton extends m.StatelessWidget {
  const PurpleButton({
    m.Key? key,
    required String text,
    required void Function() onPressed,
  })  : _text = text,
        _onPressed = onPressed,
        super(
          key: key,
        );

  final String _text;
  final void Function() _onPressed;

  @override
  m.Widget build(
    m.BuildContext context,
  ) {
    return m.Column(
      crossAxisAlignment: m.CrossAxisAlignment.stretch,
      children: [
        const m.Spacer(
          flex: 1,
        ),
        m.Expanded(
          flex: 8,
          child: m.ElevatedButton(
            onPressed: _onPressed,
            style: m.ButtonStyle(
              elevation: m.MaterialStateProperty.all(
                16.0,
              ),
              backgroundColor: m.MaterialStateProperty.all(
                c.purple,
              ),
              shadowColor: m.MaterialStateProperty.all(
                c.purple,
              ),
              shape: m.MaterialStateProperty.all(
                m.RoundedRectangleBorder(
                  borderRadius: m.BorderRadius.circular(
                    16.0,
                  ),
                ),
              ),
            ),
            child: m.Text(
              _text,
              style: const m.TextStyle(
                color: m.Colors.white,
                fontSize: 16.0,
                fontWeight: m.FontWeight.w600,
              ),
            ),
          ),
        ),
        const m.Spacer(
          flex: 2,
        ),
      ],
    );
  }
}
