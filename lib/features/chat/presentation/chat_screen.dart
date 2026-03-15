import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart'
    show FlutterIslamicIcons;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fidyah_ai/core/theme/app_colors.dart';
import 'package:fidyah_ai/core/theme/app_text_styles.dart';
import 'package:fidyah_ai/core/constants/app_strings.dart';
import 'package:fidyah_ai/features/chat/models/chat_message.dart';
import 'package:fidyah_ai/features/chat/providers/chat_provider.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/typing_indicator.dart';
import 'widgets/assessment_card.dart';
import 'widgets/payment_loading_overlay.dart';
import 'widgets/chat_history_drawer.dart';
import 'widgets/payment_selection_sheet.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);

    // Listen for payment completion → navigate to success
    ref.listen<ChatState>(chatProvider, (prev, next) {
      if (next.paymentRefNumber != null &&
          !next.isProcessingPayment &&
          (prev?.paymentRefNumber == null ||
              prev?.isProcessingPayment == true)) {
        context.go('/success');
      }
    });

    // Auto-scroll when messages change
    ref.listen<ChatState>(chatProvider, (_, __) {
      _scrollToBottom();
    });

    // Listen for error messages
    ref.listen(chatProvider.select((s) => s.errorSnackBarMessage), (
      prev,
      next,
    ) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
        ref.read(chatProvider.notifier).clearErrorMessage();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const ChatHistoryDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                FlutterIslamicIcons.solidZakat,
                color: AppColors.accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appName,
                  style: AppTextStyles.labelBold.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                if (state.isTyping)
                  Text(
                    AppStrings.chatTyping,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accent.withValues(alpha: 0.9),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) {
              if (v == 'reset') {
                ref.read(chatProvider.notifier).resetSession();
              } else if (v == 'toggle_mock') {
                final notifier = ref.read(chatProvider.notifier);
                notifier.toggleMockMode(!notifier.isMockMode);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      notifier.isMockMode
                          ? 'Demo Mode Aktif (Mock)'
                          : 'Real API Mode Aktif',
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 18),
                    SizedBox(width: 8),
                    Text('Mulai Ulang'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_mock',
                child: Row(
                  children: [
                    Icon(
                      ref.watch(chatProvider.notifier).isMockMode
                          ? Icons.bug_report
                          : Icons.api,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ref.watch(chatProvider.notifier).isMockMode
                          ? 'Gunakan Real API'
                          : 'Mode Demo (Mock)',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: state.currentStep / 3,
            backgroundColor: AppColors.primaryDark.withValues(alpha: 0.5),
            color: AppColors.accent,
            minHeight: 4,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Main chat content
          Column(
            children: [
              // Messages list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Typing indicator at the end
                    if (index == state.messages.length && state.isTyping) {
                      return const TypingIndicator()
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.2, end: 0);
                    }

                    final message = state.messages[index];

                    // Assessment card
                    if (message.type == MessageType.assessment &&
                        message.assessment != null) {
                      return Column(
                        children: [
                          AssessmentCard(
                                assessment: message.assessment!,
                                isProcessing: state.isProcessingPayment,
                                isPaid: state.isPaid,
                                paymentRef: state.paymentRef,
                                onUpdateHari: !state.isPaid
                                    ? (newHari) {
                                        ref
                                            .read(chatProvider.notifier)
                                            .updateAssessment(newHari);
                                      }
                                    : null,
                                onTunaikan: () {
                                  if (!state.isPaid) {
                                    ref
                                        .read(chatProvider.notifier)
                                        .setStepNiat();
                                    _showNiatBottomSheet(
                                      context,
                                      state,
                                      message.assessment!.alasan,
                                    );
                                  }
                                },
                              )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: 0.15, end: 0, duration: 400.ms),
                          if (message.quickReplies.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                                left: 16,
                                right: 16,
                              ),
                              child:
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: message.quickReplies.map((reply) {
                                      return ActionChip(
                                        label: Text(
                                          reply,
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                        backgroundColor: AppColors.accent
                                            .withValues(alpha: 0.2),
                                        side: BorderSide(
                                          color: AppColors.accent.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                        onPressed: () {
                                          ref
                                              .read(chatProvider.notifier)
                                              .sendUserMessage(reply);
                                        },
                                      );
                                    }).toList(),
                                  ).animate().fadeIn(
                                    duration: 400.ms,
                                    delay: 200.ms,
                                  ),
                            ),
                        ],
                      );
                    }

                    // Regular bubble + Quick Replies
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ChatBubble(message: message)
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .slideX(
                              begin: message.type == MessageType.user
                                  ? 0.1
                                  : -0.1,
                              end: 0,
                              duration: 300.ms,
                            ),
                        if (message.quickReplies.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                              left: 16,
                              right: 16,
                            ),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: message.quickReplies.map((reply) {
                                return ActionChip(
                                  label: Text(
                                    reply,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  backgroundColor: AppColors.accent.withValues(
                                    alpha: 0.2,
                                  ),
                                  side: BorderSide(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(chatProvider.notifier)
                                        .sendUserMessage(reply);
                                  },
                                );
                              }).toList(),
                            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                          ),
                      ],
                    );
                  },
                ),
              ),

              // Input bar
              ChatInputBar(
                enabled: !state.isTyping && !state.isProcessingPayment,
                onSend: (text) {
                  ref.read(chatProvider.notifier).sendUserMessage(text);
                },
              ),
            ],
          ),

          // Payment loading overlay
          if (state.isProcessingPayment) const PaymentLoadingOverlay(),
        ],
      ),
    );
  }

  void _showPaymentMethodsBottomSheet(BuildContext context, ChatState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PaymentSelectionSheet(
        onMethodSelected: () async {
          // Proceed to process payment simulation
          await ref.read(chatProvider.notifier).processPayment();
          if (context.mounted) {
            context.go('/success');
          }
        },
      ),
    );
  }

  void _showNiatBottomSheet(
    BuildContext context,
    ChatState state,
    String alasan,
  ) {
    final niatData = getNiatFidyah(alasan);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Niat Membayar Fidyah',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      niatData['arab']!,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily:
                            'Amiri', // Or any typical arabic font in your project
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      niatData['latin']!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      '"${niatData['arti']!}"',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showPaymentMethodsBottomSheet(context, state);
                  },
                  child: Text(
                    'Saya Niat & Lanjut Bayar',
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
