# pavlok_technical_challenge

A mockup of a couple screens in Flutter for part of the Pavlok hiring process.

This project consists of two main screens. The first screen allows you to select from either good or bad habits using
tabs. By clicking a tab header a list of buttons representing good or bad habits is displayed. The second screen uses a
circular duration picker to set times to go to bed and wake up. A reminder time can be selected using a modal bottom
sheet that displays a custom widget similar to the CupertinoSelect provided by the Flutter library.

I have implemented a few custom widgets. The most complex of these is the CircularDurationPicker. This widget
allows you to select a duration using 2 handles that can be rotated around a central point. The handles represent a time
of day in a 24-hour period. The widget updates the handle positions when they are dragged and the start and end time
between are calculated and displayed to the user.

There was a bug with SVG icons not rendering on Android, the fix was to use the AssetBundle api instead of dart:io to
load the images.

Project documentation is available [here](https://tyler-conrad.github.io/pavlok_technical_challenge/).

![Demo](assets/demo.gif)

Tested on:

- Ubuntu 20.04.3 LTS

---

- Android 11
- Galaxy Tab A8

---

- Flutter 2.12.0-4.2.pre • channel beta • https://github.com/flutter/flutter.git
- Framework • revision 5c931b769b (10 days ago) • 2022-03-29 10:49:29 -0500
- Engine • revision 486f4a749e
- Tools • Dart 2.17.0 (build 2.17.0-182.2.beta) • DevTools 2.11.1
