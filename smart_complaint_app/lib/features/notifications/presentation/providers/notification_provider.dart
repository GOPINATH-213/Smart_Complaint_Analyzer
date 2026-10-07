import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/routing/app_router.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return NotificationService(apiService);
});

final initializeNotificationsProvider = FutureProvider<void>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  await notificationService.initialize();
});

final notificationTapHandlerProvider = Provider<void>((ref) {
  final authState = ref.watch(authStateProvider);
  final profileAsync = ref.watch(userProfileProvider);
  final router = ref.watch(routerProvider);

  void handlePayload(Map<String, dynamic> payload) {
    try {
      final String? type = payload['type'];
      final String? complaintId = payload['complaintId'];
      
      if (complaintId != null && complaintId.isNotEmpty && (type == 'complaint_update' || type == 'escalation')) {
        router.push('/complaint-detail/$complaintId');
      } else {
        router.push('/notifications');
      }
    } catch (e) {
      // Safely fallback
      router.push('/notifications');
    }
  }

  // Bind the global listener to process taps
  NotificationService.onPayloadTapped = (payload) {
    if (authState.value != null && profileAsync is AsyncData && profileAsync.value != null) {
      handlePayload(payload);
    } else {
      NotificationService.pendingPayload = payload;
    }
  };

  // Process any pending payload once authenticated
  if (authState.value != null && profileAsync is AsyncData && profileAsync.value != null) {
    final pending = NotificationService.pendingPayload;
    if (pending != null) {
      // Clear it before handling to avoid loops
      NotificationService.pendingPayload = null;
      // Delay navigation slightly to ensure the router has finished rendering
      Future.microtask(() {
        handlePayload(pending);
      });
    }
  }
});

final notificationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/notifications');
  if (response.statusCode == 200 && response.data['success']) {
    return response.data['data'];
  }
  return [];
});
