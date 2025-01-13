import 'package:flutter/material.dart';
import 'package:letsmeet/resources/auth_methods.dart';
import 'package:letsmeet/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthMethods _authMethods = AuthMethods();
  bool _isLoading = false;

  void _showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void _hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content of the LoginScreen
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome to Let's Meet!",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: const Text(
                    "Join virtual meetings, collaborate, and stay connected.",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 38.0, horizontal: 30),
                  child: Image.asset('assets/login_bg.png'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Stack(
                    children: [
                      CustomButton(
                        text: 'Google Sign In',
                        onPressed: () async {
                          _showLoading();
                          try {
                            bool res = await _authMethods.signInWithGoogle(context);
                            if (res) {
                              if (mounted) {
                                Navigator.pushNamed(context, '/home');
                              }
                            } else {
                              print('Google Sign In failed');
                            }
                          } catch (e) {
                            print('Error during Google Sign In: $e');
                          } finally {
                            _hideLoading();
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 35.0,bottom:35,right: 10),
                        child: Image.asset(
                          'assets/google.png',
                          width: 130,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Modern Loading Overlay (Visible only when _isLoading is true)
          AnimatedOpacity(
            opacity: _isLoading ? 1.0 : 0.0,
            duration: Duration(milliseconds: 500),
            child: _isLoading
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Custom Circular Loading Indicator
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 6.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blueAccent,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          // Modern Text
                          const Text(
                            'Signing you in...',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
