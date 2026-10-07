import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../../../core/services/api_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final authStateProvider = StreamProvider((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  // Watch authState to make this provider reactive to logins/logouts
  final authState = ref.watch(authStateProvider);
  
  if (authState.isLoading) {
    return null;
  }

  final user = authState.value ?? ref.watch(authRepositoryProvider).currentUser;
  
  if (user == null) {
    return null;
  }

  final api = ref.watch(apiServiceProvider);
  try {
    final emailQuery = user.email != null && user.email!.isNotEmpty ? '?email=${Uri.encodeComponent(user.email!)}' : '';
    final res = await api.get('/users/profile/${user.uid}$emailQuery');
    if (res.statusCode == 200 && res.data != null && res.data['data'] != null) {
      return res.data['data'] as Map<String, dynamic>;
    }
    return null;
  } catch (e) {
    debugPrint('Error loading userProfileProvider: $e');
    return null;
  }
});
