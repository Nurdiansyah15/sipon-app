import 'package:flutter/foundation.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../domain/entities/notification_item.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider(DioClient dioClient)
    : _remoteDataSource = NotificationRemoteDataSource(dioClient);

  final NotificationRemoteDataSource _remoteDataSource;
  var _items = <NotificationItem>[];
  var _isLoading = false;
  String? _error;

  List<NotificationItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _items.where((item) => !item.isRead).length;
  bool _allNotificationsEnabled = true;
  bool _doNotDisturbEnabled = false;
  bool get allNotificationsEnabled => _allNotificationsEnabled;
  bool get doNotDisturbEnabled => _doNotDisturbEnabled;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final rawItems = await _remoteDataSource.getInbox();
      _items = rawItems.map(_mapItem).toList();
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    try {
      await _remoteDataSource.markAllRead();
      _items = _items
          .map(
            (item) => NotificationItem(
              id: item.id,
              title: item.title,
              body: item.body,
              module: item.module,
              isRead: true,
              createdAt: item.createdAt,
            ),
          )
          .toList();
      notifyListeners();
    } catch (error) {
      _error = error.toString();
      notifyListeners();
    }
  }

  Future<void> markRead(NotificationItem item) async {
    if (item.isRead) return;
    try {
      await _remoteDataSource.markRead(item.id);
      _items = _items
          .map(
            (current) => current.id == item.id
                ? NotificationItem(
                    id: current.id,
                    title: current.title,
                    body: current.body,
                    module: current.module,
                    isRead: true,
                    createdAt: current.createdAt,
                  )
                : current,
          )
          .toList();
      notifyListeners();
    } catch (error) {
      _error = error.toString();
      notifyListeners();
    }
  }

  Future<void> loadPreferences() async {
    try {
      final preferences = await _remoteDataSource.getPreferences();
      _allNotificationsEnabled =
          preferences['all_notifications_enabled'] as bool? ?? true;
      _doNotDisturbEnabled =
          preferences['do_not_disturb_enabled'] as bool? ?? false;
      notifyListeners();
    } catch (error) {
      _error = error.toString();
      notifyListeners();
    }
  }

  Future<void> updatePreferences({
    required bool allNotificationsEnabled,
    required bool doNotDisturbEnabled,
  }) async {
    try {
      await _remoteDataSource.updatePreferences(
        allNotificationsEnabled: allNotificationsEnabled,
        doNotDisturbEnabled: doNotDisturbEnabled,
      );
      _allNotificationsEnabled = allNotificationsEnabled;
      _doNotDisturbEnabled = doNotDisturbEnabled;
      notifyListeners();
    } catch (error) {
      _error = error.toString();
      notifyListeners();
    }
  }

  NotificationItem _mapItem(Map<String, dynamic> json) => NotificationItem(
    id: json['id']?.toString() ?? '',
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    module: json['module'] as String? ?? 'Sistem',
    isRead: json['is_read'] as bool? ?? false,
    createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
  );
}
