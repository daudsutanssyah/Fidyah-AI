/// Model for individual chat messages
enum MessageType {
  user,
  ai,
  assessment;

  String toJson() => name;
  static MessageType fromJson(String json) => values.byName(json);
}

class ChatMessage {
  final String text;
  final MessageType type;
  final DateTime timestamp;
  final FidyahAssessmentData? assessment;
  final List<String> quickReplies;

  ChatMessage({
    required this.text,
    required this.type,
    DateTime? timestamp,
    this.assessment,
    this.quickReplies = const [],
  }) : timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? text,
    MessageType? type,
    DateTime? timestamp,
    FidyahAssessmentData? assessment,
    List<String>? quickReplies,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      assessment: assessment ?? this.assessment,
      quickReplies: quickReplies ?? this.quickReplies,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'type': type.toJson(),
    'timestamp': timestamp.toIso8601String(),
    'assessment': assessment?.toJson(),
    'quickReplies': quickReplies,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      type: MessageType.fromJson(json['type'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      assessment: json['assessment'] != null
          ? FidyahAssessmentData.fromJson(
              Map<String, dynamic>.from(json['assessment']),
            )
          : null,
      quickReplies:
          (json['quickReplies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

/// Structured data extracted from AI for fidyah calculation
class FidyahAssessmentData {
  final String alasan;
  final int hari;
  final String kategoriBeras;
  final int hargaPerHari;
  final int total;
  final String? catatan;
  final String? edukasiPerbandingan;

  const FidyahAssessmentData({
    required this.alasan,
    required this.hari,
    required this.kategoriBeras,
    required this.hargaPerHari,
    required this.total,
    this.catatan,
    this.edukasiPerbandingan,
  });

  factory FidyahAssessmentData.fromJson(Map<String, dynamic> json) {
    final hari = json['hari'] as int;
    final hargaPerHari = json['harga_per_hari'] as int;
    return FidyahAssessmentData(
      alasan: json['alasan'] as String,
      hari: hari,
      kategoriBeras: json['kategori_beras'] as String,
      hargaPerHari: hargaPerHari,
      total: json['total'] as int? ?? (hari * hargaPerHari),
      catatan: json['catatan'] as String?,
      edukasiPerbandingan: json['edukasi_perbandingan'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'alasan': alasan,
    'hari': hari,
    'kategori_beras': kategoriBeras,
    'harga_per_hari': hargaPerHari,
    'total': total,
    'catatan': catatan,
    'edukasi_perbandingan': edukasiPerbandingan,
  };
}
