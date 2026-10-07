# Firebase Authentication Email Templates Configuration

Firebase Authentication hosts and delivers email verification, password reset, and email change confirmation messages. These templates are configured inside the **Firebase Console**.

This guide provides instructions and ready-to-use HTML/text templates to update your templates to match a professional production design.

---

## 1. How to Configure in Firebase Console

1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Select your project: **smart-complaint-analyzer**.
3. In the left-hand sidebar, navigate to **Build** -> **Authentication**.
4. Click on the **Templates** tab at the top.
5. Choose the template you wish to edit (e.g., **Email verification**).
6. Click the edit (pencil) icon:
   * **Sender name**: Change `project-173491852504` (or legacy default) to:
     ```text
     Smart Complaint Analyzer Team
     ```
   * **Sender reply-to**: Set your support email address:
     ```text
     complaints-support@klnce.edu
     ```
   * **Subject**: Set the subject line:
     ```text
     Verify your email for Smart Complaint Analyzer
     ```
7. Click **Save** after making changes.

---

## 2. Professional HTML Email Template (Verify Email)

Copy and paste the following HTML structure into the **Template body** field:

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Verify your Email - Smart Complaint Analyzer</title>
  <style>
    body {
      font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
      background-color: #f4f6f8;
      margin: 0;
      padding: 0;
      -webkit-font-smoothing: antialiased;
    }
    .wrapper {
      width: 100%;
      background-color: #f4f6f8;
      padding: 40px 0;
    }
    .container {
      max-width: 600px;
      margin: 0 auto;
      background-color: #ffffff;
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
    }
    .header {
      background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
      padding: 30px;
      text-align: center;
    }
    .header h1 {
      color: #ffffff;
      margin: 0;
      font-size: 24px;
      font-weight: 700;
      letter-spacing: 0.5px;
    }
    .content {
      padding: 40px 30px;
      color: #333333;
      line-height: 1.6;
    }
    .content h2 {
      font-size: 20px;
      margin-top: 0;
      color: #1e3c72;
    }
    .btn-container {
      text-align: center;
      margin: 35px 0;
    }
    .btn {
      background: linear-gradient(135deg, #2a5298 0%, #1e3c72 100%);
      color: #ffffff !important;
      padding: 14px 30px;
      text-decoration: none;
      font-weight: bold;
      border-radius: 6px;
      display: inline-block;
      box-shadow: 0 3px 6px rgba(30, 60, 114, 0.2);
    }
    .footer {
      background-color: #f8fafc;
      padding: 25px 30px;
      text-align: center;
      border-top: 1px solid #edf2f7;
      font-size: 13px;
      color: #718096;
    }
    .footer a {
      color: #2a5298;
      text-decoration: none;
    }
  </style>
</head>
<body>
  <div class="wrapper">
    <div class="container">
      <!-- Header with Branding Logo Placeholder -->
      <div class="header">
        <h1>SMART COMPLAINT ANALYZER</h1>
      </div>
      
      <!-- Body content -->
      <div class="content">
        <h2>Welcome to the Grievance Cell Portal!</h2>
        <p>Thank you for registering. To activate your account and gain access to the complaint classification and prioritization system, please verify your email address by clicking the button below:</p>
        
        <div class="btn-container">
          <a href="%LINK%" class="btn">Verify Email Address</a>
        </div>
        
        <p>If the button doesn't work, copy and paste the following link into your web browser:</p>
        <p style="word-break: break-all; font-size: 13px; color: #718096;">%LINK%</p>
        
        <p>If you did not create an account, you can safely ignore this email.</p>
        <p>Best regards,<br><strong>Smart Complaint Analyzer Team</strong></p>
      </div>
      
      <!-- Footer details -->
      <div class="footer">
        <p>KLN College of Engineering, Pottapalayam, Tamil Nadu - 630612</p>
        <p>Need help? Contact support at <a href="mailto:complaints-support@klnce.edu">complaints-support@klnce.edu</a></p>
        <p>&copy; 2026 Smart Complaint Analyzer. All rights reserved.</p>
      </div>
    </div>
  </div>
</body>
</html>
```

---

## 3. Professional HTML Email Template (Password Reset)

Subject: `Reset your password for Smart Complaint Analyzer`

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reset your Password - Smart Complaint Analyzer</title>
  <style>
    body {
      font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
      background-color: #f4f6f8;
      margin: 0;
      padding: 0;
      -webkit-font-smoothing: antialiased;
    }
    .wrapper {
      width: 100%;
      background-color: #f4f6f8;
      padding: 40px 0;
    }
    .container {
      max-width: 600px;
      margin: 0 auto;
      background-color: #ffffff;
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
    }
    .header {
      background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
      padding: 30px;
      text-align: center;
    }
    .header h1 {
      color: #ffffff;
      margin: 0;
      font-size: 24px;
      font-weight: 700;
      letter-spacing: 0.5px;
    }
    .content {
      padding: 40px 30px;
      color: #333333;
      line-height: 1.6;
    }
    .content h2 {
      font-size: 20px;
      margin-top: 0;
      color: #1e3c72;
    }
    .btn-container {
      text-align: center;
      margin: 35px 0;
    }
    .btn {
      background: linear-gradient(135deg, #2a5298 0%, #1e3c72 100%);
      color: #ffffff !important;
      padding: 14px 30px;
      text-decoration: none;
      font-weight: bold;
      border-radius: 6px;
      display: inline-block;
      box-shadow: 0 3px 6px rgba(30, 60, 114, 0.2);
    }
    .footer {
      background-color: #f8fafc;
      padding: 25px 30px;
      text-align: center;
      border-top: 1px solid #edf2f7;
      font-size: 13px;
      color: #718096;
    }
    .footer a {
      color: #2a5298;
      text-decoration: none;
    }
  </style>
</head>
<body>
  <div class="wrapper">
    <div class="container">
      <div class="header">
        <h1>SMART COMPLAINT ANALYZER</h1>
      </div>
      
      <div class="content">
        <h2>Password Reset Request</h2>
        <p>We received a request to reset the password linked to your email address. Click the button below to configure a new secure password:</p>
        
        <div class="btn-container">
          <a href="%LINK%" class="btn">Reset Password</a>
        </div>
        
        <p>If the button doesn't work, copy and paste the following link into your web browser:</p>
        <p style="word-break: break-all; font-size: 13px; color: #718096;">%LINK%</p>
        
        <p>If you did not request a password reset, you can ignore this email. Your password will remain unchanged.</p>
        <p>Best regards,<br><strong>Smart Complaint Analyzer Team</strong></p>
      </div>
      
      <div class="footer">
        <p>KLN College of Engineering, Pottapalayam, Tamil Nadu - 630612</p>
        <p>Need help? Contact support at <a href="mailto:complaints-support@klnce.edu">complaints-support@klnce.edu</a></p>
        <p>&copy; 2026 Smart Complaint Analyzer. All rights reserved.</p>
      </div>
    </div>
  </div>
</body>
</html>
```
