import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:letsmeet/resources/auth_methods.dart';
import 'package:letsmeet/screens/video_call_zego.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../utils/ThemeProvider.dart'; // Ensure you import your ThemeProvider

class NewMeetingDialog extends StatefulWidget {
  const NewMeetingDialog({super.key});

  @override
  State<NewMeetingDialog> createState() => _NewMeetingDialogState();
}

class _NewMeetingDialogState extends State<NewMeetingDialog> {
  final AuthMethods _authMethods = AuthMethods();
  String _meetingCode = "abdcgrsf";
  String _meetingTitle = ""; // Variable to store the meeting title
  bool _isAttendanceEnabled = false;
  int _thresholdMinutes = 0;

  @override
  void initState() {
    super.initState();
    var uuid = Uuid();
    _meetingCode = uuid.v1().substring(0, 8);
  }

  Future<void> _selectThresholdTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 0),
    );

    if (picked != null) {
      setState(() {
        _thresholdMinutes = picked.hour * 60 + picked.minute;
      });
      print('Selected threshold time: $_thresholdMinutes minutes');
    } else {
      setState(() {
        _isAttendanceEnabled = false; // Turn off attendance if canceled
      });
    }
  }

  void _toggleAttendance(bool value) {
    setState(() {
      _isAttendanceEnabled = value;
      if (_isAttendanceEnabled) {
        _selectThresholdTime(context);
      } else {
        _thresholdMinutes = 0; // Reset threshold if attendance is disabled
      }
    });
  }

  Future<void> _shareMeeting() async {
    final meetingLink = 'letsmeet://join?meetingCode=$_meetingCode';
    final encodedLink = Uri.encodeFull(meetingLink);
    final shareMessage = 'Join my meeting titled "$_meetingTitle" using this link: $encodedLink';

    try {
      await Share.share(shareMessage);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16,right: 16,bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close, color: isDarkMode ? Colors.white : Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            SizedBox(height: 20),
            Image.asset("assets/ready_m.png",fit: BoxFit.cover,height: 100,),
            SizedBox(height: 20),
            Text(
              "Your meeting is ready",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 20),


            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                leading: Icon(Icons.link, color: isDarkMode ? Colors.white : Colors.black),
                title: SelectableText(
                  _meetingCode,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.copy, color: isDarkMode ? Colors.white : Colors.black),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _meetingCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Meeting Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
              onChanged: (value) {
                setState(() {
                  _meetingTitle = value; // Update meeting title on input change
                });
              },
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: isDarkMode ? Colors.white : Colors.grey),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Attendance :',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  SizedBox(width: 10),
                  Switch(
                    value: _isAttendanceEnabled,
                    onChanged: _toggleAttendance,
                    activeColor: Colors.blue, // Change switch color
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _shareMeeting,
              icon: Icon(Icons.send),
              label: Text('Share invite'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fixedSize: Size(350, 30),
              ),
            ),
            SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                try {
                  await _authMethods.createMeeting(_meetingCode, _meetingTitle, _thresholdMinutes);
                  Navigator.of(context).pop(); // Close the dialog
                  Get.to(VideoCallZ(
                    channelName: _meetingCode.trim(),
                    conferenceID: _meetingCode,
                    role: Role.Host,
                  ));
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create meeting: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: Icon(Icons.video_call),
              label: Text("Start call"),
              style: ElevatedButton.styleFrom(
                foregroundColor: isDarkMode ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fixedSize: Size(350, 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
