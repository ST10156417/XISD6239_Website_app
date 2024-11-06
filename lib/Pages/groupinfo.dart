import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sokeconsulting/Pages/messages.dart';
import 'package:sokeconsulting/Services/database_service.dart';
import 'package:sokeconsulting/palette.dart';

class GroupInfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;

  const GroupInfo({
    Key? key,
    required this.adminName,
    required this.groupName,
    required this.groupId,
  }) : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;

  @override
  void initState() {
    super.initState();
    getMembers(); // Ensure getMembers is called after super.initState()
  }

  void getMembers() {
    members = DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId);
  }

  String getName(String r) {
    int underscoreIndex = r.indexOf("_");
    return (underscoreIndex != -1 && underscoreIndex + 1 < r.length)
        ? r.substring(underscoreIndex + 1)
        : r; // Returns the original string if no underscore is found
  }

  String getId(String res) {
    int underscoreIndex = res.indexOf("_");
    return (underscoreIndex != -1)
        ? res.substring(0, underscoreIndex)
        : res; // Returns the original string if no underscore is found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          "Group Info",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Palette.whiteblue,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Exit Group"),
                    content: const Text("Are you sure you want to exit the group?"),
                    actions: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await DatabaseService(
                                  uid: FirebaseAuth.instance.currentUser!.uid)
                              .toggleGroupJoin(
                                  widget.groupId,
                                  getName(widget.adminName),
                                  widget.groupName)
                              .whenComplete(() {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const MessageScreen()),
                            );
                          });
                        },
                        icon: const Icon(
                          Icons.done,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Palette.navy.withOpacity(0.2),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Palette.babyblue,
                    child: Text(
                      widget.groupName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Palette.whiteblue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Group: ${widget.groupName}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 5),
                      Text("Admin: ${getName(widget.adminName)}"),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: memberList()),
          ],
        ),
      ),
    );
  }

  Widget memberList() {
    return StreamBuilder(
      stream: members,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Palette.azure),
          );
        }

        if (snapshot.hasData && snapshot.data['members'] != null) {
          var membersList = snapshot.data['members'];
          if (membersList.isNotEmpty) {
            return ListView.builder(
              itemCount: membersList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Palette.babyblue,
                      child: Text(
                        getName(membersList[index]).substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Palette.whiteblue,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(getName(membersList[index])),
                    subtitle: Text(getId(membersList[index])),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text("NO MEMBERS YET"),
            );
          }
        } else {
          return const Center(
            child: Text("NO MEMBERS YET"),
          );
        }
      },
    );
  }
}
