import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/admin_repository.dart';
import '../../../complaints/data/models/complaint_model.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

final adminDashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getDashboardStats();
});

final adminStudentsProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, ({String? search, String? department})>((ref, arg) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getStudents(search: arg.search, department: arg.department);
});

final adminStaffProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, ({String? search, String? department})>((ref, arg) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getStaff(search: arg.search, department: arg.department);
});

final adminDepartmentsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getDepartments();
});

final adminComplaintsProvider = FutureProvider.autoDispose.family<List<ComplaintModel>, ({String? search, String? department, String? status, String? priority, String? category})>((ref, arg) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getComplaints(
    search: arg.search,
    department: arg.department,
    status: arg.status,
    priority: arg.priority,
    category: arg.category,
  );
});
