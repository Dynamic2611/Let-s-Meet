import 'package:flutter/material.dart';
import 'package:concentric_transition/concentric_transition.dart';
import 'package:letsmeet/resources/auth_methods.dart';
import 'package:letsmeet/screens/home.dart';
import 'package:letsmeet/screens/login_screen.dart';
import 'package:letsmeet/screens/onboarding/card_planet.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: IntroductionPage(),
    );
  }
}

class IntroductionPage extends StatefulWidget {
  IntroductionPage({super.key});

  @override
  _IntroductionPageState createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<CardPlanetData> data = [
    CardPlanetData(
      title: "Redefining Virtual Collaboration",
      subtitle: "Connect effortlessly and collaborate with powerful tools like screen sharing and interactive whiteboard",
      image: LottieBuilder.asset("assets/animation/bg3.json"),
      backgroundColor: Colors.orange.shade300,
      titleColor: Colors.purple.shade300,
      subtitleColor: Colors.white,
      background: LottieBuilder.asset("assets/animation/bg2.json"),
    ),
    CardPlanetData(
      title: "Experience Enhanced Productivity",
      subtitle: "Automatic Attendance Tracking: Keep track of participation effortlessly.\n Screen Sharing: Share your work and ideas in real-time.",
      image: LottieBuilder.asset("assets/animation/intractive_whiteboard_L.json"),
      backgroundColor: Colors.white,
      titleColor: Colors.orange.shade300,
      subtitleColor: Colors.purple.shade300,
      background: LottieBuilder.asset("assets/animation/bg2.json"),
    ),
    CardPlanetData(
      title: "Collaborate Creatively",
      subtitle: "Whiteboard Collaboration : Visualize your ideas with ease.\n Get started by creating your account and scheduling your first meeting.",
      image: LottieBuilder.asset("assets/animation/bg3.json"),
      backgroundColor: Colors.purple.shade300,
      titleColor: Colors.white,
      subtitleColor: Colors.orange.shade300,
      background: LottieBuilder.asset("assets/animation/bg2.json"),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_pageListener);
  }

  void _pageListener() {
    setState(() {
      _currentPage = _controller.page?.round() ?? 0;
    });
  }

 

  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const StreamBuild()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ConcentricPageView(
            colors: data.map((e) => e.backgroundColor).toList(),
            itemCount: data.length,
            itemBuilder: (int index) {
              return CardPlanet(data: data[index]);
            },
            pageController: _controller,
            radius: MediaQuery.of(context).size.width * 1.2, // Adjust the size of the circle
          ),
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: () {
                _navigateToLogin(context);
              },
              child: const Text(
                'Skip',
                style: TextStyle(color: Colors.black, fontSize: 16,fontStyle: FontStyle.italic),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 20,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return TextButton(
                  onPressed: () {
                    if (_currentPage == data.length - 1) {
                      _navigateToLogin(context);
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  child: Text(
                    _currentPage == data.length - 1 ? 'Get Started' : 'Next >>',
                    style: const TextStyle(color: Colors.black, fontSize: 20,fontStyle: FontStyle.italic),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StreamBuild extends StatelessWidget {
  const StreamBuild({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthMethods().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
