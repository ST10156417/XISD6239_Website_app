import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sokeconsulting/palette.dart';

class SocialButton extends StatelessWidget{
  final String iconPath;
  final String label;
  final double horizontalPadding;
  const SocialButton({Key? key, required this.iconPath, required this.label, this.horizontalPadding = 100}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return TextButton.icon(
      onPressed: () {},
      icon: SvgPicture.asset(iconPath,
      width: 25,
      color: Palette.whiteblue,),
      label: Text(label,
      style: const TextStyle(color: Palette.powderblue, 
      fontSize: 17
      ),
      ),
      style: TextButton.styleFrom(
        padding:  EdgeInsets.symmetric(vertical: 30, horizontal: horizontalPadding),
        shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: Palette.azure,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(35),
      ),
    ),
    );

  }
}