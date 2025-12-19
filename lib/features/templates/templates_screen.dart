import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import 'widgets/template_card.dart';

/// Templates Screen
/// Shows WhatsApp and Email templates for job seekers
class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final whatsappTemplates = [
      TemplateCardData(
        title: 'Follow Up HRD (Sopan)',
        description: 'Untuk menanyakan kabar lamaran dengan sopan',
        isPremium: false,
        content: '''Selamat pagi/siang Bapak/Ibu,

Perkenalkan, saya [Nama Anda] yang telah melamar posisi [Posisi] di [Nama Perusahaan] pada tanggal [Tanggal].

Saya ingin menanyakan perkembangan proses rekrutmen untuk posisi tersebut. Apakah ada informasi lebih lanjut yang bisa saya ketahui?

Terima kasih atas perhatian dan waktunya.

Hormat saya,
[Nama Anda]''',
      ),
      TemplateCardData(
        title: 'Konfirmasi Interview',
        description: 'Konfirmasi kehadiran jadwal interview',
        isPremium: true,
      ),
      TemplateCardData(
        title: 'Reschedule Interview',
        description: 'Minta ganti jadwal interview dengan sopan',
        isPremium: true,
      ),
      TemplateCardData(
        title: 'Thank You After Interview',
        description: 'Ucapan terima kasih setelah interview',
        isPremium: true,
      ),
      TemplateCardData(
        title: 'Nego Gaji',
        description: 'Template negosiasi gaji yang profesional',
        isPremium: true,
      ),
    ];

    final emailTemplates = [
      TemplateCardData(
        title: 'Follow Up Formal (Email)',
        description: 'Email follow up lamaran yang formal',
        isPremium: true,
      ),
      TemplateCardData(
        title: 'Accept Offer (Email)',
        description: 'Menerima tawaran kerja secara formal',
        isPremium: true,
      ),
      TemplateCardData(
        title: 'Decline Offer (Email)',
        description: 'Menolak tawaran dengan sopan',
        isPremium: true,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.templatesTitle)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              child: Text(
                AppStrings.templatesSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // Unlock All Banner
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing16,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.spacing16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: AppSizes.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buka Semua Template',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Upgrade ke Premium sekarang!',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacing24),

            // WhatsApp Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing16,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.chat,
                    color: Color(0xFF25D366), // WhatsApp green
                    size: 24,
                  ),
                  const SizedBox(width: AppSizes.spacing8),
                  Text(
                    AppStrings.whatsappCategory,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacing12),
            ...whatsappTemplates.map(
              (template) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacing16,
                  vertical: AppSizes.spacing6,
                ),
                child: TemplateCard(
                  data: template,
                  onTap: () => _handleTemplateClick(context, template),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacing24),

            // Email Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing16,
              ),
              child: Row(
                children: [
                  const Icon(Icons.email, color: AppColors.primary, size: 24),
                  const SizedBox(width: AppSizes.spacing8),
                  Text(
                    AppStrings.emailCategory,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacing12),
            ...emailTemplates.map(
              (template) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacing16,
                  vertical: AppSizes.spacing6,
                ),
                child: TemplateCard(
                  data: template,
                  onTap: () => _handleTemplateClick(context, template),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacing100),
          ],
        ),
      ),
    );
  }

  void _handleTemplateClick(BuildContext context, TemplateCardData template) {
    if (template.isPremium) {
      _showPremiumModal(context);
    } else {
      _showTemplateContent(context, template);
    }
  }

  void _showPremiumModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 40,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              AppStrings.premiumTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              AppStrings.premiumDesc,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              AppStrings.premiumPrice,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nanti Saja'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to subscription
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: const Text(AppStrings.premiumSubscribe),
          ),
        ],
      ),
    );
  }

  void _showTemplateContent(BuildContext context, TemplateCardData template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.bottomSheetRadius),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              child: Container(
                width: AppSizes.bottomSheetHandleWidth,
                height: AppSizes.bottomSheetHandleHeight,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      template.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.spacing24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  child: Text(
                    template.content ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),

            // Copy Button
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacing24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: template.content ?? ''),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppStrings.copied),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text(AppStrings.copyTemplate),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
