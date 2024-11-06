import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubcategoryScreen extends StatelessWidget {
  final String categoryName;
  final List<String> subcategories;

  SubcategoryScreen({required this.categoryName, required this.subcategories});

  final CollectionReference bookingsCollection =
      FirebaseFirestore.instance.collection('bookings');

  void bookSubcategory(String subcategory) {
    bookingsCollection.add({
      'category': categoryName,
      'subcategory': subcategory,
      'user': 'UserID', // Replace with authenticated user ID when available
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: ListView.builder(
        itemCount: subcategories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(subcategories[index]),
            trailing: ElevatedButton(
              child: Text('Book'),
              onPressed: () {
                bookSubcategory(subcategories[index]);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${subcategories[index]} booked')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
