import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:fidyah_ai/core/theme/app_colors.dart';
import 'package:fidyah_ai/core/theme/app_text_styles.dart';
import 'package:fidyah_ai/core/constants/app_strings.dart';
import 'package:fidyah_ai/features/chat/providers/chat_provider.dart';
import 'package:fidyah_ai/shared/widgets/animated_gradient_bg.dart';

class SuccessScreen extends ConsumerStatefulWidget {
  const SuccessScreen({super.key});

  @override
  ConsumerState<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends ConsumerState<SuccessScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return '${AppStrings.currencyPrefix}${formatter.format(amount)}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);
    final assessment = state.lastAssessment;
    final refNumber = state.paymentRefNumber ?? 'MYR-FID-00000';

    return Scaffold(
      body: Stack(
        children: [
          AnimatedGradientBg(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 32,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Success checkmark
                    Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success.withValues(alpha: 0.2),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.5),
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scale(
                          begin: const Offset(0.3, 0.3),
                          end: const Offset(1.0, 1.0),
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        ),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      AppStrings.successTitle,
                      style: AppTextStyles.heading1.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

                    const SizedBox(height: 8),

                    Text(
                      AppStrings.successSubtitle,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

                    const SizedBox(height: 32),

                    // Receipt Card
                    Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Receipt header
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.receipt_long_rounded,
                                      color: AppColors.success,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'PEMBAYARAN BERHASIL',
                                      style: AppTextStyles.labelBold.copyWith(
                                        color: AppColors.success,
                                        letterSpacing: 1,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Receipt body
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    _receiptRow(
                                      AppStrings.successRef,
                                      refNumber,
                                      isBold: true,
                                    ),
                                    const SizedBox(height: 10),
                                    _receiptRow(
                                      AppStrings.successDate,
                                      _formatDate(DateTime.now()),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      child: Divider(height: 1),
                                    ),
                                    if (assessment != null) ...[
                                      _receiptRow(
                                        AppStrings.assessmentAlasan,
                                        assessment.alasan,
                                      ),
                                      const SizedBox(height: 10),
                                      _receiptRow(
                                        AppStrings.assessmentHari,
                                        '${assessment.hari} hari',
                                      ),
                                      const SizedBox(height: 10),
                                      _receiptRow(
                                        AppStrings.assessmentKategori,
                                        assessment.kategoriBeras,
                                      ),
                                      const SizedBox(height: 10),
                                      _receiptRow(
                                        AppStrings.assessmentHargaPerHari,
                                        _formatCurrency(
                                          assessment.hargaPerHari,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        child: Divider(height: 1),
                                      ),
                                      _receiptRow(
                                        AppStrings.successTotal,
                                        _formatCurrency(assessment.total),
                                        isBold: true,
                                        valueColor: AppColors.primary,
                                        valueFontSize: 20,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 500.ms)
                        .slideY(
                          begin: 0.15,
                          end: 0,
                          delay: 600.ms,
                          duration: 500.ms,
                        ),

                    const SizedBox(height: 24),

                    // Doa Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            AppStrings.doaArabic,
                            style: AppTextStyles.arabic.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.doaTranslation,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 900.ms, duration: 500.ms),

                    const SizedBox(height: 16),

                    // Sedekah Verse
                    Text(
                      "«Perumpamaan orang yang menginfakkan hartanya di jalan Allah seperti sebutir biji yang menumbuhkan tujuh tangkai, pada setiap tangkai ada seratus biji...»\n(QS. Al-Baqarah: 261)",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ).animate().fadeIn(delay: 1100.ms, duration: 600.ms),

                    const SizedBox(height: 32),

                    // Download Receipt Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mengunduh tanda terima PDF...'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.file_download_outlined,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Download Tanda Terima',
                          style: AppTextStyles.buttonLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 1200.ms, duration: 400.ms),

                    const SizedBox(height: 16),

                    // Done button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(chatProvider.notifier).markAsPaid();
                          ref.read(chatProvider.notifier).clearPaymentRef();
                          context.go('/chat');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 8,
                        ),
                        child: Text(
                          AppStrings.successDone,
                          style: AppTextStyles.buttonLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 1100.ms, duration: 400.ms),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                AppColors.primary,
                AppColors.accent,
                Colors.yellow,
                Colors.green,
                Colors.orange,
              ],
              shouldLoop: false,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    double? valueFontSize,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: (isBold ? AppTextStyles.labelBold : AppTextStyles.bodyMedium)
                .copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontSize: valueFontSize,
                ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
