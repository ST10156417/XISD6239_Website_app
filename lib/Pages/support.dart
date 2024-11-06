import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _faqItem(
            context,
            question: 'What services do we offer?',
            answer:
                'We provide a variety of services including project management, consulting, and product development.',
          ),
          _faqItem(
            context,
            question: 'How can I contact support?',
            answer:
                'You can contact our support team via email at sokemm@gmail.com.com or call us at (011) 456-7890.',
          ),
          _faqItem(
            context,
            question: 'What are the working hours?',
            answer: 'Our working hours are Monday to Friday, 9 AM to 5 PM.',
          ),
          _faqItem(
            context,
            question: 'Where are you located?',
            answer: 'We are located at Menlyn corporate Park.',
          ),
        ],
      ),
    );
  }

  Widget _faqItem(BuildContext context, {required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SupportPage(),
  ));
}
