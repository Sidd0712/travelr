import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final me = widget.session.participantFor(widget.currentUserId);

    return GestureDetector(
      onTap: () {
        if (me != null && me.remainingRoute.isNotEmpty) {
          setState(() => expanded = !expanded);
        }
      },
      child: SizedBox(
        height: 100,
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
              _Header(session: widget.session),
              const SizedBox(height: 12),

              _EtaList(session: widget.session),

              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: expanded && me != null
                    ? SizedBox(height: 160,
                      child: RemainingRouteTimeline(
                      route: me.remainingRoute,
                      scrollable: true,
                      ),
                  )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 12),

              _TravellingWithRow(
                userIds: widget.session.currentlyTravellingWith,
              ),
            ],
          ),
        ),
      ),
        ),
      );
  }
}

// Header
class _Header extends StatelessWidget {
  final LiveTravelSession session;

  const _Header({required this.session});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          session.groupName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        Text(
          'Meet at ${session.meetPoint}',
          style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}

// ETA List (scrolls if >5 users)
class _EtaList extends StatelessWidget {
  final LiveTravelSession session;

  const _EtaList({required this.session});

  @override
  Widget build(BuildContext context) {
    final limitHeight = session.participants.length > 5;

    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: limitHeight ? 220 : double.infinity),
      child: ListView.separated(
        shrinkWrap: true,
        physics: limitHeight
            ? const BouncingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: session.participants.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, index) {
          return EtaRow(participant: session.participants[index]);
        },
      ),
    );
  }
}

// ETA Row

class EtaRow extends StatelessWidget {
  final TravelParticipant participant;

  const EtaRow({
    super.key,
    required this.participant,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade300,
          child: Text(
            participant.name.characters.first.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              LinearProgressIndicator(
                value: participant.progressPercent.clamp(0.0, 1.0), 
                minHeight: 24, // pill height
                backgroundColor: (participant.hasArrived
                  ? Colors.green
                  : Colors.blue).withValues(alpha : 0.2),
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
    const SizedBox(width: 8),

          Text(
            participant.currentLocation,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ],
    );
  } // Widget build
}

// Remaining Route - scrollable timeline.
class RemainingRouteTimeline extends StatelessWidget {
  final List<RouteStop> route;
  final bool scrollable;

  const RemainingRouteTimeline({
    super.key,
    required this.route,
    this.scrollable = false,
     });

  bool _isVisited(TimeOfDay eta) {
    final now = TimeOfDay.now();
    return (eta.hour * 60 + eta.minute) <=
        (now.hour * 60 + now.minute);
  }

  @override
  Widget build(BuildContext context) {
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
                    stop.isMeetPoint
                    ? Icons.location_on
                    : visited
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                    size: 16,
                    color: stop.isMeetPoint
                    ? Colors.blue
                    : visited
                      ? Colors.green
                        : Colors.grey,
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
}

// Travelling_With Row

class _TravellingWithRow extends StatelessWidget {
  final List<String> userIds;

  const _TravellingWithRow({
    required this.userIds,
  });

  @override
  Widget build(BuildContext context) {
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
                id.characters.first.toUpperCase(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
