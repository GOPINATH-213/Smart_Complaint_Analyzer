const express = require('express');
const router = express.Router();
const { syncUser, getUserProfile, updateUserProfile } = require('../controllers/userController');

router.post('/sync', syncUser);
router.get('/profile/:firebaseUID', getUserProfile);
router.put('/profile/:firebaseUID', updateUserProfile);
router.patch('/profile/:firebaseUID', updateUserProfile);

module.exports = router;
