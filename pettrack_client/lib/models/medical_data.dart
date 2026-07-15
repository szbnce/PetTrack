import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Medication {
  final String id;
  final String name;
  final String dose;
  final int intervalHours;
  final bool alertEnabled;
  final int colorValue;

  Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.intervalHours,
    this.alertEnabled = false,
    this.colorValue = 0xFF4DB6AC, // Default teal
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dose': dose,
    'intervalHours': intervalHours,
    'alertEnabled': alertEnabled,
    'colorValue': colorValue,
  };

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    id: json['id'],
    name: json['name'],
    dose: json['dose'],
    intervalHours: json['intervalHours'] ?? 24,
    alertEnabled: json['alertEnabled'] ?? false,
    colorValue: json['colorValue'] ?? 0xFF4DB6AC,
  );
}

class Vaccine {
  final String id;
  final String name;
  final String dateGiven;
  final String nextDue;
  final int colorValue;

  Vaccine({
    required this.id,
    required this.name,
    required this.dateGiven,
    required this.nextDue,
    this.colorValue = 0xFF4DB6AC, // Default teal
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dateGiven': dateGiven,
    'nextDue': nextDue,
    'colorValue': colorValue,
  };

  factory Vaccine.fromJson(Map<String, dynamic> json) => Vaccine(
    id: json['id'],
    name: json['name'],
    dateGiven: json['dateGiven'],
    nextDue: json['nextDue'],
    colorValue: json['colorValue'] ?? 0xFF4DB6AC,
  );
}

class MedicalDataManager {
  static const String _medKey = 'saved_medications';
  static const String _vacKey = 'saved_vaccines';

  static Future<List<Medication>> loadMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_medKey);
    if (jsonStr == null) return [];
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => Medication.fromJson(e)).toList();
  }

  static Future<void> saveMedications(List<Medication> meds) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(meds.map((e) => e.toJson()).toList());
    await prefs.setString(_medKey, jsonStr);
  }

  static Future<List<Vaccine>> loadVaccines() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_vacKey);
    if (jsonStr == null) return [];
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => Vaccine.fromJson(e)).toList();
  }

  static Future<void> saveVaccines(List<Vaccine> vacs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(vacs.map((e) => e.toJson()).toList());
    await prefs.setString(_vacKey, jsonStr);
  }
}
