import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sale_record.dart';

class StorageService {
  static const String _salesKey = 'sales_records';
  static const String _langKey = 'language_preference';
  static StorageService? _instance;

  StorageService._();
  static StorageService get instance => _instance ??= StorageService._();

  Future<List<SaleRecord>> getAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_salesKey);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => SaleRecord.fromJson(e)).toList();
  }

  Future<void> saveRecord(SaleRecord record) async {
    final records = await getAllRecords();
    records.add(record);
    await _saveAll(records);
  }

  Future<void> updateRecord(SaleRecord updated) async {
    final records = await getAllRecords();
    final idx = records.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      records[idx] = updated;
      await _saveAll(records);
    }
  }

  Future<void> deleteRecord(String id) async {
    final records = await getAllRecords();
    records.removeWhere((r) => r.id == id);
    await _saveAll(records);
  }

  Future<List<SaleRecord>> getRecordsForDate(DateTime date) async {
    final all = await getAllRecords();
    return all
        .where((r) =>
            r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<Map<String, double>> getDailyTotals(int year, int month) async {
    final all = await getAllRecords();
    final Map<String, double> totals = {};
    for (final r in all) {
      if (r.date.year == year && r.date.month == month) {
        final key = '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')}';
        totals[key] = (totals[key] ?? 0) + r.amount;
      }
    }
    return totals;
  }

  Future<List<SaleRecord>> getRecordsInRange(DateTime start, DateTime end) async {
    final all = await getAllRecords();
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return all
        .where((r) => r.date.isAfter(startDay.subtract(const Duration(seconds: 1))) &&
            r.date.isBefore(endDay.add(const Duration(seconds: 1))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> _saveAll(List<SaleRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_salesKey, jsonEncode(records.map((r) => r.toJson()).toList()));
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_langKey) ?? 'auto';
  }

  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang);
  }
}
