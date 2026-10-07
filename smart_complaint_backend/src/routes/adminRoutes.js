const express = require('express');
const router = express.Router();
const { requireAdmin } = require('../middlewares/authMiddleware');
const {
  getAdminDashboardStats,
  getAdminStudents,
  getAdminStaff,
  getAdminDepartments,
  getAdminComplaints,
  assignComplaintDepartment,
} = require('../controllers/adminController');

// All routes in adminRoutes are protected by requireAdmin middleware
router.use(requireAdmin);

router.get('/dashboard', getAdminDashboardStats);
router.get('/students', getAdminStudents);
router.get('/staff', getAdminStaff);
router.get('/departments', getAdminDepartments);
router.get('/complaints', getAdminComplaints);
router.patch('/complaints/:complaintId/assign', assignComplaintDepartment);

module.exports = router;
