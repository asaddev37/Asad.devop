import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../models/user_profile.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class CsvService {
  static Future<List<Map<String, dynamic>>> parseStudentCsv() async {
    final result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['csv'],
      type: FileType.custom,
    );
    if (result == null) return [];
    final fileBytes = result.files.single.bytes!;
    final csvString = String.fromCharCodes(fileBytes);
    final csvList = const CsvToListConverter().convert(csvString);
    return csvList
        .skip(1)
        .map((row) => {
              'student_name': row[0],
              'department': row[1],
              'phone_no': row[2],
              'batch_no': row[3],
              'student_email': row[4],
            })
        .toList();
  }

  /// Generate CSV data for students
  static Future<String> generateStudentsCSV(
      List<Map<String, dynamic>> students) async {
    final csvData = StringBuffer();

    // Add header
    csvData.writeln('Name,Email,Phone,Student ID,Batch,Created At');

    // Add data rows
    for (final student in students) {
      final name = student['name'] as String? ?? '';
      final email = student['email'] as String? ?? '';
      final phone = student['phone_no'] as String? ?? '';
      final studentId = student['student_id'] as String? ?? '';
      final batchName = student['batch']?['batch_name'] as String? ?? '';
      final createdAt = student['created_at'] as String? ?? '';

      csvData.writeln(
          '"$name","$email","$phone","$studentId","$batchName","$createdAt"');
    }

    return csvData.toString();
  }

  /// Generate CSV data for advisors
  static Future<String> generateAdvisorsCSV(
      List<Map<String, dynamic>> advisors) async {
    final csvData = StringBuffer();

    // Add header
    csvData.writeln('Name,Email,Batch,Created At');

    // Add data rows
    for (final advisor in advisors) {
      final name = advisor['name'] as String? ?? '';
      final email = advisor['email'] as String? ?? '';
      final batchName = advisor['batch']?['batch_name'] as String? ?? '';
      final createdAt = advisor['created_at'] as String? ?? '';

      csvData.writeln('"$name","$email","$batchName","$createdAt"');
    }

    return csvData.toString();
  }

  /// Generate CSV data for complaints
  static Future<String> generateComplaintsCSV(
      List<Map<String, dynamic>> complaints) async {
    final csvData = StringBuffer();

    // Add header
    csvData.writeln(
        'Student,Student Email,Batch,Subject,Description,Status,Created At,Resolved At');

    // Add data rows
    for (final complaint in complaints) {
      final studentName = complaint['student']?['name'] as String? ?? '';
      final studentEmail = complaint['student']?['email'] as String? ?? '';
      final batchName = complaint['batch']?['batch_name'] as String? ?? '';
      final subject = complaint['subject'] as String? ?? '';
      final description = complaint['description'] as String? ?? '';
      final status = complaint['status'] as String? ?? '';
      final createdAt = complaint['created_at'] as String? ?? '';
      final resolvedAt = complaint['resolved_at'] as String? ?? '';

      csvData.writeln(
          '"$studentName","$studentEmail","$batchName","$subject","$description","$status","$createdAt","$resolvedAt"');
    }

    return csvData.toString();
  }

  /// Generate CSV data for all system data
  static Future<String> generateAllDataCSV({
    required List<Map<String, dynamic>> students,
    required List<Map<String, dynamic>> advisors,
    required List<Map<String, dynamic>> complaints,
    required List<Map<String, dynamic>> batches,
  }) async {
    final csvData = StringBuffer();

    // Add title
    csvData.writeln('Smart Complaint System - Complete Data Export');
    csvData.writeln('Generated on: ${DateTime.now().toIso8601String()}');
    csvData.writeln();

    // Students section
    csvData.writeln('STUDENTS DATA');
    csvData.writeln('Name,Email,Phone,Student ID,Batch,Created At');
    for (final student in students) {
      final name = student['name'] as String? ?? '';
      final email = student['email'] as String? ?? '';
      final phone = student['phone_no'] as String? ?? '';
      final studentId = student['student_id'] as String? ?? '';
      final batchName = student['batch']?['batch_name'] as String? ?? '';
      final createdAt = student['created_at'] as String? ?? '';

      csvData.writeln(
          '"$name","$email","$phone","$studentId","$batchName","$createdAt"');
    }
    csvData.writeln();

    // Advisors section
    csvData.writeln('ADVISORS DATA');
    csvData.writeln('Name,Email,Batch,Created At');
    for (final advisor in advisors) {
      final name = advisor['name'] as String? ?? '';
      final email = advisor['email'] as String? ?? '';
      final batchName = advisor['batch']?['batch_name'] as String? ?? '';
      final createdAt = advisor['created_at'] as String? ?? '';

      csvData.writeln('"$name","$email","$batchName","$createdAt"');
    }
    csvData.writeln();

    // Complaints section
    csvData.writeln('COMPLAINTS DATA');
    csvData.writeln(
        'Student,Student Email,Batch,Subject,Description,Status,Created At,Resolved At');
    for (final complaint in complaints) {
      final studentName = complaint['student']?['name'] as String? ?? '';
      final studentEmail = complaint['student']?['email'] as String? ?? '';
      final batchName = complaint['batch']?['batch_name'] as String? ?? '';
      final subject = complaint['subject'] as String? ?? '';
      final description = complaint['description'] as String? ?? '';
      final status = complaint['status'] as String? ?? '';
      final createdAt = complaint['created_at'] as String? ?? '';
      final resolvedAt = complaint['resolved_at'] as String? ?? '';

      csvData.writeln(
          '"$studentName","$studentEmail","$batchName","$subject","$description","$status","$createdAt","$resolvedAt"');
    }
    csvData.writeln();

    // Batches section
    csvData.writeln('BATCHES DATA');
    csvData.writeln('Batch Name,Advisor,Student Count,Created At');
    for (final batch in batches) {
      final batchName = batch['batch_name'] as String? ?? '';
      final advisorName = batch['advisor']?['name'] as String? ?? '';
      final studentCount = batch['students']?[0]?['count'] as int? ?? 0;
      final createdAt = batch['created_at'] as String? ?? '';

      csvData
          .writeln('"$batchName","$advisorName","$studentCount","$createdAt"');
    }

    return csvData.toString();
  }

  /// Download CSV file
  static Future<void> downloadCSV(String csvData, String fileName) async {
    try {
      print('Starting CSV download: $fileName');
      print('CSV data length: ${csvData.length} characters');

      // Get the appropriate directory based on platform
      Directory? directory;

      try {
        if (Platform.isAndroid || Platform.isIOS) {
          // For mobile platforms, try to get external storage
          directory = await getExternalStorageDirectory();
          if (directory == null) {
            // Fallback to app documents directory
            directory = await getApplicationDocumentsDirectory();
          }
        } else {
          // For desktop platforms, use documents directory
          directory = await getApplicationDocumentsDirectory();
        }
      } catch (e) {
        print('Error getting directory: $e');
        // Final fallback
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        print('Using directory: ${directory.path}');

        // Create a Reports folder if it doesn't exist
        final reportsDir = Directory('${directory.path}/Reports');
        if (!await reportsDir.exists()) {
          await reportsDir.create(recursive: true);
        }

        // Save CSV file
        final file = File('${reportsDir.path}/$fileName');
        await file.writeAsString(csvData, encoding: utf8);
        print('CSV file saved to: ${file.path}');

        // Try to open the file (optional)
        try {
          await OpenFile.open(file.path);
          print('CSV file opened successfully');
        } catch (e) {
          print('Could not open CSV file automatically: $e');
          print('File is saved at: ${file.path}');
        }
      } else {
        print('Could not access any storage directory');
        throw Exception('No storage directory available');
      }

      print('CSV download completed successfully');
    } catch (e) {
      print('Error in CSV download: $e');
      throw Exception('Failed to process CSV data: $e');
    }
  }
}
