# Quick EmailJS Setup Guide

## Step 1: Sign up for EmailJS
1. Go to https://www.emailjs.com/
2. Click "Sign Up" and create a free account
3. Verify your email address

## Step 2: Create Email Service
1. In EmailJS dashboard, go to "Email Services"
2. Click "Add New Service"
3. Choose "Gmail" as your email service
4. Enter your Gmail credentials:
   - Email: masadullah373737@gmail.com
   - Password: tyqmoxgrnxxwkxeu (your app password)
5. Click "Create Service"
6. **Copy the Service ID** (it looks like: service_abc123)

## Step 3: Create Email Template
1. Go to "Email Templates"
2. Click "Create New Template"
3. Name it "Account Setup"
4. Use this template content:

**Subject:**
```
Smart Complaint System - Account Setup
```

**HTML Content:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>Smart Complaint System - Account Setup</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
    <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="text-align: center; border-bottom: 2px solid #0054a6; padding-bottom: 10px;">
            <h1 style="color: #0054a6; margin: 0;">Smart Complaint System</h1>
        </div>
        
        <div style="padding: 20px 0;">
            <p>Dear {{to_name}},</p>
            
            <p>Your account for Smart Complaint System has been set up as a {{role}}.</p>
            
            <div style="background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0;">
                <h3 style="margin-top: 0;">Login Credentials:</h3>
                <p><strong>Email:</strong> {{username}}</p>
                <p><strong>Password:</strong> {{password}}</p>
                {{#if batch}}<p><strong>Batch:</strong> {{batch}}</p>{{/if}}
                {{#if student_id}}<p><strong>Student ID:</strong> {{student_id}}</p>{{/if}}
            </div>
            
            <p>Please log in to update your password and access the system.</p>
            
            <p>If you have any questions, please contact us at masadullah373737@gmail.com</p>
            
            <p>Best regards,<br>Smart Complaint System Team</p>
        </div>
        
        <div style="text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; font-size: 12px; color: #666;">
            <p>© 2025 Smart Complaint System. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
```

5. Click "Save"
6. **Copy the Template ID** (it looks like: template_abc123)

## Step 4: Get Your User ID
1. Go to "Account" in EmailJS dashboard
2. **Copy your Public Key** (it looks like: user_abc123)

## Step 5: Update the Code
Replace the placeholder values in `lib/services/email_service.dart`:

```dart
// Replace these lines in the EmailService class:
static const String _emailjsServiceId = 'YOUR_SERVICE_ID_HERE'; // e.g., service_abc123
static const String _emailjsTemplateId = 'YOUR_TEMPLATE_ID_HERE'; // e.g., template_abc123
static const String _emailjsUserId = 'YOUR_USER_ID_HERE'; // e.g., user_abc123
```

## Step 6: Test
1. Run your Flutter app
2. Add a new user (student or batch advisor)
3. Try to send an email
4. Check the recipient's email inbox

## Troubleshooting

### If emails don't send:
1. Check browser console for errors
2. Verify all IDs are correct
3. Make sure your Gmail app password is correct
4. Check if emails are in spam folder

### Common Issues:
- **CORS errors**: EmailJS handles this automatically
- **Authentication errors**: Double-check your Gmail credentials
- **Template errors**: Make sure template variables match the code

## Alternative: Use Gmail API (More Advanced)

If EmailJS doesn't work, you can also set up Gmail API:

1. Go to Google Cloud Console
2. Create a new project
3. Enable Gmail API
4. Create credentials (API key)
5. Use the Gmail API to send emails

## Support

- EmailJS Documentation: https://www.emailjs.com/docs/
- Gmail API Documentation: https://developers.google.com/gmail/api
- For help: Check the main EMAIL_SETUP.md file

## Quick Test

After setup, you should see:
- "Email sent successfully!" message (not "Simulated")
- Real emails in the recipient's inbox
- No more "Socket constructor" errors 