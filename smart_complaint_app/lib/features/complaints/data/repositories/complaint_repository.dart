import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../models/complaint_model.dart';

class ComplaintRepository {
  final ApiService _apiService;

  ComplaintRepository(this._apiService);

  Future<ComplaintModel> submitComplaint({
    required String firebaseUID,
    required String title,
    required String description,
    required String department,
    String priority = 'Medium',
  }) async {
    try {
      final response = await _apiService.post('/complaints', {
        'firebaseUID': firebaseUID,
        'title': title,
        'description': description,
        'department': department,
        'priority': priority,
      });

      final data = response.data['data'] as Map<String, dynamic>;
      return ComplaintModel.fromJson(data);
    } catch (e) {
      debugPrint('Error submitting complaint: $e');
      rethrow;
    }
  }

  Future<List<ComplaintModel>> getMyComplaints(String firebaseUID) async {
    try {
      final response = await _apiService.get('/complaints/my?firebaseUID=$firebaseUID');
      final rawList = response.data['data'] as List? ?? [];
      return rawList.map((json) => ComplaintModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching my complaints: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDepartmentComplaints(String firebaseUID) async {
    try {
      final response = await _apiService.get('/complaints/department?firebaseUID=$firebaseUID');
      final rawList = response.data['data'] as List? ?? [];
      final statsJson = response.data['stats'] as Map<String, dynamic>? ?? {};
      final department = response.data['department'] ?? '';

      final complaints = rawList.map((json) => ComplaintModel.fromJson(json)).toList();
      final stats = DepartmentStats.fromJson(statsJson);

      return {
        'department': department,
        'stats': stats,
        'complaints': complaints,
      };
    } catch (e) {
      debugPrint('Error fetching department complaints: $e');
      rethrow;
    }
  }

  Future<ComplaintModel> getComplaintById(String complaintId, String firebaseUID) async {
    try {
      final response = await _apiService.get('/complaints/$complaintId?firebaseUID=$firebaseUID');
      final data = response.data['data'] as Map<String, dynamic>;
      return ComplaintModel.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching complaint details: $e');
      rethrow;
    }
  }

  Future<ComplaintModel> updateComplaintStatus({
    required String complaintId,
    required String firebaseUID,
    required String status,
    String? remarks,
  }) async {
    try {
      final response = await _apiService.patch('/complaints/$complaintId/status', {
        'firebaseUID': firebaseUID,
        'status': status,
        'remarks': remarks ?? '',
      });

      final data = response.data['data'] as Map<String, dynamic>;
      return ComplaintModel.fromJson(data);
    } catch (e) {
      debugPrint('Error updating complaint status: $e');
      rethrow;
    }
  }

  Future<ComplaintModel> analyzeComplaint(String complaintId, String firebaseUID) async {
    try {
      final response = await _apiService.post('/complaints/$complaintId/analyze', {
        'firebaseUID': firebaseUID,
      });

      final data = response.data['data'] as Map<String, dynamic>;
      return ComplaintModel.fromJson(data);
    } catch (e) {
      debugPrint('Error triggering AI analysis: $e');
      rethrow;
    }
  }

  Future<ComplaintModel> escalateComplaint(String complaintId, String reason) async {
    try {
      final response = await _apiService.post('/complaints/$complaintId/escalate', {
        'reason': reason,
      });

      if (response.statusCode == 200 && response.data['success']) {
        return ComplaintModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to escalate complaint');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw Exception(message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<ComplaintModel>> getEscalatedComplaints() async {
    try {
      final response = await _apiService.get('/complaints/escalated');
      
      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ComplaintModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch escalated complaints');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw Exception(message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
