const Complaint = require('../models/Complaint');
const User = require('../models/User');
const emailService = require('./emailService');
const notificationService = require('./notificationService');
const logger = require('../config/logger');

const checkDelayedComplaints = async () => {
  try {
    const escalationHours = parseInt(process.env.COMPLAINT_ESCALATION_HOURS, 10) || 48;
    const thresholdDate = new Date(Date.now() - escalationHours * 60 * 60 * 1000);

    const complaintsToEscalate = await Complaint.find({
      'escalation.isEscalated': false,
      status: { $in: ['Submitted', 'In Progress'] },
      createdAt: { $lt: thresholdDate }
    });

    if (complaintsToEscalate.length === 0) return;

    logger.info(`Found ${complaintsToEscalate.length} delayed complaints to escalate.`);

    const admins = await User.find({ role: 'Admin' });

    for (const complaint of complaintsToEscalate) {
      complaint.escalation = {
        isEscalated: true,
        reason: `Auto-escalated due to delay (>${escalationHours}h)`,
        escalatedAt: new Date(),
        escalatedBy: 'System',
        escalationLevel: 1,
        resolved: false
      };
      
      await complaint.save();

      for (const admin of admins) {
        await emailService.sendComplaintEscalatedEmail(admin, complaint);
        await notificationService.notifyUser(
          admin.firebaseUID,
          'Delayed Complaint Escalation',
          `Complaint ${complaint.complaintId} was auto-escalated because it has been unresolved for over ${escalationHours} hours.`,
          'escalation_alert',
          complaint.complaintId
        );
      }
    }
  } catch (error) {
    logger.error('Error checking delayed complaints', { error: error.message });
  }
};

const startEscalationCron = () => {
  // Check every hour
  setInterval(checkDelayedComplaints, 60 * 60 * 1000);
  // Also check immediately on startup
  setTimeout(checkDelayedComplaints, 10000);
};

module.exports = {
  checkDelayedComplaints,
  startEscalationCron
};
