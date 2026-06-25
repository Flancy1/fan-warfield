class ProfileModel {
  final String id;
  final String username;
  final String country;
  final String? avatarUrl;
  final int points;
  final int wins;
  final int losses;
  final DateTime? createdAt;

  const ProfileModel({
    required this.id,
    required this.username,
    required this.country,
    this.avatarUrl,
    this.points = 0,
    this.wins = 0,
    this.losses = 0,
    this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      country: json['country'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      points: json['points'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'country': country,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'points': points,
      'wins': wins,
      'losses': losses,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? username,
    String? country,
    String? avatarUrl,
    int? points,
    int? wins,
    int? losses,
    DateTime? createdAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      username: username ?? this.username,
      country: country ?? this.country,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      points: points ?? this.points,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'ProfileModel(id: $id, username: $username, country: $country)';
}
