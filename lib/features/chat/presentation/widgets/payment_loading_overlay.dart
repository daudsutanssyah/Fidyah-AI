import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fidyah_ai/core/theme/app_colors.dart';
import 'package:fidyah_ai/core/theme/app_text_styles.dart';
import 'package:fidyah_ai/core/constants/app_strings.dart';

/// Frosted glass overlay shown during mock payment processing
class PaymentLoadingOverlay extends StatelessWidget {
  const PaymentLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          color: AppColors.overlayDark,
          child: Center(
            child:
                Container(
                      margin: const EdgeInsets.symmetric(horizontal: 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 40,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated icon
                          Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.nightlight_round,
                                  size: 36,
                                  color: AppColors.primary,
                                ),
                              )
                              .animate(onPlay: (c) => c.repeat())
                              .shimmer(
                                duration: 1500.ms,
                                color: AppColors.accent.withValues(alpha: 0.3),
                              ),

                          const SizedBox(height: 24),

                          // Progress indicator
                          SizedBox(
                            width: 140,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: const LinearProgressIndicator(
                                backgroundColor: AppColors.divider,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.primary,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Title
                          Text(
                            AppStrings.paymentProcessing,
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.primaryDark,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(duration: 400.ms),

                          const SizedBox(height: 8),

                          // Subtitle
                          Text(
                            'Menyiapkan transaksi ke BAZNAS...',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.0, 1.0),
                      duration: 300.ms,
                      curve: Curves.easeOutBack,
                    ),
          ),
        ),
      ),
    );
  }
}
