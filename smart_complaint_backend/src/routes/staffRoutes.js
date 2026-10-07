const express = require('express');
const router = express.Router();
const { requireStaff } = require('../middlewares/authMiddleware');
const User = require('../models/User');
const logger = require('../config/logger');

// Protected by Department Staff authorization middleware
router.use(requireStaff);

// @desc    Get students in Staff's assigned department only
// @route   GET /api/staff/students
// @access  Private (Department Staff)
router.get('/students', async (req, res, next) => {
  const { search } = req.query;
  const staffUser = req.user;

  try {
    const staffDept = staffUser.department;
    if (!staffDept || staffDept === 'Not Assigned') {
      const error = new Error('Staff member is not assigned to a valid department');
      error.status = 400;
      return next(error);
    }

    // STRICT BACKEND ENFORCEMENT: Ignore any incoming department param & force staff's dept
    const query = {
      role: 'Student',
      department: staffDept,
    };

    if (search && search.trim()) {
      const searchRegex = new RegExp(search.trim(), 'i');
      query.$or = [
        { name: searchRegex },
        { email: searchRegex },
        { registerNumber: searchRegex },
      ];
    }

    const students = await User.find(query).select('-__v').sort({ createdAt: -1 });

    logger.info('Staff fetched department students', {
      staffUID: staffUser.firebaseUID,
      department: staffDept,
      count: students.length,
    });

    res.status(200).json({
      success: true,
      department: staffDept,
      count: students.length,
      data: students,
    });
  } catch (error) {
    logger.error('Error in staff student directory route', { error: error.message });
    next(error);
  }
});

module.exports = router;
