import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_provider.dart';

final staffStudentsProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String?>((ref, search) async {
  final api = ref.watch(apiServiceProvider);
  try {
    final queryParams = <String, dynamic>{};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    final response = await api.get('/staff/students', queryParameters: queryParams);
    if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
      final list = response.data['data'] as List;
      return list.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return [];
  } catch (e) {
    debugPrint('Error in staffStudentsProvider: $e');
    rethrow;
  }
});
