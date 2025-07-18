import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sqflite/sqflite.dart';
import 'history.dart';
import 'database_helper.dart';
import 'loading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().initDatabase();
  runApp(const BMICalculatorApp());
}

class BMICalculatorApp extends StatelessWidget {
  const BMICalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BMI Calculator',
      theme: ThemeData(
        primaryColor: const Color(0xFF00695C), // Deep Teal
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Off-white
        textTheme: GoogleFonts.poppinsTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF00695C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 2,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
      ),
      home: const LoadingScreen(),
    );
  }
}

class BMICalculatorHomeScreen extends StatefulWidget {
  const BMICalculatorHomeScreen({super.key});

  @override
  _BMICalculatorHomeScreenState createState() => _BMICalculatorHomeScreenState();
}

class _BMICalculatorHomeScreenState extends State<BMICalculatorHomeScreen> {
  String selectedGender = 'Male';
  double heightCm = 180.0;
  int weight = 74;
  int age = 19;
  bool isLoading = false;

  String? _validateInputs() {
    if (weight < 20 || weight > 200) {
      return 'Weight must be between 20 and 200 kg';
    }
    if (heightCm < 60 || heightCm > 220) {
      return 'Height must be between 60 and 220 cm';
    }
    if (age < 1 || age > 100) {
      return 'Age must be between 1 and 100 years';
    }
    return null;
  }

  void _calculateBMI() {
    final validationError = _validateInputs();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError, style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFFF6F61), // Coral
        ),
      );
      return;
    }
    double heightM = heightCm / 100;
    double bmi = weight / (heightM * heightM);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ResultScreen(
          bmi: bmi,
          weight: weight,
          age: age,
          gender: selectedGender,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HistoryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BMI Calculator',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF00695C),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00695C), Color(0xFF4DB6AC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _navigateToHistory,
            tooltip: 'View History',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: Card(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4DB6AC), Color(0xFF80CBC4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.all(16), // Reduced padding
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cardWidth = (constraints.maxWidth - 20) / 2; // Calculate dynamic width
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            SizedBox(
                            width: cardWidth,
                            child: _buildGenderCard('Male', Icons.male, const Color(0xFF00695C)),
                            ),
                              SizedBox(
                              width: cardWidth,
                              child: _buildGenderCard('Female', Icons.female, const Color(0xFFFF6F61)),
                            ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: _buildSliderCard(
                    title: 'Height',
                    value: '${heightCm.toStringAsFixed(0)} cm',
                    sliderValue: heightCm,
                    min: 60.0,
                    max: 220.0,
                    onChanged: (value) => setState(() => heightCm = value),
                  ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  duration: const Duration(milliseconds: 700),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = (constraints.maxWidth - 20) / 2;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: _buildInputCard(
                              title: 'Age',
                              value: age,
                              min: 1,
                              max: 100,
                              onChanged: (value) => setState(() => age = value.round()),
                              onIncrement: () => setState(() => age < 100 ? age++ : null),
                              onDecrement: () => setState(() => age > 1 ? age-- : null),
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _buildInputCard(
                              title: 'Weight',
                              value: weight,
                              min: 20,
                              max: 200,
                              onChanged: (value) => setState(() => weight = value.round()),
                              onIncrement: () => setState(() => weight < 200 ? weight++ : null),
                              onDecrement: () => setState(() => weight > 20 ? weight-- : null),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: FadeInUp(
                    child: ElevatedButton.icon(
                      onPressed: _calculateBMI,
                      icon: const Icon(Icons.calculate, size: 24),
                      label: Text(
                        'Calculate BMI',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 60),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF00695C)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGenderCard(String gender, IconData icon, Color iconColor) {
    return GestureDetector(
      onTap: () => setState(() => selectedGender = gender),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: selectedGender == gender ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectedGender == gender ? iconColor : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: iconColor),
            const SizedBox(height: 10),
            Text(
              gender,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderCard({
    required String title,
    required String value,
    required double sliderValue,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4DB6AC), Color(0xFF80CBC4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Slider(
              value: sliderValue,
              min: min,
              max: max,
              activeColor: const Color(0xFF00695C),
              inactiveColor: Colors.grey[300],
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String title,
    required int value,
    required int min,
    required int max,
    required ValueChanged<double> onChanged,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4DB6AC), Color(0xFF80CBC4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              '$value',
              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              activeColor: const Color(0xFF00695C),
              inactiveColor: Colors.grey[300],
              onChanged: onChanged,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Color(0xFF00695C)),
                  onPressed: onDecrement,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF00695C)),
                  onPressed: onIncrement,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatefulWidget {
  final double bmi;
  final int weight;
  final int age;
  final String gender;

  const ResultScreen({
    super.key,
    required this.bmi,
    required this.weight,
    required this.age,
    required this.gender,
  });

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _showResetDialog = false;
  bool isLoading = false;

  void _showResetDialogBox() {
    setState(() {
      _showResetDialog = true;
    });
  }

  void _resetData() {
    if (Navigator.canPop(context)) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
    setState(() {
      _showResetDialog = false;
    });
  }

  Future<void> _saveResult() async {
    setState(() => isLoading = true);
    try {
      await DatabaseHelper().insertResult({
        'bmi': widget.bmi,
        'weight': widget.weight,
        'age': widget.age,
        'gender': widget.gender,
        'timestamp': DateTime.now().toIso8601String(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Result saved successfully!', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFF00695C),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving result: $e', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFFF6F61),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String bmiCategory = widget.bmi < 18.5
        ? 'Underweight'
        : widget.bmi < 25
        ? 'Normal'
        : widget.bmi < 30
        ? 'Overweight'
        : 'Obese';
    String advice = widget.bmi < 18.5
        ? 'The best way to gain weight is through a balanced diet with more calories.'
        : widget.bmi < 25
        ? 'You are at a healthy weight! Keep maintaining a balanced diet and exercise.'
        : 'The best way to lose weight is through a combination of diet and exercise.';
    Color categoryColor = widget.bmi < 18.5
        ? Colors.blue
        : widget.bmi < 25
        ? Colors.green
        : widget.bmi < 30
        ? Colors.orange
        : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BMI Result',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF00695C),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00695C), Color(0xFF4DB6AC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    'Your Result',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00695C),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Card(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4DB6AC), Color(0xFF80CBC4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            bmiCategory.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              color: categoryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.bmi.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'kg/m²',
                            style: GoogleFonts.poppins(fontSize: 20, color: Colors.black87),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.withOpacity(0.8),
                                  Colors.green.withOpacity(0.8),
                                  Colors.orange.withOpacity(0.8),
                                  Colors.red.withOpacity(0.8),
                                ],
                                stops: [0.0, 0.4625, 0.625, 1.0],
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: (widget.bmi.clamp(0, 40) / 40) * (MediaQuery.of(context).size.width - 80),
                                  child: Container(
                                    width: 4,
                                    height: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          FadeInUp(
                            child: ElevatedButton.icon(
                              onPressed: _saveResult,
                              icon: const Icon(Icons.save, size: 24),
                              label: Text(
                                'Save Result',
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Advice: $advice',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: const Color(0xFFFF6F61),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeInUp(
                  duration: const Duration(milliseconds: 700),
                  child: FadeInUp(
                    child: ElevatedButton.icon(
                      onPressed: _showResetDialogBox,
                      icon: const Icon(Icons.refresh, size: 24),
                      label: Text(
                        'Re-Calculate BMI',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 60),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showResetDialog)
            Center(
              child: FadeIn(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Reset BMI Data?',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00695C),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _resetData,
                            child: Text(
                              'Yes',
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => setState(() => _showResetDialog = false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[400],
                            ),
                            child: Text(
                              'No',
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF00695C)),
              ),
            ),
        ],
      ),
    );
  }
}