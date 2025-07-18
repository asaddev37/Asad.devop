import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class ExcelService {
  Future<List<Map<String, dynamic>>> parseExcel(PlatformFile file) async {
    try {
      final bytes = await File(file.path!).readAsBytes();
      var excel = Excel.decodeBytes(bytes);
      var sheet = excel.tables.keys.first;
      var rows = excel.tables[sheet]!.rows;

      List<Map<String, dynamic>> students = [];
      for (var row in rows.skip(1)) { // Skip header
        students.add({
          'name': row[0]?.value?.toString() ?? '',
          'email': row[1]?.value?.toString(),
        });
      }
      return students;
    } catch (e) {
      throw Exception('Failed to parse Excel: $e');
    }
  }

  Future<void> exportToExcel(List<Map<String, dynamic>> data, String fileName) async {
    try {
      // Create a new Excel document
      var excel = Excel.createExcel();
      Sheet sheet = excel['CompletedTasks'];

      // Set headers
      sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Student ID');
      sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Student Name');
      sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Task Title');
      sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Completion Date');

      // Style headers
      for (var col in ['A', 'B', 'C', 'D']) {
        sheet
            .cell(CellIndex.indexByString('${col}1'))
            .cellStyle = CellStyle(
          bold: true,
        );
      }

      // Add data
      int rowIndex = 2;
      for (var row in data) {
        sheet.cell(CellIndex.indexByString('A$rowIndex')).value = TextCellValue(row['student_id'] ?? 'N/A');
        sheet.cell(CellIndex.indexByString('B$rowIndex')).value = TextCellValue(row['student_name'] ?? 'Unknown');
        sheet.cell(CellIndex.indexByString('C$rowIndex')).value = TextCellValue(row['task_title'] ?? '');
        sheet.cell(CellIndex.indexByString('D$rowIndex')).value = TextCellValue(row['completion_date'] ?? 'Unknown');
        rowIndex++;
      }

      // Auto-fit columns
      sheet.setColAutoFit(0);
      sheet.setColAutoFit(1);
      sheet.setColAutoFit(2);
      sheet.setColAutoFit(3);

      // Save the file
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      final fileBytes = excel.save();
      if (fileBytes == null) {
        throw Exception('Failed to generate Excel file');
      }

      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      // Open the file
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        throw Exception('Failed to open file: ${result.message}');
      }
    } catch (e) {
      throw Exception('Failed to export Excel: $e');
    }
  }
}

extension on Sheet {
  void setColAutoFit(int i) {}
}