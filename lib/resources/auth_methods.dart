import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:letsmeet/utils/utils.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User get user => _auth.currentUser!;

  Future<bool> signInWithGoogle(BuildContext context) async {
    bool res = false;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return false; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          await _db.child('users/${user.uid}').set({
            'username': user.displayName,
            'uid': user.uid,
            'email': user.email,
            'profilePhoto': user.photoURL,
          });
        }
        res = true;
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message ?? 'An unknown error occurred.');
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return res;
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> createMeeting(String mId, String title, int threshold) async {
    try {
      final meetingRef = _db.child('meetings/$mId');

      // Check if the meeting already exists
      final snapshot = await meetingRef.once();
      if (snapshot.snapshot.exists) {
        print('Meeting with ID $mId already exists.');
        return;
      }

      // Create a new meeting
      final startTime = DateTime.now().toIso8601String();
      await meetingRef.set({
        'meetingID': mId,
        'title': title,
        'startTime': startTime,
        'threshold': threshold,
        'hostID': user.uid,
      });

      // Initialize the chat for the meeting
      await meetingRef.child('chat').push().set({
        'message': 'Chat initialized',
        'timestamp': DateTime.now().toIso8601String(),
      });

    } catch (e) {
      print('Error creating meeting: $e');
    }
  }

  Future<bool> isMeetingIdValid(String meetingId) async {
  try {
    // Reference the meeting data in Firebase Realtime Database
    final meetingRef = _db.child('meetings/$meetingId');
    
    // Check if the meeting with the given ID exists
    final snapshot = await meetingRef.once();

    // Return true if the meeting exists, otherwise false
    return snapshot.snapshot.exists;
  } catch (e) {
    // Handle error, log, or rethrow
    print('Error checking meeting ID: $e');
    return false;
  }
}

  Future<void> sendMessage(String mId, String message) async {
    try {
      final meetingRef = _db.child('meetings/$mId');

      // Check if meeting exists
      final snapshot = await meetingRef.once();
      if (!snapshot.snapshot.exists) {
        print('Meeting with ID $mId does not exist.');
        return;
      }

      // Add message to the chat
      await meetingRef.child('chat').push().set({
        'userID': user.uid,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });

    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> joinMeeting(String mId) async {
    try {
      final meetingRef = _db.child('meetings/$mId');
      final participantRef = meetingRef.child('participants/${user.uid}');
      final snapshot = await participantRef.once();

      if (!snapshot.snapshot.exists) {
        // First-time joining the meeting
        await participantRef.set({
          'userID': user.uid,
          'username': user.displayName,
          'emailID': user.email,
          'duration': 0,
          'totalConnectionTime': 0,
        });
      }
    } catch (e) {
      print('Error joining meeting: $e');
    }
  }

  Future<void> leaveMeeting(String mId, String durationT) async {
    try {
      final meetingRef = _db.child('meetings/$mId');
      final participantRef = meetingRef.child('participants/${user.uid}');
      final snapshot = await participantRef.once();

      if (snapshot.snapshot.exists) {
        final participantData = snapshot.snapshot.value as Map;

        // Current duration in database
        int currentDuration = participantData['duration'] ?? 0;

        // Parse durationT to double and convert to minutes
        double sessionDurationInMinutes = double.parse(durationT) / 60;

        // Calculate new total duration
        int totalDuration = (currentDuration + sessionDurationInMinutes).toInt();

        // Update the participant data
        await participantRef.update({
          'duration': totalDuration,
          'totalConnectionTime': totalDuration,
        });
      }
    } catch (e) {
      print('Error leaving meeting: $e');
    }
  }


  Future<void> endMeetingAndMarkAttendance(String mId) async {
    try {
      final meetingRef = _db.child('meetings/$mId');
      final snapshot = await meetingRef.once();

      if (!snapshot.snapshot.exists) {
        print('Meeting with ID $mId does not exist.');
        return;
      }

      final meetingData = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (meetingData == null || meetingData['threshold'] == null) {
        print('Invalid meeting data or missing threshold.');
        return;
      }

      final int threshold = meetingData['threshold'];
      final participantsRef = meetingRef.child('participants');
      final participantsSnapshot = await participantsRef.once();

      final List<Map<String, dynamic>> attendanceList = [];

      for (var participant in participantsSnapshot.snapshot.children) {
        final participantData = participant.value as Map<dynamic, dynamic>?;

        if (participantData == null) {
          continue;
        }

        // Retrieve the totalConnectionTime directly
        final totalConnectionTime = participantData['totalConnectionTime'] as int;

        // Determine if the participant is present based on the threshold
        final isPresent = totalConnectionTime >= threshold;

        // Update participant's attendance status
        await participantsRef.child(participant.key!).update({
          'isPresent': isPresent,
        });

        attendanceList.add({
          'username': participantData['username'],
          'isPresent': isPresent,
          'connectionTime': totalConnectionTime,
        });
      }

      // Update the meeting with the final attendance list
      await meetingRef.update({'attendance': attendanceList});
    } catch (e) {
      print('Error marking attendance: $e');
    }
  }



  Future<void> deleteAllChats(String meetingId) async {
    try {
      final meetingRef = _db.child('meetings/$meetingId');
      final snapshot = await meetingRef.once();

      final meetingData = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (meetingData == null) {
        print('Meeting with ID $meetingId does not exist.');
        return;
      }

      final hostId = meetingData['hostID'] as String?;
      if (hostId == null || user.uid != hostId) {
        print('Only the host can delete chats.');
        return;
      }

      // Delete all chats
      await meetingRef.child('chat').remove();
    } catch (e) {
      print('Error deleting chats: $e');
    }
  }



  Future<String> getUserName(String meetingId) async {
    try {
      // Reference the meeting data in the database
      final meetingRef = _db.child('meetings/$meetingId');
      final snapshot = await meetingRef.once();

      // Get meeting data
      final meetingData = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (meetingData == null) {
        print('Meeting with ID $meetingId does not exist.');
        return 'Unknown User';
      }

      // Fetch the host ID from the meeting
      final hostId = meetingData['hostID'] as String?;
      if (hostId == null) {
        print('No host for this meeting.');
        return 'Unknown User';
      }

      // Fetch current user ID
      String currentUserId = user.uid;

      // Compare current user ID with host ID to determine the role
      String userName;
      if (currentUserId == hostId) {
        userName = 'Host (${user.displayName})'; // Display user as Host
      } else {
        userName = user.displayName ?? 'Participant'; // Display as Participant
      }

      return userName;
    } catch (e) {
      print('Error fetching user details: $e');
      return 'Unknown User';
    }
  }
}
