import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class CreateNotification {
  final NotificationRepository repository;

  CreateNotification(this.repository);

  Future<void> call(Notification notification) async {
    // This would need to be implemented in the repository and data source
    // For now, this is a placeholder
  }
}