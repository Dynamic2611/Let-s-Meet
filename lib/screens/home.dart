import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letsmeet/resources/auth_methods.dart';
import 'package:letsmeet/screens/about.dart';
import 'package:letsmeet/screens/home1_page.dart';
import 'package:letsmeet/screens/onboarding/MeetingHistory.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/ThemeProvider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;
  PageController _pageController = PageController();
  User? _currentUser;
  File? _imageFile; // Local image file

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _loadStoredImage(); // Load stored image on startup
  }

  Future<void> _fetchCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _loadStoredImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/profile_image.png';
    final file = File(imagePath);

    if (await file.exists()) {
      setState(() {
        _imageFile = file; // Load the stored image
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Save the new image to local storage
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/profile_image.png';
      await _imageFile!.copy(imagePath);
    }
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void onBottomNavigationBarTap(int page) {
    _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> signOut(BuildContext context) async {
    await AuthMethods().signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  final List<String> _titles = [
    'Create / Join',
    'Meeting History',
  ];

  List<Widget> pages(BuildContext context) => [
    Home1Page(),
    MeetingHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Get the theme provider here
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(_titles[_page]),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        centerTitle: true,
      ),
      drawer: _buildDrawer(context, isDarkMode),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: onPageChanged,
            children: pages(context),
          ),
          Positioned(
            bottom: screenHeight * 0.03,
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            child: _buildBottomNavigationBar(screenWidth, screenHeight, isDarkMode),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context, bool isDarkMode) {
    final screenHeight = MediaQuery.of(context).size.height;
    final themeProvider = Provider.of<ThemeProvider>(context);


    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(colors: [Colors.grey[850]!, Colors.grey[900]!])
              : LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent]),
        ),
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!) as ImageProvider<Object>? // Cast to ImageProvider
                              : (_currentUser?.photoURL != null && _currentUser!.photoURL!.isNotEmpty
                              ? NetworkImage(_currentUser!.photoURL!) // Load image from Firebase
                              : null),
                          child: _imageFile == null && (_currentUser?.photoURL == null || _currentUser!.photoURL!.isEmpty)
                              ? Icon(
                            Icons.person,
                            size: 50,
                            color: isDarkMode ? Colors.white : Colors.black,
                          )
                              : null,
                        ),
                        SizedBox(height: 10),
                        Text(
                          _currentUser?.displayName ?? "Guest",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _currentUser?.email ?? "No Email",
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 20),
                children: [
                  _buildDrawerItem(Icons.person, "Profile", () {
                    Navigator.pushNamed(context, '/profile');
                  }, isDarkMode),
                  
                  _buildDrawerItem(
                    isDarkMode ? Icons.wb_sunny : Icons.brightness_6,
                    isDarkMode ? "Day Mode" : "Night Mode",
                        () {
                      themeProvider.toggleTheme();
                    },
                    isDarkMode,
                  ),
                  _buildDrawerItem(Icons.info, "About", () {
                    Get.to(AboutPage());
                  }, isDarkMode),
                ],
              ),
            ),
            Divider(color: isDarkMode ? Colors.grey : Colors.black),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildDrawerItem(Icons.logout, "Sign Out", () => signOut(context), isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title, VoidCallback onTap, bool isDarkMode) {
    return ListTile(
      leading: Icon(icon, color: isDarkMode ? Colors.white : Colors.black, size: 30),
      title: Text(
        title,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 18),
      ),
      onTap: onTap,
    );
  }

  Widget _buildBottomNavigationBar(double screenWidth, double screenHeight, bool isDarkMode) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          height: screenHeight * 0.08,
          width: screenWidth * 0.4,
          left: _page == 0 ? 0 : screenWidth * 0.4,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.blue[900] : Colors.grey,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: isDarkMode ? Colors.blue[900]! : Colors.grey, width: 1),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? Colors.black54 : Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: isDarkMode ? Colors.blue : Colors.transparent, width: 1.5),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                selectedItemColor: isDarkMode ? Colors.white : Colors.black,
                unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                onTap: onBottomNavigationBarTap,
                currentIndex: _page,
                unselectedFontSize: screenWidth * 0.035,
                selectedFontSize: screenWidth * 0.04,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.comment_bank),
                    label: 'Meet & Chat',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    label: 'History',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}