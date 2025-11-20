import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient supabaseClient;

  NotificationRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final response = await supabaseClient
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await supabaseClient
        .from('notifications')
        .update({'read': true})
        .eq('id', notificationId);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await supabaseClient
        .from('notifications')
        .update({'read': true})
        .eq('user_id', userId)
        .eq('read', false);
  }
}
