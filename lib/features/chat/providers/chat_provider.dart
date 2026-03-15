import 'dart:math';
import 'package:fidyah_ai/core/services/gemini_services.dart';
import 'package:fidyah_ai/core/services/hive_storage_service.dart';
import 'package:fidyah_ai/features/chat/models/chat_session.dart';
import 'package:fidyah_ai/main.dart'; // for hiveStorageProvider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import 'package:google_generative_ai/google_generative_ai.dart'
    hide ChatSession; // for Content

/// State for the chat screen
class ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final bool isProcessingPayment;
  final FidyahAssessmentData? lastAssessment;
  final String? paymentRefNumber;
  final int currentStep; // 1: Konsultasi, 2: Assessment, 3: Niat & Bayar

  // History related
  final String? currentSessionId;
  final List<ChatSession> history;
  final String? errorSnackBarMessage;

  bool get isPaid {
    if (currentSessionId == null) return false;
    try {
      final session = history.firstWhere((s) => s.id == currentSessionId);
      return session.isPaid;
    } catch (_) {
      return false;
    }
  }

  String? get paymentRef {
    if (currentSessionId == null) return paymentRefNumber;
    try {
      final session = history.firstWhere((s) => s.id == currentSessionId);
      return session.paymentRef ?? paymentRefNumber;
    } catch (_) {
      return paymentRefNumber;
    }
  }

  const ChatState({
    this.messages = const [],
    this.isTyping = false,
    this.isProcessingPayment = false,
    this.lastAssessment,
    this.paymentRefNumber,
    this.currentStep = 1,
    this.currentSessionId,
    this.history = const [],
    this.errorSnackBarMessage,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    bool? isProcessingPayment,
    FidyahAssessmentData? lastAssessment,
    String? paymentRefNumber,
    int? currentStep,
    String? currentSessionId,
    List<ChatSession>? history,
    String? errorSnackBarMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      isProcessingPayment: isProcessingPayment ?? this.isProcessingPayment,
      lastAssessment: lastAssessment ?? this.lastAssessment,
      paymentRefNumber: paymentRefNumber ?? this.paymentRefNumber,
      currentStep: currentStep ?? this.currentStep,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      history: history ?? this.history,
      errorSnackBarMessage: errorSnackBarMessage,
    );
  }
}

/// Chat state notifier
class ChatNotifier extends StateNotifier<ChatState> {
  final GeminiServices _geminiServices;
  final HiveStorageService _storageService;

  ChatNotifier(this._geminiServices, this._storageService)
    : super(const ChatState()) {
    _initHistory();
    _startNewSessionInternal();
  }

  void _initHistory() {
    state = state.copyWith(history: _storageService.getAllSessions());
  }

  void _startNewSessionInternal() {
    _geminiServices.startNewSession(); // start fresh Gemini session
    final welcomeMsg = ChatMessage(
      text:
          'Assalamualaikum! 👋\n\n'
          'Ceritakan kondisi puasa Anda tahun lalu. Misalnya:\n'
          '"Saya batal puasa 10 hari karena menyusui bayi."',
      type: MessageType.ai,
    );
    state = state.copyWith(
      messages: [welcomeMsg],
      currentSessionId: null,
      lastAssessment: null,
      currentStep: 1,
    );
  }

  void startNewSession() {
    _startNewSessionInternal();
  }

  void loadSession(String id) {
    final session = _storageService.getSession(id);
    if (session == null) return;

    // Convert existing ChatMessage to google_generative_ai Content for history
    List<Content> geminiHistory = [];
    for (var msg in session.messages) {
      if (msg.type == MessageType.user) {
        geminiHistory.add(Content.text(msg.text));
      } else if (msg.type == MessageType.ai) {
        geminiHistory.add(Content.model([TextPart(msg.text)]));
      }
    }
    _geminiServices.startNewSession(history: geminiHistory);

    state = state.copyWith(
      messages: session.messages,
      currentSessionId: session.id,
      lastAssessment: session.lastAssessment,
      currentStep: session.lastAssessment != null
          ? (session.isPaid ? 3 : 2)
          : 1,
    );
  }

  Future<void> deleteSession(String id) async {
    await _storageService.deleteSession(id);
    _initHistory();
    if (state.currentSessionId == id) {
      startNewSession();
    }
  }

  Future<void> renameSession(String id, String newTitle) async {
    final session = _storageService.getSession(id);
    if (session != null) {
      final updated = session.copyWith(
        title: newTitle,
        updatedAt: DateTime.now(),
      );
      await _storageService.saveSession(updated);
      _initHistory();
    }
  }

  void _saveCurrentContentToSession() {
    if (state.currentSessionId != null) {
      final existing = _storageService.getSession(state.currentSessionId!);
      if (existing != null) {
        final updated = existing.copyWith(
          messages: state.messages,
          lastAssessment: state.lastAssessment,
          updatedAt: DateTime.now(),
        );
        _storageService.saveSession(updated).then((_) {
          // Silent update history to refresh UI in drawer
          state = state.copyWith(history: _storageService.getAllSessions());
        });
      }
    }
  }

  Future<void> _handleAutoTitle(String sessionId, String text) async {
    final title = await _geminiServices.generateChatTitle(text);
    final existing = _storageService.getSession(sessionId);
    if (existing != null) {
      final updated = existing.copyWith(title: title);
      await _storageService.saveSession(updated);
      state = state.copyWith(history: _storageService.getAllSessions());
    }
  }

  /// Send a user message and get AI response
  Future<void> sendUserMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMsg = ChatMessage(text: text.trim(), type: MessageType.user);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
      errorSnackBarMessage: null, // Clear previous error
    );

    if (text.trim().toLowerCase().contains('test bayar')) {
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Sim mimic delay
      final mockAssessment = FidyahAssessmentData(
        alasan: 'Uzur Syar\'i (Testing)',
        hari: 7,
        kategoriBeras: 'Sesuai SK BAZNAS',
        hargaPerHari: 60000,
        total: 420000,
        catatan: 'Setara 1.5 kg beras/hari (Mock Mode)',
        edukasiPerbandingan: 'Ini adalah mode percobaan tanpa API.',
      );

      final mockAiMsg = ChatMessage(
        text:
            'Ini adalah simulasi Assessment Card untuk testing tanpa memotong kuota API Gemini. Silakan coba fitur pembayaran di bawah ini.',
        type: MessageType.ai,
      );

      final mockAssessmentMsg = ChatMessage(
        text: '',
        type: MessageType.assessment,
        assessment: mockAssessment,
      );

      state = state.copyWith(
        messages: [...state.messages, mockAiMsg, mockAssessmentMsg],
        isTyping: false,
        lastAssessment: mockAssessment,
        currentStep: 2,
      );
      _saveCurrentContentToSession();
      return;
    }
    bool isFirstUserMessage = false;
    if (state.currentSessionId == null) {
      isFirstUserMessage = true;
      final newSession = ChatSession(
        messages: state.messages,
        lastAssessment: state.lastAssessment,
      );
      state = state.copyWith(currentSessionId: newSession.id);
      await _storageService.saveSession(newSession);
    } else {
      _saveCurrentContentToSession();
    }

    // Trigger auto-title lazily (doesn't block UI)
    if (isFirstUserMessage && state.currentSessionId != null) {
      _handleAutoTitle(state.currentSessionId!, text);
    }

    // Human-friendly delay to prevent spamming and mimic thinking
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final responseMap = await _geminiServices.sendMessage(text);

      final responseObj = responseMap['response'] as Map<String, dynamic>?;
      if (responseObj == null) {
        throw Exception('Format JSON tidak sesuai dengan skema BAZNAS.');
      }

      final salam = responseObj['salam'] as String? ?? '';
      final jawaban = responseObj['jawaban'] as Map<String, dynamic>?;
      final penjelasan =
          jawaban?['penjelasan'] as String? ??
          'Maaf, format jawaban tidak valid.';
      final penutup = responseObj['penutup'] as String? ?? '';

      final displayMessageParts = [
        salam,
        penjelasan,
        penutup,
      ].where((e) => e.trim().isNotEmpty).toList();
      final displayMessage = displayMessageParts.join('\n\n');

      final perhitungan =
          jawaban?['perhitungan_fidyah'] as Map<String, dynamic>?;

      // Parse boolean value robustly
      bool isAssessmentReady = false;
      if (perhitungan != null) {
        final berlaku = perhitungan['berlaku'];
        if (berlaku is bool) {
          isAssessmentReady = berlaku;
        } else if (berlaku is String) {
          isAssessmentReady = berlaku.toLowerCase() == 'true';
        }
      }

      // Parse quick replies
      List<String> quickRepliesList = [];
      if (responseObj['quick_replies'] is List) {
        quickRepliesList = (responseObj['quick_replies'] as List)
            .map((e) => e.toString())
            .toList();
      }

      final aiMsg = ChatMessage(
        text: displayMessage,
        type: MessageType.ai,
        quickReplies: quickRepliesList,
      );

      FidyahAssessmentData? assessmentData;
      ChatMessage? assessmentMsg;
      int newStep = state.currentStep;

      if (isAssessmentReady) {
        final hari =
            int.tryParse(perhitungan?['jumlah_hari']?.toString() ?? '0') ?? 0;
        final hargaPerHari =
            int.tryParse(
              perhitungan?['tarif_per_hari']?.toString() ?? '60000',
            ) ??
            60000;
        final total =
            int.tryParse(
              perhitungan?['total_fidyah_rupiah']?.toString() ??
                  '${hari * hargaPerHari}',
            ) ??
            (hari * hargaPerHari);

        final alasan = responseObj['topik'] as String? ?? 'Uzur Syar\'i';
        final setaraBeras =
            perhitungan?['setara_beras_kg']?.toString() ?? '1.5';
        final edukasi = perhitungan?['edukasi_perbandingan']?.toString();

        assessmentData = FidyahAssessmentData(
          alasan: alasan,
          hari: hari,
          kategoriBeras: 'Sesuai SK BAZNAS',
          hargaPerHari: hargaPerHari,
          total: total,
          catatan: 'Setara $setaraBeras kg beras/hari',
          edukasiPerbandingan: edukasi,
        );

        assessmentMsg = ChatMessage(
          text: '',
          type: MessageType.assessment,
          assessment: assessmentData,
        );
        newStep = 2; // Pindah ke step Assessment
      }

      state = state.copyWith(
        messages: [
          ...state.messages,
          aiMsg,
          if (assessmentMsg != null) assessmentMsg,
        ],
        isTyping: false,
        lastAssessment: assessmentData,
        currentStep: newStep,
      );

      _saveCurrentContentToSession();
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      String humanMessage =
          'Mohon maaf, sistem mengalami kesalahan saat memproses pesan: $e';
      bool showAsSnackBar = false;

      // Islamic & Human friendly error handling
      if (errorStr.contains('quota exceeded') ||
          errorStr.contains('rate limit') ||
          errorStr.contains('429')) {
        humanMessage =
            'Mohon maaf, sistem sedang sibuk melayani banyak antrian. Silakan tunggu 30 detik atau coba lagi nanti.';
        showAsSnackBar = true;
      }

      if (showAsSnackBar) {
        state = state.copyWith(
          isTyping: false,
          errorSnackBarMessage: humanMessage,
        );
      } else {
        final errorMsg = ChatMessage(text: humanMessage, type: MessageType.ai);
        state = state.copyWith(
          messages: [...state.messages, errorMsg],
          isTyping: false,
        );
      }
      _saveCurrentContentToSession();
    }
  }

  /// Update jumlah hari di assessment yang sedang aktif
  void updateAssessment(int newHari) {
    if (state.lastAssessment == null) return;

    final current = state.lastAssessment!;
    final newTotal = newHari * current.hargaPerHari;

    final updatedAssessment = FidyahAssessmentData(
      alasan: current.alasan,
      hari: newHari,
      kategoriBeras: current.kategoriBeras,
      hargaPerHari: current.hargaPerHari,
      total: newTotal,
      catatan: current.catatan,
      edukasiPerbandingan: current.edukasiPerbandingan,
    );

    // Update message lists to reflect new assessment
    final updatedMessages = state.messages.map((msg) {
      if (msg.type == MessageType.assessment && msg.assessment != null) {
        return msg.copyWith(assessment: updatedAssessment);
      }
      return msg;
    }).toList();

    state = state.copyWith(
      messages: updatedMessages,
      lastAssessment: updatedAssessment,
    );
    _saveCurrentContentToSession();
  }

  /// Go to Step 3: Niat & Bayar
  void setStepNiat() {
    state = state.copyWith(currentStep: 3);
  }

  /// Process mock payment
  Future<void> processPayment() async {
    state = state.copyWith(isProcessingPayment: true);

    // Simulate server processing (2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    // Generate dummy reference number e.g FID/2026/0314/001
    final now = DateTime.now();
    final year = now.year.toString();
    final date =
        '${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomStr = (Random().nextInt(900) + 100)
        .toString(); // 3 digit random
    final ref = 'FID/$year/$date/$randomStr';

    state = state.copyWith(isProcessingPayment: false, paymentRefNumber: ref);
  }

  /// Reset for new session
  void resetSession() {
    startNewSession();
  }

  /// Mark current session as paid
  void markAsPaid() {
    if (state.currentSessionId != null) {
      final session = _storageService.getSession(state.currentSessionId!);
      if (session != null) {
        final updated = session.copyWith(
          isPaid: true,
          paymentRef: state.paymentRefNumber,
        );
        _storageService.saveSession(updated).then((_) {
          state = state.copyWith(history: _storageService.getAllSessions());
        });
      }
    }
  }

  /// Clear payment reference (after navigating to success)
  void clearPaymentRef() {
    // Mark session as paid
    if (state.currentSessionId != null) {
      final session = _storageService.getSession(state.currentSessionId!);
      if (session != null) {
        final updated = session.copyWith(
          isPaid: true,
          paymentRef: state.paymentRefNumber,
        );
        _storageService.saveSession(updated).then((_) {
          state = state.copyWith(history: _storageService.getAllSessions());
        });
      }
    }

    state = ChatState(
      messages: state.messages,
      isTyping: false,
      isProcessingPayment: false,
      lastAssessment: state.lastAssessment,
      paymentRefNumber: null,
      currentStep: 1, // Reset step
      currentSessionId: state.currentSessionId,
      history: state.history,
    );
  }

  /// Clear the error snackbar message
  void clearErrorMessage() {
    state = state.copyWith(errorSnackBarMessage: null);
  }

  /// Toggle Mock Mode in GeminiServices
  void toggleMockMode(bool value) {
    _geminiServices.isMockMode = value;
    state = state
        .copyWith(); // Trigger rebuild if needed, though GeminiServices state is external
  }

  bool get isMockMode => _geminiServices.isMockMode;
}

/// Helper method to return Niat text based on alasan
Map<String, String> getNiatFidyah(String alasan) {
  final lAlasan = alasan.toLowerCase();

  if (lAlasan.contains('hamil') || lAlasan.contains('menyusui')) {
    return {
      'arab':
          'نَوَيْتُ أَنْ أُخْرِجَ فِدْيَةَ الصَّوْمِ عَنْ نَفْسِيْ لِلْحَمْلِ/لِلرَّضَاعِ فَرْضًا لِلَّهِ تَعَالَى',
      'latin':
          'Nawaitu an ukhrija fidyatash shaumi \'an nafsî lilhamli/lirradhâ\'i fardhan lillâhi ta\'âlâ',
      'arti':
          'Aku niat mengeluarkan fidyah puasa dari diriku karena hamil/menyusui, fardhu karena Allah Ta\'ala.',
    };
  } else if (lAlasan.contains('meninggal') || lAlasan.contains('mait')) {
    return {
      'arab':
          'نَوَيْتُ أَنْ أُخْرِجَ فِدْيَةَ الصَّوْمِ عَنْ (فُلانِ بْنِ فُلانٍ) فَرْضًا لِلَّهِ تَعَالَى',
      'latin':
          'Nawaitu an ukhrija fidyatash shaumi \'an (sebut nama fulan) fardhan lillâhi ta\'âlâ',
      'arti':
          'Aku niat mengeluarkan fidyah puasa dari (sebutkan nama orang yang meninggal), fardhu karena Allah Ta\'ala.',
    };
  } else {
    // Default for sakit/tua/dll
    return {
      'arab':
          'نَوَيْتُ أَنْ أُخْرِجَ فِدْيَةَ الصَّوْمِ عَنْ نَفْسِيْ لِلْمَرَضِ/لِلْكِبَرِ فَرْضًا لِلَّهِ تَعَالَى',
      'latin':
          'Nawaitu an ukhrija fidyatash shaumi \'an nafsî lilmaradhi/lilkibari fardhan lillâhi ta\'âlâ',
      'arti':
          'Aku niat mengeluarkan fidyah puasa atas diriku karena sakit/tua renta, fardhu karena Allah Ta\'ala.',
    };
  }
}

final geminiServicesProvider = Provider<GeminiServices>((ref) {
  return GeminiServices();
});

/// Provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final geminiServices = ref.watch(geminiServicesProvider);
  final storageService = ref.watch(hiveStorageProvider);
  return ChatNotifier(geminiServices, storageService);
});
