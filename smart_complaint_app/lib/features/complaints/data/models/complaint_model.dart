class StatusHistoryItem {
  final String status;
  final String changedBy;
  final DateTime changedAt;
  final String remarks;

  StatusHistoryItem({
    required this.status,
    required this.changedBy,
    required this.changedAt,
    required this.remarks,
  });

  factory StatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return StatusHistoryItem(
      status: json['status'] ?? 'Submitted',
      changedBy: json['changedBy'] ?? 'Unknown',
      changedAt: json['changedAt'] != null
          ? DateTime.parse(json['changedAt'])
          : DateTime.now(),
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'changedBy': changedBy,
      'changedAt': changedAt.toIso8601String(),
      'remarks': remarks,
    };
  }
}

class EscalationModel {
  final bool isEscalated;
  final String? reason;
  final DateTime? escalatedAt;
  final String? escalatedBy;
  final int escalationLevel;
  final bool resolved;

  EscalationModel({
    required this.isEscalated,
    this.reason,
    this.escalatedAt,
    this.escalatedBy,
    required this.escalationLevel,
    required this.resolved,
  });

  factory EscalationModel.fromJson(Map<String, dynamic> json) {
    return EscalationModel(
      isEscalated: json['isEscalated'] ?? false,
      reason: json['reason'],
      escalatedAt: json['escalatedAt'] != null ? DateTime.parse(json['escalatedAt']) : null,
      escalatedBy: json['escalatedBy'],
      escalationLevel: json['escalationLevel'] ?? 0,
      resolved: json['resolved'] ?? false,
    );
  }
}

class ComplaintModel {
  final String id;
  final String complaintId;
  final String title;
  final String description;
  final String studentUID;
  final String studentName;
  final String studentRegisterNumber;
  final String department;
  final String assignedDepartment;
  final String? assignedStaffUID;
  final String? assignedStaffName;
  final String status;
  final String priority;
  final String resolutionRemarks;
  final List<StatusHistoryItem> statusHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Phase 3 Gemini AI Fields
  final String? category;
  final String? aiPriority;
  final String? urgency;
  final String? sentiment;
  final String? aiSummary;
  final String? suggestedResponse;
  final double? aiConfidence;
  final String analysisStatus;
  final DateTime? analyzedAt;
  final EscalationModel? escalation;

  ComplaintModel({
    required this.id,
    required this.complaintId,
    required this.title,
    required this.description,
    required this.studentUID,
    required this.studentName,
    required this.studentRegisterNumber,
    required this.department,
    required this.assignedDepartment,
    this.assignedStaffUID,
    this.assignedStaffName,
    required this.status,
    required this.priority,
    required this.resolutionRemarks,
    required this.statusHistory,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.aiPriority,
    this.urgency,
    this.sentiment,
    this.aiSummary,
    this.suggestedResponse,
    this.aiConfidence,
    this.analysisStatus = 'Pending',
    this.analyzedAt,
    this.escalation,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    var rawHistory = json['statusHistory'] as List? ?? [];
    List<StatusHistoryItem> historyList =
        rawHistory.map((item) => StatusHistoryItem.fromJson(item)).toList();

    double? parsedConfidence;
    if (json['aiConfidence'] != null) {
      parsedConfidence = (json['aiConfidence'] as num).toDouble();
    }

    return ComplaintModel(
      id: json['_id'] ?? '',
      complaintId: json['complaintId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      studentUID: json['studentUID'] ?? '',
      studentName: json['studentName'] ?? '',
      studentRegisterNumber: json['studentRegisterNumber'] ?? '',
      department: json['department'] ?? 'General',
      assignedDepartment: json['assignedDepartment'] ?? json['department'] ?? 'General',
      assignedStaffUID: json['assignedStaffUID'],
      assignedStaffName: json['assignedStaffName'],
      status: json['status'] ?? 'Submitted',
      priority: json['priority'] ?? 'Medium',
      resolutionRemarks: json['resolutionRemarks'] ?? '',
      statusHistory: historyList,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      category: json['category'],
      aiPriority: json['aiPriority'],
      urgency: json['urgency'],
      sentiment: json['sentiment'],
      aiSummary: json['aiSummary'],
      suggestedResponse: json['suggestedResponse'],
      aiConfidence: parsedConfidence,
      analysisStatus: json['analysisStatus'] ?? 'Pending',
      analyzedAt: json['analyzedAt'] != null ? DateTime.parse(json['analyzedAt']) : null,
      escalation: json['escalation'] != null ? EscalationModel.fromJson(json['escalation']) : null,
    );
  }
}

class DepartmentStats {
  final int total;
  final int submitted;
  final int inProgress;
  final int resolved;
  final int closed;

  DepartmentStats({
    required this.total,
    required this.submitted,
    required this.inProgress,
    required this.resolved,
    required this.closed,
  });

  factory DepartmentStats.fromJson(Map<String, dynamic> json) {
    return DepartmentStats(
      total: json['total'] ?? 0,
      submitted: json['submitted'] ?? 0,
      inProgress: json['inProgress'] ?? 0,
      resolved: json['resolved'] ?? 0,
      closed: json['closed'] ?? 0,
    );
  }
}
