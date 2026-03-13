import 'dart:convert';
import 'package:supermarket_flutter_app/core/services/api_service.dart';
import '../../../core/models/notification.dart';

class NotificationRepository {
  Future<List<NotificationModel>> getNotifications() async {
    final response = await ApiService.get('/notifications');
    ApiService.handleError(response);
    final List data = jsonDecode(response.body);
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<void> markAsRead(int id) async {
    final response = await ApiService.put('/notifications/$id/read', {});
    ApiService.handleError(response);
  }
}