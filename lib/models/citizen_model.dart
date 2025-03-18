class CitizenModel {
  CitizenModel({
    required this.id,
    required this.createdAt,
    required this.pushToken,
    required this.name,
    required this.username,
    required this.imageUrl,
    required this.phoneNumber,
    required this.email,
    required this.followers,
    required this.following,
    required this.isVerified,
    required this.postIds,
    required this.complaintIds,
  });

  late String id;
  late String createdAt;
  late String pushToken;
  late String name;
  late String username;
  late String imageUrl;
  late String phoneNumber;
  late String email;
  late List followers;
  late List following;
  late bool isVerified;
  late List postIds;
  late List complaintIds;

  CitizenModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    createdAt = json['created_at'] ?? '';
    pushToken = json['push_token'] ?? '';
    name = json['name'] ?? 'Unknown';
    username = json['username'] ?? '';
    imageUrl = json['imageUrl'] ?? '';
    phoneNumber = json['phone_number'] ?? '';
    email = json['email'] ?? '';
    followers = json['followers'] ?? [];
    following = json['following'] ?? [];
    isVerified = json['isVerified'] ?? false;
    postIds = json['postIds'] ?? [];
    complaintIds = json['complaintIds'] ?? [];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['push_token'] = pushToken;
    data['name'] = name;
    data['username'] = username;
    data['imageUrl'] = imageUrl;
    data['phone_number'] = phoneNumber;
    data['email'] = email;
    data['followers'] = followers;
    data['following'] = following;
    data['isVerified'] = isVerified;
    data['postIds'] = postIds;
    data['complaintIds'] = complaintIds;
    return data;
  }
}
