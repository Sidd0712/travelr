class FriendRequestModel {
  final String fromUid;
  final DateTime? requestedAt;

  FriendRequestModel({
    required this.fromUid,
    this.requestedAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      fromUid: json["from"],
      requestedAt: json["requestedAt"] != null
          ? DateTime.parse(json["requestedAt"])
          : null,
    );
  }
}
