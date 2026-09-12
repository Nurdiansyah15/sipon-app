import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8081/api/v1';

  static const int connectionTimeout = 15000;
  static const int receiveTimeout = 15000;

  static const String login = '/web/auth/login';
  static const String register = '/web/auth/register';
  static const String refreshToken = '/web/auth/refresh-token';
  static const String me = '/web/auth/me';
  static const String logout = '/auth/logout';
    static const String changePassword = '/web/auth/change-password';
  static const String notificationDevices = '/web/notifications/devices';
  static const String notificationsInbox = '/web/notifications/inbox';
  static const String notificationsReadAll = '/web/notifications/read-all';
  static const String notificationsPreferences =
      '/web/notifications/preferences';

  static const String articles = '/web/articles';
  static const String santriProfile = '/web/santri/profile';
  static const String keuanganSummary = '/web/keuangan/summary';
  static const String keuanganInvoices = '/web/keuangan/invoices';
  static const String mySchedules = '/web/akademik/my/jadwal';
  static const String myAttendance = '/web/akademik/my/absensi';
  static const String psbRegistration = '/web/psb/pendaftaran';
  static const String psbDocumentPresign = '/web/psb/dokumen/presign';
  static const String psbDocuments = '/web/psb/dokumen';
  static const String paymentProofPresign =
      '/web/keuangan/payments/proof/presign';
  static const String payments = '/web/keuangan/payments';
}
