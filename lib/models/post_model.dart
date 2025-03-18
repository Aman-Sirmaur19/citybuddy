class PostModel {
  PostModel({
    required this.id,
    required this.createdAt,
    required this.senderId,
    required this.receiverId,
    required this.latitude,
    required this.longitude,
    required this.message,
    required this.isReplied,
    required this.upVotes,
    required this.replyIds,
    required this.imagesLink,
  });

  late String id;
  late String createdAt;
  late String senderId;
  late String receiverId;
  late String latitude;
  late String longitude;
  late String message;
  late bool isReplied;
  late List<String> upVotes;
  late List<String> replyIds;
  late List<String> imagesLink;

  PostModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    createdAt = json['created_at'] ?? '';
    senderId = json['senderId'] ?? '';
    receiverId = json['receiverId'] ?? '';
    latitude = json['latitude'] ?? '';
    longitude = json['longitude'] ?? '';
    message = json['message'] ?? '';
    isReplied = json['isReplied'] ?? false;
    upVotes = json['upVotes'] ?? '';
    replyIds = json['replyIds'] ?? '';
    imagesLink = json['imagesLink'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['senderId'] = senderId;
    data['receiverId'] = receiverId;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['message'] = message;
    data['isReplied'] = isReplied;
    data['upVotes'] = upVotes;
    data['replyIds'] = replyIds;
    data['imagesLink'] = imagesLink;
    return data;
  }
}
