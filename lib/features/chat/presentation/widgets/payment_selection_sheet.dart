import 'package:flutter/material.dart';
import 'package:fidyah_ai/core/theme/app_colors.dart';
import 'package:fidyah_ai/core/theme/app_text_styles.dart';

class PaymentSelectionSheet extends StatelessWidget {
  final Future<void> Function() onMethodSelected;

  const PaymentSelectionSheet({super.key, required this.onMethodSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Metode Pembayaran', style: AppTextStyles.heading2),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('E-Wallet'),
          _buildPaymentMethod(
            context,
            'GoPay',
            Icons.account_balance_wallet_rounded,
          ),
          _buildPaymentMethod(
            context,
            'OVO',
            Icons.account_balance_wallet_rounded,
          ),
          _buildPaymentMethod(context, 'QRIS', Icons.qr_code_2_rounded),
          const SizedBox(height: 12),
          _buildSectionTitle('Transfer Bank'),
          _buildPaymentMethod(
            context,
            'Bank Mandiri',
            Icons.account_balance_rounded,
          ),
          _buildPaymentMethod(
            context,
            'BCA Virtual Account',
            Icons.account_balance_rounded,
          ),
          _buildPaymentMethod(
            context,
            'BRI Virtual Account',
            Icons.account_balance_rounded,
          ),
          const SizedBox(height: 16), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 8),
      child: Text(
        title,
        style: AppTextStyles.labelBold.copyWith(
          color: AppColors.primary,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: () {
        Navigator.pop(context); // Close the sheet
        onMethodSelected(); // Trigger loading
      },
      hoverColor: AppColors.accent.withValues(alpha: 0.05),
    );
  }
}
