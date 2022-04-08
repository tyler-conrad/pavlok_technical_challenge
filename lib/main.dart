import 'package:flutter/material.dart' as m;
import 'package:flutter/foundation.dart' as f;
import 'package:device_preview/device_preview.dart' as dp;

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

//todo
void main() {
  m.runApp(
    dp.DevicePreview(
      enabled: !f.kReleaseMode,
      builder: (context) => m.MaterialApp(
        useInheritedMediaQuery: true,
        locale: dp.DevicePreview.locale(
          context,
        ),
        builder: dp.DevicePreview.appBuilder,
        theme: _themeData(),
        themeMode: m.ThemeMode.light,
        initialRoute: '/',
        routes: {
          '/': (_context) => const m.Scaffold(
                body: spv.ScreenPageView(),
              ),
        },
      ),
    ),
  );
}
//todo
