import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'database_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await DatabaseHelper().getResults();
      setState(() {
        _history = history;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading history: $e', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFFF6F61),
        ),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _clearHistory() async {
    setState(() => isLoading = true);
    try {
      await DatabaseHelper().clearResults();
      setState(() {
        _history = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('History cleared successfully!', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFF00695C),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing history: $e', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFFF6F61),
        ),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BMI History',
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
          isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00695C)))
              : _history.isEmpty
              ? Center(
            child: FadeIn(
              duration: const Duration(milliseconds: 500),
              child: Text(
                'No history yet!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _history.length,
            itemBuilder: (context, index) {
              final result = _history[index];
              return FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: Duration(milliseconds: 100 * index),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4DB6AC), Color(0xFF80CBC4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        'BMI: ${result['bmi'].toStringAsFixed(1)}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        'Weight: ${result['weight']} kg, Age: ${result['age']}, Gender: ${result['gender']}\n'
                            'Saved on: ${DateTime.parse(result['timestamp']).toLocal().toString().split('.')[0]}',
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (_history.isNotEmpty && !isLoading)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: FadeInUp(
                  child: ElevatedButton.icon(
                    onPressed: _clearHistory,
                    icon: const Icon(Icons.delete, size: 24),
                    label: Text(
                      'Clear History',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F61),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}