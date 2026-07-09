import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pettrack_client/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:crypto/crypto.dart';

class ZonesScreen extends StatefulWidget {
  final String serverIp;
  final String token;

  const ZonesScreen({super.key, required this.serverIp, required this.token});

  @override
  State<ZonesScreen> createState() => _ZonesScreenState();
}

class _ZonesScreenState extends State<ZonesScreen> {
  Uint8List? _latestFrame;
  String? _secretToken;
  Timer? _timer;
  List<Offset> _currentPolygon = [];
  bool _isDrawing = false;
  final _zoneNameController = TextEditingController();
  String _selectedZoneType = 'toilet';
  List<dynamic> _existingZones = [];

  @override
  void initState() {
    super.initState();
    _loadSecret();
    _startPolling();
  }

  Future<void> _loadSecret() async {
    final prefs = await SharedPreferences.getInstance();
    _secretToken = prefs.getString('secret_token');
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      _fetchFrame();
    });
    _fetchZones();
  }

  Future<void> _fetchZones() async {
    try {
      final response = await http
          .get(
            Uri.parse('http://${widget.serverIp}/api/zones'),
            headers: {'x-api-token': widget.token},
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        final fetchedZones = data['zones'] as List<dynamic>;

        setState(() {
          // Add a dummy 'type' for UI colors since the API only returns name and polygon
          _existingZones = fetchedZones.map((z) {
            print("DEBUG ZONE FETCHED: ${z['name']} -> ${z['type']}");
            return {
              "name": z['name'],
              "polygon": z['polygon'],
              "type": z['type'] ?? "safe",
            };
          }).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchFrame() async {
    if (_secretToken == null) return;
    try {
      final response = await http
          .get(
            Uri.parse('http://${widget.serverIp}/api/frame/latest'),
            headers: {'x-api-token': widget.token},
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200 && mounted) {
        try {
          final keyBytes = sha256.convert(utf8.encode(_secretToken!)).bytes;
          final key = enc.Key.fromBase64(base64Url.encode(keyBytes));
          final encrypter = enc.Encrypter(enc.Fernet(key));

          final encryptedString = utf8.decode(response.bodyBytes);
          final decryptedBytes = encrypter.decryptBytes(
            enc.Encrypted.fromBase64(encryptedString),
          );

          setState(() {
            _latestFrame = Uint8List.fromList(decryptedBytes);
          });
        } catch (e) {
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            print(l10n.decodingErrorZones(e.toString()));
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _saveZone() async {
    if (_currentPolygon.length < 3 || _zoneNameController.text.isEmpty) return;

    final zoneConfig = {
      "name": _zoneNameController.text.trim(),
      "polygon": _currentPolygon.map((p) => {"x": p.dx, "y": p.dy}).toList(),
      "type": _selectedZoneType,
    };

    final allZonesToSave = _existingZones
        .map(
          (z) => {
            "name": z['name'],
            "polygon": z['polygon'],
            "type": z['type'] ?? 'safe',
          },
        )
        .toList();
    allZonesToSave.add(zoneConfig);

    try {
      await http.post(
        Uri.parse('http://${widget.serverIp}/api/zones'),
        headers: {
          'x-api-token': widget.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(allZonesToSave),
      );

      if (mounted) {
        setState(() {
          _existingZones.add({
            "id": DateTime.now().millisecondsSinceEpoch.toString(),
            "name": _zoneNameController.text.trim(),
            "polygon": _currentPolygon
                .map((p) => {"x": p.dx, "y": p.dy})
                .toList(),
            "type": _selectedZoneType,
          });
          _isDrawing = false;
          _currentPolygon.clear();
          _zoneNameController.clear();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Zóna elmentve!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hiba: $e')));
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _zoneNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            // Usually this would pop, but we are in a bottom nav.
          },
        ),
        title: Text(
          l10n.editZones,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.pets, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Camera Area
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 300,
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
                      )
                    else
                      const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),

                    if (_isDrawing)
                      GestureDetector(
                        onTapDown: (details) {
                          setState(() {
                            _currentPolygon.add(details.localPosition);
                          });
                        },
                        child: Container(
                          color: Colors.transparent,
                          width: double.infinity,
                          height: double.infinity,
                          child: CustomPaint(
                            painter: PolygonPainter(_currentPolygon),
                          ),
                        ),
                      ),

                    // Saved zones overlays
                    if (!_isDrawing && _existingZones.isNotEmpty)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: SavedZonesPainter(_existingZones),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _isDrawing
                  ? Column(
                      children: [
                        TextField(
                          controller: _zoneNameController,
                          decoration: InputDecoration(
                            hintText: 'Zóna neve...',
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedZoneType,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'toilet',
                              child: Row(
                                children: [
                                  const Icon(Icons.wc, color: Colors.blueGrey),
                                  const SizedBox(width: 8),
                                  Text(l10n.toiletZone),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'bed',
                              child: Row(
                                children: [
                                  const Icon(Icons.bed, color: Colors.indigo),
                                  const SizedBox(width: 8),
                                  Text(l10n.bedZone),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'food',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.restaurant,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(l10n.foodZone),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'water',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.water_drop,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(l10n.waterZone),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'play',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.sports_tennis,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(l10n.playZone),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedZoneType = val);
                            }
                          },
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => setState(() {
                                  _isDrawing = false;
                                  _currentPolygon.clear();
                                }),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.outline,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  l10n.cancel,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _saveZone,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.warning,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: Text(l10n.save),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _isDrawing = true),
                        icon: const Icon(Icons.add_box_outlined),
                        label: Text(
                          l10n.addNewZone,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 32),

            // Existing Zones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.existingZones,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  ..._existingZones.map((zone) {
                    IconData icon;
                    Color color;
                    Color bgColor;
                    String subtitle;

                    switch (zone['type']) {
                      case 'toilet':
                        icon = Icons.wc;
                        color = Colors.blueGrey;
                        bgColor = Colors.blueGrey.withOpacity(0.1);
                        subtitle = l10n.toiletZone;
                        break;
                      case 'bed':
                        icon = Icons.bed;
                        color = Colors.indigo;
                        bgColor = Colors.indigo.withOpacity(0.1);
                        subtitle = l10n.bedZone;
                        break;
                      case 'water':
                        icon = Icons.water_drop;
                        color = Colors.blue;
                        bgColor = Colors.blue.withOpacity(0.1);
                        subtitle = l10n.waterZone;
                        break;
                      case 'food':
                        icon = Icons.restaurant;
                        color = Colors.orange;
                        bgColor = Colors.orange.withOpacity(0.1);
                        subtitle = l10n.foodZone;
                        break;
                      case 'play':
                        icon = Icons.sports_tennis;
                        color = Colors.green;
                        bgColor = Colors.green.withOpacity(0.1);
                        subtitle = l10n.playZone;
                        break;
                      default:
                        icon = Icons.place;
                        color = AppColors.primary;
                        bgColor = AppColors.primary.withOpacity(0.1);
                        subtitle = l10n.safeZone;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: zone['type'] == 'alert'
                            ? Border.all(color: Colors.red.withOpacity(0.5))
                            : null,
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        title: Text(
                          zone['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          subtitle,
                          style: TextStyle(color: color),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              _existingZones.remove(zone);
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneBadge(String name, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            name,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class PolygonPainter extends CustomPainter {
  final List<Offset> points;
  PolygonPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintPoint = Paint()
      ..color = Colors
          .white // Paint color for polygon nodes (keep white)
      ..style = PaintingStyle.fill;

    if (points.isEmpty) return;

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 5, paintPoint);
      if (i > 0) {
        canvas.drawLine(points[i - 1], points[i], paintLine);
      }
    }

    if (points.length > 2) {
      canvas.drawLine(points.last, points.first, paintLine);

      final path = Path()..addPolygon(points, true);
      final fillPaint = Paint()
        ..color = AppColors.primary.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SavedZonesPainter extends CustomPainter {
  final List<dynamic> zones;
  SavedZonesPainter(this.zones);

  @override
  void paint(Canvas canvas, Size size) {
    if (zones.isEmpty) return;

    for (final zone in zones) {
      if (zone['polygon'] == null) continue;
      final polyRaw = zone['polygon'] as List<dynamic>;
      if (polyRaw.isEmpty) continue;

      final points = polyRaw
          .map((p) => Offset(p['x'].toDouble(), p['y'].toDouble()))
          .toList();

      if (points.length > 2) {
        final path = Path()..addPolygon(points, true);

        final fillPaint = Paint()
          ..color = AppColors.primary.withOpacity(0.2)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);

        final strokePaint = Paint()
          ..color = AppColors.primary
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, strokePaint);

        // Calculate Centroid
        double cx = 0, cy = 0;
        for (var p in points) {
          cx += p.dx;
          cy += p.dy;
        }
        cx /= points.length;
        cy /= points.length;

        // Draw Name text at the centroid inside a nice badge
        final textSpan = TextSpan(
          text: zone['name'],
          style: const TextStyle(
            color: Colors.white, // Stroke color for nodes
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final bgRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy),
            width: textPainter.width + 16,
            height: textPainter.height + 10,
          ),
          const Radius.circular(12),
        );
        final bgPaint = Paint()..color = AppColors.onSurface.withOpacity(0.8);
        canvas.drawRRect(bgRect, bgPaint);

        textPainter.paint(
          canvas,
          Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
