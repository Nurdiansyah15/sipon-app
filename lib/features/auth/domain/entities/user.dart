class User {
  final String id;
  final String username;
  final String email;
  final String? fullname;
  final String? phone;
  final String status;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool hasPassword;
  final String? avatarUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.fullname,
    this.phone,
    required this.status,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.hasPassword,
    this.avatarUrl,
    required this.createdAt,
  });

  /// Best-effort display name for greetings ("Selamat datang, {name}!").
  String get displayName {
    final name = fullname?.trim();
    if (name != null && name.isNotEmpty) return name;
    return username;
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? fullname,
    String? phone,
    String? status,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? hasPassword,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullname: fullname ?? this.fullname,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      hasPassword: hasPassword ?? this.hasPassword,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
