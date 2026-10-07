const mongoose = require('mongoose');

const statusHistorySchema = new mongoose.Schema(
  {
    status: {
      type: String,
      required: true,
      enum: ['Submitted', 'In Progress', 'Resolved', 'Closed'],
    },
    changedBy: {
      type: String,
      required: true,
    },
    changedAt: {
      type: Date,
      default: Date.now,
    },
    remarks: {
      type: String,
      default: '',
    },
  },
  { _id: false }
);

const complaintSchema = new mongoose.Schema(
  {
    complaintId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    title: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      required: true,
      trim: true,
    },
    studentUID: {
      type: String,
      required: true,
      index: true,
    },
    studentName: {
      type: String,
      required: true,
    },
    studentRegisterNumber: {
      type: String,
      default: '',
    },
    department: {
      type: String,
      required: true,
      index: true,
    },
    assignedBy: {
      type: String,
      default: null,
    },
    assignedAt: {
      type: Date,
      default: null,
    },
    assignedDepartment: {
      type: String,
      default: function () {
        return this.department;
      },
    },
    assignedStaffUID: {
      type: String,
      default: null,
    },
    assignedStaffName: {
      type: String,
      default: null,
    },
    status: {
      type: String,
      required: true,
      enum: ['Submitted', 'In Progress', 'Resolved', 'Closed'],
      default: 'Submitted',
      index: true,
    },
    priority: {
      type: String,
      required: true,
      enum: ['Low', 'Medium', 'High'],
      default: 'Medium',
    },
    resolutionRemarks: {
      type: String,
      default: '',
    },
    statusHistory: [statusHistorySchema],

    // Phase 3 Gemini AI Placeholder Fields (unpopulated in Phase 2)
    category: {
      type: String,
      default: null,
    },
    aiPriority: {
      type: String,
      default: null,
    },
    urgency: {
      type: String,
      default: null,
    },
    sentiment: {
      type: String,
      default: null,
    },
    aiSummary: {
      type: String,
      default: null,
    },
    suggestedResponse: {
      type: String,
      default: null,
    },
    aiConfidence: {
      type: Number,
      default: null,
    },
    analysisStatus: {
      type: String,
      enum: ['Pending', 'Processing', 'Completed', 'Failed'],
      default: 'Pending',
    },
    analyzedAt: {
      type: Date,
      default: null,
    },
    
    // Phase 5 Escalation Fields
    escalation: {
      isEscalated: { type: Boolean, default: false },
      reason: { type: String, default: null },
      escalatedAt: { type: Date, default: null },
      escalatedBy: { type: String, default: null }, // Admin or Staff name/UID, or 'System'
      escalationLevel: { type: Number, default: 0 },
      resolved: { type: Boolean, default: false },
    },
  },
  {
    timestamps: true,
  }
);

const Complaint = mongoose.model('Complaint', complaintSchema);

module.exports = Complaint;
