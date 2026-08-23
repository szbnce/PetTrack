import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pettrack_app/l10n/app_localizations.dart';
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
  ui.Image? _currentUiImage;
  String? _secretToken;
  Timer? _timer;
  final List<Offset> _currentPolygon = [];
  bool _isDrawing = false;
  final _zoneNameController = TextEditingController();
  String _selectedZoneType = 'toilet';
  List<dynamic> _existingZones = [];
  Size _canvasSize = Size(1.0, 1.0);

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
    if (widget.serverIp.contains('demo_ip')) {
      debugPrint("Demo mode: skipping Zones HTTP polling");
      return;
    }
    
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      _fetchFrame();
    });
    _fetchZones();
  }

  Future<void> _fetchZones() async {
    try {
      final response = await http
          .get(
            Uri.parse('${widget.serverIp}/api/zones'),
            headers: {'x-api-token': widget.token},
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        final fetchedZones = data['zones'] as List<dynamic>;

        setState(() {
          // Add a dummy 'type' for UI colors since the API only returns name and polygon
          _existingZones = fetchedZones.map((z) {
            debugPrint("DEBUG ZONE FETCHED: ${z['name']} -> ${z['type']}");
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
            Uri.parse('${widget.serverIp}/api/frame/latest'),
            headers: {'x-api-token': widget.token},
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200 && mounted) {
          final newBytes = response.bodyBytes;
          ui.decodeImageFromList(newBytes, (ui.Image img) {
            if (mounted) {
              setState(() {
                _currentUiImage?.dispose();
                _currentUiImage = img;
              });
            } else {
              img.dispose();
            }
          });
      }
    } catch (_) {}
  }

  Future<void> _saveZone() async {
    if (_currentPolygon.length < 3 || _zoneNameController.text.isEmpty) return;

    final zoneConfig = {
      "name": _zoneNameController.text.trim(),
      "polygon": _currentPolygon.map((p) => {
        "x": p.dx / _canvasSize.width,
        "y": p.dy / _canvasSize.height
      }).toList(),
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
        Uri.parse('${widget.serverIp}/api/zones'),
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
                .map((p) => {
                  "x": p.dx / _canvasSize.width,
                  "y": p.dy / _canvasSize.height
                })
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
    _currentUiImage?.dispose();
    _zoneNameController.dispose();
    super.dispose();
  }

  Widget _buildDesktopHeader(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.editZones,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCameraArea() {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF15181E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.outline.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 0 && constraints.maxHeight > 0) {
              _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                if (_currentUiImage != null)
                  RawImage(
                    image: _currentUiImage!,
                    fit: BoxFit.contain,
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
                if (!_isDrawing && _existingZones.isNotEmpty)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: SavedZonesPainter(_existingZones),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      ),
    );
  }

  Widget _buildControls(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2128),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
      ),
      child: _isDrawing
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Új zóna felvétele",
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _zoneNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Zóna neve...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedZoneType,
                  dropdownColor: const Color(0xFF1E2128),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
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
                          const Icon(Icons.restaurant, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(l10n.foodZone),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'water',
                      child: Row(
                        children: [
                          const Icon(Icons.water_drop, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(l10n.waterZone),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'play',
                      child: Row(
                        children: [
                          const Icon(Icons.sports_tennis, color: Colors.green),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() {
                          _isDrawing = false;
                          _currentPolygon.clear();
                        }),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveZone,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(l10n.save, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                icon: const Icon(Icons.add_box_outlined, color: Colors.white),
                label: Text(
                  l10n.addNewZone,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
    );
  }

  Widget _buildExistingZonesList(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.existingZones,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_existingZones.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                "Nincsenek még zónák.",
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ),
          )
        else
          ..._existingZones.map((zone) {
            IconData icon;
            Color color;
            Color bgColor;
            String subtitle;

            switch (zone['type']) {
              case 'toilet':
                icon = Icons.wc; color = Colors.blueGrey; bgColor = Colors.blueGrey.withValues(alpha: 0.1); subtitle = l10n.toiletZone; break;
              case 'bed':
                icon = Icons.bed; color = Colors.indigo; bgColor = Colors.indigo.withValues(alpha: 0.1); subtitle = l10n.bedZone; break;
              case 'water':
                icon = Icons.water_drop; color = Colors.blue; bgColor = Colors.blue.withValues(alpha: 0.1); subtitle = l10n.waterZone; break;
              case 'food':
                icon = Icons.restaurant; color = Colors.orange; bgColor = Colors.orange.withValues(alpha: 0.1); subtitle = l10n.foodZone; break;
              case 'play':
                icon = Icons.sports_tennis; color = Colors.green; bgColor = Colors.green.withValues(alpha: 0.1); subtitle = l10n.playZone; break;
              default:
                icon = Icons.place; color = AppColors.primary; bgColor = AppColors.primary.withValues(alpha: 0.1); subtitle = l10n.safeZone;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2128),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                title: Text(
                  zone['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                subtitle: Text(subtitle, style: TextStyle(color: Colors.white54)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _existingZones.remove(zone);
                    });
                  },
                ),
              ),
            );
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          // Desktop Layout
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDesktopHeader(l10n),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column (Camera)
                      Expanded(
                        flex: 2,
                        child: _buildCameraArea(),
                      ),
                      const SizedBox(width: 24),
                      // Right Column (Controls & List)
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildControls(l10n),
                            const SizedBox(height: 32),
                            _buildExistingZonesList(l10n),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          // Mobile Layout (legacy)
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () {},
              ),
              title: Text(
                l10n.editZones,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(icon: const Icon(Icons.pets, color: AppColors.primary), onPressed: () {}),
              ],
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildCameraArea(),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildControls(l10n),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildExistingZonesList(l10n),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        }
      }
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
        ..color = AppColors.primary.withValues(alpha: 0.3)
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

      final points = polyRaw.map((p) {
        double px = p['x'].toDouble();
        double py = p['y'].toDouble();
        // If they are absolute (from old bug), assume they are way out of bounds or draw them scaled down
        if (px > 2.0 || py > 2.0) {
          return Offset(px, py); // draw as absolute (will look broken but that's what's in DB)
        }
        return Offset(px * size.width, py * size.height);
      }).toList();

      if (points.length > 2) {
        final path = Path()..addPolygon(points, true);

        final fillPaint = Paint()
          ..color = AppColors.primary.withValues(alpha: 0.2)
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
        final bgPaint = Paint()..color = AppColors.onSurface.withValues(alpha: 0.8);
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
