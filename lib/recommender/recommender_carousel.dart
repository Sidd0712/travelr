import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travelr/friends/friends_service.dart';
import 'package:travelr/recommender/recommendation_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RecommenderCarousel extends StatefulWidget {
  final List<Recommendation> recommendations;
  final VoidCallback onClose;

  const RecommenderCarousel({
    super.key,
    required this.recommendations,
    required this.onClose,
  });

  @override
  State<RecommenderCarousel> createState() => _RecommenderCarouselState();
}

class _RecommenderCarouselState extends State<RecommenderCarousel> {
  int currentIndex = 0;
  bool isFriend = false;
  bool allowTransportModes = true;
  late List<Recommendation> _recommendations;

  @override
  void initState() {
    super.initState();

    _recommendations = List<Recommendation>.from(
      widget.recommendations,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: colorScheme.scrim.withValues(alpha: 0.25),
    ));
    if (_recommendations.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onClose();
      });
      return const SizedBox.shrink();
    }

    final activeRecommendation = _recommendations[currentIndex];
    // will replace with API logic later
    isFriend = activeRecommendation.phoneNumber != null;
    allowTransportModes = activeRecommendation.segments?.isNotEmpty ?? false;
    print("Recommendations count: ${_recommendations.length}");

    return Material(
      color: colorScheme.scrim.withValues(alpha: 0),
      child: Stack(
        children: [
          // Blur + Dim Background
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onClose,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: colorScheme.scrim.withValues(alpha: 0.32),
                ),
              ),
            ),
          ),

          // Overlay Body
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Text(
                    "Travel Buddies Found",
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onInverseSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: PageView.builder(
                      itemCount: _recommendations.length,
                      controller: PageController(viewportFraction: 0.9),
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: RecommendationCard(
                            recommendation: _recommendations[index],
                            allowTransportModes: allowTransportModes,
                            allowPhoneNumber: isFriend,
                            isActive: index == currentIndex,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    //page indicator
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _recommendations.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentIndex == index ? 12 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: currentIndex == index
                              ? colorScheme.onInverseSurface
                              : colorScheme.primary.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: isFriend
                        ? widget.onClose
                        : () async {
                            try {
                              await FriendsService.sendFriendRequest(
                                activeRecommendation.uid,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Friend Request sent to ${activeRecommendation.name}",
                                  ),
                                ),
                              );

                              setState(() {
                                _recommendations.remove(activeRecommendation);

                                if (_recommendations.isEmpty) {
                                  widget.onClose();
                                  return;
                                }

                                currentIndex = currentIndex.clamp(
                                  0,
                                  _recommendations.length - 1,
                                );
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          },
                    style: ButtonStyle(
                      fixedSize: const WidgetStatePropertyAll(Size(200, 48)),
                      backgroundColor:
                          WidgetStatePropertyAll(colorScheme.primary),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    child: Text(
                      isFriend ? "Close" : "Send Request",
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
  final bool allowTransportModes;
  final bool allowPhoneNumber;
  final bool isActive;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.allowTransportModes,
    required this.allowPhoneNumber,
    required this.isActive,
  });

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  bool showDetails = false;
  GoogleMapController? _mapController;

  List<LatLng> _decodePolyline(String encoded) {
    final decoded = PolylinePoints().decodePolyline(encoded);
    return decoded.map((p) => LatLng(p.latitude, p.longitude)).toList();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _toggleDetails() {
    setState(() {
      showDetails = !showDetails;
    });
  }

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

  // Add this helper to _RecommendationCardState
  int _nearestIndex(List<LatLng> points, LatLng target) {
    int best = 0;
    double bestDist = double.infinity;
    for (int i = 0; i < points.length; i++) {
      final dLat = points[i].latitude - target.latitude;
      final dLng = points[i].longitude - target.longitude;
      final dist = dLat * dLat + dLng * dLng;
      if (dist < bestDist) {
        bestDist = dist;
        best = i;
      }
    }
    return best;
  }

  void _animateToRoute() {
    final controller = _mapController;
    if (controller == null) return;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final boundsPoints = _decodePolyline(widget.recommendation.polyline);

      final minLat =
          boundsPoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
      final maxLat =
          boundsPoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
      final minLng =
          boundsPoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
      final maxLng =
          boundsPoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

      final hasArea =
          (maxLat - minLat).abs() > 0.0001 || (maxLng - minLng).abs() > 0.0001;

      if (hasArea) {
        controller.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(minLat, minLng),
              northeast: LatLng(maxLat, maxLng),
            ),
            48,
          ),
        );
      } else {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: boundsPoints.first, zoom: 15),
          ),
        );
      }
    });
  }

  @override
  void didUpdateWidget(RecommendationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _animateToRoute();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cardColor = colorScheme.inverseSurface;
    final cardTextColor = colorScheme.onInverseSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Builder(builder: (context) {
            final polyline = widget.recommendation.polyline;
            if (polyline.isEmpty) {
              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      "No route available",
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }

            final points = _decodePolyline(polyline);
            if (points.isEmpty) return const SizedBox(height: 160);

            final meetPoint = LatLng(widget.recommendation.meetPoint[0],
                widget.recommendation.meetPoint[1]);
            final splitPoint = LatLng(widget.recommendation.splitPoint[0],
                widget.recommendation.splitPoint[1]);

            final startIndex = _nearestIndex(points, meetPoint);
            final endIndex = _nearestIndex(points, splitPoint);

            final commonPoints = startIndex <= endIndex
                ? points.sublist(startIndex, endIndex + 1)
                : points.sublist(endIndex, startIndex + 1);

            final polylineSet = {
              Polyline(
                polylineId: const PolylineId('user_route'),
                points: points,
                width: 6,
                color: colorScheme.outline,
                zIndex: 1,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
              Polyline(
                polylineId: const PolylineId('common_route'),
                points: commonPoints,
                width: 6,
                color: colorScheme.primary,
                zIndex: 2,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            };

            final markers = {
              Marker(
                markerId: const MarkerId('Meet'),
                position: points.first,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
              ),
              Marker(
                markerId: const MarkerId('Split'),
                position: points.last,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
              ),
            };

            return Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AbsorbPointer(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: points[points.length ~/ 2],
                      zoom: 12,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      if (widget.isActive) _animateToRoute();
                    },
                    polylines: polylineSet,
                    markers: markers,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    compassEnabled: false,
                    scrollGesturesEnabled: false,
                    style: '''
                  [
                    { "elementType": "labels", "stylers": [{ "visibility": "off" }] },
                    { "featureType": "poi", "stylers": [{ "visibility": "off" }] },
                    { "featureType": "transit", "stylers": [{ "visibility": "off" }] },
                    { "featureType": "road", "elementType": "labels", "stylers": [{ "visibility": "off" }] }
                  ]
                  ''',
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),
          Row(
            //mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colorScheme.primaryContainer,

                // When you have an image URL later, this line will activate
                // backgroundImage: NetworkImage(widget.recommendation.profileImageUrl),

                child: Text(
                  "DP",
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Name + gender/age
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.recommendation.name,
                    style: textTheme.titleMedium?.copyWith(
                      color: cardTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${widget.recommendation.gender}  ${widget.recommendation.age}",
                    style: textTheme.labelSmall?.copyWith(
                      color: cardTextColor.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (widget.allowPhoneNumber &&
              widget.recommendation.phoneNumber != null)
            Row(
              children: [
                const SizedBox(height: 6),
                Text(
                  widget.recommendation.phoneNumber!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: cardTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
                      minHeight: 36, // pill height
                      backgroundColor:
                          colorScheme.tertiary.withValues(alpha: 0.25),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.tertiary,
                      ),
                    ),
                    Text(
                      "Shared Route : ${widget.recommendation.overlapDist.toStringAsFixed(1)} km",
                      style: textTheme.labelSmall?.copyWith(
                        color: cardTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.allowTransportModes)
            Row(
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.recommendation.segments!.map((segment) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        _iconForMode(segment.mode),
                        size: 20,
                        color: cardTextColor.withValues(alpha: 0.72),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

          // -- Temporary Meet Split Code --
          // const SizedBox(height: 16),
          // // Meet / Split
          // Text("Meet: ${widget.recommendation.meetPoint}"),
          // Text("Split: ${widget.recommendation.splitPoint}"),

          if (widget.recommendation.canShowETA &&
              widget.recommendation.etaAtMeetPoint != null)
            Row(
              children: [
                const SizedBox(height: 16),
                Text(
                  "ETA at meet point: ${widget.recommendation.etaAtMeetPoint!.format(context)}",
                  style: textTheme.labelSmall?.copyWith(
                    color: cardTextColor.withValues(alpha: 0.64),
                  ),
                ),
              ],
            ),
          // COLLAPSED STATE → View Details
          if (!showDetails && widget.allowTransportModes)
            Row(
              children: [
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _toggleDetails,
                  style: ButtonStyle(
                    overlayColor: WidgetStatePropertyAll(
                      colorScheme.primary.withValues(alpha: 0.08),
                    ),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                  child: Text(
                    "View Details",
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

          //         if (widget.allowTransportModes)
          // TextButton(
          //   onPressed: _toggleDetails,
          //   style: const ButtonStyle(
          //     overlayColor: WidgetStatePropertyAll(null),
          //     padding: WidgetStatePropertyAll(
          //       EdgeInsets.symmetric(vertical: 6),
          //     ),
          //   ),
          //   child: Text(
          //     showDetails ? "Hide Details" : "View Details",
          //     style: null,
          //   ),
          // ),

          if (showDetails && widget.allowTransportModes)
            Column(
              children: [
                const SizedBox(height: 16),
                SizedBox(
                  height: 140,
                  child: SingleChildScrollView(
                    child: Column(
                      children: widget.recommendation.segments!.map((segment) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                _iconForMode(segment.mode),
                                color: cardTextColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "${segment.mode}: ${segment.from} → ${segment.to}",
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: cardTextColor,
                                  ),
                                ),
                              ),
                              Text(
                                "${segment.startTime.format(context)} - ${segment.endTime.format(context)}",
                                style: textTheme.labelSmall?.copyWith(
                                  color: cardTextColor.withValues(alpha: 0.72),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _toggleDetails,
                  style: ButtonStyle(
                    overlayColor: WidgetStatePropertyAll(
                      colorScheme.primary.withValues(alpha: 0.08),
                    ),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                  child: Text(
                    "Hide Details",
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
