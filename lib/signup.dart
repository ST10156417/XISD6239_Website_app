import 'package:flutter/material.dart';
import 'package:sokeconsulting/Services/auth_service.dart';
import 'package:sokeconsulting/Widgets/gradientbutton2.dart';
import 'package:sokeconsulting/Widgets/loginfield.dart';
import 'package:sokeconsulting/login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isLoading = false; // Use camelCase for variables

  AuthService authService = AuthService();
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(); // Added to manage the 'Full name' field

  bool _obscurePassword = true; // Password visibility toggle

  // Email validation function
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Password validation function
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose(); // Dispose the 'Full name' controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColorLight))
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Form(
                    key: _formKey, // Form key for validation
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8, // Constrain image width to 80% of screen
                          child: Image.asset(
                            'assets/images/sphere2-removebg-preview.png',
                            height: 250, // Restrict height
                          ),
                        ),
                        const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 50,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // 'Full name' field with controller
                        LoginField(
                          hintText: 'Full name',
                          controller: _nameController, // Added controller for 'Full name'
                        ),

                        const SizedBox(height: 15),

                        // 'Email' field
                        LoginField(
                          hintText: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),

                        const SizedBox(height: 20),

                        // 'Password' field
                        LoginField(
                          hintText: 'Password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: _validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              // Only rebuild when necessary
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Sign Up button
                        GradientButton2(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              // Call the register method
                              register();
                            }
                          },
                        ),

                        const SizedBox(height: 15),

                        // Navigate to login
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Have an account? Sign in instead.",
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> register() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Capture the input values before registering
      String fullname = _nameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      setState(() {
        _isLoading = true;
      });

      try {
        // Call the AuthService to register the user
        String result = await authService.registerUserWithEmailandPassword(fullname, email, password);

        if (result == 'success') {
          // If registration is successful, navigate to the login screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          // If registration fails, show a snackbar with the error message
          showSnackbar(context, result, Colors.red);
        }
      } catch (e) {
        // Handle any errors that may occur during the registration
        showSnackbar(context, "An error occurred: $e", Colors.red);
      } finally {
        // Ensure that the loading spinner is hidden once the process completes
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to show snackbars for notifications
  void showSnackbar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(content: Text(message), backgroundColor: color);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
