import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/template.dart';
import '../../data/repositories/template_repository.dart';
import '../../data/services/revenue_cat_service.dart';
import 'providers/template_providers.dart';
import 'widgets/template_card.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  final Future<bool> Function(Template template) canAccessChecker;
  final Future<void> Function(BuildContext context) paywallLauncher;

  const TemplatesScreen({
    super.key,
    this.canAccessChecker = TemplateRepository.canAccess,
    this.paywallLauncher = RevenueCatService.showPaywall,
  });

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  Future<void> _handleTemplateTap(
    BuildContext context,
    Template template,
  ) async {
    var isLoadingVisible = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    isLoadingVisible = true;

    try {
      final canAccess = await widget.canAccessChecker(template);

      if (!context.mounted) return;

      if (isLoadingVisible) {
        Navigator.of(context, rootNavigator: true).pop();
        isLoadingVisible = false;
      }

      if (!canAccess) {
        _showPremiumDialog(context);
        return;
      }

      _showTemplateContent(context, template);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat template: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (isLoadingVisible && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  void _showPremiumDialog(BuildContext context) {
    final rootContext = this.context;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        title: const Text(AppStrings.premiumTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.premiumDesc,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.spacing12),
            const Text('Fitur premium termasuk:'),
            const SizedBox(height: AppSizes.spacing8),
            _buildFeatureRow(Icons.description, 'Template premium unlimited'),
            _buildFeatureRow(Icons.cloud_sync, 'Backup cloud aman'),
            _buildFeatureRow(Icons.no_adult_content, 'Tanpa iklan'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Nanti saja'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (!rootContext.mounted) return;
              await widget.paywallLauncher(rootContext);
            },
            child: const Text(AppStrings.premiumSubscribe),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacing4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSizes.spacing8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }

  void _showTemplateContent(BuildContext context, Template template) {
    final rootContext = this.context;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(sheetContext).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(sheetContext).colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.bottomSheetRadius),
          ),
        ),
        child: Column(
          children: [
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
                      style: Theme.of(sheetContext).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.spacing24),
                child: Text(
                  template.content,
                  style: Theme.of(sheetContext).textTheme.bodyMedium,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacing24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: template.content));
                    Navigator.pop(sheetContext);
                    if (!rootContext.mounted) return;
                    ScaffoldMessenger.of(rootContext).showSnackBar(
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

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(templatesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text(AppStrings.templatesTitle)),
      body: SafeArea(
        top: false,
        child: templatesAsync.when(
          data: (templates) {
            final whatsappTemplates = templates
                .where((t) => t.category == TemplateCategory.whatsapp)
                .toList();
            final emailTemplates = templates
                .where((t) => t.category == TemplateCategory.email)
                .toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.spacing16),
                    child: Text(
                      AppStrings.templatesSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (whatsappTemplates.isNotEmpty)
                    _buildSection('WhatsApp', whatsappTemplates),
                  if (emailTemplates.isNotEmpty)
                    _buildSection('Email', emailTemplates),
                  const SizedBox(height: AppSizes.spacing100),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'Error: ${error.toString()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Template> templates) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.spacing16,
        right: AppSizes.spacing16,
        bottom: AppSizes.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSizes.spacing12),
          ...templates.map(
            (template) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.spacing6),
              child: TemplateCard(
                data: TemplateCardData(
                  title: template.title,
                  description: template.description,
                  isPremium: template.isPremium,
                  content: template.content,
                ),
                onTap: () => _handleTemplateTap(context, template),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
