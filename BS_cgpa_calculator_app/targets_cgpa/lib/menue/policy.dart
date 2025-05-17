import 'package:flutter/material.dart';

class PolicyScreen extends StatelessWidget {
  final bool isDarkMode;

  const PolicyScreen({super.key, required this.isDarkMode,}) ;

  @override
  Widget build(BuildContext context) {
    // Define color schemes for dark and light modes
    final backgroundGradient = isDarkMode
        ? LinearGradient(
      colors: [Colors.grey.shade900, Colors.grey.shade800],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : LinearGradient(
      colors: [Colors.grey.shade50, Colors.grey.shade100],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final appBarGradient = isDarkMode
        ? LinearGradient(
      colors: [Colors.grey.shade800, Colors.grey.shade700],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : LinearGradient(
      colors: [Colors.blue.shade800, Colors.blue.shade600],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final textColor = isDarkMode ? Colors.white : Colors.blue.shade900;
    final tableHeaderColor = isDarkMode ? Colors.grey.shade700 : Colors.blue.shade600;
    final tableRowColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final tableBorderColor = isDarkMode ? Colors.amberAccent : Colors.blue.shade400;
    final buttonColor = isDarkMode ? Colors.amberAccent : Colors.blue.shade600;
    final iconColor = isDarkMode ? Colors.amberAccent : Colors.black;

    // Policy data with percentage ranges from your earlier "GRADE DISTRIBUTION"
    final List<Map<String, dynamic>> policyData = [
      {'marks': '>= 85', 'percentage': '85-100', 'gpa': 4.00, 'grade': 'A'},
      {'marks': '>= 80', 'percentage': '80-84.99', 'gpa': 3.66, 'grade': 'A-'},
      {'marks': '>= 75', 'percentage': '75-79.99', 'gpa': 3.33, 'grade': 'B+'},
      {'marks': '>= 71', 'percentage': '71-74.99', 'gpa': 3.00, 'grade': 'B'},
      {'marks': '>= 68', 'percentage': '68-70.99', 'gpa': 2.66, 'grade': 'B-'},
      {'marks': '>= 64', 'percentage': '64-67.99', 'gpa': 2.33, 'grade': 'C+'},
      {'marks': '>= 61', 'percentage': '61-63.99', 'gpa': 2.00, 'grade': 'C'},
      {'marks': '>= 58', 'percentage': '58-60.99', 'gpa': 1.66, 'grade': 'C-'},
      {'marks': '>= 54', 'percentage': '54-57.99', 'gpa': 1.33, 'grade': 'D+'},
      {'marks': '>= 50', 'percentage': '50-53.99', 'gpa': 1.00, 'grade': 'D'},
      {'marks': '< 50', 'percentage': '0-49.99', 'gpa': 0.00, 'grade': 'F'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'COMSATS Grading Policy',
          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appBarGradient),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context), // Navigate back to home
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Grading Policy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 15,
                  headingRowColor: WidgetStateColor.resolveWith((states) => tableHeaderColor),
                  dataRowColor: WidgetStateColor.resolveWith((states) => tableRowColor),
                  decoration: BoxDecoration(
                    border: Border.all(color: tableBorderColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        'Marks Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Percentage',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'GPA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Grade',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  rows: policyData.map((data) {
                    return DataRow(cells: [
                      DataCell(
                        Center(
                          child: Text(
                            data['marks'],
                            style: TextStyle(fontSize: 14, color: textColor),
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(
                            data['percentage'],
                            style: TextStyle(fontSize: 14, color: textColor),
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(
                            data['gpa'].toStringAsFixed(2),
                            style: TextStyle(fontSize: 14, color: textColor),
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(
                            data['grade'],
                            style: TextStyle(fontSize: 14, color: textColor),
                          ),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 10,
                ),
                child: Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20), // Extra space at the bottom
            ],
          ),
        ),
      ),
    );
  }
}