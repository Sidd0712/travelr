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
              fontSize: 14, color: Colors.black, fontWeight: FontWeight.w400),
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
          const SizedBox(width: 12)
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
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ]
      ],
    );
  }

  // Remaining Route - scrollable timeline.
  Padding RemainingRouteTimeline(
      BuildContext context, List<RouteStop> route, bool scrollable) {
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

  Row TravellingWithRow(List<String> userIds) {
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
              Divider(height: 2),
              const SizedBox(height: 10),
              Row(
                children: [
                  TravellingWithRow(
                    widget.session.currentlyTravellingWith,
                  ),
                  Expanded(
                    child: Text(
                      widget.session.updatedAt.toString(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
