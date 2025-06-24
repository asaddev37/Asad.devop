import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

class PDFService {
  /// Generate PDF for students data
  static Future<void> generateStudentsPDF({
    required List<Map<String, dynamic>> students,
    required String departmentName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader('Students Report', departmentName),
          _buildStudentsTable(students),
          _buildFooter(context),
        ],
      ),
    );

    await _savePDF(pdf, 'students_report.pdf');
  }

  /// Generate PDF for advisors data
  static Future<void> generateAdvisorsPDF({
    required List<Map<String, dynamic>> advisors,
    required List<Map<String, dynamic>> batches,
    required String departmentName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader('Advisors Report', departmentName),
          _buildAdvisorsTable(advisors, batches),
          _buildFooter(context),
        ],
      ),
    );

    await _savePDF(pdf, 'advisors_report.pdf');
  }

  /// Generate PDF for complaints data
  static Future<void> generateComplaintsPDF({
    required List<Map<String, dynamic>> complaints,
    required String departmentName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader('Complaints Report', departmentName),
          _buildComplaintsTable(complaints),
          _buildFooter(context),
        ],
      ),
    );

    await _savePDF(pdf, 'complaints_report.pdf');
  }

  /// Generate PDF for all system data
  static Future<void> generateAllDataPDF({
    required List<Map<String, dynamic>> students,
    required List<Map<String, dynamic>> advisors,
    required List<Map<String, dynamic>> complaints,
    required List<Map<String, dynamic>> batches,
    required String departmentName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader('Complete System Report', departmentName),
          _buildSummarySection(students, advisors, complaints, batches),
          _buildStudentsTable(students),
          _buildAdvisorsTable(advisors, batches),
          _buildComplaintsTable(complaints),
          _buildBatchesTable(batches),
          _buildFooter(context),
        ],
      ),
    );

    await _savePDF(pdf, 'complete_system_report.pdf');
  }

  /// Build header section
  static pw.Widget _buildHeader(String title, String departmentName) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(25),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
          colors: [
            PdfColor.fromInt(0xFF1E3A8A), // Deep blue
            PdfColor.fromInt(0xFF3B82F6), // Blue
            PdfColor.fromInt(0xFF60A5FA), // Light blue
          ],
        ),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 60,
                height: 60,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(30),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'SCS',
                    style: pw.TextStyle(
                      color: PdfColor.fromInt(0xFF1E3A8A),
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Smart Complaint System',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      departmentName,
                      style: pw.TextStyle(
                        fontSize: 18,
                        color: PdfColor.fromInt(0xFFE5E7EB),
                        fontWeight: pw.FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 25),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFF1E3A8A),
              ),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF3F4F6),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              'Generated on: ${DateFormat('MMMM dd, yyyy - HH:mm').format(DateTime.now())}',
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColor.fromInt(0xFF6B7280),
                fontWeight: pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build summary section
  static pw.Widget _buildSummarySection(
    List<Map<String, dynamic>> students,
    List<Map<String, dynamic>> advisors,
    List<Map<String, dynamic>> complaints,
    List<Map<String, dynamic>> batches,
  ) {
    final totalStudents = students.length;
    final totalAdvisors = advisors.length;
    final totalComplaints = complaints.length;
    final totalBatches = batches.length;
    final resolvedComplaints =
        complaints.where((c) => c['status'] == 'Resolved').length;
    final pendingComplaints = complaints
        .where((c) => c['status'] == 'Submitted' || c['status'] == 'Pending')
        .length;

    return pw.Container(
      margin: const pw.EdgeInsets.all(20),
      padding: const pw.EdgeInsets.all(25),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
          colors: [
            PdfColor.fromInt(0xFFF8FAFC),
            PdfColor.fromInt(0xFFF1F5F9),
          ],
        ),
        border: pw.Border.all(
          color: PdfColor.fromInt(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF1E3A8A),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              'System Summary',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            children: [
              _buildSummaryCard('Total Students', totalStudents.toString(),
                  PdfColor.fromInt(0xFF3B82F6)),
              pw.SizedBox(width: 12),
              _buildSummaryCard('Total Advisors', totalAdvisors.toString(),
                  PdfColor.fromInt(0xFF10B981)),
              pw.SizedBox(width: 12),
              _buildSummaryCard('Total Batches', totalBatches.toString(),
                  PdfColor.fromInt(0xFFF59E0B)),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              _buildSummaryCard('Total Complaints', totalComplaints.toString(),
                  PdfColor.fromInt(0xFFEF4444)),
              pw.SizedBox(width: 12),
              _buildSummaryCard('Resolved', resolvedComplaints.toString(),
                  PdfColor.fromInt(0xFF10B981)),
              pw.SizedBox(width: 12),
              _buildSummaryCard('Pending', pendingComplaints.toString(),
                  PdfColor.fromInt(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  /// Build summary card
  static pw.Widget _buildSummaryCard(
      String title, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: color, width: 2),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColor.fromInt(0xFF6B7280),
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Get light version of a color
  static PdfColor _getLightColor(PdfColor color) {
    if (color == PdfColors.blue) return PdfColors.lightBlue;
    if (color == PdfColors.green) return PdfColors.lightGreen;
    return PdfColors.grey100;
  }

  /// Build students table
  static pw.Widget _buildStudentsTable(List<Map<String, dynamic>> students) {
    return pw.Container(
      margin: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF1E3A8A),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              'Students Data',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromInt(0xFFE2E8F0)),
            ),
            child: pw.Table(
              border: pw.TableBorder(
                horizontalInside:
                    pw.BorderSide(color: PdfColor.fromInt(0xFFE2E8F0)),
                verticalInside:
                    pw.BorderSide(color: PdfColor.fromInt(0xFFE2E8F0)),
              ),
              columnWidths: const {
                0: pw.FlexColumnWidth(2),
                1: pw.FlexColumnWidth(2),
                2: pw.FlexColumnWidth(1.5),
                3: pw.FlexColumnWidth(1.5),
                4: pw.FlexColumnWidth(1.5),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF8FAFC),
                  ),
                  children: [
                    _buildTableHeader('Name'),
                    _buildTableHeader('Email'),
                    _buildTableHeader('Phone'),
                    _buildTableHeader('Student ID'),
                    _buildTableHeader('Batch'),
                  ],
                ),
                // Data rows
                ...students.map((student) => pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                      ),
                      children: [
                        _buildTableCell(student['name'] as String? ?? ''),
                        _buildTableCell(student['email'] as String? ?? ''),
                        _buildTableCell(student['phone_no'] as String? ?? ''),
                        _buildTableCell(student['student_id'] as String? ?? ''),
                        _buildTableCell(
                            student['batch']?['batch_name'] as String? ?? ''),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build advisors table
  static pw.Widget _buildAdvisorsTable(
      List<Map<String, dynamic>> advisors, List<Map<String, dynamic>> batches) {
    return pw.Container(
      margin: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Advisors Data',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.lightGreen),
                children: [
                  _buildTableHeader('Name'),
                  _buildTableHeader('Email'),
                  _buildTableHeader('Batch'),
                ],
              ),
              // Data rows
              ...advisors.map((advisor) {
                final advisorId = advisor['id'] as String?;
                String batchName = '';
                if (advisorId != null) {
                  final batch = batches
                      .where((b) => b['advisor_id'] == advisorId)
                      .firstOrNull;
                  batchName = batch?['batch_name'] as String? ?? '';
                }

                return pw.TableRow(
                  children: [
                    _buildTableCell(advisor['name'] as String? ?? ''),
                    _buildTableCell(advisor['email'] as String? ?? ''),
                    _buildTableCell(batchName),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  /// Build complaints table
  static pw.Widget _buildComplaintsTable(
      List<Map<String, dynamic>> complaints) {
    return pw.Container(
      margin: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Complaints Data',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            columnWidths: const {
              0: pw.FlexColumnWidth(1.5),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(1.5),
              3: pw.FlexColumnWidth(2),
              4: pw.FlexColumnWidth(1),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _buildTableHeader('Student'),
                  _buildTableHeader('Subject'),
                  _buildTableHeader('Batch'),
                  _buildTableHeader('Status'),
                  _buildTableHeader('Created'),
                ],
              ),
              // Data rows
              ...complaints.map((complaint) => pw.TableRow(
                    children: [
                      _buildTableCell(
                          complaint['student']?['name'] as String? ?? ''),
                      _buildTableCell(complaint['subject'] as String? ?? ''),
                      _buildTableCell(
                          complaint['batch']?['batch_name'] as String? ?? ''),
                      _buildStatusCell(complaint['status'] as String? ?? ''),
                      _buildTableCell(DateFormat('MMM dd').format(
                          DateTime.tryParse(
                                  complaint['created_at'] as String? ?? '') ??
                              DateTime.now())),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }

  /// Build batches table
  static pw.Widget _buildBatchesTable(List<Map<String, dynamic>> batches) {
    return pw.Container(
      margin: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Batches Data',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(1),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _buildTableHeader('Batch Name'),
                  _buildTableHeader('Advisor'),
                  _buildTableHeader('Students'),
                ],
              ),
              // Data rows
              ...batches.map((batch) => pw.TableRow(
                    children: [
                      _buildTableCell(batch['batch_name'] as String? ?? ''),
                      _buildTableCell(
                          batch['advisor']?['name'] as String? ?? ''),
                      _buildTableCell(
                          (batch['students']?[0]?['count'] as int? ?? 0)
                              .toString()),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }

  /// Build table header
  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 12,
          color: PdfColor.fromInt(0xFF374151),
        ),
      ),
    );
  }

  /// Build table cell
  static pw.Widget _buildTableCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          color: PdfColor.fromInt(0xFF6B7280),
        ),
      ),
    );
  }

  /// Build status cell with color
  static pw.Widget _buildStatusCell(String status) {
    PdfColor statusColor;
    PdfColor backgroundColor;

    switch (status.toLowerCase()) {
      case 'resolved':
        statusColor = PdfColor.fromInt(0xFF059669);
        backgroundColor = PdfColor.fromInt(0xFFD1FAE5);
        break;
      case 'rejected':
        statusColor = PdfColor.fromInt(0xFFDC2626);
        backgroundColor = PdfColor.fromInt(0xFFFEE2E2);
        break;
      case 'escalated':
        statusColor = PdfColor.fromInt(0xFF7C3AED);
        backgroundColor = PdfColor.fromInt(0xFFEDE9FE);
        break;
      case 'in progress':
        statusColor = PdfColor.fromInt(0xFFD97706);
        backgroundColor = PdfColor.fromInt(0xFFFEF3C7);
        break;
      default:
        statusColor = PdfColor.fromInt(0xFF6B7280);
        backgroundColor = PdfColor.fromInt(0xFFF3F4F6);
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: pw.BoxDecoration(
          color: backgroundColor,
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Text(
          status,
          style: pw.TextStyle(
            fontSize: 10,
            color: statusColor,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Build footer
  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.all(20),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
          colors: [
            PdfColor.fromInt(0xFFF8FAFC),
            PdfColor.fromInt(0xFFF1F5F9),
          ],
        ),
        border: pw.Border(
          top: pw.BorderSide(color: PdfColor.fromInt(0xFFE2E8F0), width: 2),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF1E3A8A),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              'Smart Complaint System',
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF6B7280),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              'Generated on: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.white,
                fontWeight: pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Save PDF file
  static Future<void> _savePDF(pw.Document pdf, String fileName) async {
    try {
      // Generate PDF bytes
      final bytes = await pdf.save();
      print('PDF generated successfully: $fileName');
      print('PDF size: ${bytes.length} bytes');

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

        // Save PDF file
        final file = File('${reportsDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        print('PDF file saved to: ${file.path}');

        // Try to open the file (optional)
        try {
          await OpenFile.open(file.path);
          print('PDF file opened successfully');
        } catch (e) {
          print('Could not open PDF file automatically: $e');
          print('File is saved at: ${file.path}');
        }
      } else {
        print('Could not access any storage directory');
        throw Exception('No storage directory available');
      }

      print('PDF generation completed successfully');
    } catch (e) {
      print('Error saving PDF: $e');
      throw Exception('Failed to generate PDF: $e');
    }
  }
}
