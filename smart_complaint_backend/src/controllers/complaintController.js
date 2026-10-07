const Complaint = require('../models/Complaint');
const Counter = require('../models/Counter');
const User = require('../models/User');
const logger = require('../config/logger');
const { analyzeComplaintWithGemini } = require('../services/geminiService');
const emailService = require('../services/emailService');
const notificationService = require('../services/notificationService');

// Helper to generate sequential human-readable Complaint ID (e.g. SCA-2026-000001)
const generateComplaintId = async () => {
  const currentYear = new Date().getFullYear();
  const counter = await Counter.findOneAndUpdate(
    { id: 'complaintId' },
    { $inc: { seq: 1 } },
    { new: true, upsert: true }
  );

  const sequenceFormatted = String(counter.seq).padStart(6, '0');
  return `SCA-${currentYear}-${sequenceFormatted}`;
};

// Valid status transitions map
const VALID_TRANSITIONS = {
  Submitted: ['In Progress'],
  'In Progress': ['Resolved', 'Closed'],
  Resolved: ['Closed', 'In Progress'],
  Closed: [],
};

// @desc    Submit a new complaint (Student)
// @route   POST /api/complaints
// @access  Public (Student)
const createComplaint = async (req, res, next) => {
  const { firebaseUID, title, description, department, priority } = req.body;

  logger.info('Create complaint request received', { firebaseUID, title, department });

  try {
    if (!firebaseUID) {
      const error = new Error('Authentication required: firebaseUID missing');
      error.status = 401;
      return next(error);
    }

    const user = await User.findOne({ firebaseUID });
    if (!user) {
      const error = new Error('User profile not found. Please complete profile setup.');
      error.status = 404;
      return next(error);
    }

    if (user.role !== 'Student') {
      const error = new Error('Only students are authorized to submit complaints');
      error.status = 403;
      return next(error);
    }

    if (!title || !title.trim()) {
      const error = new Error('Complaint title is required');
      error.status = 400;
      return next(error);
    }

    if (!description || !description.trim()) {
      const error = new Error('Complaint description is required');
      error.status = 400;
      return next(error);
    }

    if (!department || !department.trim()) {
      const error = new Error('Department is required for complaint submission');
      error.status = 400;
      return next(error);
    }

    const complaintPriority = ['Low', 'Medium', 'High'].includes(priority) ? priority : 'Medium';
    const complaintId = await generateComplaintId();

    const newComplaint = new Complaint({
      complaintId,
      title: title.trim(),
      description: description.trim(),
      studentUID: user.firebaseUID,
      studentName: user.name,
      studentRegisterNumber: user.registerNumber || '',
      department: department.trim(),
      assignedDepartment: department.trim(),
      status: 'Submitted',
      priority: complaintPriority,
      analysisStatus: 'Pending',
      statusHistory: [
        {
          status: 'Submitted',
          changedBy: user.name,
          changedAt: new Date(),
          remarks: 'Complaint submitted by student',
        },
      ],
    });

    const savedComplaint = await newComplaint.save();
    logger.info('New complaint created successfully', { complaintId: savedComplaint.complaintId, studentUID: user.firebaseUID });

    // Asynchronously send emails and notifications
    setImmediate(async () => {
      await emailService.sendComplaintSubmittedEmail(user, savedComplaint);
      await notificationService.notifyUser(
        user.firebaseUID, 
        'Complaint Submitted', 
        `Your complaint ${savedComplaint.complaintId} has been submitted successfully.`, 
        'complaint_update', 
        savedComplaint.complaintId
      );
    });

    // Asynchronously trigger Gemini AI Analysis in background
    setImmediate(async () => {
      try {
        savedComplaint.analysisStatus = 'Processing';
        await savedComplaint.save();

        const aiResult = await analyzeComplaintWithGemini(savedComplaint);
        savedComplaint.category = aiResult.category;
        savedComplaint.aiPriority = aiResult.aiPriority;
        savedComplaint.urgency = aiResult.urgency;
        savedComplaint.sentiment = aiResult.sentiment;
        savedComplaint.aiSummary = aiResult.aiSummary;
        savedComplaint.suggestedResponse = aiResult.suggestedResponse;
        savedComplaint.aiConfidence = aiResult.aiConfidence;
        savedComplaint.analysisStatus = 'Completed';
        savedComplaint.analyzedAt = new Date();
        
        if (aiResult.urgency === 'High' || aiResult.urgency === 'Critical') {
          savedComplaint.escalation = {
            isEscalated: true,
            reason: `Auto-escalated by AI due to ${aiResult.urgency} urgency`,
            escalatedAt: new Date(),
            escalatedBy: 'System',
            escalationLevel: 1,
            resolved: false
          };
        }
        
        await savedComplaint.save();
        logger.info('Automatic AI analysis completed for complaint', { complaintId: savedComplaint.complaintId });
        
        if (savedComplaint.escalation.isEscalated) {
          setImmediate(async () => {
            const admins = await User.find({ role: 'Admin' });
            for (const admin of admins) {
              await notificationService.notifyUser(
                admin.firebaseUID,
                'AI Auto-Escalation',
                `Complaint ${savedComplaint.complaintId} was automatically escalated due to ${aiResult.urgency} urgency.`,
                'escalation_alert',
                savedComplaint.complaintId
              );
            }
          });
        }
      } catch (aiErr) {
        logger.error('Automatic AI analysis failed for complaint', { complaintId: savedComplaint.complaintId, error: aiErr.message });
        savedComplaint.analysisStatus = 'Failed';
        await savedComplaint.save().catch(() => {});
      }
    });

    res.status(201).json({
      success: true,
      message: 'Complaint submitted successfully',
      data: savedComplaint,
    });
  } catch (error) {
    logger.error('Error in createComplaint', { error: error.message });
    next(error);
  }
};

// @desc    Get complaints for authenticated Student
// @route   GET /api/complaints/my
// @access  Public (Student)
const getMyComplaints = async (req, res, next) => {
  const firebaseUID = req.query.firebaseUID || req.headers['x-firebase-uid'];

  try {
    if (!firebaseUID) {
      const error = new Error('Authentication required: firebaseUID missing');
      error.status = 401;
      return next(error);
    }

    const complaints = await Complaint.find({ studentUID: firebaseUID }).sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: complaints.length,
      data: complaints,
    });
  } catch (error) {
    logger.error('Error in getMyComplaints', { error: error.message, firebaseUID });
    next(error);
  }
};

// @desc    Get department complaints & stats for Department Staff
// @route   GET /api/complaints/department
// @access  Public (Department Staff)
const getDepartmentComplaints = async (req, res, next) => {
  const firebaseUID = req.query.firebaseUID || req.headers['x-firebase-uid'];

  try {
    if (!firebaseUID) {
      const error = new Error('Authentication required: firebaseUID missing');
      error.status = 401;
      return next(error);
    }

    const user = await User.findOne({ firebaseUID });
    if (!user) {
      const error = new Error('User profile not found');
      error.status = 404;
      return next(error);
    }

    if (user.role !== 'Department Staff') {
      const error = new Error('Only Department Staff are authorized to view department complaints');
      error.status = 403;
      return next(error);
    }

    const staffDept = user.department;
    if (!staffDept || staffDept === 'Not Assigned') {
      const error = new Error('Staff member is not assigned to any valid department');
      error.status = 400;
      return next(error);
    }

    const complaints = await Complaint.find({ department: staffDept }).sort({ createdAt: -1 });

    // Calculate simple stats
    const stats = {
      total: complaints.length,
      submitted: complaints.filter((c) => c.status === 'Submitted').length,
      inProgress: complaints.filter((c) => c.status === 'In Progress').length,
      resolved: complaints.filter((c) => c.status === 'Resolved').length,
      closed: complaints.filter((c) => c.status === 'Closed').length,
    };

    res.status(200).json({
      success: true,
      department: staffDept,
      stats,
      data: complaints,
    });
  } catch (error) {
    logger.error('Error in getDepartmentComplaints', { error: error.message, firebaseUID });
    next(error);
  }
};

// @desc    Get complaint details by complaintId
// @route   GET /api/complaints/:complaintId
// @access  Public (Authorized Student or Department Staff)
const getComplaintById = async (req, res, next) => {
  const { complaintId } = req.params;
  const firebaseUID = req.query.firebaseUID || req.headers['x-firebase-uid'];

  try {
    if (!firebaseUID) {
      const error = new Error('Authentication required: firebaseUID missing');
      error.status = 401;
      return next(error);
    }

    const user = await User.findOne({ firebaseUID });
    if (!user) {
      const error = new Error('User profile not found');
      error.status = 404;
      return next(error);
    }

    const isMongoId = /^[0-9a-fA-F]{24}$/.test(complaintId);
    const complaint = await Complaint.findOne(
      isMongoId ? { _id: complaintId } : { complaintId }
    );
    if (!complaint) {
      const error = new Error('Complaint not found');
      error.status = 404;
      return next(error);
    }

    // Authorization check
    if (user.role === 'Student') {
      if (complaint.studentUID !== user.firebaseUID) {
        const error = new Error('Unauthorized: You can only view your own complaints');
        error.status = 403;
        return next(error);
      }
    } else if (user.role === 'Department Staff') {
      if (complaint.department !== user.department) {
        const error = new Error('Unauthorized: You can only view complaints for your assigned department');
        error.status = 403;
        return next(error);
      }
    }

    res.status(200).json({
      success: true,
      data: complaint,
    });
  } catch (error) {
    logger.error('Error in getComplaintById', { error: error.message, complaintId });
    next(error);
  }
};

// @desc    Update complaint status and add resolution remarks (Department Staff)
// @route   PATCH /api/complaints/:complaintId/status
// @access  Public (Department Staff)
const updateComplaintStatus = async (req, res, next) => {
  const { complaintId } = req.params;
  const { firebaseUID, status: newStatus, remarks } = req.body;

  logger.info('Update complaint status request', { complaintId, firebaseUID, newStatus });

  try {
    if (!firebaseUID) {
      const error = new Error('Authentication required: firebaseUID missing');
      error.status = 401;
      return next(error);
    }

    const user = await User.findOne({ firebaseUID });
    if (!user) {
      const error = new Error('User profile not found');
      error.status = 404;
      return next(error);
    }

    if (user.role !== 'Department Staff' && user.role !== 'Admin') {
      const error = new Error('Only Department Staff or Admin are authorized to update complaint status');
      error.status = 403;
      return next(error);
    }

    const isMongoId = /^[0-9a-fA-F]{24}$/.test(complaintId);
    const complaint = await Complaint.findOne(
      isMongoId ? { _id: complaintId } : { complaintId }
    );
    if (!complaint) {
      const error = new Error('Complaint not found');
      error.status = 404;
      return next(error);
    }

    if (user.role === 'Department Staff' && complaint.department !== user.department) {
      const error = new Error('Unauthorized: Staff can only update complaints for their assigned department');
      error.status = 403;
      return next(error);
    }

    if (!newStatus || !['Submitted', 'In Progress', 'Resolved', 'Closed'].includes(newStatus)) {
      const error = new Error('Invalid status provided. Allowed: Submitted, In Progress, Resolved, Closed');
      error.status = 400;
      return next(error);
    }

    const currentStatus = complaint.status;

    if (currentStatus === newStatus) {
      return res.status(200).json({
        success: true,
        message: 'Status remains unchanged',
        data: complaint,
      });
    }

    // Validate status transition sequence
    const allowedNextStatuses = VALID_TRANSITIONS[currentStatus] || [];
    if (!allowedNextStatuses.includes(newStatus)) {
      const error = new Error(`Invalid status transition from '${currentStatus}' to '${newStatus}'`);
      error.status = 400;
      return next(error);
    }

    const updatedRemarks = remarks ? remarks.trim() : `Status updated to ${newStatus}`;

    if (['Resolved', 'Closed'].includes(newStatus)) {
      if (remarks && remarks.trim()) {
        complaint.resolutionRemarks = remarks.trim();
      }
    }

    complaint.status = newStatus;
    complaint.statusHistory.push({
      status: newStatus,
      changedBy: `${user.name} (${user.department})`,
      changedAt: new Date(),
      remarks: updatedRemarks,
    });

    const updatedComplaint = await complaint.save();
    logger.info('Complaint status updated successfully', { complaintId, newStatus, staff: user.name });

    setImmediate(async () => {
      const student = await User.findOne({ firebaseUID: updatedComplaint.studentUID });
      if (student) {
        await emailService.sendComplaintStatusUpdatedEmail(student, updatedComplaint, currentStatus);
        await notificationService.notifyUser(
          student.firebaseUID,
          'Complaint Status Updated',
          `Your complaint ${updatedComplaint.complaintId} is now ${newStatus}.`,
          'complaint_update',
          updatedComplaint.complaintId
        );
      }
    });

    res.status(200).json({
      success: true,
      message: `Complaint status updated to ${newStatus}`,
      data: updatedComplaint,
    });
  } catch (error) {
    logger.error('Error in updateComplaintStatus', { error: error.message, complaintId });
    next(error);
  }
};

// @desc    Trigger or retry Gemini AI analysis for a complaint (Department Staff / Admin)
// @route   POST /api/complaints/:complaintId/analyze
// @access  Public (Department Staff / Admin)
const analyzeComplaint = async (req, res, next) => {
  const { complaintId } = req.params;
  const firebaseUID = req.body.firebaseUID || req.headers['x-firebase-uid'];

  try {
    if (!firebaseUID) {
      const error = new Error('Authentication required: firebaseUID missing');
      error.status = 401;
      return next(error);
    }

    const user = await User.findOne({ firebaseUID });
    if (!user) {
      const error = new Error('User profile not found');
      error.status = 404;
      return next(error);
    }

    if (user.role !== 'Department Staff' && user.role !== 'Admin' && user.role !== 'Super Admin') {
      const error = new Error('Only Department Staff or Admins can trigger AI analysis');
      error.status = 403;
      return next(error);
    }

    const isMongoId = /^[0-9a-fA-F]{24}$/.test(complaintId);
    const complaint = await Complaint.findOne(
      isMongoId ? { _id: complaintId } : { complaintId }
    );

    if (!complaint) {
      const error = new Error('Complaint not found');
      error.status = 404;
      return next(error);
    }

    if (user.role === 'Department Staff' && complaint.department !== user.department) {
      const error = new Error('Unauthorized: Staff can only analyze complaints for their assigned department');
      error.status = 403;
      return next(error);
    }

    complaint.analysisStatus = 'Processing';
    await complaint.save();

    try {
      const aiResult = await analyzeComplaintWithGemini(complaint);
      complaint.category = aiResult.category;
      complaint.aiPriority = aiResult.aiPriority;
      complaint.urgency = aiResult.urgency;
      complaint.sentiment = aiResult.sentiment;
      complaint.aiSummary = aiResult.aiSummary;
      complaint.suggestedResponse = aiResult.suggestedResponse;
      complaint.aiConfidence = aiResult.aiConfidence;
      complaint.analysisStatus = 'Completed';
      complaint.analyzedAt = new Date();

      const updatedComplaint = await complaint.save();
      logger.info('Manual Gemini AI analysis completed', { complaintId: updatedComplaint.complaintId });

      res.status(200).json({
        success: true,
        message: 'AI Analysis completed successfully',
        data: updatedComplaint,
      });
    } catch (aiError) {
      logger.error('Manual Gemini AI analysis failed', { complaintId, error: aiError.message });
      complaint.analysisStatus = 'Failed';
      await complaint.save();

      res.status(500).json({
        success: false,
        message: 'AI analysis is currently unavailable. Please try again later.',
        data: complaint,
      });
    }
  } catch (error) {
    logger.error('Error in analyzeComplaint', { error: error.message, complaintId });
    next(error);
  }
};

// @desc    Manually escalate a complaint (Department Staff / Admin)
// @route   POST /api/complaints/:complaintId/escalate
// @access  Private (Department Staff / Admin)
const escalateComplaint = async (req, res, next) => {
  const { complaintId } = req.params;
  const { reason } = req.body;
  const firebaseUID = req.user.firebaseUID;

  try {
    const isMongoId = /^[0-9a-fA-F]{24}$/.test(complaintId);
    const complaint = await Complaint.findOne(
      isMongoId ? { _id: complaintId } : { complaintId }
    );

    if (!complaint) {
      const error = new Error('Complaint not found');
      error.status = 404;
      return next(error);
    }

    if (req.user.role === 'Department Staff' && complaint.department !== req.user.department) {
      const error = new Error('Unauthorized: Staff can only escalate complaints for their assigned department');
      error.status = 403;
      return next(error);
    }

    if (complaint.escalation.isEscalated) {
      const error = new Error('Complaint is already escalated');
      error.status = 400;
      return next(error);
    }

    complaint.escalation = {
      isEscalated: true,
      reason: reason || 'Manually escalated',
      escalatedAt: new Date(),
      escalatedBy: req.user.name,
      escalationLevel: 1,
      resolved: false
    };

    const updatedComplaint = await complaint.save();
    logger.info('Complaint escalated manually', { complaintId, user: req.user.name });

    setImmediate(async () => {
      const admins = await User.find({ role: 'Admin' });
      for (const admin of admins) {
        await emailService.sendComplaintEscalatedEmail(admin, updatedComplaint);
        await notificationService.notifyUser(
          admin.firebaseUID,
          'Complaint Escalated',
          `Complaint ${updatedComplaint.complaintId} was escalated by ${req.user.name}.`,
          'escalation_alert',
          updatedComplaint.complaintId
        );
      }
    });

    res.status(200).json({
      success: true,
      message: 'Complaint escalated successfully',
      data: updatedComplaint,
    });
  } catch (error) {
    logger.error('Error in escalateComplaint', { error: error.message, complaintId });
    next(error);
  }
};

// @desc    Get all escalated complaints (Admin/Staff)
// @route   GET /api/complaints/escalated
// @access  Private (Department Staff / Admin)
const getEscalatedComplaints = async (req, res, next) => {
  try {
    const query = { 'escalation.isEscalated': true, 'escalation.resolved': false };
    
    if (req.user.role === 'Department Staff') {
      query.department = req.user.department;
    }

    const complaints = await Complaint.find(query).sort({ 'escalation.escalatedAt': -1 });

    res.status(200).json({
      success: true,
      count: complaints.length,
      data: complaints,
    });
  } catch (error) {
    logger.error('Error in getEscalatedComplaints', { error: error.message });
    next(error);
  }
};

module.exports = {
  createComplaint,
  getMyComplaints,
  getDepartmentComplaints,
  getComplaintById,
  updateComplaintStatus,
  analyzeComplaint,
  escalateComplaint,
  getEscalatedComplaints,
};
