class CallLog {
  CallLog({
    required this.id,
    required this.userId,
    required this.toNumber,
    required this.startedAt,
    required this.endedAt,
    required this.durationSec,
    required this.status,
  });

  final String id;
  final String userId;
  final String toNumber;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int durationSec;
  final String status;

  factory CallLog.fromMap(Map<String, dynamic> map) {
    return CallLog(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      toNumber: map['to_number']?.toString() ?? '',
      startedAt: _parseDate(map['started_at']),
      endedAt: _parseDate(map['ended_at']),
      durationSec: _parseInt(map['duration_sec']),
      status: map['status']?.toString() ?? 'unknown',
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.tryParse(value.toString());
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
