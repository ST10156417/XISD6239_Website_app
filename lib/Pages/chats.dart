import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sokeconsulting/Pages/groupinfo.dart';
import 'package:sokeconsulting/Services/database_service.dart';
import 'package:sokeconsulting/Widgets/message_tile.dart';
import 'package:sokeconsulting/palette.dart';

class ChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String fullname;

  const ChatScreen({
    Key? key,
    required this.groupName,
    required this.groupId,
    required this.fullname,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  late Future<String> admin;

  @override
  void initState() {
    super.initState();
    admin = DatabaseService().getGroupAdmin(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.groupName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Palette.whiteblue,
          ),
        ),
        actions: [
          FutureBuilder<String>(
            future: admin,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              final adminName = snapshot.data ?? 'Admin';
              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupInfo(
                        groupId: widget.groupId,
                        groupName: widget.groupName,
                        adminName: adminName,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.info),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Palette.skyblue,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      style: const TextStyle(color: Palette.whiteblue),
                      decoration: const InputDecoration(
                        hintText: "Send a message...",
                        hintStyle: TextStyle(color: Palette.whiteblue, fontSize: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      sendMessage();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Palette.darkblue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Icon(Icons.send, color: Palette.whiteblue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget chatMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseService().getChats(widget.groupId),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: snapshot.data!.docs[index]['message'],
                    sender: snapshot.data!.docs[index]['sender'],
                    sentByMe: widget.fullname == snapshot.data!.docs[index]['sender'],
                  );
                },
              )
            : Container();
      },
    );
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.fullname,
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}