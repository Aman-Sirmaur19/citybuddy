class OrganizationModel {
  OrganizationModel({
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
    required this.organizationType,
    required this.registrationId,
    required this.pinCode,
    required this.address,
    required this.city,
    required this.district,
    required this.state,
    required this.country,
    required this.docLink,
    required this.isDocVerified,
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
  late String organizationType;
  late String registrationId;
  late String pinCode;
  late String address;
  late String city;
  late String district;
  late String state;
  late String country;
  late String docLink;
  late bool isDocVerified;
  late List postIds;
  late List complaintIds;

  OrganizationModel.fromJson(Map<String, dynamic> json) {
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
    organizationType = json['organizationType'] ?? '';
    registrationId = json['registrationId'] ?? '';
    pinCode = json['pinCode'] ?? '';
    address = json['address'] ?? '';
    city = json['city'] ?? '';
    district = json['district'] ?? '';
    state = json['state'] ?? '';
    country = json['country'] ?? '';
    docLink = json['docLink'] ?? '';
    isDocVerified = json['isDocVerified'] ?? true;
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
    data['organizationType'] = organizationType;
    data['registrationId'] = registrationId;
    data['pinCode'] = pinCode;
    data['address'] = address;
    data['city'] = city;
    data['district'] = district;
    data['state'] = state;
    data['country'] = country;
    data['docLink'] = docLink;
    data['isDocVerified'] = isDocVerified;
    data['postIds'] = postIds;
    data['complaintIds'] = complaintIds;
    return data;
  }
}
