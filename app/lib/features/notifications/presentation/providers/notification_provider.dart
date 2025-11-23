import 'package:flutter/material.dart';
import '../../domain/entities/notification.dart' as entity;
import '../../domain/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;
  List<entity.Notification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  NotificationProvider(this._repository);

  List<entity.Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.read).length;

  Future<void> fetchNotifications(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _repository.getNotifications(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        // Create a new list with the updated notification to ensure immutability if needed
        // But for now, just replacing the item is fine or re-fetching.
        // To avoid re-fetching, we can manually update the local list.
        // Since Notification is immutable, we create a new instance.
        // However, Notification doesn't have copyWith. I should probably add it or just re-fetch.
        // Re-fetching ensures sync with server but is slower.
        // Let's just update the local state for responsiveness.
        // I'll assume I can't easily copyWith without adding it.
        // I'll just re-fetch for now or just ignore the local update if I don't want to add copyWith yet.
        // Actually, let's just update the read status in the list by creating a new object.
        // I'll add copyWith to Notification entity later if needed.
        // For now, I'll just re-fetch to be safe and simple.
        // Or better, I'll just manually toggle the read status in the UI or rely on fetch.
        // Let's try to update locally.
        // Since I didn't add copyWith, I'll just re-fetch.
        // wait, I can just modify the list if I make the fields not final? No, they are final.
        // I will add copyWith to the entity.
        // Optimistic update:
        final updatedList = _notifications.map((n) {
          if (n.id == notificationId) {
            return entity.Notification(
              id: n.id,
              userId: n.userId,
              type: n.type,
              title: n.title,
              message: n.message,
              data: n.data,
              read: true,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();
        _notifications = updatedList;
        notifyListeners();
      }
    } catch (e) {
      // Handle error - could log to analytics or show user message
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _repository.markAllAsRead(userId);
      _notifications = _notifications
          .map(
            (n) => entity.Notification(
              id: n.id,
              userId: n.userId,
              type: n.type,
              title: n.title,
              message: n.message,
              data: n.data,
              read: true,
              createdAt: n.createdAt,
            ),
          )
          .toList();
      notifyListeners();
    } catch (e) {
      // Handle error - could log to analytics or show user message
    }
  }
}
