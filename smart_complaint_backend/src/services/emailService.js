const config = require('../config');
const logger = require('../config/logger');

const sendEmail = async (toEmail, toName, subject, htmlContent) => {
  if (!config.email.brevoApiKey) {
    logger.warn('Brevo API key missing, skipping email send');
    return;
  }

  try {
    const response = await fetch('https://api.brevo.com/v3/smtp/email', {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'api-key': config.email.brevoApiKey
      },
      body: JSON.stringify({
        sender: {
          email: config.email.senderEmail,
          name: config.email.senderName
        },
        to: [{ email: toEmail, name: toName }],
        subject: subject,
        htmlContent: htmlContent
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      logger.error('Failed to send email via Brevo', { status: response.status, error: errorText });
    } else {
      logger.info(`Email sent successfully to ${toEmail}`);
    }
  } catch (error) {
    logger.error('Email service exception', { error: error.message });
  }
};

const sendComplaintSubmittedEmail = async (user, complaint) => {
  const html = `
    <div style="font-family: sans-serif; max-width: 600px; margin: auto;">
      <h2>Smart Complaint Analyzer</h2>
      <h3>Complaint Submitted Successfully</h3>
      <p>Dear ${user.name},</p>
      <p>Your complaint has been successfully submitted and is being processed.</p>
      <p><strong>Complaint ID:</strong> ${complaint.complaintId}</p>
      <p><strong>Title:</strong> ${complaint.title}</p>
      <p><strong>Department:</strong> ${complaint.department}</p>
      <p><strong>Status:</strong> ${complaint.status}</p>
      <p>We will notify you when there are updates.</p>
      <br/>
      <p>Regards,<br/>Smart Complaint Analyzer Team</p>
    </div>
  `;
  await sendEmail(user.email, user.name, `Complaint Submitted - ${complaint.complaintId}`, html);
};

const sendComplaintAssignedEmail = async (staffMember, complaint) => {
  const html = `
    <div style="font-family: sans-serif; max-width: 600px; margin: auto;">
      <h2>Smart Complaint Analyzer</h2>
      <h3>New Complaint Assignment</h3>
      <p>Dear ${staffMember.name},</p>
      <p>A new complaint has been assigned to your department (${complaint.department}).</p>
      <p><strong>Complaint ID:</strong> ${complaint.complaintId}</p>
      <p><strong>Title:</strong> ${complaint.title}</p>
      <p><strong>Priority:</strong> ${complaint.priority}</p>
      <p><strong>Urgency:</strong> ${complaint.urgency || 'Normal'}</p>
      <br/>
      <p>Please review and take necessary action.</p>
      <br/>
      <p>Regards,<br/>Smart Complaint Analyzer Admin</p>
    </div>
  `;
  await sendEmail(staffMember.email, staffMember.name, `New Assignment - ${complaint.complaintId}`, html);
};

const sendComplaintStatusUpdatedEmail = async (user, complaint, oldStatus) => {
  const html = `
    <div style="font-family: sans-serif; max-width: 600px; margin: auto;">
      <h2>Smart Complaint Analyzer</h2>
      <h3>Complaint Status Updated</h3>
      <p>Dear ${user.name},</p>
      <p>Your complaint status has changed from <strong>${oldStatus}</strong> to <strong>${complaint.status}</strong>.</p>
      <p><strong>Complaint ID:</strong> ${complaint.complaintId}</p>
      <p><strong>Title:</strong> ${complaint.title}</p>
      ${complaint.resolutionRemarks ? `<p><strong>Remarks:</strong> ${complaint.resolutionRemarks}</p>` : ''}
      <br/>
      <p>Regards,<br/>Smart Complaint Analyzer Team</p>
    </div>
  `;
  await sendEmail(user.email, user.name, `Status Update - ${complaint.complaintId}`, html);
};

const sendComplaintEscalatedEmail = async (staffOrAdmin, complaint) => {
  const html = `
    <div style="font-family: sans-serif; max-width: 600px; margin: auto;">
      <h2>Smart Complaint Analyzer</h2>
      <h3 style="color: red;">Complaint Escalated</h3>
      <p>Dear ${staffOrAdmin.name},</p>
      <p>The following complaint has been escalated and requires attention.</p>
      <p><strong>Complaint ID:</strong> ${complaint.complaintId}</p>
      <p><strong>Title:</strong> ${complaint.title}</p>
      <p><strong>Status:</strong> ${complaint.status}</p>
      <p><strong>Priority:</strong> ${complaint.priority}</p>
      <p><strong>Escalation Reason:</strong> ${complaint.escalation.reason}</p>
      <br/>
      <p>Regards,<br/>Smart Complaint Analyzer System</p>
    </div>
  `;
  await sendEmail(staffOrAdmin.email, staffOrAdmin.name, `ESCALATION ALERT - ${complaint.complaintId}`, html);
};

module.exports = {
  sendEmail,
  sendComplaintSubmittedEmail,
  sendComplaintAssignedEmail,
  sendComplaintStatusUpdatedEmail,
  sendComplaintEscalatedEmail
};
