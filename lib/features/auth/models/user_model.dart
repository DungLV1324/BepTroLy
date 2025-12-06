class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final List<String> dietaryPreferences;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.dietaryPreferences = const [],
  });

  factory UserModel.empty() {
    return UserModel(
      uid: '',
      email: '',
      displayName: 'Khách',
      photoUrl: null,
    );
  }

  bool get isEmpty => uid.isEmpty;
  bool get isNotEmpty => uid.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'dietaryPreferences': dietaryPreferences,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '', // <-- Đọc key 'uid'
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? 'Người dùng',
      photoUrl: json['photoUrl'],
      dietaryPreferences: json['dietaryPreferences'] != null
          ? List<String>.from(json['dietaryPreferences'])
          : [],
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    List<String>? dietaryPreferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
    );
  }
}