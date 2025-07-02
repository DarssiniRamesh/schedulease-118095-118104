import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// PUBLIC_INTERFACE
/// CalendarHomePage displays a monthly calendar with events.
/// Users can add new events, which are displayed on their respective days.
/// Event data is kept in memory for now; can be extended to use local storage.
class CalendarHome extends StatefulWidget {
  const CalendarHome({super.key});

  @override
  State<CalendarHome> createState() => _CalendarHomeState();
}

class _CalendarHomeState extends State<CalendarHome> {
  // Store events: Map keyed by yyyy-MM-dd -> List of event titles
  final Map<String, List<CalendarEvent>> _events = {};

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  // Helper: Find first day for calendar view grid (start of week for 1st)
  DateTime get _monthStartGrid {
    // Assume week starts on Sunday
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    return firstDay.subtract(Duration(days: firstDay.weekday % 7));
  }

  // Removed unused _monthEndGrid

  // Format: 'yyyy-MM-dd'
  String dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  // Show dialog to create event
  // PUBLIC_INTERFACE
  Future<void> _showAddEventDialog({DateTime? selectedDate}) async {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime picked = selectedDate ?? DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Event'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Title', icon: Icon(Icons.event)),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Description', icon: Icon(Icons.notes)),
                  minLines: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: picked,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (d != null) {
                            setState(() => picked = d);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            DateFormat('EEE, MMM d, yyyy').format(picked),
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Save
                  setState(() {
                    final key = dateKey(picked);
                    (_events[key] ??= []).add(CalendarEvent(
                      date: picked,
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Drawing the calendar grid cells (days)
  Widget _monthGrid() {
    final today = dateKey(DateTime.now());
    final d0 = _monthStartGrid;

    List<Widget> rows = [];
    DateTime cursor = d0;
    for (int row = 0; row < 6; row++) {
      List<Widget> days = [];
      for (int col = 0; col < 7; col++) {
        final dayKey = dateKey(cursor);
        final isCurrentMonth = cursor.month == _selectedMonth.month;
        final eventList = _events[dayKey] ?? [];

        days.add(
          GestureDetector(
            onTap: () async {
              // Optionally display events or allow add event for this date
              await _showAddEventDialog(selectedDate: cursor);
            },
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: dayKey == today
                    // Use .withAlpha for modern Flutter, casting from 0-1 to 0-255
                    ? Theme.of(context).colorScheme.primary.withAlpha((0.2 * 255).toInt())
                    : isCurrentMonth
                        ? Colors.transparent
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: eventList.isNotEmpty
                    ? Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 1)
                    : null,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 4,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        '${cursor.day}',
                        style: TextStyle(
                            color: isCurrentMonth
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 15),
                      ),
                    ),
                  ),
                  if (eventList.isNotEmpty)
                    Positioned(
                      bottom: 2,
                      left: 0,
                      right: 0,
                      child: _eventDots(eventList),
                    ),
                ],
              ),
            ),
          ),
        );
        cursor = cursor.add(const Duration(days: 1));
      }
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: days.map((w) => Expanded(child: SizedBox(height: 54, child: w))).toList(),
      ));
    }

    return Column(
      children: rows,
    );
  }

  Widget _eventDots(List<CalendarEvent> events) {
    // Show up to 3 dots to indicate events
    int n = events.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        n > 3 ? 3 : n,
        (ix) => Container(
          margin: EdgeInsets.symmetric(horizontal: 1.5),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // App bar title is the current month
  String get _monthTitle =>
      DateFormat('MMMM yyyy').format(_selectedMonth);

  // Switch months
  void _goPrevMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _goNextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_monthTitle),
        actions: [
          IconButton(
              onPressed: _goPrevMonth,
              icon: const Icon(Icons.chevron_left)),
          IconButton(
              onPressed: _goNextMonth,
              icon: const Icon(Icons.chevron_right)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _weekdayHeader(),
            const SizedBox(height: 4),
            Expanded(child: _monthGrid()),
            const SizedBox(height: 6),
            _eventListForDayBox(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(),
        tooltip: "Add Event",
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _weekdayHeader() {
    final days =
        ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: days.map((d) {
        return Expanded(
          child: Center(
            child: Text(
              d,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Optionally show events for today or last event-clicked day (for demo, just today)
  Widget _eventListForDayBox() {
    final todayKey = dateKey(DateTime.now());
    final list = _events[todayKey] ?? [];
    if (list.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today\'s Events:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...list.map((e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e.title),
                  subtitle: e.description.isNotEmpty
                      ? Text(e.description)
                      : null,
                )),
          ],
        ),
      ),
    );
  }
}

// Data model for a calendar event
// PUBLIC_INTERFACE
class CalendarEvent {
  final DateTime date;
  final String title;
  final String description;
  CalendarEvent(
      {required this.date, required this.title, required this.description});
}
