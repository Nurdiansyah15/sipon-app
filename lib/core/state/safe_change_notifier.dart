import 'dart:async';

import 'package:flutter/foundation.dart';

/// [ChangeNotifier] whose notifications become no-ops once it is disposed.
///
/// Providers here fetch over the network, and a reply can land after the
/// screen that owned the provider is gone. Calling [notifyListeners] then
/// throws ("was used after being disposed"), which is why every async
/// callback would otherwise need its own guard. Use [safeNotify] instead and
/// the guard is automatic.
abstract class SafeChangeNotifier extends ChangeNotifier {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @protected
  void safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  /// [safeNotify] deferred to the next microtask — for a notification fired
  /// synchronously from `initState` (which runs during build and would
  /// otherwise throw `setState() or markNeedsBuild() called during build`).
  @protected
  void safeNotifyLater() {
    if (_disposed) return;
    scheduleMicrotask(safeNotify);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
