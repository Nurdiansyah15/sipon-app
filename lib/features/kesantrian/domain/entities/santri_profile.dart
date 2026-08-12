class SantriProfile {
  final String id;
  final String nis;
  final String status;
  final String? fullname;
  final String? program;

  SantriProfile({
    required this.id,
    required this.nis,
    required this.status,
    this.fullname,
    this.program,
  });
}
