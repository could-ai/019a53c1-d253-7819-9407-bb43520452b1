import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../models/attendance_record.dart';

class StorageService {
  static const String studentsKey = 'students';
  static const String attendanceKey = 'attendance_records';

  // Save students list
  static Future<void> saveStudents(List<Student> students) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentsJson = students.map((s) => s.toJson()).toList();
      await prefs.setString(studentsKey, jsonEncode(studentsJson));
    } catch (e) {
      debugPrint('Error saving students: $e');
    }
  }

  // Load students list
  static Future<List<Student>> loadStudents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentsString = prefs.getString(studentsKey);
      if (studentsString == null) return [];
      
      final List<dynamic> studentsJson = jsonDecode(studentsString);
      return studentsJson.map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading students: $e');
      return [];
    }
  }

  // Save attendance records
  static Future<void> saveAttendanceRecords(List<AttendanceRecord> records) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = records.map((r) => r.toJson()).toList();
      await prefs.setString(attendanceKey, jsonEncode(recordsJson));
    } catch (e) {
      debugPrint('Error saving attendance records: $e');
    }
  }

  // Load attendance records
  static Future<List<AttendanceRecord>> loadAttendanceRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsString = prefs.getString(attendanceKey);
      if (recordsString == null) return [];
      
      final List<dynamic> recordsJson = jsonDecode(recordsString);
      return recordsJson.map((json) => AttendanceRecord.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading attendance records: $e');
      return [];
    }
  }

  // Get attendance records for a specific date
  static Future<List<AttendanceRecord>> getAttendanceByDate(DateTime date) async {
    final allRecords = await loadAttendanceRecords();
    return allRecords.where((record) {
      return record.date.year == date.year &&
             record.date.month == date.month &&
             record.date.day == date.day;
    }).toList();
  }
}
