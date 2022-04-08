# pavlok_technical_challenge

A mockup of a couple screens in Flutter for part of the Pavlok hiring process.

The project consists of two main screens.  The first screen allows you to select from either good or bad habits using
tabs.  By clicking a tab header a list of buttons representing good or bad habits is displayed.  The second screen uses
a circular duration picker to set times to go to bed and wake up.  A reminder time can be selected using a modal bottom
sheet that displays a custom widget similar to a CupertinoSelect widget provided by the Flutter library.

This project implements a few custom widgets.  The most complex of these is the CircularDurationPicker.  This widget
allows you to select a duration using 2 handles that can be rotated around a central point.  The handles represent a
time of day in a 24-hour period.  The widget updates the handle positions when they are dragged and the start, end and
time between durations are calculated and displayed to the user.