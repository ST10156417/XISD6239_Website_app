import 'package:flutter/material.dart';
import 'package:sokeconsulting/palette.dart';

class LoginField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller; // To control the text field input
  final bool obscureText; // To handle password field obscuring
  final Widget? suffixIcon; // To allow passing an icon for password visibility toggle
  final TextInputType? keyboardType; // To specify keyboard type (email or text)
  final String? Function(String?)? validator; // For field validation

  const LoginField({
    Key? key,
    required this.hintText,
    this.controller,
    this.obscureText = false, // By default, text is not obscured (i.e., password field)
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      child: TextFormField(
        controller: controller, 
        obscureText: obscureText, 
        keyboardType: keyboardType, 
        validator: validator, 
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(27),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Palette.azure,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(35),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Palette.skyblue,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(35),
          ),
          hintText: hintText, 
          suffixIcon: suffixIcon, 
        ),
      ),
    );
  }
}

void showSnackbar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      backgroundColor: color, 
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: "Ok",
        onPressed: () {},
        textColor: Palette.whiteblue,
      ),
    ),
  );
}
