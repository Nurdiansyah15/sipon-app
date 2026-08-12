import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.fullname,
    super.phone,
    required super.status,
    required super.isEmailVerified,
    required super.isPhoneVerified,
    required super.hasPassword,
    super.avatarUrl,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullname: json['fullname'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String? ?? 'active',
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isPhoneVerified: json['is_phone_verified'] as bool? ?? false,
      hasPassword: json['has_password'] as bool? ?? true,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullname': fullname,
      'phone': phone,
      'status': status,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'has_password': hasPassword,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
