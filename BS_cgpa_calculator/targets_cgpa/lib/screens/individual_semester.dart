import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

class IndividualSemesterScreen extends StatefulWidget {
  final bool isDarkMode;

  const IndividualSemesterScreen({super.key, required this.isDarkMode});

  @override
  State<IndividualSemesterScreen> createState() => _IndividualSemesterScreenState();
}

class _IndividualSemesterScreenState extends State<IndividualSemesterScreen> {
  int subjects = 1;
  int selectedSemester = 1;
  List<String> subjectList = [];
  List<int> creditList = [];
  List<double> gpaList = [];
  List<double> marksList = [];
  double cgpa = 0.0;
  String gpaMessage = '';
  bool isComsatsPolicyEnabled = false;

  final List<int> creditHoursOptions = List.generate(6, (index) => index + 1);
  final List<int> semesterOptions = List.generate(8, (index) => index + 1);
  List<TextEditingController> inputControllers = [];
  List<TextEditingController> subjectNameControllers = []; // For subject names
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _gpaSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    updateSubjectLists(subjects);
  }

  void updateSubjectLists(int newSubjectCount) {
    setState(() {
      subjects = newSubjectCount;

      // Dispose old controllers
      for (var controller in subjectNameControllers) {
        controller.dispose();
      }
      for (var controller in inputControllers) {
        controller.dispose();
      }

      // Regenerate lists
      subjectList = List.generate(subjects, (index) => '');
      creditList = List.generate(subjects, (index) => 1);
      gpaList = List.generate(subjects, (index) => 0.0);
      marksList = List.generate(subjects, (index) => 0.0);
      subjectNameControllers = List.generate(subjects, (index) => TextEditingController(text: ''));
      inputControllers = List.generate(subjects, (index) => TextEditingController(text: ''));

      debugPrint("Subject List: $subjectList");
      debugPrint("Input Controllers Length: ${inputControllers.length}");
    });
  }


  double convertMarksToGPA(double marks) {
    if (marks >= 85) return 4.00;
    if (marks >= 80) return 3.66;
    if (marks >= 75) return 3.33;
    if (marks >= 71) return 3.00;
    if (marks >= 68) return 2.66;
    if (marks >= 64) return 2.33;
    if (marks >= 61) return 2.00;
    if (marks >= 58) return 1.66;
    if (marks >= 54) return 1.33;
    if (marks >= 50) return 1.00;
    return 0.00;
  }

  void calculateCGPA() async {
    if (creditList.isEmpty || gpaList.isEmpty) return;

    double totalCredits = creditList.reduce((a, b) => a + b).toDouble();
    double weightedSum = 0.0;

    for (int i = 0; i < subjects; i++) {
      weightedSum += gpaList[i] * creditList[i];
    }

    setState(() {
      cgpa = totalCredits > 0 ? weightedSum / totalCredits : 0.0;

      if (cgpa < 2.0) {
        gpaMessage = 'Don’t give up! Every step forward counts—keep pushing!';
      } else if (cgpa >= 2.0 && cgpa < 2.5) {
        gpaMessage = 'Solid effort! You’re on the right track—keep it up!';
      } else if (cgpa >= 2.5 && cgpa < 3.0) {
        gpaMessage = 'Great work! You’re building a strong foundation!';
      } else if (cgpa >= 3.0 && cgpa < 3.3) {
        gpaMessage = 'Impressive! You’re excelling—aim even higher!';
      } else if (cgpa >= 3.3 && cgpa < 3.5) {
        gpaMessage = 'Outstanding! You’re a star in the making!';
      } else if (cgpa >= 3.5 && cgpa < 3.7) {
        gpaMessage = 'Fantastic! Your dedication is shining through!';
      } else if (cgpa >= 3.7) {
        gpaMessage = 'Exceptional! You’re at the top—keep soaring!';
      } else {
        gpaMessage = '';
      }
    });

    final prefs = await SharedPreferences.getInstance();
    final isHistoryEnabled = prefs.getBool('isHistoryEnabled') ?? true;

    if (isHistoryEnabled && cgpa > 0.0) {
      await _saveToHistory();
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox = _gpaSectionKey.currentContext?.findRenderObject() as RenderBox?;
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

  Future<void> _saveToHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isHistoryEnabled') ?? true) {
      final db = await DatabaseService.database;
      await db.insert('individual_semester_history', {
        'semester': 'Semester $selectedSemester',
        'subjects': subjectList.join(','),
        'credits': creditList.join(','),
        'grades': gpaList.map((gpa) => gpa.toStringAsFixed(2)).join(','),
        'cgpa': cgpa,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void resetFields() {
    setState(() {
      // Reset the selected semester to 1
      selectedSemester = 1;

      // Reset the number of subjects to 1
      subjects = 1;

      // Dispose old controllers
      for (var controller in subjectNameControllers) {
        controller.dispose();
      }
      for (var controller in inputControllers) {
        controller.dispose();
      }

      // Clear the lists
      subjectList.clear();
      creditList.clear();
      gpaList.clear();
      marksList.clear();
      subjectNameControllers.clear();
      inputControllers.clear();

      // Regenerate the subject lists and controllers
      subjectList = List.generate(subjects, (index) => '');
      creditList = List.generate(subjects, (index) => 1);
      gpaList = List.generate(subjects, (index) => 0.0);
      marksList = List.generate(subjects, (index) => 0.0);
      subjectNameControllers = List.generate(subjects, (index) => TextEditingController(text: ''));
      inputControllers = List.generate(subjects, (index) => TextEditingController(text: ''));

      // Reset CGPA and GPA message
      cgpa = 0.0;
      gpaMessage = '';
    });
  }

  String? validateInput(String? value, bool isMarks) {
    if (value == null || value.isEmpty) return null;

    if (isMarks) {
      double marks = double.tryParse(value) ?? -1;
      if (marks < 0 || marks > 100) {
        return 'Marks must be between 0 and 100';
      }
    } else {
      double gpa = double.tryParse(value) ?? -1;
      if (gpa < 0.0 || gpa > 4.0) {
        return 'GPA must be between 0.0 and 4.0';
      }
    }
    return null;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      colors: [Colors.blue.shade800, Colors.blue.shade600],
    );

    final textColor = widget.isDarkMode ? Colors.white : Colors.grey.shade800;
    final labelColor = widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade700;
    final fillColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50;
    final borderColor = widget.isDarkMode ? Colors.grey.shade600 : Colors.blue.shade200;
    final headingRowColor = widget.isDarkMode ? Colors.grey.shade600 : Colors.blue.shade700;
    final dataRowColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.white;
    final buttonColor = widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade700;
    final buttonHoverColor = widget.isDarkMode ? Colors.amber.shade700 : Colors.blue.shade600;
    final iconColor = widget.isDarkMode ? Colors.amberAccent : Colors.white;
    final dropdownMenuItemColor = widget.isDarkMode ? Colors.white : Colors.grey.shade800;
    final cursorColor = widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade700;
    final dropdownIconColor = widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade700;
    final inputTextColor = widget.isDarkMode ? Colors.white : Colors.grey.shade800;
    final containerColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.white;
    final tableBorderColor = widget.isDarkMode ? Colors.grey.shade600 : Colors.blue.shade300;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Individual Semester GPA',
          style: TextStyle(
            fontSize: 18,
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
            tooltip: 'Reset First Subject',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'COMSATS Policy',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          Switch(
                            value: isComsatsPolicyEnabled,
                            onChanged: (value) {
                              setState(() {
                                isComsatsPolicyEnabled = value;
                                for (var controller in inputControllers) {
                                  controller.clear();
                                }
                                gpaList = List.generate(subjects, (index) => 0.0);
                                marksList = List.generate(subjects, (index) => 0.0);
                              });
                            },
                            activeColor: buttonColor,
                            inactiveTrackColor: widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Toggle to use COMSATS grading system (marks-based)',
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
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
                        'Semester Selection',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: selectedSemester,
                        decoration: InputDecoration(
                          labelText: 'Select Semester',
                          labelStyle: TextStyle(
                            color: labelColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
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
                        items: semesterOptions
                            .map((value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text(
                            'Semester $value',
                            style: TextStyle(
                              color: dropdownMenuItemColor,
                              fontSize: 14,
                            ),
                          ),
                        ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedSemester = value;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Number of Subjects',
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
                          labelText: 'Select Subjects',
                          labelStyle: TextStyle(
                            color: labelColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
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
                            style: TextStyle(
                              color: dropdownMenuItemColor,
                              fontSize: 14,
                            ),
                          ),
                        ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) updateSubjectLists(value);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
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
                  child: SingleChildScrollView(
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
                        DataColumn(label: Text(isComsatsPolicyEnabled ? 'Marks' : 'GPA')),
                      ],
                      rows: List.generate(subjects, (index) {
                        return DataRow(cells: [
                          DataCell(
                            SizedBox(
                              width: 120,
                              child: TextFormField(
                                controller: subjectNameControllers[index], // Use subject name controller
                                decoration: InputDecoration(
                                  hintText: 'Subject ${index + 1}',
                                  hintStyle: TextStyle(
                                      color: widget.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400),
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
                                    subjectList[index] = value; // Update subject name in the list
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
                          DataCell(
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                controller: inputControllers[index], // Use marks controller
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: isComsatsPolicyEnabled ? '0' : '0.0',
                                  hintStyle: TextStyle(
                                      color: widget.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400),
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
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.red.shade400),
                                  ),
                                  errorText: validateInput(inputControllers[index].text, isComsatsPolicyEnabled),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                style: TextStyle(color: inputTextColor, fontSize: 14),
                                cursorColor: cursorColor,
                                onChanged: (value) {
                                  setState(() {
                                    if (isComsatsPolicyEnabled) {
                                      double marks = double.tryParse(value) ?? 0.0;
                                      if (marks < 0 || marks > 100) {
                                        marksList[index] = 0.0;
                                        gpaList[index] = 0.0;
                                        inputControllers[index].text = '0';
                                      } else {
                                        marksList[index] = marks;
                                        gpaList[index] = convertMarksToGPA(marks);
                                      }
                                    } else {
                                      double gpa = double.tryParse(value) ?? 0.0;
                                      if (value.isEmpty || (gpa >= 0.0 && gpa <= 4.0)) {
                                        gpaList[index] = gpa;
                                      } else {
                                        gpaList[index] = 0.0;
                                        inputControllers[index].text = '';
                                      }
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                        ]);
                      }),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: calculateCGPA,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: buttonHoverColor,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 2,
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    child: Text('Calculate GPA', style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  key: _gpaSectionKey,
                  width: double.infinity,
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
                    children: [
                      Text(
                        'Semester GPA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        cgpa.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: buttonColor,
                        ),
                      ),
                      if (gpaMessage.isNotEmpty) ...[
                        SizedBox(height: 12),
                        Text(
                          gpaMessage,
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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