import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../data/services/app_preferences.dart';
import '../../data/services/auth_service.dart';

/// Login Screen
/// Provides Google Sign-In and Guest Mode options
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Call actual Google Sign-In
      final userCredential = await AuthService.signInWithGoogle();

      if (userCredential == null) {
        // User cancelled sign-in
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // Save user info to preferences
      await AppPreferences.setGuestMode(false);
      await AppPreferences.setUserDisplayName(userCredential.user?.displayName);
      await AppPreferences.setUserEmail(userCredential.user?.email);
      await AppPreferences.setUserPhotoUrl(userCredential.user?.photoURL);

      if (!mounted) return;
      context.go(AppRouter.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _continueAsGuest() async {
    // Set guest mode flag
    await AppPreferences.setGuestMode(true);
    if (!mounted) return;
    context.go(AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spacing24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSizes.spacing24),

                      // Logo - adapts to dark mode
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(
                                isDarkMode ? 0.4 : 0.3,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.work_rounded,
                          size: 44,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing24),

                      // App Name
                      Text(
                        AppStrings.appName,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing32),

                      // Illustration - adapts to dark mode
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? colorScheme.primary.withOpacity(0.2)
                              : colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_pin_rounded,
                          size: 80,
                          color: isDarkMode
                              ? colorScheme.primary.withOpacity(0.8)
                              : colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing24),

                      // Title
                      Text(
                        AppStrings.loginTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing8),

                      // Subtitle
                      Text(
                        AppStrings.loginSubtitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),

                      const SizedBox(height: AppSizes.spacing32),

                      // Google Sign-In Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _signInWithGoogle,
                          icon: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.primary,
                                  ),
                                )
                              : Image.network(
                                  'https://www.google.com/favicon.ico',
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.g_mobiledata,
                                    color: Colors.red,
                                  ),
                                ),
                          label: Text(
                            AppStrings.loginWithGoogle,
                            style: TextStyle(color: colorScheme.primary),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.spacing16,
                            ),
                            side: BorderSide(
                              color: colorScheme.primary.withOpacity(0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusLarge,
                              ),
                            ),
                            backgroundColor: isDarkMode
                                ? colorScheme.surface
                                : Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.spacing16),

                      // Continue as Guest
                      TextButton(
                        onPressed: _continueAsGuest,
                        child: Column(
                          children: [
                            Text(
                              AppStrings.continueAsGuest,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              AppStrings.guestModeNote,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(
                                  0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.spacing24),

                      // Terms
                      Text(
                        AppStrings.termsAgreement,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
