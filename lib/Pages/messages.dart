import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sokeconsulting/Pages/searchpage.dart';
import 'package:sokeconsulting/Services/database_service.dart';
import 'package:sokeconsulting/Widgets/grouptile.dart';
import 'package:sokeconsulting/palette.dart';
import 'package:sokeconsulting/Helper/helper_function.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  String fullname = "";
  String email = "";
  List<String> groupList = [];
  bool _isLoading = false;
  String groupName = "";

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

String getId(String res){
  return res.substring(res.indexOf("_"));
}

  Future<void> _initializeUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      email = await HelperFunction.getUserEmail() ?? "";
      fullname = await HelperFunction.getUserName() ?? "";

      FirebaseFirestore.instance.collection("users").doc(uid).snapshots().listen((snapshot) {
        if (snapshot.exists) {
          setState(() {
            groupList = List<String>.from(snapshot.data()?['groups'] ?? []);
          });
        }
      });
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Searchpage()),
              );
            },
            icon: const Icon(Icons.search, color: Palette.whiteblue),
          )
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Groups",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Palette.whiteblue,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupDialog(),
        backgroundColor: Palette.azure,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildGroupList(),
    );
  }

  void _showCreateGroupDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create a group"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading)
              Center(child: CircularProgressIndicator(color: Palette.royalblue))
            else
              TextField(
                onChanged: (val) => setState(() => groupName = val),
                style: const TextStyle(color: Palette.whiteblue),
                decoration: InputDecoration(
                  hintText: "Enter group name",
                  hintStyle: TextStyle(color: Palette.whiteblue.withOpacity(0.6)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Palette.navy),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Palette.navy),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(backgroundColor: Palette.skyblue),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: _createGroup,
            style: ElevatedButton.styleFrom(backgroundColor: Palette.skyblue),
            child: const Text("CREATE"),
          ),
        ],
      ),
    );
  }

  Future<void> _createGroup() async {
    if (groupName.isEmpty) return;

    setState(() => _isLoading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      try {
        setState(() {
          groupList.add("temp_$groupName");
        });

        await DatabaseService(uid: uid).createGroup(fullname, uid, groupName);

        setState(() => _isLoading = false);
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Group has been created!"), backgroundColor: Palette.skyblue),
        );
      } catch (e) {
        setState(() {
          groupList.removeWhere((group) => group == "temp_$groupName");
          _isLoading = false;
        });
        debugPrint("Error creating group: $e");
      }
    }
  }

  Widget _buildGroupList() {
    if (groupList.isEmpty) {
      return _noGroupWidget();
    } else {
      return ListView.builder(
        itemCount: groupList.length,
        itemBuilder: (context, index) {
          String groupData = groupList[index];
          List<String> groupInfo = groupData.split('_');
          String groupId = groupInfo[0];
          String groupName = groupInfo[1];

          return GroupTile(
            groupId: groupId,
            groupName: groupName,
            fullname: fullname,
          );
        },
      );
    }
  }

  Widget _noGroupWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _showCreateGroupDialog(),
            child: const Icon(Icons.add_circle, color: Palette.royalblue, size: 70),
          ),
          const SizedBox(height: 20),
          const Text(
            "You haven't joined a group yet!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Palette.skyblue),
          ),
        ],
      ),
    );
  }
}
