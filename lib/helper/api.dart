import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/message_model.dart';
import '../models/post_model.dart';
import '../models/citizen_model.dart';
import '../models/complaint_model.dart';
import '../models/organization_model.dart';

class APIs {
  /// ******** Location related API *********

  static const platform = MethodChannel('com.sirmaur.citybuddy/maps');

  static Future<void> pickLocation() async {
    try {
      await platform.invokeMethod('pickLocation');
    } catch (e) {
      print("Error: $e");
    }
  }

  // for accessing current location
  static void getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
  }

  // navigate to google map
  static Future<void> openGoogleMap(double latitude, double longitude) async {
    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not open Google Maps';
    }
  }

  // launch google map
  // static Future<void> _pickLocation() async {
  //   final Uri googleMapsUrl = Uri.parse("geo:0,0?q=Select Location");
  //
  //   if (await canLaunchUrl(googleMapsUrl)) {
  //     await launchUrl(googleMapsUrl);
  //   } else {
  //     throw 'Could not open Google Maps';
  //   }
  // }

  /// ******** User related API *********

  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for storing self info
  static late dynamic me;

  // for storing self info
  static late dynamic otherUser;

  static User get user => auth.currentUser!;

  // Returns true if username is unique
  static Future<bool> isUsernameUnique(String username) async {
    final QuerySnapshot result = await firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return result.docs.isEmpty;
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        if (user.data()!.containsKey('organizationType')) {
          me = OrganizationModel.fromJson(user.data()!);
        } else {
          me = CitizenModel.fromJson(user.data()!);
        }
        log('My Data: ${user.data()}');
      }
    });
  }

  // for getting current user info
  static Future<dynamic> getUserInfo(String userId) async {
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          if (data.containsKey('organizationType')) {
            return OrganizationModel.fromJson(data);
          } else {
            return CitizenModel.fromJson(data);
          }
        }
      }
      return null; // Return null if user doesn't exist
    } catch (e) {
      log('Error fetching user info: $e');
      return null; // Handle errors gracefully
    }
  }

  // for getting current user info stream
  static Stream<dynamic> getUserStream(String userId) {
    return firestore.collection('users').doc(userId).snapshots().map((userDoc) {
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          if (data.containsKey('organizationType')) {
            return OrganizationModel.fromJson(data);
          } else {
            return CitizenModel.fromJson(data);
          }
        }
      }
      return null; // Return null if user doesn't exist
    });
  }

  // for creating a new user
  static Future<void> createUser(
      CitizenModel? citizen, OrganizationModel? organization) async {
    if (organization != null) {
      return await firestore
          .collection('users')
          .doc(user.uid)
          .set(organization.toJson());
    }
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(citizen!.toJson());
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for updating user info
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'email': me.email,
    });
  }

  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    // getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    // storage file reference with path
    final ref = storage.ref('profile_picture/${user.uid}.$ext');

    // uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data transferred: ${p0.bytesTransferred / 1024} kb');
    });

    // updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'imageUrl': me.image,
    });
  }

  /// --------------- Follow -----------------
  static Future<void> toggleFollow(String targetUserId) async {
    try {
      final currentUserId = auth.currentUser!.uid;

      // References to both users' documents
      final targetUserRef = firestore.collection('users').doc(targetUserId);
      final currentUserRef = firestore.collection('users').doc(currentUserId);

      // Get target user's document snapshot
      final targetUserSnapshot = await targetUserRef.get();
      if (!targetUserSnapshot.exists) return;

      final targetUserData = targetUserSnapshot.data()!;
      List followers = targetUserData['followers'] ?? [];

      // Check if already following
      bool isFollowing = followers.contains(currentUserId);

      // Firestore batch update
      WriteBatch batch = firestore.batch();

      if (isFollowing) {
        // Remove from followers of target user
        batch.update(targetUserRef, {
          'followers': FieldValue.arrayRemove([currentUserId])
        });

        // Remove from following of current user
        batch.update(currentUserRef, {
          'following': FieldValue.arrayRemove([targetUserId])
        });
      } else {
        // Add to followers of target user
        batch.update(targetUserRef, {
          'followers': FieldValue.arrayUnion([currentUserId])
        });

        // Add to following of current user
        batch.update(currentUserRef, {
          'following': FieldValue.arrayUnion([targetUserId])
        });
      }

      // Commit batch update
      await batch.commit();

      log('Follow status updated: ${isFollowing ? "Unfollowed" : "Followed"}');
    } catch (e) {
      log('Error toggling follow: $e');
    }
  }

  /// --------------- Post ----------------
  // for creating a new post
  static Future<void> createPost(PostModel post) async {
    return await firestore.collection('tweets').doc(post.id).set(post.toJson());
  }

  // for replying to a post
  static Future<void> replyPost(PostModel post, String mainTweetId) async {
    final tweetRef = firestore.collection('tweets').doc(post.id);
    final mainTweetRef = firestore.collection('tweets').doc(mainTweetId);

    // Start Firestore batch write
    WriteBatch batch = firestore.batch();

    // Step 1: Add the reply post
    batch.set(tweetRef, post.toJson());

    // Step 2: Add reply post ID to the `replyIds` array of main tweet
    batch.update(mainTweetRef, {
      'replyIds': FieldValue.arrayUnion([post.id]),
    });

    // Commit the batch operation
    await batch.commit();
  }

  // Fetch all tweets initially
  static Future<List<DocumentSnapshot>> getAllTweets() async {
    final querySnapshot = await firestore
        .collection('tweets')
        .orderBy('created_at', descending: true)
        .get();
    return querySnapshot.docs;
  }

  // Fetch only reply tweets
  static Future<List<DocumentSnapshot>> getReplyTweets(List replyIds) async {
    if (replyIds.isEmpty) return []; // Return empty list if no reply IDs

    final querySnapshot = await firestore
        .collection('tweets')
        .where(FieldPath.documentId, whereIn: replyIds)
        .orderBy('created_at', descending: true)
        .get();

    return querySnapshot.docs;
  }

  // Stream for a single tweet (Real-time updates)
  static Stream<DocumentSnapshot> getTweetStream(String tweetId) {
    return firestore.collection('tweets').doc(tweetId).snapshots();
  }

  // Toggle Upvote Function
  static Future<void> toggleUpvoteForPost(String postId) async {
    try {
      final currentUserId = auth.currentUser!.uid;
      final postRef = firestore.collection('tweets').doc(postId);

      // Get the current post data
      final postSnapshot = await postRef.get();
      if (!postSnapshot.exists) return;

      final postData = postSnapshot.data()!;
      List upVotes = postData['upVotes'] ?? [];

      // Check if user has upvoted
      bool hasUpvoted = upVotes.contains(currentUserId);

      // Update Firestore
      if (hasUpvoted) {
        await postRef.update({
          'upVotes': FieldValue.arrayRemove([currentUserId])
        });
      } else {
        await postRef.update({
          'upVotes': FieldValue.arrayUnion([currentUserId])
        });
      }

      log('Upvote ${hasUpvoted ? "removed" : "added"} successfully');
    } catch (e) {
      log('Error toggling upvote: $e');
    }
  }

  /// --------------- Complaint ----------------
  // for creating a new post
  static Future<void> createComplaint(ComplaintModel complaint) async {
    return await firestore
        .collection('complaints')
        .doc(complaint.id)
        .set(complaint.toJson());
  }

  // for replying to a post
  static Future<void> replyComplaintPost(
      ComplaintModel complaint, String mainTweetId) async {
    final tweetRef = firestore.collection('complaints').doc(complaint.id);
    final mainTweetRef = firestore.collection('complaints').doc(mainTweetId);

    // Start Firestore batch write
    WriteBatch batch = firestore.batch();

    // Step 1: Add the reply post
    batch.set(tweetRef, complaint.toJson());

    // Step 2: Add reply post ID to the `replyIds` array of main tweet
    batch.update(mainTweetRef, {
      'replyIds': FieldValue.arrayUnion([complaint.id]),
    });

    // Commit the batch operation
    await batch.commit();
  }

  // Fetch all tweets initially
  static Future<List<DocumentSnapshot>> getAllComplaints() async {
    final querySnapshot = await firestore
        .collection('complaints')
        .orderBy('created_at', descending: true)
        .get();
    return querySnapshot.docs;
  }

  // Fetch only complaint reply tweets
  static Future<List<DocumentSnapshot>> getComplaintReplyTweets(
      List replyIds) async {
    if (replyIds.isEmpty) return []; // Return empty list if no reply IDs

    final querySnapshot = await firestore
        .collection('complaints')
        .where(FieldPath.documentId, whereIn: replyIds)
        .orderBy('created_at', descending: true)
        .get();

    return querySnapshot.docs;
  }

  // Stream for a single tweet (Real-time updates)
  static Stream<DocumentSnapshot> getComplaintStream(String complaintId) {
    return firestore.collection('complaints').doc(complaintId).snapshots();
  }

  // Toggle Upvote Function
  static Future<void> toggleUpvoteForComplaint(String complaintId) async {
    try {
      final currentUserId = auth.currentUser!.uid;
      final postRef = firestore.collection('complaints').doc(complaintId);

      // Get the current post data
      final postSnapshot = await postRef.get();
      if (!postSnapshot.exists) return;

      final postData = postSnapshot.data()!;
      List upVotes = postData['upVotes'] ?? [];

      // Check if user has upvoted
      bool hasUpvoted = upVotes.contains(currentUserId);

      // Update Firestore
      if (hasUpvoted) {
        await postRef.update({
          'upVotes': FieldValue.arrayRemove([currentUserId])
        });
      } else {
        await postRef.update({
          'upVotes': FieldValue.arrayUnion([currentUserId])
        });
      }

      log('Upvote ${hasUpvoted ? "removed" : "added"} successfully');
    } catch (e) {
      log('Error toggling upvote: $e');
    }
  }

  static Future<void> updateComplaintStatus(String complaintId, String status) async {
    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintId)
        .update({'complaintStatus': status});
  }

  /// ******** ChatScreen related API *********

  // chats (collection) -> conversation_id (doc) -> messages -> (collection) -> message (doc)

  // useful for getting conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      dynamic user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(dynamic receiver, String msg) async {
    // message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    final MessageModel message = MessageModel(
      msg: msg,
      toId: receiver.id,
      read: '',
      type: Type.text,
      sent: time,
      fromId: user.uid,
    );

    final ref = firestore
        .collection('chats/${getConversationId(receiver.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  // update read status of sent message
  static Future<void> updateMessageStatus(MessageModel message) async {
    firestore
        .collection('chats/${getConversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      dynamic user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }
}
