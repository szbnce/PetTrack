import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WearSyncService {
  static final WearSyncService _instance = WearSyncService._internal();
  factory WearSyncService() => _instance;
  WearSyncService._internal();

  final FlutterWearOsConnectivity _wearOsConnectivity =
      FlutterWearOsConnectivity();
  bool _isConfigured = false;

  Future<void> init() async {
    if (_isConfigured) return;
    try {
      await _wearOsConnectivity.configureWearableAPI();
      _isConfigured = true;
      debugPrint("Wear OS Connectivity configured.");
    } catch (e) {
      debugPrint("Failed to configure Wear OS API: $e");
    }
  }

  /// Sends credentials from the phone to the connected watch(es)
  Future<bool> sendCredentialsToWatch(String ip, String token) async {
    if (!_isConfigured) await init();
    try {
      final data = {
        'serverIp': ip,
        'token': token,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Ensure we have connected devices
      List<WearOsDevice> connectedDevices = await _wearOsConnectivity
          .getConnectedDevices();
      if (connectedDevices.isEmpty) {
        debugPrint("No Wear OS devices connected.");
        return false;
      }

      await _wearOsConnectivity.syncData(
        path: '/pettrack/credentials',
        data: {'payload': jsonEncode(data)},
        isUrgent: true,
      );

      debugPrint("Credentials synced to Wear OS: $ip");
      return true;
    } catch (e) {
      debugPrint("Error sending credentials to watch: $e");
      return false;
    }
  }

  /// Listens for credentials on the watch side
  void listenForCredentials(
    Function(String ip, String token) onCredentialsReceived,
  ) async {
    if (!_isConfigured) await init();

    _wearOsConnectivity.dataChanged().listen((var dataEvents) async {
      for (var event in dataEvents) {
        if (event.dataItem.pathURI.path == '/pettrack/credentials') {
          try {
            final payloadStr = event.dataItem.mapData['payload'];
            if (payloadStr != null) {
              final payload = jsonDecode(payloadStr.toString());
              final ip = payload['serverIp'];
              final token = payload['token'];

              if (ip != null && token != null) {
                // Save them locally
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('server_ip', ip);
                await prefs.setString('api_token', token);

                onCredentialsReceived(ip, token);
              }
            }
          } catch (e) {
            debugPrint("Error parsing incoming credentials: $e");
          }
        }
      }
    });
  }
}
