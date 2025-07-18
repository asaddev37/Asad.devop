import 'dart:io';
import 'lib/services/pdf_service.dart';
import 'lib/services/csv_service.dart';

void main() async {
  print('Testing PDF and CSV Export Services...\n');

  // Test data
  final testStudents = [
    {
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'phone_no': '+1234567890',
      'student_id': 'STU001',
      'batch': {'batch_name': 'CS-2024'},
      'created_at': '2024-01-15T10:30:00Z',
    },
    {
      'name': 'Jane Smith',
      'email': 'jane.smith@example.com',
      'phone_no': '+1234567891',
      'student_id': 'STU002',
      'batch': {'batch_name': 'CS-2024'},
      'created_at': '2024-01-16T11:30:00Z',
    },
  ];

  final testAdvisors = [
    {
      'name': 'Dr. Advisor One',
      'email': 'advisor1@example.com',
      'batch': {'batch_name': 'CS-2024'},
      'created_at': '2024-01-10T09:00:00Z',
    },
  ];

  final testComplaints = [
    {
      'student': {'name': 'John Doe', 'email': 'john.doe@example.com'},
      'batch': {'batch_name': 'CS-2024'},
      'subject': 'Network Issue',
      'description': 'Cannot connect to WiFi',
      'status': 'Resolved',
      'created_at': '2024-01-20T14:00:00Z',
      'resolved_at': '2024-01-21T10:00:00Z',
    },
  ];

  final testBatches = [
    {
      'batch_name': 'CS-2024',
      'advisor': {'name': 'Dr. Advisor One'},
      'students': [
        {'count': 25}
      ],
      'created_at': '2024-01-01T08:00:00Z',
    },
  ];

  try {
    // Test CSV Generation
    print('1. Testing CSV Generation...');

    final studentsCsv = await CsvService.generateStudentsCSV(testStudents);
    print('✓ Students CSV generated (${studentsCsv.length} characters)');

    final advisorsCsv = await CsvService.generateAdvisorsCSV(testAdvisors);
    print('✓ Advisors CSV generated (${advisorsCsv.length} characters)');

    final complaintsCsv =
        await CsvService.generateComplaintsCSV(testComplaints);
    print('✓ Complaints CSV generated (${complaintsCsv.length} characters)');

    final allDataCsv = await CsvService.generateAllDataCSV(
      students: testStudents,
      advisors: testAdvisors,
      complaints: testComplaints,
      batches: testBatches,
    );
    print('✓ All Data CSV generated (${allDataCsv.length} characters)');

    // Test CSV Download
    print('\n2. Testing CSV Download...');
    try {
      await CsvService.downloadCSV(studentsCsv, 'test_students.csv');
      print('✓ Students CSV downloaded successfully');
    } catch (e) {
      print('⚠ Students CSV download failed: $e');
    }

    // Test PDF Generation
    print('\n3. Testing PDF Generation...');

    try {
      await PDFService.generateStudentsPDF(
        students: testStudents,
        departmentName: 'Computer Science',
      );
      print('✓ Students PDF generated successfully');
    } catch (e) {
      print('⚠ Students PDF generation failed: $e');
    }

    try {
      await PDFService.generateAdvisorsPDF(
        advisors: testAdvisors,
        batches: testBatches,
        departmentName: 'Computer Science',
      );
      print('✓ Advisors PDF generated successfully');
    } catch (e) {
      print('⚠ Advisors PDF generation failed: $e');
    }

    try {
      await PDFService.generateComplaintsPDF(
        complaints: testComplaints,
        departmentName: 'Computer Science',
      );
      print('✓ Complaints PDF generated successfully');
    } catch (e) {
      print('⚠ Complaints PDF generation failed: $e');
    }

    try {
      await PDFService.generateAllDataPDF(
        students: testStudents,
        advisors: testAdvisors,
        complaints: testComplaints,
        batches: testBatches,
        departmentName: 'Computer Science',
      );
      print('✓ All Data PDF generated successfully');
    } catch (e) {
      print('⚠ All Data PDF generation failed: $e');
    }

    print('\n✅ All tests completed!');
    print(
        '\nNote: Files are saved in the Reports folder in your app\'s documents directory.');
    print('Check the console output above for specific file paths.');
  } catch (e, stackTrace) {
    print('❌ Test failed with error: $e');
    print('Stack trace: $stackTrace');
  }
}
