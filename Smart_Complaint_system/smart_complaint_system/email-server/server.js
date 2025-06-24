const express = require('express');
const nodemailer = require('nodemailer');
const cors = require('cors');
const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Create transporter
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'masadullah373737@gmail.com',
    pass: 'tyqmoxgrnxxwkxeu' // Your app password
  }
});

// Email sending endpoint
app.post('/send-email', async (req, res) => {
  try {
    const { to, name, role, username, password, studentId, batch, uniqueId } = req.body;

    // Create email HTML
    const emailHtml = `
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
                  <p>Dear ${name},</p>
                  
                  <p>Your account for Smart Complaint System has been set up as a ${role}.</p>
                  
                  <div style="background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0;">
                      <h3 style="margin-top: 0;">Login Credentials:</h3>
                      <p><strong>Email:</strong> ${username}</p>
                      <p><strong>Password:</strong> ${password}</p>
                      ${batch ? `<p><strong>Batch:</strong> ${batch}</p>` : ''}
                      ${studentId ? `<p><strong>Student ID:</strong> ${studentId}</p>` : ''}
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
    `;

    // Email options
    const mailOptions = {
      from: 'masadullah373737@gmail.com',
      to: to,
      subject: `Smart Complaint System - Account Setup (${uniqueId})`,
      html: emailHtml,
      text: `
Hello ${name},

Your account for Smart Complaint System has been set up as a ${role}.

Login Credentials:
Email: ${username}
Password: ${password}
${batch ? `Batch: ${batch}\n` : ''}
${studentId ? `Student ID: ${studentId}\n` : ''}

Please log in to update your password and access the system.
Contact us at masadullah373737@gmail.com for assistance.

Best regards,
Smart Complaint System Team

© 2025 Smart Complaint System. All rights reserved.
      `
    };

    // Send email
    const info = await transporter.sendMail(mailOptions);
    
    console.log('Email sent successfully:', info.messageId);
    res.json({ success: true, messageId: info.messageId });
    
  } catch (error) {
    console.error('Error sending email:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Email server is running' });
});

// Start server
app.listen(port, () => {
  console.log(`Email server running at http://localhost:${port}`);
  console.log('Available endpoints:');
  console.log('  POST /send-email - Send account setup email');
  console.log('  GET  /health     - Health check');
}); 