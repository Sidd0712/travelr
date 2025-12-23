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
    final activeRecommendation = widget.recommendations[currentIndex];
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
                color: const Color.fromARGB(255, 0, 0, 0)
                    .withValues(alpha: 0.55),
              ),
            ),
          ),

          // Overlay Body
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  const Text(
                    "Travel Buddies Found",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),

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
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          child: RecommendationCard(
                            recommendation:
                                widget.recommendations[index],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.recommendations.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin:
                            const EdgeInsets.symmetric(horizontal: 4),
                        width: currentIndex == index ? 12 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: currentIndex == index
                              ? Colors.white
                              : const Color.fromARGB(97, 14, 162, 203),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: activeRecommendation.isFriend
                    ? () {
                    Navigator.of(context).pop();
                    }
                    : () {// TODO: Send Request logic (later)
                    },

                style: const ButtonStyle(
                fixedSize: WidgetStatePropertyAll(Size(200, 50)),
                backgroundColor: WidgetStatePropertyAll(Colors.blue),
                shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),

            child: Text(
            activeRecommendation.isFriend ? "Close": "Send Request",
            style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
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

class RecommendationCard extends StatefulWidget {
  final Recommendation recommendation;

  const RecommendationCard({
    super.key,
    required this.recommendation,
  });

  @override
  State<RecommendationCard> createState() =>
      _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  bool showDetails = false;

  IconData _iconForMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'train':
        return Icons.train;
      case 'metro':
        return Icons.subway;
      case 'auto':
        return Icons.directions_car;
      default:
        return Icons.directions_walk;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(22),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Map placeholder
            Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
            BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),

    BoxShadow(
      color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.25),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ],
),
  child: Stack(
    children: [
      Positioned.fill(
        child: Opacity(
          opacity: 0.08,
          child: Icon(
            Icons.map,
            size: 140,
            color: Colors.black,
          ),
        ),
      ),

      // Center label
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.location_on,
              color: Colors.blue,
              size: 28,
            ),
            SizedBox(height: 6),
            Text(
              "Route Preview",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

            const SizedBox(height: 16),
           Center(
            child: Row(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey.shade300,

  // When you have an image URL later, this line will activate
  // backgroundImage: NetworkImage(widget.recommendation.profileImageUrl),

  child: const Text(
    "DP",
    style: TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.w500,
    ),
  ),
),
        const SizedBox(width: 12),
        // Name + gender/age
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.recommendation.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "${widget.recommendation.gender}  ${widget.recommendation.age}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
  const SizedBox(height: 6),

    if (widget.recommendation.canShowPhoneNumber && widget.recommendation.phoneNumber != null)
    Text(
      widget.recommendation.phoneNumber!,
      style: const TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      ),
    ),
          const SizedBox(height: 16),
            // Overlap pill + progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

          const SizedBox(height: 6),

              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                alignment: Alignment.center,
                children: [
                  LinearProgressIndicator(
                    value: widget.recommendation.overlapPercent,
                    minHeight: 18, // pill height
                    backgroundColor: Colors.green.withOpacity(0.25),
                    valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                   Text(
                      "Shared Route : ${widget.recommendation.overlapDist.toStringAsFixed(1)} km",
                      style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      ),
                    ),
                ],
              ),
              ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.recommendation.canShowTransportModes)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.recommendation.segments.map((segment) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  _iconForMode(segment.mode),
                  size: 20,
                  color: Colors.white70,
                ),
              );
            }).toList(),
            ),

             const SizedBox(height: 12),
            // Meet / Split
            Text(
              "Meet: ${widget.recommendation.meetPoint}",
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            Text(
              "Split: ${widget.recommendation.splitPoint}",
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),

            const SizedBox(height: 12),
            if (widget.recommendation.canShowETA &&
              widget.recommendation.etaAtMeetPoint != null)
              Text(
                "ETA at meet point: ${widget.recommendation.etaAtMeetPoint!.format(context)}",
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
            const SizedBox(height: 12),

            // View Details
            if (!showDetails && widget.recommendation.canShowRouteSegments)
            GestureDetector(
              onTap: () {
              setState(() => showDetails = true);
              },
            child: const Text(
            "View Details",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

            // Expanded details
            if (showDetails && widget.recommendation.canShowRouteSegments)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  ...widget.recommendation.segments.map((segment) {
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center,
                        children: [
                          Icon(
                            _iconForMode(segment.mode),
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "${segment.mode}: ${segment.from} → ${segment.to}",
                              style: const TextStyle(
                                  color: Colors.white),
                            ),
                          ),
                          Text(
                            "${segment.startTime.format(context)} - ${segment.endTime.format(context)}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showDetails = false;
                      });
                    },
                    child: const Center(
                      child: Text(
                        "Hide Details",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
