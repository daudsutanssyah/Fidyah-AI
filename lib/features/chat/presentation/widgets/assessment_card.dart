import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:intl/intl.dart';
import 'package:fidyah_ai/core/theme/app_colors.dart';
import 'package:fidyah_ai/core/theme/app_text_styles.dart';
import 'package:fidyah_ai/core/constants/app_strings.dart';
import 'package:fidyah_ai/features/chat/models/chat_message.dart';

class AssessmentCard extends StatelessWidget {
  final FidyahAssessmentData assessment;
  final VoidCallback onTunaikan;
  final ValueChanged<int>? onUpdateHari;
  final bool isProcessing;
  final bool isPaid;
  final String? paymentRef;

  const AssessmentCard({
    super.key,
    required this.assessment,
    required this.onTunaikan,
    this.onUpdateHari,
    this.isProcessing = false,
    this.isPaid = false,
    this.paymentRef,
  });

  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return '${AppStrings.currencyPrefix}${formatter.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              FlutterIslamicIcons.solidZakat,
              color: AppColors.accent,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          // Card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          FlutterIslamicIcons.solidZakat,
                          color: AppColors.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.assessmentTitle,
                            style: AppTextStyles.labelBold.copyWith(
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content Rows
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildRow(
                          AppStrings.assessmentAlasan,
                          assessment.alasan,
                        ),
                        const SizedBox(height: 10),
                        _buildAdjustableHariRow(context),
                        const SizedBox(height: 10),
                        _buildRow(
                          AppStrings.assessmentKategori,
                          assessment.kategoriBeras,
                          tooltipMsg: assessment.edukasiPerbandingan,
                        ),
                        const SizedBox(height: 10),
                        _buildRow(
                          AppStrings.assessmentHargaPerHari,
                          _formatCurrency(assessment.hargaPerHari),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        // Total row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                AppStrings.assessmentTotal,
                                style: AppTextStyles.labelBold.copyWith(
                                  fontSize: 16,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: Text(
                                _formatCurrency(assessment.total),
                                textAlign: TextAlign.right,
                                style: AppTextStyles.heading3.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Transparency Info
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.verified_user_outlined,
                                color: AppColors.success,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Dana akan disalurkan melalui ',
                                      ),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Tooltip(
                                          message:
                                              'Transaksi aman dan diawasi lembaga resmi.',
                                          triggerMode: TooltipTriggerMode.tap,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          textStyle: AppTextStyles.caption
                                              .copyWith(color: Colors.white),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryDark
                                                .withValues(alpha: 0.9),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            'Rekening Resmi BAZNAS',
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.success,
                                                  fontSize: 11,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const TextSpan(
                                        text:
                                            ' untuk paket makanan pokok fakir miskin.',
                                      ),
                                    ],
                                  ),
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // CTA Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isPaid
                                ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Fidyah untuk sesi ini telah berhasil ditunaikan. Terima kasih atas kepedulian Anda.',
                                        ),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );
                                  }
                                : (isProcessing ? null : onTunaikan),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPaid
                                  ? AppColors.primaryDark
                                  : AppColors.accent,
                              foregroundColor: isPaid
                                  ? Colors.white
                                  : AppColors.textOnAccent,
                              disabledBackgroundColor: AppColors.accent
                                  .withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: isPaid ? 0 : 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isPaid
                                      ? Icons.check_circle
                                      : (isProcessing
                                            ? Icons.hourglass_top_rounded
                                            : Icons.lock_rounded),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    isPaid
                                        ? 'Lunas - Alhamdulillah'
                                        : '${AppStrings.assessmentCtaPrefix} ${_formatCurrency(assessment.total)}',
                                    style: AppTextStyles.buttonLarge.copyWith(
                                      color: isPaid
                                          ? Colors.white
                                          : AppColors.textOnAccent,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!isProcessing && !isPaid) ...[
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Paid Status Info (Audit Trail)
                        if (isPaid) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'ID Transaksi: ${paymentRef ?? 'BZNS-${DateTime.now().millisecondsSinceEpoch}'}\nDana dalam proses penyaluran resmi BAZNAS.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],

                        // Note
                        if (assessment.catatan != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                size: 14,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${AppStrings.assessmentNote}: ${assessment.catatan}. Penyaluran dikelola oleh lembaga amil zakat terverifikasi.',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 11,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {String? tooltipMsg}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (tooltipMsg != null && tooltipMsg.isNotEmpty) ...[
                const SizedBox(width: 4),
                Tooltip(
                  message: tooltipMsg,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(12),
                  textStyle: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  triggerMode: TooltipTriggerMode.tap,
                  child: const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.labelBold,
          ),
        ),
      ],
    );
  }

  Widget _buildAdjustableHariRow(BuildContext context) {
    if (onUpdateHari == null) {
      return _buildRow(AppStrings.assessmentHari, '${assessment.hari} hari');
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            AppStrings.assessmentHari,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: assessment.hari > 1 && !isProcessing
                    ? () => onUpdateHari!(assessment.hari - 1)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.primaryDark,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Text(
                '${assessment.hari} hari',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelBold.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: !isProcessing
                    ? () => onUpdateHari!(assessment.hari + 1)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.accent,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
