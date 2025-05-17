import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ContactPage extends StatefulWidget {
  final bool isDarkMode;

  const ContactPage({super.key, required this.isDarkMode});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

  final GlobalKey _nameFieldKey = GlobalKey();
  final GlobalKey _emailFieldKey = GlobalKey();
  final GlobalKey _messageFieldKey = GlobalKey();
  final GlobalKey _sendButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          backgroundColor: isError
              ? (widget.isDarkMode ? Colors.redAccent : Colors.red.shade600)
              : (widget.isDarkMode ? Colors.amber.shade600 : Colors.teal.shade600),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

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
        top: position.dy - 40,
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

  bool _validateForm() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty && email.isEmpty && message.isEmpty) {
      _showFieldOverlay(
        message: 'All fields are required',
        fieldKey: _sendButtonKey,
      );
      return false;
    }

    if (name.isEmpty || name.trim().isEmpty) {
      _showFieldOverlay(
        message: 'Please enter your name',
        fieldKey: _nameFieldKey,
      );
      return false;
    }

    if (email.isEmpty) {
      _showFieldOverlay(
        message: 'Please enter your email',
        fieldKey: _emailFieldKey,
      );
      return false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showFieldOverlay(
        message: 'Please enter a valid email',
        fieldKey: _emailFieldKey,
      );
      return false;
    }

    if (message.isEmpty) {
      _showFieldOverlay(
        message: 'Please enter your message',
        fieldKey: _messageFieldKey,
      );
      return false;
    }

    return true;
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: widget.isDarkMode ? _darkModeDialogBg : _lightModeDialogBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Confirm Send',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to send this email?',
            style: TextStyle(
              color: widget.isDarkMode ? _darkModeDialogText : _lightModeDialogText,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: widget.isDarkMode ? _darkModeCancelButton : _lightModeCancelButton,
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: widget.isDarkMode ? _darkModeCancelButton : _lightModeCancelButton,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: widget.isDarkMode ? _darkModeConfirmButton : _lightModeConfirmButton,
                backgroundColor: widget.isDarkMode
                    ? _darkModeConfirmButton.withAlpha(26)
                    : _lightModeConfirmButton.withAlpha(26),
              ),
              child: Text(
                'Send',
                style: TextStyle(
                  color: widget.isDarkMode ? _darkModeConfirmButton : _lightModeConfirmButton,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _sendEmailConfirmed();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendEmail() async {
    if (_isSending || !_validateForm()) return;
    await _showConfirmationDialog();
  }

  Future<void> _sendEmailConfirmed() async {
    setState(() {
      _isSending = true;
    });

    final smtpServer = gmail('asadullah.devop@gmail.com', 'kovk ftov cqkv gqps');

    final messageToAdmin = Message()
      ..from = Address(_emailController.text, _nameController.text)
      ..recipients.add('asadullah.devop@gmail.com')
      ..subject = 'Contact Request from CGPA App'
      ..text = '''
Name: ${_nameController.text}
Email: ${_emailController.text}
Message: ${_messageController.text}
''';

    final messageToUser = Message()
      ..from = const Address('asadullah.devop@gmail.com', 'CGPA App Support')
      ..recipients.add(_emailController.text)
      ..subject = 'Thank You for Contacting CGPA App Support'
      ..replyTo = const Address('asadullah.devop@gmail.com', 'CGPA App Support')
      ..html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Thank You for Contacting Us</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
  <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
    <h2 style="color: #2c3e50;">Thank You for Contacting Us!</h2>
    <p>Dear ${_nameController.text},</p>
    <p>We’ve received your message through the CGPA App contact form. Our team is reviewing it and will respond to you shortly at ${_emailController.text}. Thank you for reaching out!</p>
    
    <h3 style="color: #2c3e50;">Your Message Details:</h3>
    <ul style="list-style-type: none; padding: 0;">
      <li><strong>Email:</strong> ${_emailController.text}</li>
      <li><strong>Message:</strong> ${_messageController.text}</li>
    </ul>
    
    <p>For urgent inquiries, please reply to this email or contact us directly.</p>
    <p>Best regards,<br>CGPA App Support Team</p>
    
    <hr style="border: 0; border-top: 1px solid #eee;">
    <p style="font-size: 12px; color: #777;">
      This is an automated confirmation. If you no longer wish to receive these emails, 
      <a href="mailto:asadullah.devop@gmail.com?subject=Unsubscribe">click here to unsubscribe</a>.
      © 2025 CGPA App. All rights reserved.
    </p>
  </div>
</body>
</html>
''';

    try {
      await send(messageToAdmin, smtpServer);
      await send(messageToUser, smtpServer);
      _showSnackBar('Email sent successfully! Check your inbox for confirmation.');
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
    } catch (e) {
      _showSnackBar('Failed to send email: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBarGradient = widget.isDarkMode
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
    final backgroundGradient = widget.isDarkMode
        ? LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.grey.shade900, Colors.grey.shade800],
    )
        : LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.grey.shade50, Colors.grey.shade100],
    );
    final textColor = widget.isDarkMode ? Colors.white : Colors.grey.shade700;
    final primaryTextColor =
    widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade800;
    final accentColor =
    widget.isDarkMode ? Colors.amberAccent : Colors.blue.shade600;
    final cardColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.white;
    final iconBackgroundColor = widget.isDarkMode
        ? Colors.amber.shade100.withAlpha(51)
        : Colors.blue.shade100.withAlpha(128);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appBarGradient),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We\'d Love to Hear From You',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                        shadows: [
                          Shadow(
                            color: accentColor.withAlpha(77),
                            offset: const Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Feel free to reach out with any questions or inquiries',
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: iconBackgroundColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: accentColor.withAlpha(51),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.email,
                                    color: accentColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  'Email Us',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: widget.isDarkMode
                                        ? Colors.white
                                        : Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              key: _nameFieldKey,
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Your Name',
                                labelStyle: TextStyle(color: textColor),
                                filled: true,
                                fillColor: iconBackgroundColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: accentColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              key: _emailFieldKey,
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Your Email',
                                labelStyle: TextStyle(color: textColor),
                                filled: true,
                                fillColor: iconBackgroundColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: accentColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              key: _messageFieldKey,
                              controller: _messageController,
                              decoration: InputDecoration(
                                labelText: 'Your Message',
                                labelStyle: TextStyle(color: textColor),
                                filled: true,
                                fillColor: iconBackgroundColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: accentColor),
                                ),
                              ),
                              maxLines: 5,
                            ),
                            const SizedBox(height: 25),
                            Center(
                              child: ElevatedButton(
                                key: _sendButtonKey,
                                onPressed: _isSending ? null : _sendEmail,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  shadowColor: accentColor.withAlpha(102),
                                ),
                                child: _isSending
                                    ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Text(
                                  'Send Message',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            '© 2025 All Rights Reserved',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension on Message {
  set replyTo(Address replyTo) {}
}