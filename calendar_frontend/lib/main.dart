import 'package:flutter/material.dart';
import 'src/calendar_home.dart';

void main() {
  runApp(const MyApp());
}

/// PUBLIC_INTERFACE
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Builds the root MaterialApp and sets the home to the calendar UI.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedulease',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CalendarHome(),
    );
  }
}
