import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/models/complaint_model.dart';
import '../../data/repositories/complaint_repository.dart';

final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ComplaintRepository(apiService);
});

// Notifier for Student's My Complaints list
class MyComplaintsNotifier extends Notifier<AsyncValue<List<ComplaintModel>>> {
  @override
  AsyncValue<List<ComplaintModel>> build() {
    fetchMyComplaints();
    return const AsyncValue.loading();
  }

  Future<void> fetchMyComplaints() async {
    final repo = ref.read(complaintRepositoryProvider);
    final user = ref.read(authRepositoryProvider).currentUser;
    final uid = user?.uid ?? '';

    if (uid.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final complaints = await repo.getMyComplaints(uid);
      state = AsyncValue.data(complaints);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final myComplaintsProvider =
    NotifierProvider<MyComplaintsNotifier, AsyncValue<List<ComplaintModel>>>(
  MyComplaintsNotifier.new,
);

// Notifier for Department Staff complaints list & stats
class DepartmentComplaintsNotifier extends Notifier<AsyncValue<Map<String, dynamic>>> {
  @override
  AsyncValue<Map<String, dynamic>> build() {
    fetchDepartmentComplaints();
    return const AsyncValue.loading();
  }

  Future<void> fetchDepartmentComplaints() async {
    final repo = ref.read(complaintRepositoryProvider);
    final user = ref.read(authRepositoryProvider).currentUser;
    final uid = user?.uid ?? '';

    if (uid.isEmpty) {
      state = AsyncValue.data({
        'department': 'Unknown',
        'stats': DepartmentStats(total: 0, submitted: 0, inProgress: 0, resolved: 0, closed: 0),
        'complaints': <ComplaintModel>[],
      });
      return;
    }

    state = const AsyncValue.loading();
    try {
      final result = await repo.getDepartmentComplaints(uid);
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final departmentComplaintsProvider =
    NotifierProvider<DepartmentComplaintsNotifier, AsyncValue<Map<String, dynamic>>>(
  DepartmentComplaintsNotifier.new,
);
