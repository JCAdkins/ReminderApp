import 'package:dio/dio.dart';
import '../models/reminder_create.dart';
import '../api_client.dart';
import '../models/reminder.dart';
import '../api_exception.dart';
import '../../auth/auth_state.dart';

class ReminderService {
  final ApiClient api;

  ReminderService({ApiClient? api, required AuthState authState})
      : api = api ?? ApiClient(authState: authState);

  // ============================
  // CREATE REMINDER
  // ============================
  Future<Reminder> createReminder(ReminderCreateRequest reminder) async {
    try {
      final res = await api.dio.post(
        '/reminders',
        data: reminder.toJson(),
      );
      return Reminder.fromJson(res.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;

      if (status != null && data != null) {
        throw ApiException(data['detail'] ?? 'Failed to create reminder');
      }

      throw ApiException('Unexpected error creating reminder');
    } catch (_) {
      throw ApiException('Unexpected error creating reminder');
    }
  }

  // ============================
  // FETCH REMINDERS
  // ============================
  Future<List<Reminder>> fetchReminders() async {
    try {
      final res = await api.dio.get('/reminders');
      final List<dynamic> jsonData = res.data as List<dynamic>;
      return jsonData.map((e) => Reminder.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException(
          e.response?.data?['detail'] ?? 'Failed to fetch reminders');
    } catch (_) {
      throw ApiException('Unexpected error fetching reminders');
    }
  }

  // ============================
  // UPDATE REMINDERS
  // ============================
  Future<Reminder> updateReminder(
    String id,
    ReminderCreateRequest request,
  ) async {
    try {
      final res = await api.dio.put(
        '/reminders/$id',
        data: request.toJson(),
      );

      return Reminder.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException(
          e.response?.data?['detail'] ?? 'Failed to update reminder');
    } catch (_) {
      throw ApiException('Unexpected error updating reminder');
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      await api.dio.delete('/reminders/$id');
    } on DioException catch (e) {
      throw ApiException(
          e.response?.data?['detail'] ?? 'Failed to delete reminder');
    } catch (_) {
      throw ApiException('Unexpected error deleting reminder');
    }
  }
}
