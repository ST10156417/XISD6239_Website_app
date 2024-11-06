import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure this is imported
import 'package:sokeconsulting/palette.dart';
import 'package:sokeconsulting/Services/database_service.dart'; 

class CalendarScreen extends StatefulWidget {
  final String uid;

  const CalendarScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Map<String, dynamic>>> events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchBookings(); 
  }

  void _fetchBookings() async {
    DatabaseService databaseService = DatabaseService(uid: widget.uid);
    List<Map<String, dynamic>> bookings = await databaseService.getBookings();

    for (var booking in bookings) {
      if (booking['date'] is Timestamp) {
        DateTime bookingDate = (booking['date'] as Timestamp).toDate().toLocal();
        String eventTitle = '${booking['subCategory']} (${booking['category']})';
        events[bookingDate] = (events[bookingDate] ?? [])..add({
          'title': eventTitle,
          'details': booking['details'], 
        });
      }
    }
    setState(() {}); 
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            eventLoader: (day) => _getEventsForDay(day).map((e) => e['title']).toList(),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Palette.royalblue,
              ),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Palette.powderblue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Palette.royalblue,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView(
              children: _getEventsForDay(_selectedDay ?? DateTime.now())
                  .map((event) => ListTile(
                        title: Text(
                          event['title'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          event['details'] ?? 'No details available', // Show additional details
                          style: const TextStyle(color: Colors.white70),
                        ),
                        tileColor: Palette.royalblue,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
