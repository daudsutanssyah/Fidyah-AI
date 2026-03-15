import 'package:uuid/uuid.dart';
import 'chat_message.dart';

/// Represents a single conversation session.
class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPaid;
  final String? paymentRef;
  final List<ChatMessage> messages;
  final FidyahAssessmentData? lastAssessment;

  ChatSession({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPaid = false,
    this.paymentRef,
    this.messages = const [],
    this.lastAssessment,
  }) : id = id ?? const Uuid().v4(),
       title = title ?? 'Konsultasi Fidyah',
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  ChatSession copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPaid,
    String? paymentRef,
    List<ChatMessage>? messages,
    FidyahAssessmentData? lastAssessment,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPaid: isPaid ?? this.isPaid,
      paymentRef: paymentRef ?? this.paymentRef,
      messages: messages ?? this.messages,
      lastAssessment: lastAssessment ?? this.lastAssessment,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isPaid': isPaid,
    'paymentRef': paymentRef,
    'messages': messages.map((m) => m.toJson()).toList(),
    'lastAssessment': lastAssessment?.toJson(),
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String?,
      title: json['title'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isPaid: json['isPaid'] as bool? ?? false,
      paymentRef: json['paymentRef'] as String?,
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessage.fromJson(Map<String, dynamic>.from(m)))
              .toList() ??
          [],
      lastAssessment: json['lastAssessment'] != null
          ? FidyahAssessmentData.fromJson(
              Map<String, dynamic>.from(json['lastAssessment']),
            )
          : null,
    );
  }
}
