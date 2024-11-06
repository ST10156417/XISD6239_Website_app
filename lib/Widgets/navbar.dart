import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:sokeconsulting/palette.dart';

class Navbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  

  const Navbar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SalomonBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        SalomonBottomBarItem(
          icon: Icon(Icons.home), 
          title: Text("Home"),
          selectedColor: Palette.royalblue, 
        ),
        SalomonBottomBarItem(
          icon: Icon(Icons.calendar_month), 
          title: Text("Calendar"),
          selectedColor: Palette.darkblue,
        ),
        SalomonBottomBarItem(
          icon: Icon(Icons.message), 
          title: Text("Messages"),
          selectedColor: Palette.azure,
        ),
        SalomonBottomBarItem(
          icon: Icon(Icons.event), 
          title: Text("Events"),
          selectedColor: Palette.deepsky,
        ),
        SalomonBottomBarItem(
          icon: Icon(Icons.person), 
          title: Text("Profile"),
          selectedColor: Palette.skyblue,
        ),
      ],
    );
  }
}
