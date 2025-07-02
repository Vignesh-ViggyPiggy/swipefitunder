import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipefit/provider/provider.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> storeData() async {
    final QuerySnapshot snapshot =
        await _firestore.collection("store_items").get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<String> getCurrentUserId() async {
    final user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception("No user logged in");
    }
  }

  Future<List<String>> postData() async {
    final currentUid = await getCurrentUserId();
    final QuerySnapshot snapshot = await _firestore
        .collection("posts")
        .where('postedTo', arrayContains: currentUid)
        .get();

    List<String> imageLinks = [];

    snapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('postImage') &&
          (!data['likes'].contains(currentUid) &&
              !data['dislikes'].contains(currentUid))) {
        imageLinks.add(data['postImage'] as String);
      }
    });

    return imageLinks;
  }

  // Future<Map<String, dynamic>?> getPostDetailsByImageUrl(
  //     String imageUrl) async {
  //   final QuerySnapshot snapshot = await _firestore
  //       .collection("posts")
  //       .where('postImage', isEqualTo: imageUrl)
  //       .limit(1)
  //       .get();

  //   if (snapshot.docs.isNotEmpty) {
  //     final doc = snapshot.docs.first;
  //     final data = doc.data() as Map<String, dynamic>;
  //     return {
  //       'postTitle': data['postTitle'],
  //       'postedBy': data['postedBy'],
  //     };
  //   } else {
  //     return null;
  //   }
  // }

  Future<List<Map<String, dynamic>>> getPostDetailsByUserUid(String uid) async {
    final QuerySnapshot snapshot = await _firestore
        .collection("posts")
        .where('postedBy', isEqualTo: uid)
        .get();

    return snapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
  }

  Future<void> removeFriend(String currentUid, String selectedUid) async {
    final currentUserDoc = _firestore.collection('users').doc(currentUid);
    final otherUserDoc = _firestore.collection('users').doc(selectedUid);

    await _firestore.runTransaction((transaction) async {
      final currentUserSnapshot = await transaction.get(currentUserDoc);
      final otherUserSnapshot = await transaction.get(otherUserDoc);

      if (!currentUserSnapshot.exists || !otherUserSnapshot.exists) {
        throw Exception("User does not exist");
      }

      transaction.update(currentUserDoc, {
        'friends': FieldValue.arrayRemove([selectedUid]),
      });

      transaction.update(otherUserDoc, {
        'friends': FieldValue.arrayRemove([currentUid]),
      });
    });
  }

  // Future<List<String>> getUsernamesContaining(String query) async {
  //   final QuerySnapshot snapshot = await _firestore
  //       .collection('users')
  //       .where('username', isGreaterThanOrEqualTo: query)
  //       .where('username', isLessThanOrEqualTo: query + '\uf8ff')
  //       .get();

  //   List<String> usernames = [];

  //   snapshot.docs.forEach((doc) {
  //     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //     if (data.containsKey('username')) {
  //       usernames.add(data['username'] as String);
  //     }
  //   });

  //   return usernames;
  // }
  // Future<Map<String, String>> getUsernamesContaining(String query) async {
  //   final QuerySnapshot snapshot = await _firestore
  //       .collection('users')
  //       .where('username', isGreaterThanOrEqualTo: query.toLowerCase())
  //       .where('username', isLessThanOrEqualTo: query.toLowerCase() + '\uf8ff')
  //       .get();

  //   Map<String, String> usernames = {};

  //   print("Query: $query");
  //   snapshot.docs.forEach((doc) {
  //     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //     if (data.containsKey('username') && data.containsKey('uid')) {
  //       usernames[data['username'] as String] = data['uid'] as String;
  //     }
  //     print("Usernames: $usernames");
  //     print("data: $data");
  //   });

  //   return usernames;
  // }
  Future<Map<String, String>> getUsernamesContaining(String query) async {
    // Fetch all users from Firestore
    final QuerySnapshot snapshot = await _firestore.collection('users').get();

    Map<String, String> usernames = {};

    print("Query: $query");

    // Filter users locally based on the query
    snapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('username') && data.containsKey('uid')) {
        final username = (data['username'] as String).toLowerCase();
        final uid = data['uid'] as String;

        // Check if the query is a substring of the username
        if (username.contains(query.toLowerCase())) {
          usernames[username] = uid;
        }
      }
    });

    print("Filtered Usernames: $usernames");
    return usernames;
  }

  Future<void> addPost({
    required String postImage,
    required String postTitle,
    required String postedBy,
    required List<String> postedTo,
  }) async {
    await _firestore.collection('posts').add({
      'postImage': postImage,
      'postTitle': postTitle,
      'postedBy': postedBy,
      'postedTo': postedTo,
      'likes': [],
      'dislikes': [],
    });
  }

  Future<String> signUpUser(
      {required String email,
      required String password,
      required String username,
      required BuildContext context}) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _firestore.collection("users").doc(credential.user!.uid).set({
        "username": username,
        "uid": credential.user!.uid,
        "email": email,
        "friends": [],
        "posts": [],
        "receivedRequests": [],
        "sentRequests": [],
        "credits": 3
      });
      if (credential != null) Navigator.pushNamed(context, "/login");
    } catch (e) {
      print(e.toString());
      return e.toString();
    }

    return "Success";
  }

  Future<String> loginUser(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (_auth.currentUser != null) Navigator.pushNamed(context, "/mainpage");
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
    return "Success";
  }

  Future<void> logOut(BuildContext context, WidgetRef ref) async {
    await _auth.signOut();
    ref.invalidate(useridProvider);
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  Future<String> getCurrentUsername() async {
    final uid = await getCurrentUserId();
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection("users").doc(uid).get();
    final Map<String, dynamic> userData =
        snapshot.data() as Map<String, dynamic>;
    return userData['username'];
  }

  Future<Map<String, String>> getUsernamesFromUids(List<String> uids) async {
    Map<String, String> usernames = {};
    for (String uid in uids) {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection("users").doc(uid).get();
      final Map<String, dynamic> userData =
          snapshot.data() as Map<String, dynamic>;
      if (userData.containsKey('username')) {
        usernames[userData['username']] = uid;
      }
    }
    return usernames;
  }

  Future<List<String>> getReceivedRequests(String uid) async {
    final DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      if (data.containsKey('receivedRequests')) {
        return List<String>.from(data['receivedRequests']);
      }
    }
    return [];
  }

  Future<void> sendFriendRequest(String currentUid, String selectedUid) async {
    final currentUserDoc = _firestore.collection('users').doc(currentUid);
    final selectedUserDoc = _firestore.collection('users').doc(selectedUid);

    await _firestore.runTransaction((transaction) async {
      final currentUserSnapshot = await transaction.get(currentUserDoc);
      final selectedUserSnapshot = await transaction.get(selectedUserDoc);

      if (!currentUserSnapshot.exists || !selectedUserSnapshot.exists) {
        throw Exception("User does not exist");
      }

      transaction.update(currentUserDoc, {
        'sentRequests': FieldValue.arrayUnion([selectedUid]),
      });

      transaction.update(selectedUserDoc, {
        'receivedRequests': FieldValue.arrayUnion([currentUid]),
      });
    });
  }

  Future<void> undoFriendRequest(String currentUid, String selectedUid) async {
    final currentUserDoc = _firestore.collection('users').doc(currentUid);
    final selectedUserDoc = _firestore.collection('users').doc(selectedUid);

    await _firestore.runTransaction((transaction) async {
      final currentUserSnapshot = await transaction.get(currentUserDoc);
      final selectedUserSnapshot = await transaction.get(selectedUserDoc);

      if (!currentUserSnapshot.exists || !selectedUserSnapshot.exists) {
        throw Exception("User does not exist");
      }

      transaction.update(currentUserDoc, {
        'sentRequests': FieldValue.arrayRemove([selectedUid]),
      });

      transaction.update(selectedUserDoc, {
        'receivedRequests': FieldValue.arrayRemove([currentUid]),
      });
    });
  }

  Future<List<String>> fetchSentRequests(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      if (data.containsKey('sentRequests')) {
        return List<String>.from(data['sentRequests']);
      }
    }
    return [];
  }

  Future<List<String>> fetchFriends(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      if (data.containsKey('friends')) {
        return List<String>.from(data['friends']);
      }
    }
    return [];
  }

  Future<void> acceptFriendRequest(String currentUid, String senderUid) async {
    final currentUserDoc = _firestore.collection('users').doc(currentUid);
    final senderUserDoc = _firestore.collection('users').doc(senderUid);

    await _firestore.runTransaction((transaction) async {
      final currentUserSnapshot = await transaction.get(currentUserDoc);
      final senderUserSnapshot = await transaction.get(senderUserDoc);

      if (!currentUserSnapshot.exists || !senderUserSnapshot.exists) {
        throw Exception("User does not exist");
      }

      // Remove from sent and received requests
      transaction.update(currentUserDoc, {
        'receivedRequests': FieldValue.arrayRemove([senderUid]),
        'friends': FieldValue.arrayUnion([senderUid]),
      });

      transaction.update(senderUserDoc, {
        'sentRequests': FieldValue.arrayRemove([currentUid]),
        'friends': FieldValue.arrayUnion([currentUid]),
      });
    });
  }

  Future<void> declineFriendRequest(String currentUid, String senderUid) async {
    final currentUserDoc = _firestore.collection('users').doc(currentUid);
    final senderUserDoc = _firestore.collection('users').doc(senderUid);

    await _firestore.runTransaction((transaction) async {
      final currentUserSnapshot = await transaction.get(currentUserDoc);
      final senderUserSnapshot = await transaction.get(senderUserDoc);

      if (!currentUserSnapshot.exists || !senderUserSnapshot.exists) {
        throw Exception("User does not exist");
      }

      // Remove from sent and received requests
      transaction.update(currentUserDoc, {
        'receivedRequests': FieldValue.arrayRemove([senderUid]),
      });

      transaction.update(senderUserDoc, {
        'sentRequests': FieldValue.arrayRemove([currentUid]),
      });
    });
  }

  Future<void> likePost(String currentPost) async {
    try {
      final uid = await getCurrentUserId();
      // Get the document where postImage matches currentPost
      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .where('postImage', isEqualTo: currentPost)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Assuming there is only one document with the given postImage
        DocumentReference postDoc = snapshot.docs.first.reference;

        // Add the uid to the likes array field
        await postDoc.update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print("Error liking post: $e");
    }
  }

  Future<void> dislikePost(String currentPost) async {
    try {
      final uid = await getCurrentUserId();
      // Get the document where postImage matches currentPost
      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .where('postImage', isEqualTo: currentPost)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Assuming there is only one document with the given postImage
        DocumentReference postDoc = snapshot.docs.first.reference;

        // Add the uid to the dislikes array field
        await postDoc.update({
          'dislikes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print("Error disliking post: $e");
    }
  }
}
