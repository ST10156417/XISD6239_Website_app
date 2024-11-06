import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;

  DatabaseService({this.uid});

  // Collection references in Firestore
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  // Collection reference for bookings
  final CollectionReference bookingsCollection =
      FirebaseFirestore.instance.collection("bookings");

  // Update or create user data in the database
  Future<void> updateUserData(String fullname, String email) async {
    if (uid == null) {
      throw Exception("User ID cannot be null");
    }

    try {
      await userCollection.doc(uid).set({
        "fullname": fullname,
        "email": email,
        "groups": [], // Initialize with an empty list of groups for the messaging system
        "profilepic": "", // Placeholder for profile picture
        "uid": uid,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating user data: $e");
      throw Exception("Failed to update user data");
    }
  }

  // Retrieve user group data stream
  Stream<DocumentSnapshot> getUserGroup() {
    return userCollection.doc(uid).snapshots();
  }

  // Create a new group and update user groups
  Future<void> createGroup(String fullname, String uid, String groupName) async {
    try {
      DocumentReference groupDocumentReference = await groupCollection.add({
        "groupName": groupName,
        "groupIcon": "",
        "admin": "${uid}_${fullname}",
        "members": [],
        "groupId": "",
        "recentMessage": "",
        "recentMessageSender": "",
      });

      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_${fullname}"]), // Store in uid_fullname format
        "groupId": groupDocumentReference.id,
      });

      DocumentReference userDocumentReference = userCollection.doc(uid);
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"]), // Maintain groupId_groupName format
      });
    } catch (e) {
      print("Error creating group: $e");
      throw Exception("Failed to create group");
    }
  }

  // Get chats for a group, ordered by time
  Stream<QuerySnapshot> getChats(String groupId) {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  // Get the admin of a group
  Future<String> getGroupAdmin(String groupId) async {
    try {
      DocumentSnapshot documentSnapshot = await groupCollection.doc(groupId).get();
      return documentSnapshot['admin'];
    } catch (e) {
      print("Error fetching group admin: $e");
      throw Exception("Failed to fetch group admin");
    }
  }

  // Stream of group members
  Stream<DocumentSnapshot> getGroupMembers(String groupId) {
    return groupCollection.doc(groupId).snapshots();
  }

  // Search for groups by name
  Future<QuerySnapshot> searchByName(String groupName) async {
    try {
      return await groupCollection.where("groupName", isEqualTo: groupName).get();
    } catch (e) {
      print("Error searching groups by name: $e");
      throw Exception("Failed to search groups by name");
    }
  }

  // Check if user is already in a specific group
  Future<bool> isUserJoined(String groupName, String groupId, String fullname) async {
    try {
      DocumentSnapshot documentSnapshot = await userCollection.doc(uid).get();
      List<dynamic> groups = documentSnapshot['groups'];
      return groups.contains("${groupId}_$groupName");
    } catch (e) {
      print("Error checking group membership: $e");
      throw Exception("Failed to check if user is joined");
    }
  }

  // Toggle user's membership in a group
  Future<void> toggleGroupJoin(String groupId, String fullname, String groupName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    try {
      DocumentSnapshot documentSnapshot = await userDocumentReference.get();
      List<dynamic> groups = documentSnapshot['groups'];

      String userGroupIdentifier = "${uid}_$fullname"; // Change to uid_fullname format

      if (groups.contains("${groupId}_$groupName")) {
        await userDocumentReference.update({
          "groups": FieldValue.arrayRemove(["${groupId}_$groupName"]),
        });
        await groupDocumentReference.update({
          "members": FieldValue.arrayRemove([userGroupIdentifier]), // Use uid_fullname for membership
        });
      } else {
        await userDocumentReference.update({
          "groups": FieldValue.arrayUnion(["${groupId}_$groupName"]),
        });
        await groupDocumentReference.update({
          "members": FieldValue.arrayUnion([userGroupIdentifier]), // Use uid_fullname for membership
        });
      }
    } catch (e) {
      print("Error toggling group join: $e");
      throw Exception("Failed to toggle group join");
    }
  }

  // Retrieve booking categories
  Future<Map<String, List<String>>> getBookingCategories() async {
    return {
      "Our Services": [
        "Social Facilitation",
        "Socio-Economic Development Monitoring & Evaluation",
        "Socio-Economic Development Impact Assessment",
        "Strategic Stakeholder Engagements, Mapping & Public Consultations",
        "Planning & Implementation of Project Stability Strategies",
        "Supplier/Contractor/Enterprise Development & Localization",
        "Mentorship & Capacity Building",
        "Business Advisory & Counselling",
        "Training and Facilitation on Skills programmes",
        "Assessments",
        "Recognition of Prior Learning (RPL)",
        "Developments of WSP",
        "Technical Skills Development",
      ],
      "Skills Programs and Learnerships": [
        "Basic Fall Arrest",
        "Basic Fire fighting",
        "Fall Arrest and rescue Technique",
        "Fire Marshall",
        "Hazard Identification Risk assessment",
        "Supervision",
        "First Aid Level 1 and 2",
        "Emergency Planning and evacuations",
        "Hazardous Chemical Substance",
        "Incident Investigation",
        "SHE Representatives",
      ],
      "Non Technical Skills Programs": [
        "Human Resource Management",
        "Financial Management",
        "Marketing",
        "Aids Awareness",
        "ABET",
        "Life Skills",
      ],
    };
  }

  // Method to book a service with a specific date
  Future<void> bookService(String category, String subCategory, DateTime date) async {
    if (uid == null) {
      throw Exception("User ID cannot be null");
    }
    try {
      await bookingsCollection.add({
        "userId": uid,
        "category": category,
        "subCategory": subCategory,
        "date": date, // Add the date field
        "timestamp": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error booking service: $e");
      throw Exception("Failed to book service");
    }
  }

  // Method to retrieve bookings for the user
  Future<List<Map<String, dynamic>>> getBookings() async {
    if (uid == null) {
      throw Exception("User ID cannot be null");
    }
    try {
      QuerySnapshot snapshot = await bookingsCollection
          .where('userId', isEqualTo: uid)
          .get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error retrieving bookings: $e");
      throw Exception("Failed to retrieve bookings");
    }
  }

  // Method to send a message in a group
  Future<void> sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    await groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }
}
