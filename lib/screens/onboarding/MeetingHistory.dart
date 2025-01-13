import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:letsmeet/utils/ThemeProvider.dart';
import 'package:provider/provider.dart';
import 'attendance_sheet_dialog.dart';
import 'dart:async';

class MeetingHistoryScreen extends StatefulWidget {
  @override
  _MeetingHistoryScreenState createState() => _MeetingHistoryScreenState();
}

class _MeetingHistoryScreenState extends State<MeetingHistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  
  List<Map<String, dynamic>> meetingsCreated = [];
  List<Map<String, dynamic>> meetingsJoined = [];
  bool isLoading = true;
  StreamSubscription<DatabaseEvent>? _meetingSubscription;

  @override
  void initState() {
    super.initState();
    _fetchMeetingHistory();
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _meetingSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchMeetingHistory() async {
    final String uid = _auth.currentUser!.uid;

    // Listen for changes in meetings created by the user
    _meetingSubscription = _db
        .child('meetings')
        .orderByChild('hostID')
        .equalTo(uid)
        .onValue.listen((DatabaseEvent event) {
      meetingsCreated.clear();
      if (event.snapshot.exists) {
        final Map<dynamic, dynamic> meetingsData =
            event.snapshot.value as Map<dynamic, dynamic>;
        meetingsData.forEach((key, value) {
          meetingsCreated.add({'meetingID': key, ...Map<String, dynamic>.from(value)});
        });
      }
      // Fetch all meetings to check if the user joined
      _fetchJoinedMeetings(uid);
    });
  }

  Future<void> _fetchJoinedMeetings(String uid) async {
    // Fetch all meetings to check if the user has joined
    final joinedMeetingsSnapshot = await _db.child('meetings').once();
    meetingsJoined.clear(); // Clear previous data

    if (joinedMeetingsSnapshot.snapshot.exists) {
      final Map<dynamic, dynamic> meetingsData =
          joinedMeetingsSnapshot.snapshot.value as Map<dynamic, dynamic>;
      meetingsData.forEach((key, value) {
        final participants = Map<String, dynamic>.from(value['participants'] ?? {});
        if (participants.containsKey(uid)) {
          meetingsJoined.add({'meetingID': key, ...Map<String, dynamic>.from(value)});
        }
      });
    }

    // Update the UI
    setState(() {
      isLoading = false; // Set loading to false when data is fetched
    });
  }

  Future<void> _deleteMeeting(String meetingID) async {
    try {
      await _db.child('meetings').child(meetingID).remove();
      setState(() {
        // Update the lists after deletion
        meetingsCreated.removeWhere((meeting) => meeting['meetingID'] == meetingID);
        meetingsJoined.removeWhere((meeting) => meeting['meetingID'] == meetingID);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Meeting deleted successfully')),
      );
    } catch (e) {
      print('Error deleting meeting: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting meeting')),
      );
    }
  }

  void _showMeetingOptions(BuildContext context, String meetingID) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Meeting'),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _deleteMeeting(meetingID); // Delete the meeting
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final themeProvider = Provider.of<ThemeProvider>(context);
    // ignore: unused_local_variable
    final isDarkMode = themeProvider.isDarkMode;

    

    return Scaffold(
      body: isLoading
          ?const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Just a second...")
              ],
            ),
          )
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.01,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meetings Created',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildMeetingList(meetingsCreated, isCreatedByUser: true),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Meetings Joined',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildMeetingList(meetingsJoined, isCreatedByUser: false),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMeetingList(List<Map<String, dynamic>> meetings, {required bool isCreatedByUser}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    if (meetings.isEmpty) {
      return Center(
        child: Container(
          height: 250,
          width: 250,
          child: Image.asset("assets/meeting_history.png"),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final meeting = meetings[index];
        final meetingID = meeting['meetingID'];
        final title = meeting['title'] ?? 'Untitled Meeting';
        final startTime = meeting['startTime'] ?? 'N/A';

        return Card(
          child: ListTile(
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.width * 0.045,
              ),
            ),
            subtitle: Text('Meeting ID: $meetingID\nStart Time: $startTime'),
            onTap: () {
              _showMeetingDetailsBottomSheet(meetingID, title, startTime, isCreatedByUser, isDarkMode);
            },
            onLongPress: () {
              _showMeetingOptions(context, meetingID);
            },
          ),
        );
      },
    );
  }

  void _showMeetingDetailsBottomSheet(
    
    String meetingID, String title, String startTime, bool isCreatedByUser, bool isDarkMode) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    backgroundColor: Colors.black87, // Darker background for contrast
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      return Container(
              decoration: BoxDecoration(
              color:  isDarkMode?const Color.fromARGB(255, 37, 37, 37):Colors.white,
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(width: 1,color: Color.fromARGB(255, 137, 137, 137))
            ),
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bottom sheet drag handle
            Container(
              height: screenHeight * 0.005,
              width: screenWidth * 0.15,
              margin: EdgeInsets.only(bottom: screenHeight * 0.02),
              decoration: BoxDecoration(
                color: Colors.grey[600], // Lighter gray for the handle
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            
            // Title
            Text(
              'Meeting Details',
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: isDarkMode?Colors.white:Colors.black,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Meeting Details with icons
            ListTile(
              leading: Icon(Icons.meeting_room, color: Colors.blueAccent,size: 30),
              title: Text('Meeting ID:', style: TextStyle(color: isDarkMode ?Colors.white:Colors.black)),
              subtitle: Text(meetingID, style: TextStyle(color: isDarkMode ?Colors.white:Colors.black)),
            ),
            ListTile(
              leading: Icon(Icons.title, color: Colors.greenAccent,size: 30,),
              title: Text('Title:', style: TextStyle(color: isDarkMode ?Colors.white:Colors.black)),
              subtitle: Text(title, style: TextStyle(color: isDarkMode ?Colors.white:Colors.black)),
            ),
            ListTile(
              leading: Icon(Icons.access_time, color: Colors.amberAccent,size: 30),
              title: Text('Start Time:', style: TextStyle(color: isDarkMode ?Colors.white:Colors.black)),
              subtitle: Text(startTime, style: TextStyle(color: isDarkMode ?Colors.white:Colors.black)),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Conditional button for viewing the attendance sheet
            if (isCreatedByUser)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _showAttendanceSheet(meetingID); // Show attendance sheet dialog
                },
                icon: Icon(Icons.list_alt),
                label: Text('View Attendance Sheet',style: TextStyle(color: isDarkMode?Colors.white:Colors.black),),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.08),
                  backgroundColor: Colors.blueAccent, // Blue for attention
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

  void _showAttendanceSheet(String meetingID) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AttendanceSheetDialog(meetingID: meetingID);
      },
    );
  }
}
