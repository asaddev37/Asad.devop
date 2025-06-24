# Email Server for Smart Complaint System

This is a simple Node.js email server that sends real emails when users are added to the Smart Complaint System.

## Quick Setup

### Prerequisites
- Node.js installed on your computer
- Gmail account with app password

### Installation

1. **Navigate to the email-server directory:**
   ```bash
   cd email-server
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Start the server:**
   ```bash
   npm start
   ```

The server will start on `http://localhost:3000`

### Testing the Server

1. **Health check:**
   ```bash
   curl http://localhost:3000/health
   ```
   Should return: `{"status":"OK","message":"Email server is running"}`

2. **Test email sending:**
   ```bash
   curl -X POST http://localhost:3000/send-email \
     -H "Content-Type: application/json" \
     -d '{
       "to": "test@example.com",
       "name": "Test User",
       "role": "student",
       "username": "test@example.com",
       "password": "password123",
       "studentId": "BCS-01",
       "batch": "FA22-BSE-037",
       "uniqueId": "test-123"
     }'
   ```

## Configuration

The server uses your Gmail credentials:
- Email: `masadullah373737@gmail.com`
- Password: `tyqmoxgrnxxwkxeu` (app password)

To change these, edit the `server.js` file:

```javascript
const transporter = nodemailer.createTransporter({
  service: 'gmail',
  auth: {
    user: 'your-email@gmail.com',
    pass: 'your-app-password'
  }
});
```

## How it Works

1. The Flutter app sends a POST request to `http://localhost:3000/send-email`
2. The server uses Nodemailer to send the email via Gmail SMTP
3. The email includes HTML and text versions with account details
4. The server returns success/failure response

## Troubleshooting

### Common Issues:

1. **"Invalid login" error:**
   - Make sure you're using an app password, not your regular Gmail password
   - Enable 2-factor authentication on your Gmail account
   - Generate a new app password

2. **"Connection refused" error:**
   - Make sure the server is running on port 3000
   - Check if another service is using port 3000
   - Try a different port and update the Flutter app

3. **CORS errors:**
   - The server includes CORS middleware
   - If you still get CORS errors, check your browser console

4. **Emails not received:**
   - Check spam folder
   - Verify the recipient email address
   - Check server logs for errors

### Server Logs

The server logs all email sending attempts. Watch the console for:
- `Email sent successfully: [messageId]` - Email was sent
- `Error sending email: [error]` - Email failed to send

## Development

To run in development mode with auto-restart:
```bash
npm run dev
```

## Production Deployment

For production, you can deploy this server to:
- Heroku
- Vercel
- Railway
- Your own server

Remember to:
1. Update the Flutter app to use your production server URL
2. Set environment variables for email credentials
3. Enable HTTPS for security

## Security Notes

- Never commit email passwords to version control
- Use environment variables in production
- Consider rate limiting for email sending
- Validate email addresses before sending 