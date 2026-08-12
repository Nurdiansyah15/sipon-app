import '../../domain/entities/santri_profile.dart';

class SantriProfileModel extends SantriProfile {
  SantriProfileModel({
    required super.id,
    required super.nis,
    required super.status,
    super.fullname,
    super.program,
  });

  factory SantriProfileModel.fromJson(Map<String, dynamic> json) {
    return SantriProfileModel(
      id: json['id'].toString(),
      nis: json['nis']?.toString() ?? '',
      status: json['status'] as String? ?? '',
      fullname: json['fullname'] as String?,
      program: json['program'] as String?,
    );
  }
}
