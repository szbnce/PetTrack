import 'package:flutter/material.dart';
import 'package:pettrack_client/l10n/app_localizations.dart';
import '../models/medical_data.dart';
import '../theme/colors.dart';
import '../services/notification_service.dart';
import 'dart:math';

class MedicalScreen extends StatefulWidget {
  const MedicalScreen({super.key});

  @override
  State<MedicalScreen> createState() => _MedicalScreenState();
}

class _MedicalScreenState extends State<MedicalScreen>
    with SingleTickerProviderStateMixin {
  List<Medication> _medications = [];
  List<Vaccine> _vaccines = [];
  late TabController _tabController;

  final List<Color> _colorOptions = [
    const Color(0xFF4DB6AC), // Teal
    const Color(0xFFE57373), // Red
    const Color(0xFF64B5F6), // Blue
    const Color(0xFFFFB74D), // Orange
    const Color(0xFFBA68C8), // Purple
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final meds = await MedicalDataManager.loadMedications();
    final vacs = await MedicalDataManager.loadVaccines();
    setState(() {
      _medications = meds;
      _vaccines = vacs;
    });
  }

  void _showAddMedicationDialog(AppLocalizations l10n) {
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    final intervalCtrl = TextEditingController(text: "24");
    bool alertEnabled = false;
    Color selectedColor = _colorOptions.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.addMedication),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: l10n.medName),
                ),
                TextField(
                  controller: doseCtrl,
                  decoration: InputDecoration(labelText: l10n.dose),
                ),
                TextField(
                  controller: intervalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.alertFrequency,
                    hintText: l10n.alertFrequencyHint,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.cardColor,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _colorOptions.map((c) {
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == c
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(l10n.enableAlert),
                  value: alertEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setDialogState(() => alertEnabled = val),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final id = Random().nextInt(99999);
                final interval = int.tryParse(intervalCtrl.text) ?? 24;
                final newMed = Medication(
                  id: id.toString(),
                  name: nameCtrl.text,
                  dose: doseCtrl.text,
                  intervalHours: interval,
                  alertEnabled: alertEnabled,
                  colorValue: selectedColor.value,
                );

                if (alertEnabled) {
                  await NotificationService().schedulePeriodicNotification(
                    id: id,
                    title: l10n.medTimeTitle,
                    body: l10n.medTimeBody(newMed.name, newMed.dose),
                    intervalHours: interval,
                  );
                }

                _medications.add(newMed);
                await MedicalDataManager.saveMedications(_medications);
                setState(() {});
                if (mounted) Navigator.pop(ctx);
              },
              child: Text(l10n.saveMedication),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVaccineDialog(AppLocalizations l10n) {
    final nameCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final nextCtrl = TextEditingController();
    Color selectedColor = _colorOptions.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.addVaccine),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: l10n.vacName),
                ),
                TextField(
                  controller: dateCtrl,
                  decoration: InputDecoration(labelText: l10n.dateGiven),
                ),
                TextField(
                  controller: nextCtrl,
                  decoration: InputDecoration(labelText: l10n.nextDue),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.cardColor,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _colorOptions.map((c) {
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == c
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final newVac = Vaccine(
                  id: Random().nextInt(99999).toString(),
                  name: nameCtrl.text,
                  dateGiven: dateCtrl.text,
                  nextDue: nextCtrl.text,
                  colorValue: selectedColor.value,
                );
                _vaccines.add(newVac);
                await MedicalDataManager.saveVaccines(_vaccines);
                setState(() {});
                if (mounted) Navigator.pop(ctx);
              },
              child: Text(l10n.saveVaccine),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(icon: const Icon(Icons.medical_services), text: l10n.medications),
          Tab(icon: const Icon(Icons.vaccines), text: l10n.vaccines),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMedicationsTab(l10n), _buildVaccinesTab(l10n)],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'medical_fab',
        backgroundColor: AppColors.primary,
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddMedicationDialog(l10n);
          } else {
            _showAddVaccineDialog(l10n);
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMedicationsTab(AppLocalizations l10n) {
    if (_medications.isEmpty) {
      return Center(
        child: Text(
          l10n.noMedications,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
      itemCount: _medications.length,
      itemBuilder: (ctx, i) {
        final med = _medications[i];
        final cardColor = Color(med.colorValue);

        return Card(
          color: cardColor.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cardColor.withValues(alpha: 0.3), width: 1),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: cardColor.withValues(alpha: 0.2),
              child: Icon(Icons.medical_services, color: cardColor),
            ),
            title: Text(
              med.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                "${med.dose} • ${l10n.everyXHours(med.intervalHours)}",
                style: const TextStyle(fontSize: 13),
              ),
            ),
            trailing: med.alertEnabled
                ? const Icon(Icons.notifications_active, color: Colors.orange)
                : const Icon(Icons.notifications_off, color: Colors.grey),
            onLongPress: () async {
              // Confirm delete dialog could be added here
              if (med.alertEnabled) {
                await NotificationService().cancelNotification(
                  int.tryParse(med.id) ?? 0,
                );
              }
              setState(() => _medications.removeAt(i));
              await MedicalDataManager.saveMedications(_medications);
            },
          ),
        );
      },
    );
  }

  Widget _buildVaccinesTab(AppLocalizations l10n) {
    if (_vaccines.isEmpty) {
      return Center(
        child: Text(
          l10n.noVaccines,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
      itemCount: _vaccines.length,
      itemBuilder: (ctx, i) {
        final vac = _vaccines[i];
        final cardColor = Color(vac.colorValue);

        return Card(
          color: cardColor.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cardColor.withValues(alpha: 0.3), width: 1),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: cardColor.withValues(alpha: 0.2),
              child: Icon(Icons.vaccines, color: cardColor),
            ),
            title: Text(
              vac.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                "${l10n.dateGiven}: ${vac.dateGiven}\n${l10n.nextDue}: ${vac.nextDue}",
                style: const TextStyle(height: 1.3, fontSize: 13),
              ),
            ),
            isThreeLine: true,
            onLongPress: () async {
              setState(() => _vaccines.removeAt(i));
              await MedicalDataManager.saveVaccines(_vaccines);
            },
          ),
        );
      },
    );
  }
}
