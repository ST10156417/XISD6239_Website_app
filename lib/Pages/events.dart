import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokeconsulting/palette.dart';
import 'package:sokeconsulting/Services/database_service.dart'; 

class EventsScreen extends StatelessWidget {
  const EventsScreen({Key? key, required this.uid}) : super(key: key);
  final String uid;

  // Fetch booking categories from DatabaseService
  Future<Map<String, List<String>>> fetchCategories() async {
    DatabaseService databaseService = DatabaseService();
    return await databaseService.getBookingCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Palette.royalblue, Palette.powderblue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            elevation: 0,
            title: Center(
              child: const Text(
                'Booking System',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, List<String>>>(
        future: fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories available'));
          }

          final categories = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: categories.entries.map((entry) {
              String category = entry.key;
              List<String> subCategories = entry.value;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                child: ExpansionTile(
                  title: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: subCategories.map((subCategory) {
                    return ListTile(
                      title: Text(subCategory),
                      onTap: () {
                        _showBookingDialog(context, category, subCategory);
                      },
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showBookingDialog(BuildContext context, String category, String subCategory) {
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Book Service'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose a date for "$subCategory" under "$category":'),
              SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    selectedDate = date;
                  }
                },
                child: Text(selectedDate == null
                    ? 'Select Date'
                    : 'Selected: ${selectedDate!.toLocal()}'.split(' ')[0]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedDate != null) {
                  DatabaseService databaseService = DatabaseService(uid: uid);
                  try {
                    await databaseService.bookService(category, subCategory, selectedDate!);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Successfully booked $subCategory')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to book service: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a date')),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
