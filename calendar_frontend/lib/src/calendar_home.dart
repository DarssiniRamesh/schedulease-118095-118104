import 'package:flutter/material.dart';

// PUBLIC_INTERFACE
class CalendarHome extends StatelessWidget {
  /// The main calendar interface for the app.
  /// Displays a placeholder real calendar until full event logic is implemented.
  const CalendarHome({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with an actual calendar/event list as needed.
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScheduleEase Calendar'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.calendar_today, size: 72, color: Colors.blue),
            SizedBox(height: 24),
            Text(
              'Welcome to your Calendar!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Your scheduled events will appear here.\nUse the + button to add a new event.'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Show event scheduling UI.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add event (not implemented yet)')),
          );
        },
        tooltip: 'Schedule Event',
        child: const Icon(Icons.add),
      ),
    );
  }
}
