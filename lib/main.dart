import 'package:flutter/material.dart' as m;

import 'package:pavlok_technical_challenge/constants.dart' as c;
import 'package:pavlok_technical_challenge/widgets/select_goal_screen.dart'
    as sgs;
import 'package:pavlok_technical_challenge/widgets/sleep_duration_screen.dart'
    as sds;
import 'package:responsive_sizer/responsive_sizer.dart' as sizer;

class HabitApp extends m.StatelessWidget {
  const HabitApp({m.Key? key}) : super(key: key);

  @override
  m.Widget build(m.BuildContext context) {
    return m.MaterialApp(
      theme: _themeData(),
      themeMode: m.ThemeMode.light,
      initialRoute: '/habit',
      builder: (context, child) {
        return sizer.ResponsiveSizer(
          builder: (_context, _orientation, _screenType) =>
              m.Scaffold(body: child!),
        );
      },
      routes: {
        '/habit': (_context) => const sgs.SelectGoalScreen(),
        '/sleep': (_context) => const sds.SleepDurationScreen(),
      },
    );
  }
}

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
  m.runApp(const HabitApp());
}
