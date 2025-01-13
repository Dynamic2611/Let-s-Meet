import 'package:flutter/material.dart';
import 'package:letsmeet/screens/join_with_code.dart';
import 'package:letsmeet/screens/new_meeting.dart'; // Import the dialog widget
import 'package:provider/provider.dart';
import '../utils/ThemeProvider.dart'; // Ensure you import your ThemeProvider

class Home1Page extends StatelessWidget {
  const Home1Page({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Get the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white, // Set background color
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: screenHeight * 0.05,
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return NewMeetingDialog(); // Show the dialog
                  },
                );
              },
              icon: Icon(Icons.add),
              label: Text('New Meeting'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: isDarkMode ? Colors.blue[700] : Colors.blue, // Adjust button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fixedSize: Size(screenWidth * 0.8, screenHeight * 0.06),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: screenHeight * 0.01,
            ),
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return JoinMeetingDialog(); // Show the dialog
                  },
                );
              },
              icon: Icon(Icons.margin),
              label: Text("Join with code"),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDarkMode ? Colors.white : Colors.black,
                side: BorderSide(color: isDarkMode ? Colors.white : Colors.black), // Border color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fixedSize: Size(screenWidth * 0.8, screenHeight * 0.06),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.05,
              bottom: screenHeight * 0.05,
              left: screenWidth * 0.07,
              right: screenWidth * 0.02,
            ),
            child: Image.asset(
              "assets/home5.png",
              height: screenHeight * 0.4,
              width: screenWidth * 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
