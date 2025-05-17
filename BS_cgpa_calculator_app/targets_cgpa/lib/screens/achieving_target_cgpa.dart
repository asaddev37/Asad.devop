import 'package:flutter/material.dart';
import 'dart:math';
import 'database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievingTargetCGPAScreen extends StatefulWidget {
  final bool isDarkMode;

  const AchievingTargetCGPAScreen({super.key, required this.isDarkMode});

  @override
  State<AchievingTargetCGPAScreen> createState() => _AchievingTargetCGPAScreenState();
}

class _AchievingTargetCGPAScreenState extends State<AchievingTargetCGPAScreen> {
  final TextEditingController currentCgpaController = TextEditingController(text: '0.0');
  final TextEditingController targetCgpaController = TextEditingController(text: '0.0');
  List<TextEditingController> subjectControllers = [];

  double currentCgpa = 0.0;
  double targetCgpa = 0.0;
  int currentSemester = 1;
  int totalCreditHours = 0;
  int nextSemesterCreditHours = 4;
  double requiredCgpa = 0.0;
  String errorMessage = '';
  String requiredGpaResult = '';

  int subjects = 1;
  List<String> subjectList = [];
  List<int> creditList = [];
  List<double> requiredGpaList = [];
  List<double> randomGpaList = [];
  bool showOutputTable = false;
  bool isFirstResultDisplay = true;

  final List<int> creditHoursOptions = List.generate(6, (index) => index + 1);
  final List<double> possibleGpas = [1.00, 1.33, 1.66, 2.00, 2.33, 2.66, 3.00, 3.33, 3.66, 4.00];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _calculateButtonKey = GlobalKey();
  final GlobalKey _requiredGpaKey = GlobalKey();
  final GlobalKey _resultSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    updateSubjectLists(subjects);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    currentCgpaController.dispose();
    targetCgpaController.dispose();
    for (var controller in subjectControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void updateSubjectLists(int newSubjectCount) {
    setState(() {
      subjects = newSubjectCount;
      subjectList = List.generate(subjects, (index) => 'Subject ${index + 1}');
      creditList = List.generate(subjects, (index) => 1);
      requiredGpaList = List.generate(subjects, (index) => 0.0);
      randomGpaList = List.generate(subjects, (index) => 0.0);
      subjectControllers = List.generate(subjects, (index) => TextEditingController(text: ''));
    });
  }

  void calculateRequiredCGPA() {
    double currentGpa = double.tryParse(currentCgpaController.text) ?? 0.0;
    double targetGpa = double.tryParse(targetCgpaController.text) ?? 0.0;

    setState(() {
      if (currentGpa < 0.0 || currentGpa > 4.0) {
        currentCgpaController.text = '';
        currentCgpa = 0.0;
      } else {
        currentCgpa = currentGpa;
      }

      if (targetGpa < 0.0 || targetGpa > 4.0) {
        targetCgpaController.text = '';
        targetCgpa = 0.0;
      } else {
        targetCgpa = targetGpa;
      }

      totalCreditHours = currentSemester * 4;

      if (totalCreditHours > 0 && nextSemesterCreditHours > 0) {
        double totalQualityPoints = currentCgpa * totalCreditHours;
        double requiredQualityPoints =
            (targetCgpa * (totalCreditHours + nextSemesterCreditHours)) - totalQualityPoints;
        requiredCgpa = requiredQualityPoints / nextSemesterCreditHours;
        requiredCgpa = requiredCgpa.clamp(0.0, 4.0);
        requiredGpaResult = 'Required GPA in Next Semester: ${requiredCgpa.toStringAsFixed(2)}';
      } else {
        requiredCgpa = 0.0;
        requiredGpaResult = 'Required GPA in Next Semester: 0.00';
      }
      errorMessage = '';
      showOutputTable = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox = _requiredGpaKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero).dy;
        _scrollController.animateTo(
          position - 100,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  double calculateSemesterGpa(List<double> gpas, List<int> credits) {
    double totalGradePoints = 0.0;
    int totalCredits = 0;
    for (int i = 0; i < gpas.length; i++) {
      totalGradePoints += gpas[i] * credits[i];
      totalCredits += credits[i];
    }
    return totalCredits > 0 ? totalGradePoints / totalCredits : 0.0;
  }

  void assignRandomGpas() {
    bool wasOutputTableShown = showOutputTable;
    setState(() {
      randomGpaList = List.generate(subjects, (index) => 0.0);
      int maxIterations = 100000;
      int iterations = 0;

      while (iterations < maxIterations) {
        for (int i = 0; i < subjects; i++) {
          randomGpaList[i] = possibleGpas[Random().nextInt(possibleGpas.length)];
        }
        double semesterGpa = calculateSemesterGpa(randomGpaList, creditList);
        if ((semesterGpa - requiredCgpa).abs() < 0.05) {
          showOutputTable = true;
          errorMessage = ''; // Clear error message
          break;
        }
        iterations++;
      }

      if (!showOutputTable) {
        _showFieldOverlay(
          message: 'Unable to find a valid combination of GPAs. Please adjust your inputs.',
          fieldKey: _resultSectionKey, // Show overlay near the result section
          duration: Duration(seconds: 3),
        );
        errorMessage = ''; // Clear text-based error message
      }
    });

    if (showOutputTable && !wasOutputTableShown && isFirstResultDisplay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final RenderBox? renderBox = _resultSectionKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero).dy;
          _scrollController.animateTo(
            position - 100,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          isFirstResultDisplay = false;
        }
      });
    }
  }
  static const Color _lightModeErrorBg = Colors.black45; // Soft red background
  static const Color _lightModeErrorText = Colors.white; // Deep red text
  static const Color _darkModeErrorBg = Colors.white30;  // Dark red background
  static const Color _darkModeErrorText = Colors.black; // Light red text

  OverlayEntry? _overlayEntry;
  void _showFieldOverlay({
    required String message,
    required GlobalKey fieldKey,
    Duration duration = const Duration(seconds: 2),
  }) {
    _overlayEntry?.remove();
    final RenderBox? renderBox = fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy - 40, // Position above the field
        width: size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? _darkModeErrorBg : _lightModeErrorBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: widget.isDarkMode ? _darkModeErrorText : _lightModeErrorText,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(duration, () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }
  void calculateRequiredGPAForSubjects() async {
    if (requiredCgpa <= 0) {
      // Use an overlay to show the error message
      _showFieldOverlay(
        message: 'Please calculate the required GPA first',
        fieldKey: _calculateButtonKey, // You can pass a relevant key if needed
        duration: Duration(seconds: 2),
      );
      return;
    }

    assignRandomGpas();

    final prefs = await SharedPreferences.getInstance();
    final isHistoryEnabled = prefs.getBool('isHistoryEnabled') ?? true;

    if (isHistoryEnabled && showOutputTable) {
      await saveTargetCgpaHistory(
        currentCgpa: currentCgpa,
        targetCgpa: targetCgpa,
        remainingCredits: nextSemesterCreditHours,
        requiredGpa: requiredCgpa,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Calculation Saved to History!',
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
  }

  double calculateActualCGPA() {
    double totalQualityPoints = currentCgpa * totalCreditHours;
    double nextSemesterQualityPoints = calculateSemesterGpa(randomGpaList, creditList) * nextSemesterCreditHours;
    int totalCredits = totalCreditHours + nextSemesterCreditHours;
    return totalCredits > 0 ? (totalQualityPoints + nextSemesterQualityPoints) / totalCredits : 0.0;
  }

  String _getResultMessage() {
    double actualCGPA = calculateActualCGPA();
    if (actualCGPA >= targetCgpa) {
      return 'Congratulations! You have achieved your target CGPA.';
    } else {
      return 'Sorry! Again tap to check ! to meet the target.';
    }
  }

  void resetFields() {
    setState(() {
      currentSemester = 1;
      currentCgpaController.text = '0.0';
      targetCgpaController.text = '0.0';
      currentCgpa = 0.0;
      targetCgpa = 0.0;
      requiredCgpa = 0.0;
      errorMessage = '';
      requiredGpaResult = '';
      showOutputTable = false;
      isFirstResultDisplay = true;
      updateSubjectLists(1);
    });
  }

  Future<void> saveTargetCgpaHistory({
    required double currentCgpa,
    required double targetCgpa,
    required int remainingCredits,
    required double requiredGpa,
  }) async {
    final db = await DatabaseService.database;
    try {
      double nextSemesterGpa = calculateSemesterGpa(randomGpaList, creditList);
      double actualCgpa = calculateActualCGPA();

      await db.insert('target_cgpa_history', {
        'current_cgpa': currentCgpa,
        'target_cgpa': targetCgpa,
        'current_semester': currentSemester,
        'subjects': subjectList.join(','),
        'credits': creditList.join(','),
        'grades': randomGpaList.map((gpa) => gpa.toStringAsFixed(2)).join(','),
        'remaining_credits': remainingCredits,
        'required_gpa': requiredGpa,
        'next_semester_gpa': nextSemesterGpa,
        'actual_cgpa': actualCgpa,
        'timestamp': DateTime.now().toString(),
      });
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundGradient = widget.isDarkMode
        ? LinearGradient(colors: [Colors.grey.shade900, Colors.grey.shade800])
        : LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.grey.shade100, Colors.white],
    );

    final appBarGradient = widget.isDarkMode
        ? LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Colors.grey.shade800, Colors.grey.shade700],
    )
        : LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Colors.purple.shade800, Colors.purple.shade600],
    );

    final textColor = widget.isDarkMode ? Colors.white : Colors.grey.shade800;
    final labelColor = widget.isDarkMode ? Colors.amberAccent : Colors.purple.shade700;
    final fillColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50;
    final borderColor = widget.isDarkMode ? Colors.grey.shade600 : Colors.purple.shade200;
    final headingRowColor = widget.isDarkMode ? Colors.grey.shade600 : Colors.purple.shade700;
    final dataRowColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.white;
    final buttonColor = widget.isDarkMode ? Colors.amberAccent : Colors.purple.shade700;
    final buttonHoverColor = widget.isDarkMode ? Colors.amber.shade700 : Colors.purple.shade600;
    final iconColor = widget.isDarkMode ? Colors.amberAccent : Colors.white;
    final dropdownMenuItemColor = widget.isDarkMode ? Colors.white : Colors.grey.shade800;
    final cursorColor = widget.isDarkMode ? Colors.amberAccent : Colors.purple.shade700;
    final dropdownIconColor = widget.isDarkMode ? Colors.amberAccent : Colors.purple.shade700;
    final inputTextColor = widget.isDarkMode ? Colors.white : Colors.grey.shade800;
    final containerColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.white;
    final tableBorderColor = widget.isDarkMode ? Colors.grey.shade600 : Colors.purple.shade300;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Achieving Target CGPA',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: appBarGradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: iconColor),
            onPressed: resetFields,
            tooltip: 'Reset Fields',
          ),
        ],
        elevation: 4,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(gradient: backgroundGradient),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(widget.isDarkMode ? 51 : 25),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Academic Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: currentSemester,
                        decoration: InputDecoration(
                          labelText: 'Current Semester',
                          labelStyle: TextStyle(color: labelColor, fontSize: 14, fontWeight: FontWeight.w500),
                          filled: true,
                          fillColor: fillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: buttonColor, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        dropdownColor: widget.isDarkMode ? Colors.grey.shade700 : Colors.white,
                        icon: Icon(Icons.arrow_drop_down, color: dropdownIconColor),
                        items: List.generate(8, (index) => index + 1)
                            .map((value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text(
                            'Semester $value',
                            style: TextStyle(color: dropdownMenuItemColor, fontSize: 14),
                          ),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            currentSemester = value ?? 1;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: currentCgpaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Current CGPA',
                          labelStyle: TextStyle(color: labelColor, fontSize: 14, fontWeight: FontWeight.w500),
                          hintText: '0.0',
                          hintStyle: TextStyle(color: widget.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400),
                          filled: true,
                          fillColor: fillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: buttonColor, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        style: TextStyle(color: inputTextColor, fontSize: 14),
                        cursorColor: cursorColor,
                        onTap: () {
                          if (currentCgpaController.text == '0.0') {
                            currentCgpaController.clear();
                          }
                        },
                        onChanged: (value) {
                          setState(() {
                            double gpa = double.tryParse(value) ?? -1;
                            if (gpa < 0.0 || gpa > 4.0) {
                              currentCgpaController.text = '';
                              currentCgpa = 0.0;
                            } else {
                              currentCgpa = gpa;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(widget.isDarkMode ? 51 : 25),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target CGPA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: targetCgpaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Target CGPA',
                          labelStyle: TextStyle(color: labelColor, fontSize: 14, fontWeight: FontWeight.w500),
                          hintText: '0.0',
                          hintStyle: TextStyle(color: widget.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400),
                          filled: true,
                          fillColor: fillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: buttonColor, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        style: TextStyle(color: inputTextColor, fontSize: 14),
                        cursorColor: cursorColor,
                        onTap: () {
                          if (targetCgpaController.text == '0.0') {
                            targetCgpaController.clear();
                          }
                        },
                        onChanged: (value) {
                          setState(() {
                            double gpa = double.tryParse(value) ?? -1;
                            if (gpa < 0.0 || gpa > 4.0) {
                              targetCgpaController.text = '';
                              targetCgpa = 0.0;
                            } else {
                              targetCgpa = gpa;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    key: _calculateButtonKey,
                    onPressed: calculateRequiredCGPA,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: buttonHoverColor,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 2,
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    child: Text('Calculate Required GPA', style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(height: 10),
                if (requiredGpaResult.isNotEmpty)
                  Container(
                    key: _requiredGpaKey,
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(widget.isDarkMode ? 52 : 25),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      requiredGpaResult,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(widget.isDarkMode ? 52 : 25),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Semester Subjects',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: subjects,
                        decoration: InputDecoration(
                          labelText: 'Number of Subjects',
                          labelStyle: TextStyle(color: labelColor, fontSize: 14, fontWeight: FontWeight.w500),
                          filled: true,
                          fillColor: fillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: buttonColor, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        dropdownColor: widget.isDarkMode ? Colors.grey.shade700 : Colors.white,
                        icon: Icon(Icons.arrow_drop_down, color: dropdownIconColor),
                        items: List.generate(8, (index) => index + 1)
                            .map((value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text(
                            '$value',
                            style: TextStyle(color: dropdownMenuItemColor, fontSize: 14),
                          ),
                        ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) updateSubjectLists(value);
                        },
                      ),
                      SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 5.0,
                          headingRowColor: WidgetStateColor.resolveWith((states) => headingRowColor),
                          headingTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          dataRowColor: WidgetStateColor.resolveWith((states) => dataRowColor),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: tableBorderColor, width: 1),
                          ),
                          columns: [
                            DataColumn(label: Text('Subject')),
                            DataColumn(label: Text('Credits')),
                          ],
                          rows: List.generate(subjects, (index) {
                            return DataRow(cells: [
                              DataCell(
                                SizedBox(
                                  width: 120,
                                  child: TextFormField(
                                    controller: subjectControllers[index],
                                    decoration: InputDecoration(
                                      hintText: 'Subject ${index + 1}',
                                      hintStyle: TextStyle(color: Colors.grey.shade400),
                                      filled: true,
                                      fillColor: fillColor,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: borderColor),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: borderColor),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: buttonColor, width: 2),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    style: TextStyle(color: inputTextColor, fontSize: 14),
                                    cursorColor: cursorColor,
                                    onChanged: (value) {
                                      setState(() {
                                        subjectList[index] = value.isEmpty ? 'Subject ${index + 1}' : value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 80,
                                  child: DropdownButtonFormField<int>(
                                    value: creditList[index],
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      filled: true,
                                      fillColor: fillColor,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: borderColor),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: borderColor),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: buttonColor, width: 2),
                                      ),
                                    ),
                                    dropdownColor: widget.isDarkMode ? Colors.grey.shade700 : Colors.white,
                                    icon: Icon(Icons.arrow_drop_down, color: dropdownIconColor),
                                    items: creditHoursOptions.map((int value) {
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        child: Center(
                                          child: Text(
                                            '$value',
                                            style: TextStyle(color: dropdownMenuItemColor, fontSize: 14),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          creditList[index] = value;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ]);
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: calculateRequiredGPAForSubjects,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: buttonHoverColor,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 2,
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    child: Text('Check All Possibilities', style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(height: 20),
                if (showOutputTable)
                  Container(
                    key: _resultSectionKey,
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(widget.isDarkMode ? 52 : 25),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Possible GPA Distribution',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 35.0,
                            headingRowColor: WidgetStateColor.resolveWith((states) => headingRowColor),
                            headingTextStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            dataRowColor: WidgetStateColor.resolveWith((states) => dataRowColor),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: tableBorderColor, width: 1),
                            ),
                            columns: [
                              DataColumn(label: Text('Subject')),
                              DataColumn(label: Text('Credits')),
                              DataColumn(label: Text('GPA')),
                            ],
                            rows: List.generate(subjects, (index) {
                              return DataRow(cells: [
                                DataCell(
                                  Text(
                                    subjectList[index],
                                    style: TextStyle(color: textColor, fontSize: 14),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    creditList[index].toString(),
                                    style: TextStyle(color: textColor, fontSize: 14),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    randomGpaList[index].toStringAsFixed(2),
                                    style: TextStyle(color: textColor, fontSize: 14),
                                  ),
                                ),
                              ]);
                            }),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Next Semester GPA: ${calculateSemesterGpa(randomGpaList, creditList).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Actual CGPA: ${calculateActualCGPA().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          _getResultMessage(),
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: widget.isDarkMode ? Colors.amberAccent : Colors.purple.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}