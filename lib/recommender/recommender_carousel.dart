import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:travelr/recommender/recommendation_model.dart';

class RecommenderCarousel extends StatefulWidget {
  final List<Recommendation> recommendations;

  const RecommenderCarousel({
    super.key,
    required this.recommendations,
  });

  @override
  State<RecommenderCarousel> createState() => _RecommenderCarouselState();
}

class _RecommenderCarouselState extends State<RecommenderCarousel> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    print("Recommendations count: ${widget.recommendations.length}");
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Blur + Dim Background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: Colors.black.withValues(alpha: 0.55),
              ),
            ),
          ),

          // Overlay Body
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    "Recommended Travel Companions",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Carousel
                  // This just builds the carousel card for each recommendation
                  Expanded(
                    child: PageView.builder(
                      itemCount: widget.recommendations.length,
                      controller: PageController(viewportFraction: 0.9),
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: RecommendationCard(
                            recommendation: widget.recommendations[index],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.recommendations.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentIndex == index ? 12 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: currentIndex == index
                              ? Colors.white
                              : Colors.white38,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {}, // Leave as is, part of phase 2.
                    style: const ButtonStyle(
                      fixedSize: WidgetStatePropertyAll(Size(200, 50)),
                      padding: WidgetStatePropertyAll(EdgeInsets.zero),
                      backgroundColor: WidgetStatePropertyAll(Colors.blue),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)))),
                    ),
                    child: Center(
                      child: Text(
                        "Send Request",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;

  const RecommendationCard({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Update this code with your code. Design according to excali.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.blue),
      ),
      child: Center(
        child: Text(
          recommendation.name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
