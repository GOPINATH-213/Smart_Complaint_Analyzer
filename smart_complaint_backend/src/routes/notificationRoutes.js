const express = require('express');
const router = express.Router();
const { authenticateUser } = require('../middlewares/authMiddleware');
const notificationController = require('../controllers/notificationController');

router.use(authenticateUser);

router.post('/register-device', notificationController.registerDevice);
router.delete('/unregister-device', notificationController.unregisterDevice);
router.get('/', notificationController.getNotifications);
router.patch('/read-all', notificationController.markAllAsRead);
router.patch('/:id/read', notificationController.markAsRead);

module.exports = router;
