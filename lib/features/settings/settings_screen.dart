import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/repositories/job_repository.dart';
import '../../data/services/app_preferences.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/isar_service.dart';
import '../../data/services/revenue_cat_service.dart';
import '../../data/services/export_service.dart';
import '../../app.dart';

/// Settings Screen
/// App settings, account management, and preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeProvider _themeProvider = ThemeProvider();
  late bool _isDarkMode;
  late bool _isNotificationEnabled;
  String _storageSize = '0 KB';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isDarkMode = AppPreferences.isDarkMode;
    _isNotificationEnabled = AppPreferences.notificationsEnabled;
    _loadStorageSize();
  }

  Future<void> _loadStorageSize() async {
    try {
      final isar = await IsarService.db;
      final sizeBytes = await isar.getSize();
      setState(() {
        if (sizeBytes < 1024) {
          _storageSize = '$sizeBytes B';
        } else if (sizeBytes < 1024 * 1024) {
          _storageSize = '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
        } else {
          _storageSize = '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        }
      });
    } catch (e) {
      setState(() {
        _storageSize = 'N/A';
      });
    }
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _isDarkMode = value);
    await _themeProvider.setTheme(value);
    // Rebuild app to apply theme
    LokerKuApp.rebuildApp();
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _isNotificationEnabled = value);
    await AppPreferences.setNotificationsEnabled(value);
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Bahasa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('Indonesia', 'id'),
            _buildLanguageOption('English', 'en'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String name, String code) {
    final isSelected = AppPreferences.language == code;
    return ListTile(
      title: Text(name),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () async {
        await AppPreferences.setLanguage(code);
        AppLocalizations.setLocale(code);
        if (mounted) {
          Navigator.pop(context);
          setState(() {});
          LokerKuApp.rebuildApp();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Bahasa diubah ke $name')));
        }
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: 'v0.1.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.work_rounded, color: Colors.white, size: 28),
      ),
      children: [
        const Text(
          'LokerKu adalah aplikasi pelacak lamaran kerja yang membantu Anda mengatur dan memantau proses pencarian kerja dengan mudah.',
        ),
        const SizedBox(height: 16),
        const Text(
          '© 2024 Ruly Octareza. All rights reserved.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Syarat & Ketentuan'),
        content: const SingleChildScrollView(
          child: Text(
            'Dengan menggunakan aplikasi LokerKu, Anda setuju untuk:\n\n'
            '1. Menggunakan aplikasi ini dengan bertanggung jawab\n'
            '2. Tidak menyalahgunakan fitur yang tersedia\n'
            '3. Menjaga kerahasiaan data akun Anda\n'
            '4. Tidak melakukan tindakan yang melanggar hukum\n\n'
            'Kami berhak mengubah syarat dan ketentuan ini sewaktu-waktu tanpa pemberitahuan sebelumnya.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kebijakan Privasi'),
        content: const SingleChildScrollView(
          child: Text(
            'LokerKu menghormati privasi Anda:\n\n'
            '• Data lamaran disimpan secara lokal di perangkat Anda\n'
            '• Jika Anda login dengan Google, data disinkronkan dengan aman ke cloud\n'
            '• Kami tidak menjual atau membagikan data Anda kepada pihak ketiga\n'
            '• Anda dapat menghapus semua data kapan saja\n\n'
            'Untuk pertanyaan tentang privasi, hubungi kami di support@lokerku.app',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _rateApp() {
    // Note: In production, use url_launcher to open Play Store/App Store
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terima kasih! Rating akan diarahkan ke Play Store'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName =
        AppPreferences.userDisplayName ??
        AuthService.displayName ??
        'Guest User';
    final userEmail =
        AppPreferences.userEmail ?? AuthService.email ?? 'Mode Tamu';
    final photoUrl = AppPreferences.userPhotoUrl ?? AuthService.photoUrl;
    final isLoggedIn = AuthService.isLoggedIn;
    final isGuestMode = AppPreferences.isGuestMode;
    final currentLanguage = AppPreferences.language == 'id'
        ? 'Indonesia'
        : 'English';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              margin: const EdgeInsets.all(AppSizes.spacing16),
              padding: const EdgeInsets.all(AppSizes.spacing16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () => context.push(AppRouter.profile),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      backgroundImage: photoUrl != null
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl == null
                          ? Icon(
                              Icons.person,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing16),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          userEmail,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (!isLoggedIn && isGuestMode)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Mode Tamu',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Edit Button
                  TextButton(
                    onPressed: () => context.push(AppRouter.profile),
                    child: const Text(AppStrings.editProfile),
                  ),
                ],
              ),
            ),

            // Account Section
            _buildSectionHeader(context, AppStrings.settingsAccount),
            _buildSettingsTile(
              context,
              icon: Icons.person_outline,
              title: AppStrings.settingsProfile,
              onTap: () => context.push(AppRouter.profile),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.workspace_premium,
              title: AppStrings.settingsPremium,
              subtitle: 'Free',
              onTap: () async {
                await RevenueCatService.showPaywall(context);
              },
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacing8,
                  vertical: AppSizes.spacing4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  'Upgrade',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.sync,
              title: AppStrings.settingsSync,
              trailing: Icon(
                isLoggedIn ? Icons.check_circle : Icons.cloud_off,
                color: isLoggedIn ? AppColors.success : AppColors.textTertiary,
                size: 20,
              ),
              onTap: () {
                if (!isLoggedIn) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Login untuk mengaktifkan sinkronisasi cloud',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sinkronisasi dalam proses...'),
                    ),
                  );
                }
              },
            ),

            // App Section
            _buildSectionHeader(context, AppStrings.settingsApp),
            _buildSettingsTile(
              context,
              icon: Icons.dark_mode_outlined,
              title: AppStrings.settingsDarkMode,
              trailing: Switch(
                value: _isDarkMode,
                onChanged: _toggleDarkMode,
                activeThumbColor: AppColors.primary,
              ),
              onTap: () => _toggleDarkMode(!_isDarkMode),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.notifications_outlined,
              title: AppStrings.settingsNotification,
              trailing: Switch(
                value: _isNotificationEnabled,
                onChanged: _toggleNotifications,
                activeThumbColor: AppColors.primary,
              ),
              onTap: () => _toggleNotifications(!_isNotificationEnabled),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.language,
              title: AppStrings.settingsLanguage,
              subtitle: currentLanguage,
              onTap: _showLanguageDialog,
            ),

            // Data Section
            _buildSectionHeader(context, AppStrings.settingsData),
            _buildSettingsTile(
              context,
              icon: Icons.file_download_outlined,
              title: AppStrings.settingsExport,
              onTap: () => ExportService.showExportDialog(context),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.delete_outline,
              title: AppStrings.settingsDeleteAll,
              titleColor: AppColors.error,
              onTap: () => _showDeleteConfirmation(context),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.storage_outlined,
              title: AppStrings.settingsStorage,
              subtitle: _storageSize,
              showArrow: false,
              onTap: () {},
            ),

            // About Section
            _buildSectionHeader(context, AppStrings.settingsAbout),
            _buildSettingsTile(
              context,
              icon: Icons.info_outline,
              title: AppStrings.settingsAboutApp,
              onTap: _showAboutDialog,
            ),
            _buildSettingsTile(
              context,
              icon: Icons.description_outlined,
              title: AppStrings.settingsTerms,
              onTap: _showTermsDialog,
            ),
            _buildSettingsTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: AppStrings.settingsPrivacy,
              onTap: _showPrivacyDialog,
            ),
            _buildSettingsTile(
              context,
              icon: Icons.star_outline,
              title: AppStrings.settingsRate,
              onTap: _rateApp,
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () => _showLogoutConfirmation(context),
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: Text(
                    isLoggedIn ? AppStrings.settingsLogout : 'Masuk',
                    style: TextStyle(
                      color: isLoggedIn ? AppColors.error : AppColors.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isLoggedIn ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),

            // Version
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spacing16),
                child: Text(
                  'v0.1.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacing40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacing16,
        AppSizes.spacing24,
        AppSizes.spacing16,
        AppSizes.spacing8,
      ),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      child: ListTile(
        leading: Icon(icon, color: titleColor ?? AppColors.textSecondary),
        title: Text(title, style: TextStyle(color: titleColor)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing:
            trailing ??
            (showArrow
                ? const Icon(Icons.chevron_right, color: AppColors.textTertiary)
                : null),
        onTap: onTap,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Data?'),
        content: const Text(
          'Tindakan ini akan menghapus semua data lamaran kamu secara permanen. Data tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);

              try {
                await JobRepository.deleteAll();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Semua data telah dihapus'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadStorageSize();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final isLoggedIn = AuthService.isLoggedIn;

    if (!isLoggedIn) {
      // Not logged in - go to login
      context.go(AppRouter.login);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);

              try {
                await AuthService.signOut();
                await AppPreferences.clearUserData();

                if (mounted) {
                  context.go(AppRouter.login);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
