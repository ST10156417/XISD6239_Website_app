import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sokeconsulting/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (_user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(_user!.uid).get();
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>? ?? {};
        });
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  void _signOut() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _deleteAccount() async {
    if (_user != null) {
      try {
        await _firestore.collection('users').doc(_user!.uid).delete();
        await _user!.delete();
        _signOut();
      } catch (e) {
        print('Error deleting account: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: _userData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 20),
                    _buildUserDetails(),
                    const SizedBox(height: 20),
                    _buildSignOutButton(),
                    const SizedBox(height: 10),
                    _buildDeleteAccountButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/img/profile.jpg'),
            ),
            const SizedBox(height: 15),
            Text(_userData?['fullname'] ?? 'Loading...'),
            const SizedBox(height: 5),
            Text('UID: ${_user?.uid ?? 'Unavailable'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('User Details'),
            const SizedBox(height: 10),
            _buildDetailRow('Email:', _userData?['email'] ?? 'Loading...'),
            _buildDetailRow('Phone:', _userData?['phone'] ?? 'Not provided'),
            _buildDetailRow('Address:', _userData?['address'] ?? 'No address on file'),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return ElevatedButton.icon(
      onPressed: _signOut,
      icon: const Icon(Icons.exit_to_app),
      label: const Text('Sign Out'),
    );
  }

  Widget _buildDeleteAccountButton() {
    return ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Account Deletion'),
            content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteAccount();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.delete),
      label: const Text('Delete Account'),
    );
  }
}
