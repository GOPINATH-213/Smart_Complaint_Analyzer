const admin = require('../config/firebase');
const Device = require('../models/Device');
const Notification = require('../models/Notification');
const logger = require('../config/logger');

const sendPushNotification = async (firebaseUID, title, body, dataPayload = {}) => {
  try {
    const devices = await Device.find({ firebaseUID });
    if (devices.length === 0) return;

    const tokens = devices.map(d => d.fcmToken);

    const message = {
      notification: { title, body },
      data: dataPayload,
      tokens: tokens,
    };

    const response = await admin.messaging().sendMulticast(message);
    
    // Clean up stale tokens
    if (response.failureCount > 0) {
      const failedTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          const errorCode = resp.error?.code;
          if (errorCode === 'messaging/invalid-registration-token' ||
              errorCode === 'messaging/registration-token-not-registered') {
            failedTokens.push(tokens[idx]);
          }
        }
      });
      if (failedTokens.length > 0) {
        await Device.deleteMany({ fcmToken: { $in: failedTokens } });
        logger.info(`Removed ${failedTokens.length} stale FCM tokens`);
      }
    }
  } catch (error) {
    logger.error('Push notification send error', { error: error.message });
  }
};

const notifyUser = async (firebaseUID, title, message, type, complaintId = null) => {
  try {
    // 1. Save to DB history
    await Notification.create({
      firebaseUID,
      title,
      message,
      type,
      complaintId
    });

    // 2. Send push
    await sendPushNotification(firebaseUID, title, message, {
      type,
      complaintId: complaintId || ''
    });
  } catch (error) {
    logger.error('Failed to notify user', { error: error.message });
  }
};

module.exports = {
  notifyUser,
  sendPushNotification
};
