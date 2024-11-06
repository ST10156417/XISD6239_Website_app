import 'package:flutter/material.dart';
import 'package:sokeconsulting/palette.dart';

class GradientButton2 extends StatelessWidget {
  final VoidCallback? onPressed; 
  final String text; 

  const GradientButton2({
    Key? key,
    required this.onPressed,
    this.text = 'Sign up', 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Palette.navy,
            Palette.royalblue,
            Palette.darkblue,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed: onPressed, 
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(395, 55),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}
