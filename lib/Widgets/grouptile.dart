import 'package:flutter/material.dart'; 
import 'package:sokeconsulting/palette.dart';
import 'package:sokeconsulting/Pages/chats.dart';

class GroupTile extends StatelessWidget {
  final String fullname;
  final String groupId;
  final String groupName;

  const GroupTile({
    Key? key, 
    required this.groupId, 
    required this.groupName, 
    required this.fullname,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              groupId: groupId,
              groupName: groupName,
              fullname: fullname,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Palette.darkblue,
            child: Text(
              groupName.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Palette.whiteblue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            groupName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Join the conversation as ${fullname}" ,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }
}
