import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();

  void _sendFeedback() async {
    final String feedback = _feedbackController.text.trim();
    if (feedback.isNotEmpty) {
      const String email = 'ST10076452@vcconnect.edu.za'; 
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: email,
        query: _encodeQueryParameters(<String, String>{
          'subject': 'Feedback from User',
          'body': feedback,
        }),
      );

      if (await launch(emailLaunchUri.toString())) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback sent!')),
        );
        _feedbackController.clear();
      } else {
        // Failure
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send feedback.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter feedback.')),
      );
    }
  }

  String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback Hub')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We value your feedback! Please share your thoughts below:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your feedback here...',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendFeedback,
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
