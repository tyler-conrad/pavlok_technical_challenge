import 'package:flutter/material.dart' as m;

import 'package:pavlok_technical_challenge/src/constants.dart' as c;
import 'package:pavlok_technical_challenge/src/widgets/screen_page_view.dart'
    as spv;

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
      initialRoute: '/',
      routes: {
        '/': (_context) => const m.Scaffold(
              body: spv.ScreenPageView(),
            ),
      },
    ),
  );
}
