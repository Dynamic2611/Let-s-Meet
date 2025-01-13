import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CardPlanetData {
  final String title;
  final String subtitle;
  final LottieBuilder image;
  final Color backgroundColor;
  final Color titleColor;
  final Color subtitleColor;
  final LottieBuilder background;

  const CardPlanetData({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.backgroundColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.background,
  });
}

class CardPlanet extends StatelessWidget {
  const CardPlanet({
    required this.data,
    super.key,
  });

  final CardPlanetData data;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        data.background,
        Container(
          color: data.backgroundColor.withOpacity(0.5), // Ensure background color is slightly visible
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                const Spacer(flex: 3),
                Flexible(
                  flex: 20,
                  child: data.image,
                ),
                const Spacer(flex: 1),
                Text(
                  data.title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    color: data.titleColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  maxLines: 1,
                ),
                const Spacer(flex: 1),
                Text(
                  data.subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: data.subtitleColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 5),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
