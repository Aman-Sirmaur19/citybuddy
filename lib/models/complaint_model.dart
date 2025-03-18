enum ComplaintStatus { pending, resolved, rejected }

class ComplaintModel {
  ComplaintModel({
    required this.id,
    required this.createdAt,
    required this.senderId,
    required this.receiverEmail,
    required this.subject,
    required this.latitude,
    required this.longitude,
    required this.complaint,
    required this.complaintStatus,
    required this.isReplied,
    required this.upVotes,
    required this.replyIds,
    required this.imagesLink,
  });

  late String id;
  late String createdAt;
  late String senderId;
  late String receiverEmail;
  late String subject;
  late String latitude;
  late String longitude;
  late String complaint;
  late String complaintStatus;
  late bool isReplied;
  late List<String> upVotes;
  late List<String> replyIds;
  late List<String> imagesLink;

  ComplaintModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    createdAt = json['created_at'] ?? '';
    senderId = json['senderId'] ?? '';
    receiverEmail = json['receiverEmail'] ?? '';
    subject = json['subject'] ?? '';
    latitude = json['latitude'] ?? '';
    longitude = json['longitude'] ?? '';
    complaint = json['complaint'] ?? '';
    complaintStatus = json['complaintStatus'] ?? '';
    isReplied = json['isReplied'] ?? false;
    upVotes = json['upVotes'] ?? [];
    replyIds = json['replyIds'] ?? [];
    imagesLink = json['imagesLink'] ?? [];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['senderId'] = senderId;
    data['receiverEmail'] = receiverEmail;
    data['subject'] = subject;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['complaint'] = complaint;
    data['complaintStatus'] = complaintStatus;
    data['isReplied'] = isReplied;
    data['upVotes'] = upVotes;
    data['replyIds'] = replyIds;
    data['imagesLink'] = imagesLink;
    return data;
  }
}
