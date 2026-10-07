const express = require('express');
const router = express.Router();
const {
  createComplaint,
  getMyComplaints,
  getDepartmentComplaints,
  getComplaintById,
  updateComplaintStatus,
  analyzeComplaint,
  escalateComplaint,
  getEscalatedComplaints,
} = require('../controllers/complaintController');

const { requireAdminOrStaff } = require('../middlewares/authMiddleware');

router.post('/', createComplaint);
router.get('/my', getMyComplaints);
router.get('/department', getDepartmentComplaints);
router.get('/escalated', requireAdminOrStaff, getEscalatedComplaints);
router.get('/:complaintId', getComplaintById);
router.patch('/:complaintId/status', updateComplaintStatus);
router.post('/:complaintId/analyze', analyzeComplaint);
router.post('/:complaintId/escalate', requireAdminOrStaff, escalateComplaint);

module.exports = router;
