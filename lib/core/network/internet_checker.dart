import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Abstract interface for internet connectivity checking
abstract interface class InternetChecker {
  /// Check if device has internet connection
  Future<bool> get hasInternetConnection;

  /// Stream of internet connection status changes
  Stream<bool> get onConnectivityChanged;

  /// Check connection with custom timeout
  Future<bool> hasInternetConnectionWithTimeout({Duration? timeout});

  /// Get current connection status
  ConnectionStatus get connectionStatus;

  /// Stream of detailed connection status
  Stream<ConnectionStatus> get onStatusChanged;
}

/// Custom connection status enum
enum ConnectionStatus {
  connected,
  disconnected,
  unknown,
}

/// Implementation of InternetChecker using internet_connection_checker_plus
class InternetCheckerImpl implements InternetChecker {
  final InternetConnection _internetConnection;

  InternetCheckerImpl({InternetConnection? internetConnection})
      : _internetConnection = internetConnection ?? InternetConnection();

  @override
  Future<bool> get hasInternetConnection async {
    try {
      return await _internetConnection.hasInternetAccess;
    } catch (e) {
      print('Error checking internet connection: $e');
      return false;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _internetConnection.onStatusChange.map((status) {
      switch (status) {
        case InternetStatus.connected:
          return true;
        case InternetStatus.disconnected:
          return false;
        default:
          return false;
      }
    }).handleError((error) {
      // Use debugPrint instead of print for production
      debugPrint('Error in connectivity stream: $error');
      return false;
    });
  }

  @override
  Future<bool> hasInternetConnectionWithTimeout({Duration? timeout}) async {
    try {
      final customChecker = InternetConnection.createInstance(
        customCheckOptions: [
          InternetCheckOption(
            uri: Uri.parse('https://icanhazip.com/'),
            timeout: timeout ?? const Duration(seconds: 10),
          ),
          InternetCheckOption(
            uri: Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
            timeout: timeout ?? const Duration(seconds: 10),
          ),
        ],
        useDefaultOptions: false,
      );

      return await customChecker.hasInternetAccess;
    } catch (e) {
      print('Error checking internet connection with timeout: $e');
      return false;
    }
  }

  @override
  InternetStatus get connectionStatus {
    // Note: This is a synchronous getter, but the underlying check is async
    // For real-time status, use the stream instead
    return InternetStatus.unknown;
  }

  @override
  Stream<InternetStatus> get onStatusChanged {
    return _internetConnection.onStatusChange.map((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          return InternetStatus.connected;
        case InternetConnectionStatus.disconnected:
          return InternetStatus.disconnected;
      }
    }).handleError((error) {
      print('Error in status stream: $error');
      return InternetStatus.unknown;
    });
  }
}
