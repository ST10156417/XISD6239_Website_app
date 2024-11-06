import 'package:flutter/material.dart';
import 'package:sokeconsulting/Pages/feedback.dart';
import 'package:sokeconsulting/Pages/support.dart';
import 'package:sokeconsulting/Pages/calendar.dart';
import 'package:sokeconsulting/Pages/messages.dart';
import 'package:sokeconsulting/Pages/events.dart';
import 'package:sokeconsulting/Pages/profile.dart';
import 'package:sokeconsulting/Services/auth_service.dart';
import 'package:sokeconsulting/Widgets/navbar.dart';
import 'package:sokeconsulting/palette.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SokeMM',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _username = "User"; // Default value
  String? _uid;
  bool _isLoading = true;
  final AuthService _authService = AuthService();
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final username = await _authService.getCurrentUserName() ?? "User";
    final uid = await _authService.getCurrentUserId();

    setState(() {
      _username = username;
      _uid = uid;

      _pages = [
        HomeContent(onContactAdmin: _sendEmail),
        CalendarScreen(uid: uid!),
        const MessageScreen(),
        EventsScreen(uid: uid!),
        const ProfileScreen(),
      ];
      _isLoading = false;
    });
  }

  void _sendEmail() async {
    const String email = 'admin@company.com';
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Inquiry',
        'body': 'Hello, I would like to inquire about...',
      }),
    );
    await launch(emailLaunchUri.toString());
  }

  String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Widget _buildWelcomeBanner() {
    if (_currentIndex == 0 && !_isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Palette.royalblue, Palette.powderblue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          "Welcome to SokeMM, $_username!",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 80),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _pages[_currentIndex],
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _buildWelcomeBanner(),
          ),
        ],
      ),
      bottomNavigationBar: Navbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index >= 0 && index < _pages.length) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final Function onContactAdmin;

  const HomeContent({Key? key, required this.onContactAdmin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              _buildCardGrid(context),
              _buildImageGallery(), 
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: [
          _buildCard('Feedback Hub', 'Submit and view feedback', Icons.feedback, context, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackPage()));
          }),
          _buildCard('Support/Help', 'Access FAQs and support', Icons.help, context, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportPage()));
          }),
          
        ],
      ),
    );
  }

  Widget _buildCard(String title, String subtitle, IconData icon, BuildContext context, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Image Gallery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          children: List.generate(6, (index) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: AssetImage('assets/images/stocks/stock1${index + 1}.jpg'), 
                  fit: BoxFit.cover,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
