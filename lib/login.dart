import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sokeconsulting/Widgets/gradientbutton.dart';
import 'package:sokeconsulting/Widgets/loginfield.dart';
import 'package:sokeconsulting/Widgets/socialbutton.dart';
import 'package:sokeconsulting/signup.dart';
import 'package:sokeconsulting/Pages/home.dart';
import 'package:sokeconsulting/Helper/helper_function.dart';
import 'package:sokeconsulting/Services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Email validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Password validation
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
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        bool isSuccess = await _authService.loginUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (isSuccess) {
          await HelperFunction.setUserLoggedInStatus(true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          _showSnackbar(context, "Login failed, please check your credentials.", Colors.red);
        }
      } catch (e) {
        _showSnackbar(context, "An error occurred: $e", Colors.red);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final isSuccess = await _authService.signInWithGoogle();
      if (isSuccess) {
        await HelperFunction.setUserLoggedInStatus(true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _showSnackbar(context, "Google sign-in failed.", Colors.red);
      }
    } catch (e) {
      _showSnackbar(context, "An error occurred: $e", Colors.red);
    }
  }

  // Snackbar helper
  void _showSnackbar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(content: Text(message), backgroundColor: color);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColorLight))
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Image.asset('assets/images/sphere-removebg-preview.png'),
                        const Text(
                          'Sign In',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 50,
                          ),
                        ),
                        const SizedBox(height: 50),
                        GestureDetector(
                          onTap: _signInWithGoogle,
                          child: const SocialButton(
                            iconPath: 'assets/svg/icons8-google.svg',
                            label: 'Continue with Google',
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SocialButton(
                          iconPath: 'assets/svg/icons8-facebook.svg',
                          label: 'Continue with Facebook',
                          horizontalPadding: 90,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'or',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 15),
                        LoginField(
                          hintText: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 20),
                        LoginField(
                          hintText: 'Password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: _validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 25),
                        GradientButton(
                          onPressed: _loginUser,
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUpScreen()),
                            );
                          },
                          child: const Text(
                            "Don't have an account? Sign up instead",
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
}
