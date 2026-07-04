import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pettrack_client/l10n/app_localizations.dart';
import '../theme/colors.dart';
import '../services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  final String serverIp;
  final String token;
  final String petName;

  const DashboardScreen({
    super.key,
    required this.serverIp,
    required this.token,
    required this.petName,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Uint8List? _latestFrame;
  Timer? _timer;
  List<dynamic> _activities = [];
  Uint8List? _profilePicBytes;
  String _petType = 'rabbit';
  String _monitorId = "Searching...";
  int _batteryLevel = 100;
  bool _isCharging = false;
  bool _alertsZoneEnabled = true;
  bool _alertsBatteryEnabled = true;
  double _batteryThreshold = 20.0;
  bool _hasAlertedBattery = false;
  bool _hasCameraError = false;
  DateTime? _frameTimestamp;

  IconData _getPetIcon(String type) {
    switch (type) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.pets;
      case 'rabbit':
        return Icons.cruelty_free;
      case 'bird':
        return Icons.flutter_dash;
      case 'guineapig':
        return Icons.pest_control_rodent;
      default:
        return Icons.pets;
    }
  }

  late int _greetingIndex;
  late int _subGreetingIndex;

  @override
  void initState() {
    super.initState();
    final rand = Random();
    _greetingIndex = rand.nextInt(10);
    _subGreetingIndex = rand.nextInt(10);
    NotificationService().init();
    NotificationService().requestPermissions();
    _loadAlertSettings();
    _loadProfilePic();
    _startPolling();
  }

  Future<void> _loadAlertSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _alertsZoneEnabled = prefs.getBool('alerts_zone_enabled') ?? true;
        _alertsBatteryEnabled = prefs.getBool('alerts_battery_enabled') ?? true;
        _batteryThreshold = prefs.getDouble('alerts_battery_threshold') ?? 20.0;
      });
    }
  }

  Future<void> _loadProfilePic() async {
    final prefs = await SharedPreferences.getInstance();
    final b64 = prefs.getString('profile_pic');
    final pType = prefs.getString('pet_type') ?? 'rabbit';
    if (mounted) {
      setState(() {
        _petType = pType;
        if (b64 != null) {
          _profilePicBytes = base64Decode(b64);
        }
      });
    }
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      _fetchFrame();
      _fetchActivity();
      _fetchStatus();
    });
  }

  Future<void> _fetchFrame() async {
    try {
      final response = await http
          .get(
            Uri.parse('http://${widget.serverIp}/api/frame/latest'),
            headers: {'x-api-token': widget.token},
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200 && mounted) {
        if (response.headers['content-type']?.contains('application/json') ?? false) {
          setState(() {
            _latestFrame = null;
            _hasCameraError = true;
          });
        } else {
          DateTime? lastModified;
          final lmHeader = response.headers['last-modified'];
          if (lmHeader != null) {
            try {
              lastModified = HttpDate.parse(lmHeader);
            } catch (_) {}
          }
          
          setState(() {
            _latestFrame = response.bodyBytes;
            _hasCameraError = false;
            _frameTimestamp = lastModified;
          });
        }
      } else if (mounted) {
        setState(() => _hasCameraError = true);
      }
    } catch (_) {
      if (mounted) setState(() => _hasCameraError = true);
    }
  }

  Future<void> _fetchActivity() async {
    try {
      final response = await http
          .get(
            Uri.parse('http://${widget.serverIp}/api/activity?limit=5'),
            headers: {'x-api-token': widget.token},
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        if (data['events'] == null) return;
        final newEvents = data['events'] as List<dynamic>;

        if (_activities.isEmpty && newEvents.isNotEmpty) {
          setState(() => _activities = newEvents);
        } else if (_activities.length != newEvents.length ||
            (_activities.isNotEmpty &&
                newEvents.isNotEmpty &&
                _activities.first['timestamp'] !=
                    newEvents.first['timestamp'])) {
          if (_activities.isNotEmpty && _alertsZoneEnabled) {
            final ev = newEvents.first;
            final isEnter = ev['event_type'] == 'zone_enter';
            final l10n = AppLocalizations.of(context)!;
            final zoneName = ev['zone_name'] ?? l10n.unknown;
            NotificationService().showNotification(
              id: 2,
              title: l10n.alertsTitle,
              body: isEnter
                  ? l10n.zoneEntered(widget.petName, zoneName)
                  : l10n.zoneLeft(widget.petName, zoneName),
            );
          }
          setState(() => _activities = newEvents);
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchStatus() async {
    try {
      final response = await http
          .get(
            Uri.parse('http://${widget.serverIp}/api/status'),
            headers: {'x-api-token': widget.token},
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data['monitor_id'] != null) {
            _monitorId = data['monitor_id'];
          }
          if (data['battery_level'] != null) {
            int newBat = data['battery_level'];
            if (_alertsBatteryEnabled &&
                !_isCharging &&
                newBat <= _batteryThreshold &&
                newBat < _batteryLevel &&
                !_hasAlertedBattery) {
              _hasAlertedBattery = true;
              final l10n = AppLocalizations.of(context)!;
              NotificationService().showNotification(
                id: 1,
                title: l10n.batteryLowTitle,
                body: l10n.batteryLowBody(newBat),
              );
            }
            if (newBat > _batteryThreshold || _isCharging) {
              _hasAlertedBattery = false;
            }
            _batteryLevel = newBat;
            _isCharging = data['is_charging'] ?? false;
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  ({String text, Color textColor, Color bgColor}) _getBadgeInfo(AppLocalizations l10n) {
    if (_hasCameraError || _latestFrame == null) {
      return (text: "OFFLINE!", textColor: Colors.red, bgColor: const Color(0xFFFFE5E5));
    }
    
    if (_frameTimestamp != null) {
      final diff = DateTime.now().toUtc().difference(_frameTimestamp!);
      final sec = diff.inSeconds;
      if (sec <= 10) {
        return (text: "Live", textColor: Colors.green[800]!, bgColor: Colors.green[100]!);
      } else if (sec <= 30) {
        return (text: l10n.secondsAgo(sec), textColor: Colors.lightGreen[800]!, bgColor: Colors.lightGreen[100]!);
      } else {
        return (text: l10n.secondsAgo(sec), textColor: Colors.orange[800]!, bgColor: Colors.orange[100]!);
      }
    }
    
    return (text: "Live", textColor: Colors.green[800]!, bgColor: Colors.green[100]!);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.pets, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              l10n.appName,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.greetingsList.split('|')[_greetingIndex],
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.subGreetingsList.split('|')[_subGreetingIndex],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary,
                        backgroundImage: _profilePicBytes != null
                            ? MemoryImage(_profilePicBytes!)
                            : null,
                        child: _profilePicBytes == null
                            ? Icon(_getPetIcon(_petType), color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.petName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.bolt,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              Text(
                                l10n.active,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Live Video Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.liveVideo,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Builder(
                  builder: (context) {
                    final badge = _getBadgeInfo(l10n);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badge.bgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: badge.textColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            badge.text,
                            style: TextStyle(
                              color: badge.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Live Video Card
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.onSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.outline.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_latestFrame != null)
                      Image.memory(
                        _latestFrame!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.videocam_off,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.cameraOffline,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),


                    // Overlay Chips
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Row(
                        children: [
                          _buildChip(
                            _isCharging
                                ? Icons.battery_charging_full
                                : Icons.battery_full,
                            "$_batteryLevel%",
                          ),
                          const SizedBox(width: 8),
                          _buildChip(Icons.wifi, _monitorId),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats row (Mock data)
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.favorite,
                    _getFavoriteZone(),
                    "",
                    l10n.favoriteZone,
                    AppColors.surfaceVariant,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.access_time,
                    _getLastSeen(l10n),
                    "",
                    l10n.lastSeen,
                    const Color(0xFFFFDBC9),
                    AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Activities Timeline
            Text(
              l10n.activities,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),

            if (_activities.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    l10n.noRecentEvents,
                    style: const TextStyle(color: AppColors.outline),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activities.length,
                itemBuilder: (context, index) {
                  final ev = _activities[index];
                  final isEnter = ev['event_type'] == 'zone_enter';
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    (ev['timestamp'] * 1000).toInt(),
                  );
                  final timeString =
                      "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
                  final zone = ev['zone_name'] ?? l10n.unknown;

                  return _buildTimelineItem(
                    isEnter ? Icons.meeting_room : Icons.directions_walk,
                    isEnter ? AppColors.primary : AppColors.secondary,
                    isEnter
                        ? l10n.zoneEntered(widget.petName, zone)
                        : l10n.zoneLeft(widget.petName, zone),
                    isEnter ? l10n.cameraDetectedMovement : l10n.leftTheZone,
                    timeString,
                    isLast: index == _activities.length - 1,
                  );
                },
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String unit,
    String label,
    Color bgColor,
    Color iconColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.outline.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Text(
                l10n.today,
                style: const TextStyle(
                  color: AppColors.outline,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                if (unit.isNotEmpty)
                  Text(
                    " $unit",
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.outline, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    IconData icon,
    Color color,
    String title,
    String subtitle,
    String time, {
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.outline.withOpacity(0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppColors.outline,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      color: AppColors.outline,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFavoriteZone() {
    if (_activities.isEmpty) return "-";
    final zoneCounts = <String, int>{};
    for (var ev in _activities) {
      if (ev['zone_name'] != null) {
        zoneCounts[ev['zone_name']] = (zoneCounts[ev['zone_name']] ?? 0) + 1;
      }
    }
    if (zoneCounts.isEmpty) return "-";
    final fav = zoneCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    return fav.length > 8 ? '${fav.substring(0, 8)}...' : fav;
  }

  String _getLastSeen(AppLocalizations l10n) {
    if (_activities.isEmpty) return "-";
    final lastEv = _activities.first;
    if (lastEv['timestamp'] == null) return "-";

    final diff = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch((lastEv['timestamp'] * 1000).toInt()),
    );
    if (diff.inMinutes == 0) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minsAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    return l10n.daysAgo(diff.inDays);
  }
}
