import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letsmeet/resources/auth_methods.dart';
import 'package:letsmeet/screens/video_call_zego.dart';

// Define a new widget for the Join Meeting Dialog
class JoinMeetingDialog extends StatefulWidget {
  const JoinMeetingDialog({super.key});

  @override
  State<JoinMeetingDialog> createState() => _JoinMeetingDialogState();
}

class _JoinMeetingDialogState extends State<JoinMeetingDialog> {
  final TextEditingController _roomCodeController = TextEditingController();
  final AuthMethods _authMethods = AuthMethods();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            SizedBox(height: 20),
            Image.asset("assets/join_m.png",fit: BoxFit.cover,height: 100,),
            SizedBox(height: 20),
            const Text(
              "Join with code",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _roomCodeController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Example: abc-efg-ijk",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String meetingId = _roomCodeController.text.trim();

                // Check if the meeting ID is valid
                bool isValid = await _authMethods.isMeetingIdValid(meetingId);

                if (isValid) {
                  try {
                    // Join the meeting
                    await _authMethods.joinMeeting(meetingId);

                    Navigator.pop(context); // Close the dialog

                    // Navigate to the Video Call screen
                    Get.to(() => VideoCallZ(
                          channelName: meetingId,
                          conferenceID: meetingId,
                          role: Role.Audience,
                        ));
                  } catch (e) {
                    Navigator.pop(context); // Close the dialog

                    // Show error message if joining fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to join meeting: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  // Show error message if the meeting ID is invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid meeting ID'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                "Join",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fixedSize: Size(350, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
