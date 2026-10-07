const User = require('../models/User');
const Complaint = require('../models/Complaint');
const logger = require('../config/logger');
const emailService = require('../services/emailService');
const notificationService = require('../services/notificationService');

// @desc    Get aggregate stats for Admin Dashboard
// @route   GET /api/admin/dashboard
// @access  Private (Admin)
const getAdminDashboardStats = async (req, res, next) => {
  try {
    const [
      totalStudents,
      totalStaff,
      totalComplaints,
      submitted,
      inProgress,
      resolved,
      closed,
      highPriority,
      urgent,
      departmentsList,
    ] = await Promise.all([
      User.countDocuments({ role: 'Student' }),
      User.countDocuments({ role: 'Department Staff' }),
      Complaint.countDocuments({}),
      Complaint.countDocuments({ status: 'Submitted' }),
      Complaint.countDocuments({ status: 'In Progress' }),
      Complaint.countDocuments({ status: 'Resolved' }),
      Complaint.countDocuments({ status: 'Closed' }),
      Complaint.countDocuments({ priority: 'High' }),
      Complaint.countDocuments({
        $or: [
          { urgency: 'Critical' },
          { urgency: 'High' },
          { aiPriority: 'High' },
        ],
      }),
      User.distinct('department', { department: { $ne: 'Not Assigned' } }),
    ]);

    const stats = {
      totalStudents,
      totalStaff,
      totalDepartments: departmentsList.length,
      totalComplaints,
      submitted,
      inProgress,
      resolved,
      closed,
      highPriority,
      urgent,
    };

    res.status(200).json({
      success: true,
      data: stats,
    });
  } catch (error) {
    logger.error('Error in getAdminDashboardStats', { error: error.message });
    next(error);
  }
};

// @desc    Get all registered students directory for Admin
// @route   GET /api/admin/students
// @access  Private (Admin)
const getAdminStudents = async (req, res, next) => {
  const { search, department } = req.query;

  try {
    const query = { role: 'Student' };

    if (department && department.trim() && department !== 'All') {
      query.department = department.trim();
    }

    if (search && search.trim()) {
      const searchRegex = new RegExp(search.trim(), 'i');
      query.$or = [
        { name: searchRegex },
        { email: searchRegex },
        { registerNumber: searchRegex },
        { department: searchRegex },
      ];
    }

    const students = await User.find(query)
      .select('-__v')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: students.length,
      data: students,
    });
  } catch (error) {
    logger.error('Error in getAdminStudents', { error: error.message });
    next(error);
  }
};

// @desc    Get all department staff directory for Admin
// @route   GET /api/admin/staff
// @access  Private (Admin)
const getAdminStaff = async (req, res, next) => {
  const { search, department } = req.query;

  try {
    const query = { role: 'Department Staff' };

    if (department && department.trim() && department !== 'All') {
      query.department = department.trim();
    }

    if (search && search.trim()) {
      const searchRegex = new RegExp(search.trim(), 'i');
      query.$or = [
        { name: searchRegex },
        { email: searchRegex },
        { employeeId: searchRegex },
        { department: searchRegex },
        { designation: searchRegex },
      ];
    }

    const staff = await User.find(query)
      .select('-__v')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: staff.length,
      data: staff,
    });
  } catch (error) {
    logger.error('Error in getAdminStaff', { error: error.message });
    next(error);
  }
};

// @desc    Get department statistics breakdown for Admin
// @route   GET /api/admin/departments
// @access  Private (Admin)
const getAdminDepartments = async (req, res, next) => {
  try {
    const userDepts = await User.distinct('department');
    const complaintDepts = await Complaint.distinct('department');

    const allDeptsSet = new Set([
      ...userDepts,
      ...complaintDepts,
      'Computer Science & Engineering',
      'Electrical & Electronics Engineering',
      'Electronics & Communication Engineering',
      'Mechanical Engineering',
      'Civil Engineering',
      'Information Technology',
    ]);
    allDeptsSet.delete('Not Assigned');
    allDeptsSet.delete('');

    const departmentsList = Array.from(allDeptsSet).sort();

    const departmentSummaries = await Promise.all(
      departmentsList.map(async (dept) => {
        const [studentCount, staffCount, totalComplaints, pendingComplaints] = await Promise.all([
          User.countDocuments({ role: 'Student', department: dept }),
          User.countDocuments({ role: 'Department Staff', department: dept }),
          Complaint.countDocuments({ department: dept }),
          Complaint.countDocuments({ department: dept, status: { $in: ['Submitted', 'In Progress'] } }),
        ]);

        return {
          department: dept,
          studentCount,
          staffCount,
          totalComplaints,
          pendingComplaints,
        };
      })
    );

    res.status(200).json({
      success: true,
      count: departmentSummaries.length,
      data: departmentSummaries,
    });
  } catch (error) {
    logger.error('Error in getAdminDepartments', { error: error.message });
    next(error);
  }
};

// @desc    Get all complaints across institution for Admin
// @route   GET /api/admin/complaints
// @access  Private (Admin)
const getAdminComplaints = async (req, res, next) => {
  const { search, department, status, priority, category } = req.query;

  try {
    const query = {};

    if (department && department.trim() && department !== 'All') {
      query.department = department.trim();
    }

    if (status && status.trim() && status !== 'All') {
      query.status = status.trim();
    }

    if (priority && priority.trim() && priority !== 'All') {
      query.priority = priority.trim();
    }

    if (category && category.trim() && category !== 'All') {
      query.category = category.trim();
    }

    if (search && search.trim()) {
      const searchRegex = new RegExp(search.trim(), 'i');
      query.$or = [
        { complaintId: searchRegex },
        { title: searchRegex },
        { description: searchRegex },
        { studentName: searchRegex },
        { studentRegisterNumber: searchRegex },
        { department: searchRegex },
      ];
    }

    const complaints = await Complaint.find(query).sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: complaints.length,
      data: complaints,
    });
  } catch (error) {
    logger.error('Error in getAdminComplaints', { error: error.message });
    next(error);
  }
};

// @desc    Assign or Reassign Complaint to a Department (Admin)
// @route   PATCH /api/admin/complaints/:complaintId/assign
// @access  Private (Admin)
const assignComplaintDepartment = async (req, res, next) => {
  const { complaintId } = req.params;
  const { assignedDepartment, assignedStaffUID, assignedStaffName, remarks } = req.body;

  try {
    if (!assignedDepartment || !assignedDepartment.trim()) {
      const error = new Error('assignedDepartment is required');
      error.status = 400;
      return next(error);
    }

    const targetDepartment = assignedDepartment.trim();

    const isMongoId = /^[0-9a-fA-F]{24}$/.test(complaintId);
    const complaint = await Complaint.findOne(
      isMongoId ? { _id: complaintId } : { complaintId }
    );

    if (!complaint) {
      const error = new Error('Complaint not found');
      error.status = 404;
      return next(error);
    }

    const previousDept = complaint.department;
    complaint.assignedDepartment = targetDepartment;
    complaint.department = targetDepartment; // Ensure staff query picks it up
    
    if (assignedStaffUID && assignedStaffName) {
      complaint.assignedStaffUID = assignedStaffUID;
      complaint.assignedStaffName = assignedStaffName;
    } else {
      complaint.assignedStaffUID = null;
      complaint.assignedStaffName = null;
    }

    complaint.assignedBy = `${req.user.name} (Admin)`;
    complaint.assignedAt = new Date();

    let defaultRemark = `Complaint reassigned from '${previousDept}' to '${targetDepartment}' by Admin`;
    if (assignedStaffName) {
      defaultRemark += `, specifically assigned to ${assignedStaffName}`;
    }

    const updateRemark = remarks && remarks.trim()
      ? remarks.trim()
      : defaultRemark;

    complaint.statusHistory.push({
      status: complaint.status,
      changedBy: `${req.user.name} (Admin)`,
      changedAt: new Date(),
      remarks: updateRemark,
    });

    const updatedComplaint = await complaint.save();
    logger.info('Complaint assigned to department by Admin', {
      complaintId: updatedComplaint.complaintId,
      assignedDepartment: targetDepartment,
      assignedStaffName: assignedStaffName || 'None',
      admin: req.user.name,
    });

    setImmediate(async () => {
      let targetStaff = [];
      if (assignedStaffUID) {
        const staff = await User.findOne({ firebaseUID: assignedStaffUID });
        if (staff) targetStaff.push(staff);
      } else {
        targetStaff = await User.find({ department: targetDepartment, role: 'Department Staff' });
      }

      for (const staff of targetStaff) {
        await emailService.sendComplaintAssignedEmail(staff, updatedComplaint);
        await notificationService.notifyUser(
          staff.firebaseUID,
          'New Complaint Assigned',
          `Complaint ${updatedComplaint.complaintId} has been assigned to ${assignedStaffName ? 'you' : 'your department'}.`,
          'assignment_alert',
          updatedComplaint.complaintId
        );
      }
      
      const student = await User.findOne({ firebaseUID: updatedComplaint.studentUID });
      if (student) {
        await notificationService.notifyUser(
          student.firebaseUID,
          'Complaint Assigned',
          `Your complaint ${updatedComplaint.complaintId} has been assigned to a department.`,
          'complaint_update',
          updatedComplaint.complaintId
        );
      }
    });

    res.status(200).json({
      success: true,
      message: assignedStaffName 
        ? `Complaint assigned to ${assignedStaffName} in ${targetDepartment}`
        : `Complaint assigned to ${targetDepartment} department`,
      data: updatedComplaint,
    });
  } catch (error) {
    logger.error('Error in assignComplaintDepartment', { error: error.message, complaintId });
    next(error);
  }
};

module.exports = {
  getAdminDashboardStats,
  getAdminStudents,
  getAdminStaff,
  getAdminDepartments,
  getAdminComplaints,
  assignComplaintDepartment,
};
