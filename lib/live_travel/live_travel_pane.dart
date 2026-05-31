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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.session.groupName,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          'Meet at ${widget.session.meetPoint}',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progressColor =
        participant.hasArrived ? colorScheme.tertiary : colorScheme.primary;

    return Row(
      children: [
        if (participant.userId != widget.currentUserId) ...[
          CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.secondaryContainer,
            child: Text(
              participant.name.characters.first.toUpperCase(),
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              LinearProgressIndicator(
                value: participant.progressPercent.clamp(0.0, 1.0),
                minHeight: 24, // pill height
                backgroundColor: progressColor.withValues(alpha: 0.18),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                borderRadius: BorderRadius.circular(99),
              ),

              // ETA text on top of the pill
              Text(
                participant.etaLabel,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (participant.userId != widget.currentUserId) ...[
          const SizedBox(width: 8),
          Text(
            participant.currentLocation,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                    color: visited ? colorScheme.primary : colorScheme.outline,
                  ),
                  if (index != route.length - 1)
                    Container(
                      width: 2,
                      height: 24,
                      color: colorScheme.outlineVariant,
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
                      Text(
                        stop.placeName,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        stop.eta.format(context),
                        style: textTheme.labelSmall?.copyWith(
                          color: visited
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (userIds.isEmpty) return SizedBox();
    return Row(
      children: [
        Text(
          'Travelling with:',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        ...userIds.map(
          (id) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: colorScheme.secondaryContainer,
              child: Text(
                widget.session
                        .participantFor(id)
                        ?.name
                        .characters
                        .first
                        .toUpperCase() ??
                    "X",
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w800,
                ),
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

  Color _routeColorForIndex(
    int index,
    bool isMe,
    ColorScheme colorScheme,
  ) {
    if (isMe) return colorScheme.primary;
    final palette = [
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.error,
      colorScheme.inversePrimary,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];
    return palette[index % palette.length];
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
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: 2,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 20, color: colorScheme.onSurface),
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
    final colorScheme = Theme.of(context).colorScheme;
    final me = widget.session.participantFor(widget.currentUserId);

    return GestureDetector(
      onTap: () {
        if (me != null && me.remainingRoute.isNotEmpty) {
          setState(() => expanded = !expanded);
        }
      },
      child: Card(
        color: colorScheme.surface,
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header(),
              const SizedBox(height: 16),
              MapPlot(),
              const SizedBox(height: 16),
              ETA_List(),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: expanded && me != null
                    ? Column(
                        children: [
                          const SizedBox(height: 8),
                          Divider(
                            height: 2,
                            color: colorScheme.outlineVariant,
                          ),
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
              const SizedBox(height: 8),
              if (widget.session.currentlyTravellingWith.isEmpty) ...[
                Divider(height: 2, color: colorScheme.outlineVariant),
                const SizedBox(height: 8),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final participants = widget.session.participants;

    if (participants.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "No routes available",
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
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
      final routeColor = _routeColorForIndex(routeIndex, isMe, colorScheme);
      final outlineColor = colorScheme.shadow.withValues(alpha: 0.35);

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
            title:
                isMe ? 'Your destination' : '${participant.name} destination',
          ),
        ),
      );

      routeIndex += 1;
    }

    if (polylines.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "No route data",
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
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
        borderRadius: BorderRadius.circular(16),
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
