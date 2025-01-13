import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../utils/ThemeProvider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _displayNameController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    User? user = _auth.currentUser;
    setState(() {
      _currentUser = user;
      if (user != null) {
        _displayNameController.text = user.displayName ?? '';
        _loadStoredImage();
      }
    });
  }

  Future<void> _loadStoredImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/profile_image.png';
    final file = File(imagePath);

    if (await file.exists()) {
      setState(() {
        _imageFile = file;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_imageFile != null) {
          final directory = await getApplicationDocumentsDirectory();
          final imagePath = '${directory.path}/profile_image.png';
          await _imageFile!.copy(imagePath);
        }

        await _currentUser!.updateProfile(displayName: _displayNameController.text);
        await _currentUser!.reload();
        _currentUser = _auth.currentUser;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(255, 58, 190, 251),
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final screenHeight = MediaQuery.of(context).size.height;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: screenHeight * 0.22,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/pro_back.png"),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.grey[800] : Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(100)),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 5,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _imageFile != null
                                  ? Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                      width: 130,
                                      height: 130,
                                    )
                                  : (_currentUser?.photoURL != null &&
                                          _currentUser!.photoURL!.isNotEmpty
                                      ? Image.network(
                                          _currentUser!.photoURL!,
                                          fit: BoxFit.cover,
                                          width: 130,
                                          height: 130,
                                        )
                                      : const CircleAvatar(
                                          radius: 50,
                                          backgroundColor:
                                              Color.fromARGB(255, 67, 66, 66),
                                          child: Icon(
                                            Icons.person,
                                            size: 70,
                                            color: Colors.grey,
                                          ),
                                        )),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100, left: 120),
                          child: Icon(Icons.add_a_photo,
                              size: 30,
                              color:
                                  isDarkMode ? Colors.white : Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  Card(
                    color: isDarkMode ? Colors.grey[850] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 60, left: 16, right: 16, bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Email ",
                            style: TextStyle(
                                fontSize: 20,
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          if (_currentUser != null) ...[
                            Text(
                              _currentUser!.email ?? 'No email available',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black),
                            ),
                            SizedBox(height: 10),
                          ],
                          SizedBox(height: 20),
                          Text(
                            "Name ",
                            style: TextStyle(
                                fontSize: 20,
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 20),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _displayNameController,
                                  decoration: InputDecoration(
                                    labelText: "Display Name",
                                    labelStyle: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.black),
                                    filled: true,
                                    fillColor: isDarkMode
                                        ? Colors.grey[900]
                                        : Colors.transparent,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.blue, width: 2),
                                    ),
                                  ),
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 18),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 50),
                                ElevatedButton(
                                  onPressed: _updateProfile,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  child: Text('Save Changes'),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
