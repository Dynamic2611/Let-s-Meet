import 'package:flutter/material.dart';
import 'package:letsmeet/utils/ThemeProvider.dart';
import 'package:provider/provider.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text("About  Let's Meet"),
        backgroundColor: isDarkMode ? Colors.black : Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome to Let's Meet!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.blue,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your all-in-one solution for seamless virtual meetings. Designed with user experience in mind, our app empowers you to connect, collaborate, and communicate effectively, no matter where you are.',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Key Features:',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.blue,
                    ),
                  ),
                  SizedBox(height: 10),
                  BulletPoint(text: 'Automatic Attendance Tracking', isDarkMode: isDarkMode),
                  BulletPoint(text: 'In-Meeting Chat', isDarkMode: isDarkMode),
                  BulletPoint(text: 'Interactive Whiteboard', isDarkMode: isDarkMode),
                  BulletPoint(text: 'Screen Sharing', isDarkMode: isDarkMode),
                  BulletPoint(text: 'User-Friendly Interface', isDarkMode: isDarkMode),
                  SizedBox(height: 20),
                  Text(
                    "Why Choose Let's Meet ?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.blue,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'We believe that effective communication is the cornerstone of any successful collaboration. With LetsMeet, you can host and participate in meetings that are not only productive but also enjoyable. Our app is built with advanced technology to provide a reliable and secure meeting experience.',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Join us in transforming the way you meet and collaborate. Download LetsMeet today and take your virtual meetings to the next level!',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  final bool isDarkMode;

  const BulletPoint({Key? key, required this.text, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 10, color: isDarkMode ? Colors.white : Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.white70 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
