const Device = require('../models/Device');
const Notification = require('../models/Notification');
const logger = require('../config/logger');

// @desc    Register FCM device token
// @route   POST /api/notifications/register-device
exports.registerDevice = async (req, res, next) => {
  const { fcmToken, platform } = req.body;
  if (!fcmToken) return res.status(400).json({ success: false, message: 'FCM token required' });

  try {
    await Device.findOneAndUpdate(
      { fcmToken },
      { firebaseUID: req.user.firebaseUID, platform: platform || 'unknown' },
      { upsert: true, new: true }
    );
    res.status(200).json({ success: true, message: 'Device registered' });
  } catch (error) {
    logger.error('Error registering device', { error: error.message });
    next(error);
  }
};

// @desc    Unregister FCM device token
// @route   DELETE /api/notifications/unregister-device
exports.unregisterDevice = async (req, res, next) => {
  const { fcmToken } = req.body;
  if (!fcmToken) return res.status(400).json({ success: false, message: 'FCM token required' });

  try {
    await Device.findOneAndDelete({ fcmToken, firebaseUID: req.user.firebaseUID });
    res.status(200).json({ success: true, message: 'Device unregistered' });
  } catch (error) {
    logger.error('Error unregistering device', { error: error.message });
    next(error);
  }
};

// @desc    Get notification history
// @route   GET /api/notifications
exports.getNotifications = async (req, res, next) => {
  try {
    const notifications = await Notification.find({ firebaseUID: req.user.firebaseUID })
      .sort({ createdAt: -1 })
      .limit(50);
    res.status(200).json({ success: true, data: notifications });
  } catch (error) {
    logger.error('Error getting notifications', { error: error.message });
    next(error);
  }
};

// @desc    Mark notification as read
// @route   PATCH /api/notifications/:id/read
exports.markAsRead = async (req, res, next) => {
  try {
    const notification = await Notification.findOneAndUpdate(
      { _id: req.params.id, firebaseUID: req.user.firebaseUID },
      { isRead: true },
      { new: true }
    );
    if (!notification) return res.status(404).json({ success: false, message: 'Not found' });
    res.status(200).json({ success: true, data: notification });
  } catch (error) {
    logger.error('Error marking notification read', { error: error.message });
    next(error);
  }
};

// @desc    Mark all notifications as read
// @route   PATCH /api/notifications/read-all
exports.markAllAsRead = async (req, res, next) => {
  try {
    await Notification.updateMany(
      { firebaseUID: req.user.firebaseUID, isRead: false },
      { isRead: true }
    );
    res.status(200).json({ success: true, message: 'All marked as read' });
  } catch (error) {
    logger.error('Error marking all notifications read', { error: error.message });
    next(error);
  }
};
