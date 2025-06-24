# Email Setup Guide for Smart Complaint System

## Overview
The Smart Complaint System has been updated to be web-compatible and avoid the "Socket constructor" error that occurs when using the `mailer` package in Flutter web applications.

## Current Implementation
The current email service simulates email sending for demonstration purposes. In production, you'll need to implement one of the following solutions:

## Option 1: EmailJS (Recommended for Web)

### Setup Steps:
1. **Sign up for EmailJS** at https://www.emailjs.com/
2. **Create an Email Service**:
   - Go to Email Services
   - Add your Gmail account
   - Use the provided SMTP credentials
3. **Create an Email Template**:
   - Go to Email Templates
   - Create a new template with variables: `{{to_name}}`, `{{role}}`, `{{username}}`, `{{password}}`, `{{student_id}}`, `{{batch}}`
4. **Get your credentials**:
   - Service ID
   - Template ID
   - User ID (Public Key)

### Update the Code:
Replace the placeholder values in `lib/services/email_service.dart`:

```dart
const String emailjsServiceId = 'your-actual-service-id';
const String emailjsTemplateId = 'your-actual-template-id';
const String emailjsUserId = 'your-actual-user-id';
```

### Usage:
Call `sendCredentialsViaEmailJS()` instead of `sendCredentials()`.

## Option 2: Backend API

### Setup Steps:
1. **Create a backend server** (Node.js, Python, etc.)
2. **Implement an email endpoint** that accepts POST requests
3. **Use a server-side email library** like Nodemailer (Node.js) or smtplib (Python)

### Example Node.js Backend:
```javascript
const express = require('express');
const nodemailer = require('nodemailer');
const app = express();

app.use(express.json());

app.post('/send-email', async (req, res) => {
  const { to, subject, name, role, username, password, studentId, batch } = req.body;
  
  const transporter = nodemailer.createTransporter({
    service: 'gmail',
    auth: {
      user: 'your-email@gmail.com',
      pass: 'your-app-password'
    }
  });

  const mailOptions = {
    from: 'your-email@gmail.com',
    to: to,
    subject: subject,
    html: `Your email template here with ${name}, ${role}, etc.`
  };

  try {
    await transporter.sendMail(mailOptions);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

### Update the Code:
Replace the API URL in `lib/services/email_service.dart`:

```dart
const String apiUrl = 'https://your-backend-domain.com/send-email';
```

### Usage:
Call `sendCredentialsViaAPI()` instead of `sendCredentials()`.

## Option 3: Supabase Edge Functions

### Setup Steps:
1. **Create a Supabase Edge Function**:
```bash
supabase functions new send-email
```

2. **Implement the function** in `supabase/functions/send-email/index.ts`:
```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { SmtpClient } from "https://deno.land/x/smtp/mod.ts";

serve(async (req) => {
  const { to, name, role, username, password, studentId, batch } = await req.json();
  
  const client = new SmtpClient();
  
  await client.connectTLS({
    hostname: "smtp.gmail.com",
    port: 587,
    username: Deno.env.get("SMTP_USERNAME"),
    password: Deno.env.get("SMTP_PASSWORD"),
  });
  
  await client.send({
    from: Deno.env.get("SMTP_USERNAME"),
    to: to,
    subject: "Smart Complaint System - Account Setup",
    content: `Your email content here...`,
  });
  
  await client.close();
  
  return new Response(JSON.stringify({ success: true }), {
    headers: { "Content-Type": "application/json" },
  });
});
```

3. **Deploy the function**:
```bash
supabase functions deploy send-email
```

### Update the Code:
Replace the API URL in `lib/services/email_service.dart`:

```dart
const String apiUrl = 'https://your-project.supabase.co/functions/v1/send-email';
```

## Option 4: SendGrid API

### Setup Steps:
1. **Sign up for SendGrid** at https://sendgrid.com/
2. **Create an API key**
3. **Verify your sender email**

### Implementation:
Add SendGrid API calls to the email service:

```dart
static Future<void> sendCredentialsViaSendGrid({
  required BuildContext context,
  required String toEmail,
  required String name,
  required String role,
  required String username,
  required String password,
  String? studentId,
  String? batch,
  required bool isDarkMode,
}) async {
  const String sendgridApiKey = 'your-sendgrid-api-key';
  
  final response = await http.post(
    Uri.parse('https://api.sendgrid.com/v3/mail/send'),
    headers: {
      'Authorization': 'Bearer $sendgridApiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'personalizations': [
        {
          'to': [{'email': toEmail, 'name': name}],
          'subject': 'Smart Complaint System - Account Setup',
        }
      ],
      'from': {'email': 'your-verified-email@domain.com', 'name': 'Smart Complaint System'},
      'content': [
        {
          'type': 'text/html',
          'value': 'Your email HTML content here...',
        }
      ],
    }),
  );
  
  // Handle response...
}
```

## Security Considerations

1. **Never expose API keys in client-side code**
2. **Use environment variables** for sensitive data
3. **Implement rate limiting** on your backend
4. **Validate email addresses** before sending
5. **Use HTTPS** for all API calls

## Testing

1. **Test with real email addresses** in development
2. **Check spam folders** for test emails
3. **Verify email templates** render correctly
4. **Test error handling** with invalid emails

## Migration from Current Implementation

To switch from the current simulation to real email sending:

1. Choose one of the options above
2. Update the email service configuration
3. Replace `sendCredentials()` calls with the appropriate method
4. Test thoroughly before deploying

## Troubleshooting

### Common Issues:
- **CORS errors**: Ensure your backend allows requests from your Flutter app domain
- **Authentication errors**: Verify API keys and credentials
- **Rate limiting**: Implement delays between email sends
- **Template errors**: Check email template syntax and variables

### Debug Tips:
- Check browser console for network errors
- Verify API endpoints are accessible
- Test email templates separately
- Monitor email service logs

## Support

For issues with specific email services:
- **EmailJS**: https://www.emailjs.com/docs/
- **SendGrid**: https://sendgrid.com/docs/
- **Supabase**: https://supabase.com/docs/guides/functions
- **Gmail SMTP**: https://support.google.com/mail/answer/7126229 