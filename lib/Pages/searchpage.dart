import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sokeconsulting/Helper/helper_function.dart';
import 'package:sokeconsulting/Pages/chats.dart';
import 'package:sokeconsulting/Services/database_service.dart';
import 'package:sokeconsulting/Widgets/grouptile.dart';
import 'package:sokeconsulting/Widgets/loginfield.dart';
import 'package:sokeconsulting/palette.dart';

class Searchpage extends StatefulWidget {
  const Searchpage({Key? key}) : super(key: key);

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  bool isLoading = false;
  Stream<QuerySnapshot>? searchSnapshot;
  bool hasUserSearched = false;
  String fullname = "";
  User? user;
  bool isJoined = false;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
  }

  Future<void> getCurrentUserIdandName() async {
    fullname = (await HelperFunction.getUserName()) ?? '';
    user = FirebaseAuth.instance.currentUser;
    setState(() {}); // Trigger a rebuild after fetching user data
  }

  String getName(String r) {
    int underscoreIndex = r.indexOf("_");
    return underscoreIndex != -1 && underscoreIndex + 1 < r.length
        ? r.substring(underscoreIndex + 1)
        : r;
  }

  String getId(String res) {
    int underscoreIndex = res.indexOf("_");
    return underscoreIndex != -1 && underscoreIndex + 1 < res.length
        ? res.substring(underscoreIndex + 1)
        : res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Search",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Palette.whiteblue,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Palette.deepsky,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Palette.whiteblue),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search groups",
                      hintStyle: TextStyle(color: Palette.whiteblue, fontSize: 16),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => initiateSearchMethod(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Palette.whiteblue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(Icons.search, color: Palette.whiteblue),
                  ),
                ),
              ],
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator(color: Palette.deepsky))
              : groupList(),
        ],
      ),
    );
  }

  void initiateSearchMethod() {
    if (searchController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      searchSnapshot = DatabaseService().searchByName(searchController.text).asStream();
      setState(() {
        isLoading = false;
        hasUserSearched = true;
      });
    }
  }

  Widget groupList() {
    return hasUserSearched
        ? StreamBuilder<QuerySnapshot>(
            stream: searchSnapshot,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Palette.deepsky));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No groups found"));
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final groupData = snapshot.data!.docs[index];
                  return groupTile(
                    fullname,
                    groupData['groupId'],
                    groupData['groupName'],
                    groupData['admin'],
                  );
                },
              );
            },
          )
        : Container();
  }

  Future<void> joinedOrNot(String fullname, String groupId, String groupName, String admin) async {
    isJoined = await DatabaseService(uid: user!.uid).isUserJoined(groupName, groupId, fullname);
    setState(() {}); // Trigger a rebuild to update join status
  }

  Widget groupTile(String fullname, String groupId, String groupName, String admin) {
    joinedOrNot(fullname, groupId, groupName, admin);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Palette.deepsky,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Palette.whiteblue),
        ),
      ),
      title: Text(
        groupName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text("Admin: ${getName(admin)}"),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: user!.uid).toggleGroupJoin(groupId, fullname, groupName);
          if (isJoined) {
            setState(() {
              isJoined = !isJoined;
            });
            showSnackbar(context, Palette.skyblue, "Successfully Joined!");
            Future.delayed(const Duration(seconds: 3), () {
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
            });
          } else {
            setState(() {
              isJoined = !isJoined;
              showSnackbar(context, Colors.red, "Left the group $groupName");
            });
          }
        },
        child: isJoined
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Palette.royalblue,
                  border: Border.all(color: Palette.whiteblue, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text("Joined", style: TextStyle(color: Palette.whiteblue)),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Palette.deepsky,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text("Join", style: TextStyle(color: Palette.whiteblue)),
              ),
      ),
    );
  }
}
