import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'live_travel_model.dart';

class LiveTravelPane extends StatefulWidget {
  final LiveTravelSession session;
  final String currentUserId;

  const LiveTravelPane({
    super.key,
    required this.session,
    required this.currentUserId,
  });

  @override
  State<LiveTravelPane> createState() => _LiveTravelPaneState();
}

class _LiveTravelPaneState extends State<LiveTravelPane>
    with TickerProviderStateMixin {
  bool expanded = false;
  GoogleMapController? _mapController;
  String? _lastFitKey;

  Row header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.session.groupName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        Text(
          'Meet at ${widget.session.meetPoint}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ETA List (scrolls if >5 users)
  ConstrainedBox ETA_List() {
    final limitHeight = widget.session.participants.length > 5;

    return ConstrainedBox(
      constraints: limitHeight
          ? const BoxConstraints(maxHeight: 220)
          : const BoxConstraints(),
      child: ListView.separated(
        shrinkWrap: true,
        physics: limitHeight
            ? const BouncingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: widget.session.participants.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, index) {
          return ETA_Row(widget.session.participants[index]);
        },
      ),
    );
  }

  Row ETA_Row(TravelParticipant participant) {
    return Row(
      children: [
        if (participant.userId != widget.currentUserId) ...[
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade300,
            child: Text(
              participant.name.characters.first.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              LinearProgressIndicator(
                value: participant.progressPercent.clamp(0.0, 1.0),
                minHeight: 24, // pill height
                backgroundColor:
                    (participant.hasArrived ? Colors.green : Colors.blue)
                        .withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  participant.hasArrived ? Colors.green : Colors.blue,
                ),
                borderRadius: BorderRadius.circular(14),
              ),

              // ETA text on top of the pill
              Text(
                participant.etaLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        if (participant.userId != widget.currentUserId) ...[
          const SizedBox(width: 8),
          Text(
            participant.currentLocation,
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ],
    );
  }

  // Remaining Route - scrollable timeline.
  Padding RemainingRouteTimeline(
    BuildContext context,
    List<RouteStop> route,
    bool scrollable,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ListView.builder(
        shrinkWrap: true,
        physics: scrollable
            ? const BouncingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: route.length,
        itemBuilder: (_, index) {
          final stop = route[index];
          final visited = _isVisited(stop.eta);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(
                    visited ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 16,
                    color: visited ? Colors.green : Colors.grey,
                  ),
                  if (index != route.length - 1)
                    Container(
                      width: 2,
                      height: 24,
                      color: Colors.grey.shade300,
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(stop.placeName),
                      Text(
                        stop.eta.format(context),
                        style: TextStyle(
                          fontSize: 12,
                          color: visited ? Colors.green : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isVisited(TimeOfDay eta) {
    final now = TimeOfDay.now();
    return (eta.hour * 60 + eta.minute) <= (now.hour * 60 + now.minute);
  }

  Widget TravellingWithRow(List<String> userIds) {
    if (userIds.isEmpty) return SizedBox();
    return Row(
      children: [
        const Text('Travelling with:', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 8),
        ...userIds.map(
          (id) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade300,
              child: Text(
                widget.session
                        .participantFor(id)
                        ?.name
                        .characters
                        .first
                        .toUpperCase() ??
                    "X",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<LatLng> decodePolyline(String encoded) {
    final decoded = PolylinePoints().decodePolyline(encoded);
    return decoded.map((p) => LatLng(p.latitude, p.longitude)).toList();
  }

  Color _routeColorForIndex(int index, bool isMe) {
    if (isMe) return Colors.blue.shade700;
    const palette = [
      Colors.teal,
      Colors.deepOrange,
      Colors.purple,
      Colors.indigo,
      Colors.green,
      Colors.brown,
      Colors.pink,
    ];
    return palette[index % palette.length].shade600;
  }

  Future<void> _zoomBy(double delta) async {
    final controller = _mapController;
    if (controller == null) return;
    final zoom = await controller.getZoomLevel();
    await controller.animateCamera(CameraUpdate.zoomTo(zoom + delta));
  }

  Widget _zoomButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
      ),
    );
  }

  void _maybeFitCamera(Set<Polyline> polylines, String fitKey) {
    if (_mapController == null || polylines.isEmpty) return;
    if (_lastFitKey == fitKey) return;
    _lastFitKey = fitKey;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _mapController == null) return;
      await _fitCameraToPolylines(polylines);
    });
  }

  Future<void> _fitCameraToPolylines(Set<Polyline> polylines) async {
    if (polylines.isEmpty) return;

    double? minLat;
    double? maxLat;
    double? minLng;
    double? maxLng;

    for (final polyline in polylines) {
      for (final point in polyline.points) {
        if (minLat == null || point.latitude < minLat!) {
          minLat = point.latitude;
        }
        if (maxLat == null || point.latitude > maxLat!) {
          maxLat = point.latitude;
        }
        if (minLng == null || point.longitude < minLng!) {
          minLng = point.longitude;
        }
        if (maxLng == null || point.longitude > maxLng!) {
          maxLng = point.longitude;
        }
      }
    }

    if (minLat == null || maxLat == null || minLng == null || maxLng == null) {
      return;
    }

    final hasArea =
        (maxLat - minLat).abs() > 0.0001 || (maxLng - minLng).abs() > 0.0001;

    if (!hasArea) {
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(minLat, minLng), zoom: 15),
        ),
      );
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 48),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = widget.session.participantFor(widget.currentUserId);

    return GestureDetector(
      onTap: () {
        if (me != null && me.remainingRoute.isNotEmpty) {
          setState(() => expanded = !expanded);
        }
      },
      child: Card(
        color: Colors.white,
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header(),
              const SizedBox(height: 12),
              MapPlot(),
              const SizedBox(height: 12),
              ETA_List(),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: expanded && me != null
                    ? Column(
                        children: [
                          const SizedBox(height: 10),
                          Divider(height: 2),
                          SizedBox(
                            height: 160,
                            width: double.infinity,
                            child: RemainingRouteTimeline(
                              context,
                              me.remainingRoute,
                              true,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 10),
              if (widget.session.currentlyTravellingWith.isEmpty) ...[
                Divider(height: 2),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  TravellingWithRow(widget.session.currentlyTravellingWith),
                  // Expanded(
                  //   child: Text(
                  //     widget.session.updatedAt.toString(),
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget MapPlot() {
    final participants = widget.session.participants;

    if (participants.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No routes available")),
      );
    }

    final Map<PolylineId, Polyline> polylines = {};
    final Set<Marker> markers = {};
    int routeIndex = 0;

    for (final participant in participants) {
      if (participant.polyline?.isEmpty ?? true) continue;

      final points = decodePolyline(participant.polyline!);
      if (points.isEmpty) continue;

      final isMe = participant.userId == widget.currentUserId;
      final routeColor = _routeColorForIndex(routeIndex, isMe);
      final outlineColor = Colors.black.withValues(alpha: 0.35);

      polylines[PolylineId('${participant.userId}_base')] = Polyline(
        polylineId: PolylineId('${participant.userId}_base'),
        points: points,
        width: isMe ? 10 : 8,
        color: outlineColor,
        zIndex: isMe ? 2 : 1,
      );

      polylines[PolylineId('${participant.userId}_main')] = Polyline(
        polylineId: PolylineId('${participant.userId}_main'),
        points: points,
        width: isMe ? 6 : 4,
        color: routeColor,
        zIndex: isMe ? 3 : 2,
      );

      final start = points.first;
      final end = points.last;

      markers.add(
        Marker(
          markerId: MarkerId('start_${participant.userId}'),
          position: start,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isMe ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(
            title: isMe ? 'Your start' : '${participant.name} start',
          ),
        ),
      );

      markers.add(
        Marker(
          markerId: MarkerId('end_${participant.userId}'),
          position: end,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isMe ? BitmapDescriptor.hueRed : BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: isMe ? 'Your destination' : '${participant.name} destination',
          ),
        ),
      );

      routeIndex += 1;
    }

    if (polylines.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No route data")),
      );
    }

    final fitPolylines = polylines.values
        .where((polyline) => polyline.polylineId.value.endsWith('_main'))
        .toSet();
    final fitKey = participants
        .where((p) => p.polyline?.isNotEmpty ?? false)
        .map((p) => '${p.userId}:${p.polyline.hashCode}')
        .join('|');

    if (_mapController != null && fitPolylines.isNotEmpty) {
      _maybeFitCamera(fitPolylines, fitKey);
    }

    debugPrint("Polyline count: ${polylines.length}");
    for (final p in polylines.entries) {
      debugPrint(
          "Polyline ${p.value.polylineId.value} points: ${p.value.points.length}");
    }

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: fitPolylines.first.points.first,
                zoom: 13,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                if (fitPolylines.isNotEmpty) {
                  _maybeFitCamera(fitPolylines, fitKey);
                }
              },
              polylines: Set<Polyline>.of(polylines.values),
              markers: markers,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Column(
                children: [
                  _zoomButton(icon: Icons.add, onTap: () => _zoomBy(1)),
                  const SizedBox(height: 6),
                  _zoomButton(icon: Icons.remove, onTap: () => _zoomBy(-1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
