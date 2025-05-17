import 'package:flutter/material.dart';
import '../widgets/input_field.dart';
import '../widgets/result_display.dart';
import 'database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentTargetCGPAScreen extends StatefulWidget {
  final bool isDarkMode;

 const CurrentTargetCGPAScreen({super.key,required this.isDarkMode});

  @override
  State<CurrentTargetCGPAScreen> createState() => _CurrentTargetCGPAScreenState();
}

class _CurrentTargetCGPAScreenState extends State<CurrentTargetCGPAScreen> {
  String errorMessage = '';
  String gpaMessage = '';
  int targetSemester = 1;
  int numPreviousSemesters = 0;
  double totalCgpa = 0.0;
  int totalCreditHours = 0;
  double currentCgpa = 0.0;
  double targetCgpa = 0.0;
  double requiredCgpa = 0.0;

  final List<int> semesterChoices = List.generate(8, (index) => index + 1);
  final int fixedCreditHours = 4;

  List<double> semesterCgpaValues = [];
  List<TextEditingController> semesterControllers = [];
  List<String?> semesterErrors = [];

  final TextEditingController targetCgpaController = TextEditingController(text: '0.0');
  String? targetCgpaError;

  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultSectionKey = GlobalKey();
  final GlobalKey _calculateCurrentCgpaButtonKey = GlobalKey();

  bool isCurrentCgpaCalculated = false;
  OverlayEntry? _overlayEntry;

  // Define the overlay colors as static constants
  static const Color _lightModeErrorBg = Colors.black45; // Soft red background
  static const Color _lightModeErrorText = Colors.white; // Deep red text
  static const Color _darkModeErrorBg = Colors.white30;  // Dark red background
  static const Color _darkModeErrorText = Colors.black; // Light red text

  @override
  void initState() {
    super.initState();
    updateSemesterList(targetSemester);
  }

  void updateSemesterList(int newSemester) {
    setState(() {
      targetSemester = newSemester;
      numPreviousSemesters = targetSemester - 1;

      if (semesterCgpaValues.length != numPreviousSemesters) {
        if (semesterCgpaValues.length < numPreviousSemesters) {
          semesterCgpaValues.addAll(
              List.filled(numPreviousSemesters - semesterCgpaValues.length, 0.0));
        } else {
          semesterCgpaValues = List.from(semesterCgpaValues.sublist(0, numPreviousSemesters));
        }
      }

      if (semesterControllers.length != numPreviousSemesters) {
        if (semesterControllers.length > numPreviousSemesters) {
          for (int i = numPreviousSemesters; i < semesterControllers.length; i++) {
            semesterControllers[i].dispose();
          }
          semesterControllers = List.from(semesterControllers.sublist(0, numPreviousSemesters));
        } else {
          semesterControllers.addAll(List.generate(
            numPreviousSemesters - semesterControllers.length,
                (index) => TextEditingController(text: '0.0'),
          ));
        }
      }

      if (semesterErrors.length != numPreviousSemesters) {
        if (semesterErrors.length < numPreviousSemesters) {
          semesterErrors
              .addAll(List.filled(numPreviousSemesters - semesterErrors.length, null));
        } else {
          semesterErrors = List.from(semesterErrors.sublist(0, numPreviousSemesters));
        }
      }
    });
  }

  void calculateCurrentCGPA() {
    if (semesterCgpaValues.isEmpty) return;

    bool isValid = true;
    for (int i = 0; i < numPreviousSemesters; i++) {
      double gpa = double.tryParse(semesterControllers[i].text) ?? -1;
      setState(() {
        if (gpa < 0.0 || gpa > 4.0) {
          semesterControllers[i].text = '';
          semesterCgpaValues[i] = 0.0;
          isValid = false;
        } else {
          semesterCgpaValues[i] = gpa;
        }
      });
    }

    if (!isValid) return;

    setState(() {
      totalCreditHours = numPreviousSemesters * fixedCreditHours;
      totalCgpa = semesterCgpaValues
          .take(numPreviousSemesters)
          .fold(0.0, (sum, cgpa) => sum + cgpa * fixedCreditHours);
      currentCgpa = totalCreditHours > 0 ? totalCgpa / totalCreditHours : 0.0;
      isCurrentCgpaCalculated = true;
      errorMessage = '';
    });
  }

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

  Future<void> calculateRequiredCGPA() async {
    if (!isCurrentCgpaCalculated) {
      _showFieldOverlay(
        message: 'Please calculate your current cgpa first',
        fieldKey: _calculateCurrentCgpaButtonKey,
        duration: Duration(seconds: 2),
      );
      return;
    }

    double gpa = double.tryParse(targetCgpaController.text) ?? -1;
    setState(() {
      if (gpa < 0.0 || gpa > 4.0) {
        targetCgpaController.text = '';
        targetCgpa = 0.0;
        return;
      } else {
        targetCgpa = gpa;
      }
    });

    setState(() {
      int totalTargetCreditHours = targetSemester * fixedCreditHours;
      requiredCgpa = (targetCgpa * totalTargetCreditHours - totalCgpa) / fixedCreditHours;
      if (requiredCgpa < 0) requiredCgpa = 0;

      if (requiredCgpa >= 4.0) {
        gpaMessage = 'Wow, your target is incredibly ambitious! Aim for the stars!';
      } else if (requiredCgpa > 3.0 && requiredCgpa < 4.0) {
        gpaMessage = 'Best of luck with your target CGPA! You’ve got this!';
      } else if (requiredCgpa <= 3.0 && requiredCgpa > 0) {
        gpaMessage = 'Keep pushing forward—your goal is within reach!';
      } else {
        gpaMessage = '';
      }

      errorMessage = '';
    });

    var nextSemesterCreditHours = fixedCreditHours;
    List<double> semesterGpas = List.from(semesterCgpaValues);

    if (requiredCgpa > 0.00) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final isHistoryEnabled = prefs.getBool('isHistoryEnabled') ?? true;

        if (isHistoryEnabled) {
          await saveTargetCgpaHistory(
            currentCgpa: currentCgpa,
            targetCgpa: targetCgpa,
            remainingCredits: nextSemesterCreditHours,
            requiredGpa: requiredCgpa,
            semesterGpas: semesterGpas,
            targetSemester: targetSemester,
          );

          if (context.mounted) {
            if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Calculation saved to history!',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                backgroundColor: Colors.teal.shade600,
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
      } catch (e) {
        setState(() {
          errorMessage = 'Failed to save history. Please try again.';
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox = _resultSectionKey.currentContext?.findRenderObject() as RenderBox?;
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

  void resetFields() {
    setState(() {
      targetSemester = 1;
      numPreviousSemesters = 0;
      totalCgpa = 0.0;
      totalCreditHours = 0;
      currentCgpa = 0.0;
      targetCgpa = 0.0;
      requiredCgpa = 0.0;
      semesterCgpaValues = [];
      for (var controller in semesterControllers) {
        controller.dispose();
      }
      semesterControllers = [];
      semesterErrors = [];
      targetCgpaController.text = '0.0';
      targetCgpaError = null;
      isCurrentCgpaCalculated = false;
      errorMessage = '';
      gpaMessage = '';
    });
    updateSemesterList(1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var controller in semesterControllers) {
      controller.dispose();
    }
    targetCgpaController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  String? validatePreviousSemesterGPA(String? value) {
    if (value == null || value.isEmpty) return null;
    double gpa = double.tryParse(value) ?? -1;
    if (gpa < 0.0 || gpa > 4.0) {
      return null; // No error message, handled in onChanged
    }
    return null;
  }

  String? validateTargetCGPA(String? value) {
    if (!isCurrentCgpaCalculated) return null;
    if (value == null || value.isEmpty) return null;
    double gpa = double.tryParse(value) ?? -1;
    if (gpa < 0.0 || gpa > 4.0) {
      return null; // No error message, handled in onChanged
    }
    return null;
  }

  Future<void> saveTargetCgpaHistory({
    required double currentCgpa,
    required double targetCgpa,
    required int remainingCredits,
    required double requiredGpa,
    required List<double> semesterGpas,
    required int targetSemester,
  }) async {
    final db = await DatabaseService.database;
    try {
      final result = await db.insert('current_target_cgpa_history', {
        'current_cgpa': currentCgpa,
        'target_cgpa': targetCgpa,
        'remaining_credits': remainingCredits,
        'required_gpa': requiredGpa,
        'semester_gpas': semesterGpas.isNotEmpty ? semesterGpas.join(',') : null,
        'target_semester': targetSemester,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ History saved with ID: $result');
    } catch (e) {
      debugPrint('❌ Error saving history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundGradient = widget.isDarkMode
        ? LinearGradient(
      colors: [Colors.grey.shade900, Colors.grey.shade800],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : LinearGradient(
      colors: [Colors.grey.shade50, Colors.blueGrey.shade50],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final appBarGradient = widget.isDarkMode
        ? LinearGradient(
      colors: [Colors.grey.shade800, Colors.grey.shade700],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : LinearGradient(
      colors: [Colors.teal.shade700, Colors.teal.shade500],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final textColor = widget.isDarkMode ? Colors.white : Colors.blueGrey.shade800;
    final labelColor = widget.isDarkMode ? Colors.amberAccent : Colors.teal.shade700;
    final fillColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.teal.shade50;
    final borderColor = widget.isDarkMode ? Colors.amberAccent : Colors.teal.shade200;
    final buttonColor = widget.isDarkMode ? Colors.amberAccent : Colors.teal.shade600;
    final buttonHoverColor = widget.isDarkMode ? Colors.amberAccent : Colors.teal.shade700;
    final iconColor = widget.isDarkMode ? Colors.amberAccent : Colors.white;
    final dropdownMenuItemColor = widget.isDarkMode ? Colors.white : Colors.blueGrey.shade700;
    final cursorColor = widget.isDarkMode ? Colors.amberAccent : Colors.teal.shade700;
    final dropdownIconColor = widget.isDarkMode ? Colors.amberAccent : Colors.teal.shade700;
    final inputTextColor = widget.isDarkMode ? Colors.white : Colors.blueGrey.shade700;
    final containerColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Current & Target CGPA',
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
            tooltip: 'Reset Fields',
          ),
        ],
        elevation: 4,
      ),
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: backgroundGradient)),
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
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
                          'Target Semester',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: targetSemester,
                          decoration: InputDecoration(
                            labelText: 'Select Target Semester',
                            labelStyle: TextStyle(
                                color: labelColor, fontSize: 14, fontWeight: FontWeight.w500),
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
                          items: semesterChoices.map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(
                                'Semester $value',
                                style: TextStyle(color: dropdownMenuItemColor, fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              updateSemesterList(value);
                            }
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
                          'Previous Semesters GPA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: numPreviousSemesters,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: TextFormField(
                                controller: semesterControllers[index],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'GPA for Semester ${index + 1}',
                                  labelStyle: TextStyle(
                                      color: labelColor, fontSize: 14, fontWeight: FontWeight.w500),
                                  hintText: '0.0',
                                  hintStyle: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.grey.shade500
                                          : Colors.grey.shade400),
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
                                  contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                style: TextStyle(color: inputTextColor, fontSize: 14),
                                cursorColor: cursorColor,
                                onTap: () {
                                  if (semesterControllers[index].text == '0.0') {
                                    semesterControllers[index].clear();
                                  }
                                },
                                onChanged: (value) {
                                  setState(() {
                                    double gpa = double.tryParse(value) ?? -1;
                                    if (gpa < 0.0 || gpa > 4.0) {
                                      semesterControllers[index].text = '';
                                      semesterCgpaValues[index] = 0.0;
                                    } else {
                                      semesterCgpaValues[index] = gpa;
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      key: _calculateCurrentCgpaButtonKey,
                      onPressed: calculateCurrentCGPA,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: buttonHoverColor,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 2,
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      child: Text('Calculate Current CGPA', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
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
                          'Current CGPA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          currentCgpa.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: buttonColor,
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
                            labelStyle: TextStyle(
                                color: labelColor, fontSize: 14, fontWeight: FontWeight.w500),
                            hintText: '0.0',
                            hintStyle: TextStyle(
                                color: widget.isDarkMode
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade400),
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
                              errorMessage = '';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
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
                  SizedBox(height: 20),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        errorMessage,
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.redAccent : Colors.red.shade700,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(height: 20),
                  Container(
                    key: _resultSectionKey,
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
                        Text.rich(
                          TextSpan(
                            text: 'Required GPA in Semester $targetSemester: ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                            children: [
                              TextSpan(
                                text: requiredCgpa.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: buttonColor,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (gpaMessage.isNotEmpty) ...[
                          SizedBox(height: 12),
                          Text(
                            gpaMessage,
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: widget.isDarkMode
                                  ? Colors.tealAccent.shade400
                                  : Colors.teal.shade600,
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
          ),
        ],
      ),
    );
  }
}