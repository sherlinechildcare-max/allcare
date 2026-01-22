class Profile {
  final String id;
  final String? fullName;
  final String? phone;
  final String? city;
  final String? bio;
  final String? avatarUrl;

  const Profile({
    required this.id,
    this.fullName,
    this.phone,
    this.city,
    this.bio,
    this.avatarUrl,
  });

  factory Profile.empty(String id) => Profile(id: id);

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: (map["id"] ?? "") as String,
      fullName: map["full_name"] as String?,
      phone: map["phone"] as String?,
      city: map["city"] as String?,
      bio: map["bio"] as String?,
      avatarUrl: map["avatar_url"] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "full_name": fullName,
      "phone": phone,
      "city": city,
      "bio": bio,
      "avatar_url": avatarUrl,
      "updated_at": DateTime.now().toIso8601String(),
    };
  }

  Profile copyWith({
    String? fullName,
    String? phone,
    String? city,
    String? bio,
    String? avatarUrl,
  }) {
    return Profile(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
