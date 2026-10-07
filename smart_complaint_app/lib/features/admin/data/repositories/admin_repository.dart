import 'package:flutter/foundation.dart';
import 'package:smart_complaint_app/core/services/api_service.dart';
import 'package:smart_complaint_app/features/complaints/data/models/complaint_model.dart';

class AdminRepository {
  final ApiService _apiService;

  AdminRepository({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  /// Fetch Admin Dashboard aggregated metrics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiService.get('/admin/dashboard');
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception('Failed to load admin dashboard statistics');
    } catch (e) {
      debugPrint('Error in getDashboardStats: $e');
      rethrow;
    }
  }

  /// Fetch registered students list with optional search and department filters
  Future<List<Map<String, dynamic>>> getStudents({String? search, String? department}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (department != null && department.trim().isNotEmpty && department != 'All') {
        queryParams['department'] = department.trim();
      }

      final response = await _apiService.get('/admin/students', queryParameters: queryParams);
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        final list = response.data['data'] as List;
        return list.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error in getStudents: $e');
      rethrow;
    }
  }

  /// Fetch department staff directory with optional search and department filters
  Future<List<Map<String, dynamic>>> getStaff({String? search, String? department}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (department != null && department.trim().isNotEmpty && department != 'All') {
        queryParams['department'] = department.trim();
      }

      final response = await _apiService.get('/admin/staff', queryParameters: queryParams);
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        final list = response.data['data'] as List;
        return list.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error in getStaff: $e');
      rethrow;
    }
  }

  /// Fetch departments breakdown (counts of students, staff, complaints)
  Future<List<Map<String, dynamic>>> getDepartments() async {
    try {
      final response = await _apiService.get('/admin/departments');
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        final list = response.data['data'] as List;
        return list.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error in getDepartments: $e');
      rethrow;
    }
  }

  /// Fetch all complaints for Admin with optional filters
  Future<List<ComplaintModel>> getComplaints({
    String? search,
    String? department,
    String? status,
    String? priority,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (department != null && department.trim().isNotEmpty && department != 'All') {
        queryParams['department'] = department.trim();
      }
      if (status != null && status.trim().isNotEmpty && status != 'All') {
        queryParams['status'] = status.trim();
      }
      if (priority != null && priority.trim().isNotEmpty && priority != 'All') {
        queryParams['priority'] = priority.trim();
      }
      if (category != null && category.trim().isNotEmpty && category != 'All') {
        queryParams['category'] = category.trim();
      }

      final response = await _apiService.get('/admin/complaints', queryParameters: queryParams);
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        final list = response.data['data'] as List;
        return list.map((item) => ComplaintModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error in getComplaints: $e');
      rethrow;
    }
  }

  /// Assign or reassign complaint to a department and optional staff
  Future<ComplaintModel> assignDepartment(
    String complaintId,
    String assignedDepartment, {
    String? assignedStaffUID,
    String? assignedStaffName,
    String? remarks,
  }) async {
    try {
      final response = await _apiService.patch(
        '/admin/complaints/$complaintId/assign',
        {
          'assignedDepartment': assignedDepartment,
          if (assignedStaffUID != null) 'assignedStaffUID': assignedStaffUID,
          if (assignedStaffName != null) 'assignedStaffName': assignedStaffName,
          if (remarks != null && remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
        },
      );

      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        return ComplaintModel.fromJson(response.data['data']);
      }
      throw Exception(response.data?['message'] ?? 'Failed to assign department');
    } catch (e) {
      debugPrint('Error in assignDepartment: $e');
      rethrow;
    }
  }
}
