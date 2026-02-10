import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_service.dart';
import '../models/call_log.dart';

class HistoryRepository {
  HistoryRepository(this._service);

  final SupabaseService _service;

  SupabaseClient get _client => _service.client;

  Future<List<CallLog>> fetchLogs({required String userId}) async {
    final response = await _client
        .from('call_logs')
        .select()
        .eq('user_id', userId)
        .order('started_at', ascending: false);

    final rows = response as List<dynamic>;
    return rows
        .whereType<Map<String, dynamic>>()
        .map(CallLog.fromMap)
        .toList();
  }

  Future<void> insertLog({
    required String userId,
    required String toNumber,
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationSec,
    required String status,
  }) async {
    await _client.from('call_logs').insert({
      'user_id': userId,
      'to_number': toNumber,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt.toIso8601String(),
      'duration_sec': durationSec,
      'status': status,
    });
  }
}
