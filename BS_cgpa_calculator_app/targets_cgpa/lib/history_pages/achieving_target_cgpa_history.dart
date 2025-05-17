import 'dart:io' show Directory, File, Platform;
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:targets_cgpa/screens/database_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class AchievingTargetCgpaHistory extends StatefulWidget {
  final bool isDarkMode;

  const AchievingTargetCgpaHistory({super.key, required this.isDarkMode});

  @override
  State<AchievingTargetCgpaHistory> createState() => _AchievingTargetCgpaHistoryState();
}

class _AchievingTargetCgpaHistoryState extends State<AchievingTargetCgpaHistory> {
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarColor = widget.isDarkMode ? Colors.grey.shade800 : Color(0xFFD35400);
    final backgroundGradient = widget.isDarkMode
        ? LinearGradient(
      colors: [Colors.grey.shade900, Colors.grey.shade800],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    )
        : LinearGradient(
      colors: [
        Color(0xFFF39C12).withAlpha(25),
        Color(0xFFFFF3E0),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final textColor = widget.isDarkMode ? Colors.white : Color(0xFF7F8C8D);
    final primaryTextColor = widget.isDarkMode ? Colors.amberAccent : Color(0xFFD35400);
    final buttonColor = widget.isDarkMode ? Colors.amberAccent : Color(0xFFF39C12);
    final shadowColor = widget.isDarkMode ? Colors.amberAccent.withAlpha(77) : Color(0xFFE74C3C).withAlpha(77);
    final pressedColor = widget.isDarkMode ? Colors.amberAccent.withAlpha(51) : Color(0xFFE74C3C).withAlpha(77);
    final hoverColor = widget.isDarkMode ? Colors.amberAccent.withAlpha(25) : Color(0xFFF39C12).withAlpha(25);
    final progressColor = widget.isDarkMode ? Colors.amberAccent : Color(0xFFE74C3C);
    final borderColor = widget.isDarkMode ? Colors.amberAccent.withAlpha(128) : Color(0xFFE74C3C).withAlpha(128);
    final cardColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.white;
    final headerColor = widget.isDarkMode ? Colors.grey.shade700 : Color(0xFFFFF3E0);
    final tableHeaderColor = widget.isDarkMode ? Colors.amberAccent : Color(0xFFF39C12);

    return Scaffold(
      appBar: AppBar(
        title: Text('Target CGPA History', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: appBarColor,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _getTargetHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: progressColor));
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: textColor)));
              }

              final data = (snapshot.data ?? []).map((record) => Map<String, dynamic>.from(record)).toList();

              data.sort((a, b) {
                DateTime timestampA = DateTime.tryParse(a['timestamp']?.toString() ?? '') ?? DateTime(1970, 1, 1);
                DateTime timestampB = DateTime.tryParse(b['timestamp']?.toString() ?? '') ?? DateTime(1970, 1, 1);
                return timestampB.compareTo(timestampA);
              });

              return CustomScrollView(
                slivers: [
                  SliverStickyHeader(
                    header: Container(
                      color: headerColor,
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text(
                              'Target CGPA History',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 16.0),
                            child: Tooltip(
                              message: 'Download history',
                              child: ElevatedButton(
                                onPressed: () => _showDownloadOptions(context, data),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.all(12),
                                  shape: CircleBorder(),
                                  elevation: 4,
                                  shadowColor: shadowColor,
                                ).copyWith(
                                  overlayColor: WidgetStateProperty.resolveWith<Color?>(
                                        (Set<WidgetState> states) {
                                      if (states.contains(WidgetState.pressed)) return pressedColor;
                                      if (states.contains(WidgetState.hovered)) return hoverColor;
                                      return null;
                                    },
                                  ),
                                ),
                                child: Icon(Icons.download, size: 24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          if (data.isEmpty) {
                            if (index == 0) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.0),
                                  child: Text(
                                    'No history available yet.\nStart planning your target CGPA!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18, color: textColor, fontStyle: FontStyle.italic),
                                  ),
                                ),
                              );
                            } else if (index == 1) {
                              return Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: buttonColor,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    elevation: 4,
                                    shadowColor: shadowColor,
                                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ).copyWith(
                                    overlayColor: WidgetStateProperty.resolveWith<Color?>(
                                          (Set<WidgetState> states) {
                                        if (states.contains(WidgetState.pressed)) return pressedColor;
                                        if (states.contains(WidgetState.hovered)) return hoverColor;
                                        return null;
                                      },
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Back'),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_back_ios, size: 16),
                                    ],
                                  ),
                                ),
                              );
                            }
                          } else {
                            if (index == data.length) {
                              return Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: buttonColor,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    elevation: 4,
                                    shadowColor: shadowColor,
                                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ).copyWith(
                                    overlayColor: WidgetStateProperty.resolveWith<Color?>(
                                          (Set<WidgetState> states) {
                                        if (states.contains(WidgetState.pressed)) return pressedColor;
                                        if (states.contains(WidgetState.hovered)) return hoverColor;
                                        return null;
                                      },
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Back'),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_back_ios, size: 16),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final record = data[index];
                            final rawSubjects = (record['subjects'] as String?) ?? '';
                            final rawCredits = (record['credits'] as String?) ?? '';
                            final rawGrades = (record['grades'] as String?) ?? '';

                            final subjects = rawSubjects.split(',').map((s) => s.trim()).toList();
                            final credits = rawCredits.split(',').map((c) => int.tryParse(c.trim()) ?? 0).toList();
                            final grades = rawGrades.split(',').map((g) => double.tryParse(g.trim()) ?? 0.0).toList();

                            final maxLength = [subjects.length, credits.length, grades.length].reduce((a, b) => a > b ? a : b);
                            final validSubjects = List<String>.generate(
                              maxLength,
                                  (i) => i < subjects.length && subjects[i].isNotEmpty ? subjects[i] : 'Subject ${i + 1}',
                            );
                            final validCredits = List<int>.generate(maxLength, (i) => i < credits.length ? credits[i] : 0);
                            final validGrades = List<double>.generate(maxLength, (i) => i < grades.length ? grades[i] : 0.0);

                            final currentSemester = record['current_semester'] as int? ?? 0;
                            final currentCgpa = record['current_cgpa'] as double? ?? 0.0;
                            final targetCgpa = record['target_cgpa'] as double? ?? 0.0;
                            final requiredGpa = record['required_gpa'] as double? ?? 0.0;
                            final nextSemesterGpa = record['next_semester_gpa'] as double? ?? 0.0;
                            final actualCgpa = record['actual_cgpa'] as double? ?? 0.0;
                            final timestamp = DateTime.tryParse(record['timestamp']?.toString() ?? '') ?? DateTime(1970, 1, 1);
                            final formattedTimestamp = DateFormat('dd-MM-yyyy :: HH:mm:ss').format(timestamp);

                            return Card(
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(color: borderColor, width: 1),
                              ),
                              color: cardColor,
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Current Semester: $currentSemester',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
                                    SizedBox(height: 8),
                                    Text('Current CGPA: ${currentCgpa.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 16, color: primaryTextColor)),
                                    SizedBox(height: 8),
                                    Text('Target CGPA: ${targetCgpa.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 16, color: primaryTextColor)),
                                    SizedBox(height: 8),
                                    Text('Required GPA for Next Semester: ${requiredGpa.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 16, color: primaryTextColor)),
                                    SizedBox(height: 12),
                                    Text('Subjects: $maxLength', style: TextStyle(fontSize: 16, color: primaryTextColor)),
                                    SizedBox(height: 12),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columnSpacing: 10.0,
                                        headingRowColor: WidgetStateColor.resolveWith((states) => tableHeaderColor),
                                        headingTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                        dataRowColor: WidgetStateColor.resolveWith(
                                              (states) => states.contains(WidgetState.selected)
                                              ? (widget.isDarkMode ? Colors.grey.shade700 : Color(0xFFFFF3E0))
                                              : cardColor,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: borderColor, width: 1),
                                        ),
                                        columns: const [
                                          DataColumn(label: Text('Subjects')),
                                          DataColumn(label: Text('Credits')),
                                          DataColumn(label: Text('GPA')),
                                        ],
                                        rows: List.generate(maxLength, (index) {
                                          return DataRow(cells: [
                                            DataCell(Text(validSubjects[index],
                                                style: TextStyle(fontSize: 16, color: primaryTextColor))),
                                            DataCell(Center(
                                                child: Text(validCredits[index].toString(),
                                                    style: TextStyle(fontSize: 16, color: primaryTextColor)))),
                                            DataCell(Text(validGrades[index].toStringAsFixed(2),
                                                style: TextStyle(fontSize: 16, color: primaryTextColor))),
                                          ]);
                                        }),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text('Next Semester GPA: ${nextSemesterGpa.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 16, color: primaryTextColor)),
                                    SizedBox(height: 8),
                                    Text('Actual CGPA: ${actualCgpa.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 16, color: primaryTextColor)),
                                    SizedBox(height: 8),
                                    Text('Timestamp: $formattedTimestamp',
                                        style: TextStyle(fontSize: 14, color: textColor)),
                                  ],
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                        childCount: data.isEmpty ? 2 : data.length + 1,
                      ),
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

  Future<List<Map<String, dynamic>>> _getTargetHistory() async {
    final db = await DatabaseService.database;
    return await db.query('target_cgpa_history');
  }

  void _showDownloadOptions(BuildContext context, List<Map<String, dynamic>> data) {
    // Colors for light and dark mode consistent with the file
    final dialogBackgroundColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.white;
    final dialogTitleColor = widget.isDarkMode ? Colors.amber : Color(0xFFD35400);
    final dialogTextColor = widget.isDarkMode ? Colors.white70 : Color(0xFF7F8C8D);
    final confirmButtonColor = widget.isDarkMode ? Colors.amberAccent : Color(0xFFF39C12);
    final cancelButtonColor = widget.isDarkMode ? Colors.grey : Colors.grey.shade600;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: dialogBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Download Options',
            style: TextStyle(
              color: dialogTitleColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'How would you like to download the history?',
            style: TextStyle(
              color: dialogTextColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _downloadHistory(data, 'csv');
              },
              style: TextButton.styleFrom(
                foregroundColor: confirmButtonColor,
                backgroundColor: confirmButtonColor.withAlpha(26),
              ),
              child: Text(
                'CSV',
                style: TextStyle(
                  color: confirmButtonColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _downloadHistory(data, 'pdf');
              },
              style: TextButton.styleFrom(
                foregroundColor: confirmButtonColor,
                backgroundColor: confirmButtonColor.withAlpha(26),
              ),
              child: Text(
                'PDF',
                style: TextStyle(
                  color: confirmButtonColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Simply close the dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: cancelButtonColor,
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: cancelButtonColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadHistory(List<Map<String, dynamic>> data, String format) async {
    if (data.isEmpty) {
      if (_isMounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No data available to download!', style: TextStyle(color: Colors.white)),
            duration: Duration(seconds: 2),
            backgroundColor: widget.isDarkMode ? Colors.redAccent : Color(0xFFE74C3C),
            action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
          ),
        );
      }
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    BuildContext? dialogContext;

    try {
      if (_isMounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext ctx) {
            dialogContext = ctx;
            return Center(child: CircularProgressIndicator());
          },
        ).then((_) => dialogContext = null);
      }

      bool permissionGranted = await _requestStoragePermission();
      if (!permissionGranted) {
        if (_isMounted && dialogContext != null) {
          Navigator.pop(dialogContext!);
        }
        if (_isMounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Storage permission denied', style: TextStyle(color: Colors.white)),
              duration: Duration(seconds: 2),
              backgroundColor: widget.isDarkMode ? Colors.redAccent : Color(0xFFE74C3C),
              action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
            ),
          );
        }
        return;
      }

      String fileName = '';
      if (format == 'csv') {
        fileName = await _saveCsvFile(data);
      } else if (format == 'pdf') {
        fileName = await _savePdfFile(data);
      }

      if (_isMounted && dialogContext != null) {
        Navigator.pop(dialogContext!);
      }

      if (_isMounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              '${format.toUpperCase()} downloaded successfully: $fileName',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (_isMounted && dialogContext != null) {
        Navigator.pop(dialogContext!);
      }
      if (_isMounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error downloading file: $e', style: TextStyle(color: Colors.white)),
            duration: Duration(seconds: 2),
            backgroundColor: widget.isDarkMode ? Colors.redAccent : Color(0xFFE74C3C),
            action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
          ),
        );
      }
    }
  }

  Future<String> _saveCsvFile(List<Map<String, dynamic>> data) async {
    List<List<dynamic>> csvData = [
      [
        'Current Semester',
        'Current CGPA',
        'Target CGPA',
        'Required GPA',
        'Subjects',
        'Credits',
        'Grades',
        'Next Semester GPA',
        'Actual CGPA',
        'Timestamp'
      ]
    ];

    for (var record in data) {
      final timestamp = DateTime.tryParse(record['timestamp']?.toString() ?? '') ?? DateTime(1970, 1, 1);
      final formattedTimestamp = DateFormat('dd-MM-yyyy :: HH:mm:ss').format(timestamp);

      csvData.add([
        record['current_semester'] ?? 'N/A',
        record['current_cgpa']?.toStringAsFixed(2) ?? '0.0',
        record['target_cgpa']?.toStringAsFixed(2) ?? '0.0',
        record['required_gpa']?.toStringAsFixed(2) ?? '0.0',
        record['subjects'] ?? '',
        record['credits'] ?? '',
        record['grades'] ?? '',
        record['next_semester_gpa']?.toStringAsFixed(2) ?? '0.0',
        record['actual_cgpa']?.toStringAsFixed(2) ?? '0.0',
        formattedTimestamp,
      ]);
    }

    String csv = const ListToCsvConverter().convert(csvData);
    Directory directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) await directory.create(recursive: true);
    } else {
      final tempDir = await getDownloadsDirectory();
      if (tempDir == null) throw Exception('Could not access downloads directory');
      directory = tempDir;
    }

    String fileName = 'Target_CGPA_History_${DateTime.now().millisecondsSinceEpoch}.csv';
    String filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsString(csv);

    if (!await file.exists()) {
      throw Exception('Failed to create CSV file');
    }

    return fileName;
  }

  Future<String> _savePdfFile(List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();

    final tableHeaderColor = widget.isDarkMode ? PdfColors.amberAccent : PdfColors.orange;
    final textColor = widget.isDarkMode ? PdfColors.white : PdfColors.grey800;
    final primaryTextColor = widget.isDarkMode ? PdfColors.amberAccent : PdfColors.orange;
    final borderColor = widget.isDarkMode ? PdfColors.amberAccent : PdfColors.redAccent;
    final cardColor = widget.isDarkMode ? PdfColors.grey800 : PdfColors.white;

    for (var record in data) {
      final rawSubjects = (record['subjects'] as String?) ?? '';
      final rawCredits = (record['credits'] as String?) ?? '';
      final rawGrades = (record['grades'] as String?) ?? '';

      final subjects = rawSubjects.split(',').map((s) => s.trim()).toList();
      final credits = rawCredits.split(',').map((c) => int.tryParse(c.trim()) ?? 0).toList();
      final grades = rawGrades.split(',').map((g) => double.tryParse(g.trim()) ?? 0.0).toList();

      final maxLength = [subjects.length, credits.length, grades.length].reduce((a, b) => a > b ? a : b);
      final validSubjects = List<String>.generate(
        maxLength,
            (i) => i < subjects.length && subjects[i].isNotEmpty ? subjects[i] : 'Subject ${i + 1}',
      );
      final validCredits = List<int>.generate(maxLength, (i) => i < credits.length ? credits[i] : 0);
      final validGrades = List<double>.generate(maxLength, (i) => i < grades.length ? grades[i] : 0.0);

      final currentSemester = record['current_semester'] as int? ?? 0;
      final currentCgpa = record['current_cgpa'] as double? ?? 0.0;
      final targetCgpa = record['target_cgpa'] as double? ?? 0.0;
      final requiredGpa = record['required_gpa'] as double? ?? 0.0;
      final nextSemesterGpa = record['next_semester_gpa'] as double? ?? 0.0;
      final actualCgpa = record['actual_cgpa'] as double? ?? 0.0;
      final timestamp = DateTime.tryParse(record['timestamp']?.toString() ?? '') ?? DateTime(1970, 1, 1);
      final formattedTimestamp = DateFormat('dd-MM-yyyy :: HH:mm:ss').format(timestamp);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Current Semester: $currentSemester',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: primaryTextColor)),
              pw.SizedBox(height: 8),
              pw.Text('Current CGPA: ${currentCgpa.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 16, color: primaryTextColor)),
              pw.SizedBox(height: 8),
              pw.Text('Target CGPA: ${targetCgpa.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 16, color: primaryTextColor)),
              pw.SizedBox(height: 8),
              pw.Text('Required GPA for Next Semester: ${requiredGpa.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 16, color: primaryTextColor)),
              pw.SizedBox(height: 12),
              pw.Text('Subjects: $maxLength', style: pw.TextStyle(fontSize: 16, color: primaryTextColor)),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder.all(color: borderColor),
                columnWidths: {
                  0: pw.FlexColumnWidth(2),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: tableHeaderColor),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Subjects', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Credits', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('GPA', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...List.generate(maxLength, (index) => pw.TableRow(
                    decoration: pw.BoxDecoration(color: cardColor),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(validSubjects[index], style: pw.TextStyle(color: primaryTextColor)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(validCredits[index].toString(), style: pw.TextStyle(color: primaryTextColor)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(validGrades[index].toStringAsFixed(2), style: pw.TextStyle(color: primaryTextColor)),
                      ),
                    ],
                  )),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Text('Next Semester GPA: ${nextSemesterGpa.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 16, color: primaryTextColor)),
              pw.SizedBox(height: 8),
              pw.Text('Actual CGPA: ${actualCgpa.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 16, color: primaryTextColor)),
              pw.SizedBox(height: 8),
              pw.Text('Timestamp: $formattedTimestamp', style: pw.TextStyle(fontSize: 14, color: textColor)),
            ],
          ),
        ),
      );
    }

    Directory directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) await directory.create(recursive: true);
    } else {
      final tempDir = await getDownloadsDirectory();
      if (tempDir == null) throw Exception('Could not access downloads directory');
      directory = tempDir;
    }

    String fileName = 'Target_CGPA_History_${DateTime.now().millisecondsSinceEpoch}.pdf';
    String filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    if (!await file.exists()) {
      throw Exception('Failed to create PDF file');
    }

    return fileName;
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) status = await Permission.storage.request();
      if (!status.isGranted && await _isAndroid11OrHigher()) {
        status = await Permission.manageExternalStorage.request();
      }
      return status.isGranted;
    }
    return true;
  }

  Future<bool> _isAndroid11OrHigher() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      var androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 30;
    }
    return false;
  }
}