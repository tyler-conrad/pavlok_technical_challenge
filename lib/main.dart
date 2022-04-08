import 'package:flutter/material.dart' as m;

import 'package:pavlok_technical_challenge/src/constants.dart' as c;
import 'package:pavlok_technical_challenge/src/widgets/select_goal_screen.dart'
    as sgs;
import 'package:pavlok_technical_challenge/src/widgets/sleep_duration_screen.dart'
    as sds;

m.ThemeData _themeData() {
  final base = m.ThemeData.light();
  return base.copyWith(
    backgroundColor: c.backgroundColor,
    textTheme: base.textTheme.apply(
      fontFamily: 'Manrope',
    ),
  );
}

void main() {
  m.runApp(
    m.MaterialApp(
      theme: _themeData(),
      themeMode: m.ThemeMode.light,
      initialRoute: '/habit',
      routes: {
        '/habit': (_context) => const m.Scaffold(
              body: sgs.SelectGoalScreen(),
            ),
        '/sleep': (_context) => const m.Scaffold(
              body: sds.SleepDurationScreen(),
            )
      },
    ),
  );
}
