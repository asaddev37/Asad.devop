import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static const String _smtpEmail = '@gmail.com';
  static const String _smtpPassword =
      ''; // App-specific password
  static const String _appName = 'Smart Complaint System';

  static const Color _lightModeErrorBg = Colors.black45;
  static const Color _lightModeErrorText = Colors.white;
  static const Color _darkModeErrorBg = Colors.white30;
  static const Color _darkModeErrorText = Colors.black;
  static const Color _lightModeDialogBg = Colors.white;
  static const Color _lightModeDialogText = Colors.grey;
  static const Color _lightModeConfirmButton = Colors.blue;
  static const Color _lightModeCancelButton = Colors.grey;
  static const Color _darkModeDialogBg = Color(0xFF424242);
  static const Color _darkModeDialogText = Colors.white70;
  static const Color _darkModeConfirmButton = Colors.amber;
  static const Color _darkModeCancelButton = Colors.grey;
  static final Logger _logger = Logger('EmailService');

  static bool get isConfigured =>
      _smtpEmail.isNotEmpty && _smtpPassword.isNotEmpty;

  static void _setupLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  static String _getEmailTemplate({
    required String name,
    required String role,
    required String username,
    required String password,
    String? studentId,
    String? batch,
    required bool isDarkMode,
    required String uniqueId,
    required bool isUpdate,
  }) {
    final actionText = isUpdate ? 'updated' : 'set up';
    final subjectText = isUpdate ? 'Account Updated' : 'Account Setup';

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$_appName - $subjectText</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.5;
            color: ${isDarkMode ? '#ffffff' : '#333333'};
            max-width: 600px;
            margin: 0 auto;
            padding: 15px;
            background-color: ${isDarkMode ? '#1a1a1a' : '#f9f9f9'};
        }
        .container {
            background-color: ${isDarkMode ? '#2d2d2d' : '#ffffff'};
            padding: 15px;
            border-radius: 6px;
        }
        .header {
            text-align: center;
            padding-bottom: 10px;
            border-bottom: 1px solid #0054a6;
        }
        .header h1 {
            color: #0054a6;
            font-size: 22px;
            margin: 0;
        }
        .content p {
            margin: 8px 0;
        }
        .credentials {
            background-color: ${isDarkMode ? '#3c3c3c' : '#f5f5f5'};
            padding: 10px;
            border-radius: 4px;
            margin: 10px 0;
        }
        .footer {
            text-align: center;
            margin-top: 15px;
            font-size: 11px;
            color: ${isDarkMode ? '#aaaaaa' : '#666666'};
        }
        a {
            color: #0054a6;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>$_appName</h1>
        </div>
        <div class="content">
            <p>Dear $name,</p>
            <p>Your account for $_appName has been $actionText as a $role.</p>
            <div class="credentials">
                <p><strong>Email:</strong> $username</p>
                <p><strong>Password:</strong> $password</p>
                ${batch != null ? '<p><strong>Batch:</strong> $batch</p>' : ''}
                ${studentId != null ? '<p><strong>Student ID:</strong> $studentId</p>' : ''}
            </div>
            <p>Log in to update your password and access the system.</p>
            <p>Contact us at <a href="mailto:$_smtpEmail">$_smtpEmail</a> for assistance.</p>
            <p>Best regards,<br>$_appName Team</p>
        </div>
        <div class="footer">
            <p>© 2025 $_appName. All rights reserved.</p>
            <p><a href="mailto:$_smtpEmail?subject=Unsubscribe-$uniqueId">Unsubscribe</a> | <a href="#">Privacy Policy</a></p>
        </div>
    </div>
</body>
</html>
    ''';
  }

  static String _getPlainTextTemplate({
    required String name,
    required String role,
    required String username,
    required String password,
    String? studentId,
    String? batch,
    required String uniqueId,
    required bool isUpdate,
  }) {
    final actionText = isUpdate ? 'updated' : 'set up';

    return '''
Hello $name,

Your account for $_appName has been $actionText as a $role.

Login Credentials:
Email: $username
Password: $password
${batch != null ? 'Batch: $batch\n' : ''}
${studentId != null ? 'Student ID: $studentId\n' : ''}

Log in to update your password and access the system.
Contact us at $_smtpEmail for assistance.

Best regards,
$_appName Team

© 2025 $_appName. All rights reserved.
To unsubscribe, reply to this email with "Unsubscribe-$uniqueId" in the subject.
    ''';
  }

  static Future<void> sendCredentials({
    required BuildContext context,
    required String toEmail,
    required String name,
    required String role,
    required String username,
    required String password,
    String? studentId,
    String? batch,
    required bool isDarkMode,
    bool isUpdate = false,
  }) async {
    try {
      _setupLogging();
      if (!EmailValidator.validate(toEmail)) {
        _logger.warning('Invalid email address: $toEmail');
        _showSnackBar(
          context,
          'Invalid email address',
          isError: true,
          isDarkMode: isDarkMode,
        );
        return;
      }

      final confirmed =
          await _showConfirmationDialog(context, isDarkMode, isUpdate);
      if (!confirmed) {
        _logger.info('Email sending cancelled by user for $toEmail');
        return;
      }

      final uniqueId = Uuid().v4();

      // Show loading indicator
      if (context.mounted) {
        _showSnackBar(
          context,
          'Sending email...',
          isDarkMode: isDarkMode,
        );
      }

      final emailSent = await _sendViaSMTP(
        toEmail: toEmail,
        name: name,
        role: role,
        username: username,
        password: password,
        studentId: studentId,
        batch: batch,
        uniqueId: uniqueId,
        isUpdate: isUpdate,
      );

      if (context.mounted) {
        _showSnackBar(
          context,
          emailSent
              ? 'Email sent successfully!'
              : 'Failed to send email. Please try again.',
          isError: !emailSent,
          isDarkMode: isDarkMode,
        );
      }

      // Increased delay to prevent rapid sending
      await Future.delayed(Duration(seconds: 1));
    } catch (e) {
      _logger.severe('Failed to send email to $toEmail: $e');
      if (context.mounted) {
        _showSnackBar(
          context,
          'Failed to send email: $e',
          isError: true,
          isDarkMode: isDarkMode,
        );
      }
    }
  }

  static Future<bool> _sendViaSMTP({
    required String toEmail,
    required String name,
    required String role,
    required String username,
    required String password,
    String? studentId,
    String? batch,
    required String uniqueId,
    required bool isUpdate,
  }) async {
    try {
      // Create Gmail SMTP server
      final smtpServer = gmail(_smtpEmail, _smtpPassword);

      final actionText = isUpdate ? 'updated' : 'set up';
      final subjectText = isUpdate ? 'Account Updated' : 'Account Setup';

      // Create message
      final message = Message()
        ..from = Address(_smtpEmail, _appName)
        ..recipients.add(toEmail)
        ..subject = '$_appName - $subjectText ($uniqueId)'
        ..html = _getEmailTemplate(
          name: name,
          role: role,
          username: username,
          password: password,
          studentId: studentId,
          batch: batch,
          isDarkMode: false,
          uniqueId: uniqueId,
          isUpdate: isUpdate,
        )
        ..text = _getPlainTextTemplate(
          name: name,
          role: role,
          username: username,
          password: password,
          studentId: studentId,
          batch: batch,
          uniqueId: uniqueId,
          isUpdate: isUpdate,
        );

      // Send the message
      final sendReport = await send(message, smtpServer);

      _logger.info('Email sent successfully to $toEmail via SMTP');
      _logger.info('Message ID: ${sendReport.toString()}');

      return true;
    } catch (e) {
      _logger.severe('SMTP error: $e');
      return false;
    }
  }

  static Future<bool> _showConfirmationDialog(
    BuildContext context,
    bool isDarkMode,
    bool isUpdate,
  ) async {
    final actionText = isUpdate ? 'update' : 'send';
    final subjectText = isUpdate ? 'Account Update' : 'Account Setup';

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor:
                isDarkMode ? _darkModeDialogBg : _lightModeDialogBg,
            title: Text(
              'Confirm Email $subjectText',
              style: TextStyle(
                color: isDarkMode ? _darkModeDialogText : _lightModeDialogText,
              ),
            ),
            content: Text(
              'Do you want to $actionText an email with the account credentials?',
              style: TextStyle(
                color: isDarkMode ? _darkModeDialogText : _lightModeDialogText,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isDarkMode
                        ? _darkModeCancelButton
                        : _lightModeCancelButton,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? _darkModeConfirmButton
                      : _lightModeConfirmButton,
                ),
                child: Text(
                  isUpdate ? 'Send Update Email' : 'Send Email',
                  style: TextStyle(
                    color: isDarkMode ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isDarkMode = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? (isDarkMode ? _darkModeErrorBg : _lightModeErrorBg)
            : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }
}
