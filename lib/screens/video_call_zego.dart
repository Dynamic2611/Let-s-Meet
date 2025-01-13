import 'package:flutter/material.dart';
import 'package:letsmeet/helper/chat_room.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'whiteboard.dart';
import 'package:letsmeet/resources/auth_methods.dart';

enum Role { Host, Audience, Participant }

class VideoCallZ extends StatefulWidget {
  final String channelName;
  final String conferenceID;
  final Role role;

  VideoCallZ({
    required this.channelName,
    Key? key,
    required this.conferenceID,
    required this.role,
  }) : super(key: key);

  @override
  _VideoCallZState createState() => _VideoCallZState();
}

class _VideoCallZState extends State<VideoCallZ> {
  final AuthMethods _authMethods = AuthMethods();
  bool _showWhiteboard = false;
  bool isSwitched = false; // State variable for captions
  String? currentUserId; // Store current user ID
  bool isHost = false; // Check if current user is host
  String? hostId = "";
  String? userName = "";
  String? durationT = ""; // Store duration in seconds

  // Variables for draggable floating action button positions
  Offset whiteboardButtonPosition = Offset(20, 150);
  Offset chatButtonPosition = Offset(20, 230);

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    userName = FirebaseAuth.instance.currentUser?.displayName;
    _checkIfUserIsHost();
  }

  // Function to check if the current user is the host
  Future<void> _checkIfUserIsHost() async {
    final meetingDoc = await FirebaseFirestore.instance
        .collection('meetings')
        .doc(widget.channelName)
        .get();

    if (meetingDoc.exists && mounted) {
      hostId = meetingDoc['hostID'] ?? "";
      if (mounted) {
        setState(() {
          isHost = currentUserId == hostId;
        });
      }
    }
  }

  // Function to handle meeting end and cleanup
  Future<void> _handleEndMeeting(String durationT) async {
    if (isHost) {
      await _authMethods.deleteAllChats(widget.channelName);
    }
    await _authMethods.leaveMeeting(widget.channelName, durationT);
    await _authMethods.endMeetingAndMarkAttendance(widget.channelName);
    

    if (mounted) { // Check if the widget is still mounted
      Navigator.of(context).pop(); // Exit the call UI
    }
  }

  @override
  void dispose() {
    // Ensure we clean up when the widget is disposed
    if (durationT != null) {
      _handleEndMeeting(durationT!); // Call before dispose
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Use IgnorePointer to allow button interactions
            IgnorePointer(
              ignoring: _showWhiteboard, // Ignore pointer events if whiteboard is shown
              child: ZegoUIKitPrebuiltVideoConference(
                appID: 852478794, // Replace with your actual appID
                appSign: '51c3ed478a915d936c1550d4ea2f540fc859f9cce994421be900c95a6660a508', // Replace with your actual appSign
                userID: '$currentUserId',
                userName: '$userName',
                conferenceID: widget.channelName,
                config: ZegoUIKitPrebuiltVideoConferenceConfig(
                  topMenuBarConfig: ZegoTopMenuBarConfig(
                    title: "Let's Meet : ${widget.conferenceID}",
                    // Optionally add actions for the buttons
                    // (Make sure to implement the actions if needed)
                  ),
                  leaveConfirmDialogInfo: ZegoLeaveConfirmDialogInfo(
                    title: "Leave the Meeting",
                    message: "Are you sure to leave the Meeting?",
                    cancelButtonName: "Cancel",
                    confirmButtonName: "Leave",
                  ),
                  audioVideoViewConfig: ZegoPrebuiltAudioVideoViewConfig(
                      showAvatarInAudioMode: true),
                  duration: ZegoVideoConferenceDurationConfig(
                    isVisible: false,
                    canSync: true,
                  ),
                ),
                events: ZegoUIKitPrebuiltVideoConferenceEvents(
                  duration: ZegoVideoConferenceDurationEvents(
                    onUpdated: (Duration d) {
                      durationT = d.inSeconds.toString();


                    },
                  ),
                ),
              ),
            ),

            // Whiteboard overlay
            if (_showWhiteboard)
              const Positioned.fill(
                child: WhiteboardScreen(),
              ),

            Positioned(
              left: whiteboardButtonPosition.dx,
              top: whiteboardButtonPosition.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    whiteboardButtonPosition += details.delta;
                  });
                },
                child: FloatingActionButton(
                  heroTag: 'whiteboardButton', // Unique hero tag
                  onPressed: () {
                    setState(() {
                      _showWhiteboard = !_showWhiteboard;
                    });
                  },
                  child: Icon(_showWhiteboard ? Icons.videocam : Icons.create),
                  backgroundColor: Colors.blue,
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
}
