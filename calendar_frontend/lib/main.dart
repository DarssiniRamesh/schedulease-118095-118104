import 'package:flutter/material.dart';
import 'package:calendar_frontend/src/calendar_home.dart';

/// Entry point for the calendar frontend application
void main() {
  runApp(const MyApp());
}

// PUBLIC_INTERFACE
class MyApp extends StatelessWidget {
  /// The root widget for the Calendar App.
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedulease Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const CalendarHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}
