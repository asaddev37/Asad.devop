import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

void main() async {
  print('Testing SMTP email functionality...');

  try {
    // Test SMTP configuration
    final smtpEmail = 'masadullah373737@gmail.com';
    final smtpPassword = 'tyqmoxgrnxxwkxeu';

    print('Creating SMTP server...');
    final smtpServer = gmail(smtpEmail, smtpPassword);

    print('Creating test message...');
    final message = Message()
      ..from = Address(smtpEmail, 'Smart Complaint System Test')
      ..recipients.add('test@example.com') // Replace with your test email
      ..subject = 'SMTP Test Email'
      ..text =
          'This is a test email to verify SMTP functionality is working correctly.';

    print('Sending test email...');
    final sendReport = await send(message, smtpServer);

    print('Email sent successfully!');
    print('Message ID: ${sendReport.toString()}');
  } catch (e) {
    print('Error sending email: $e');
  }
}
