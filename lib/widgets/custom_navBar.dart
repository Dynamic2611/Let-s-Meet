import 'package:flutter/material.dart';
import 'dart:async';

class CustNavBar extends StatefulWidget {
  const CustNavBar({super.key});

  @override
  State<CustNavBar> createState() => _CustNavBarState();
}

List<IconData> navIcons=[
  Icons.home,
  Icons.person,
  Icons.settings
  ];


List<String> navTitle=[
  "Home",
  "Account",
  "Setting"
  ];


int  selectedIndex=0;

class _CustNavBarState extends State<CustNavBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //create bottom navigation bar
          Align(
            alignment: Alignment.bottomCenter,
            child: _navBar())
        ],
      ),
    );
  }

  Widget _navBar() {
    bool _isHighlighted = false; // Flag for background color state

    void _toggleHighlight() {
      setState(() {
        _isHighlighted = true; // Set highlighted state on tap
        Future.delayed(Duration(milliseconds: 300), () { // Delay color change
          setState(() {
            _isHighlighted = false; // Remove highlight after 100ms
          });
        });
      });
    }

    return Container(
      height: 65,
      margin: const EdgeInsets.only(right: 24, left: 24, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 30,
            spreadRadius: 15,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: navIcons.map((icon) {
          int index = navIcons.indexOf(icon);
          bool isSelected = selectedIndex == index;

          return AnimatedContainer(
            duration: Duration(milliseconds: 300), // Animation duration
            curve: Curves.easeInOut, // Animation curve

            decoration: BoxDecoration(
              color: isSelected
                  ? (_isHighlighted ? Colors.lightBlue.withOpacity(0.2) : Colors.transparent)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(isSelected ? 25 : 10),
            ),
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  _toggleHighlight();
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(
                            left: 35, right: 35, top: 8, bottom: 0),
                        child: Icon(
                          icon,
                          color: isSelected ? Colors.blue : Colors.grey,
                          size: isSelected ? 40 : 35,
                        ),
                      ),
                      isSelected?Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          navTitle[index],
                          style: TextStyle(
                            color: isSelected ? Colors.blue.withOpacity(0.7) : Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ):Text(""),
                    
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
