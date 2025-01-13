import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<void> fetchCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  Future<void> updateProfile(String displayName) async {
    if (_currentUser != null) {
      await _currentUser!.updateProfile(displayName: displayName);
      await _currentUser!.reload();
      _currentUser = FirebaseAuth.instance.currentUser;
      notifyListeners();
    }
  }
}
