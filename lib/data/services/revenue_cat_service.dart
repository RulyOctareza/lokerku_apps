import 'dart:io';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat Service for managing in-app purchases and subscriptions
class RevenueCatService {
  static const String _apiKey = 'test_hluHSrQIDCwhTKqjVxuhYSGvfHP';

  static bool _isInitialized = false;

  /// Initialize RevenueCat SDK
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_apiKey);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_apiKey);
      } else {
        debugPrint('RevenueCat: Unsupported platform');
        return;
      }

      await Purchases.configure(configuration);
      _isInitialized = true;

      // Get initial customer info
      await Purchases.getCustomerInfo();
      debugPrint('RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('RevenueCat initialization error: $e');
    }
  }

  /// Check if user has active premium subscription
  static Future<bool> isPremium() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey('premium');
    } catch (e) {
      debugPrint('Error checking premium status: $e');
      return false;
    }
  }

  /// Get available offerings (subscription packages)
  static Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('Error getting offerings: $e');
      return null;
    }
  }

  /// Purchase a package
  static Future<bool> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      return result.customerInfo.entitlements.active.containsKey('premium');
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }

  /// Restore purchases
  static Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.active.containsKey('premium');
    } catch (e) {
      debugPrint('Restore purchases error: $e');
      return false;
    }
  }

  /// Login user (for cross-platform restore)
  static Future<void> login(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('RevenueCat login error: $e');
    }
  }

  /// Logout user
  static Future<void> logout() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('RevenueCat logout error: $e');
    }
  }

  /// Show paywall dialog
  static Future<bool> showPaywall(BuildContext context) async {
    try {
      final offerings = await getOfferings();
      if (offerings == null || offerings.current == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Paket premium tidak tersedia saat ini'),
            ),
          );
        }
        return false;
      }

      final packages = offerings.current!.availablePackages;
      if (packages.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada paket tersedia')),
          );
        }
        return false;
      }

      if (!context.mounted) return false;

      // Show simple paywall dialog
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => _PaywallDialog(packages: packages),
      );

      return result ?? false;
    } catch (e) {
      debugPrint('Show paywall error: $e');
      return false;
    }
  }
}

/// Simple paywall dialog
class _PaywallDialog extends StatelessWidget {
  final List<Package> packages;

  const _PaywallDialog({required this.packages});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('LokerKu Premium'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Upgrade ke Premium untuk fitur eksklusif:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Template CV Unlimited'),
              dense: true,
            ),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Sinkronisasi Cloud'),
              dense: true,
            ),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Export ke PDF'),
              dense: true,
            ),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Tanpa Iklan'),
              dense: true,
            ),
            const SizedBox(height: 16),
            ...packages.map((package) => _buildPackageButton(context, package)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                final restored = await RevenueCatService.restorePurchases();
                if (context.mounted) {
                  Navigator.pop(context, restored);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        restored
                            ? 'Pembelian berhasil dipulihkan!'
                            : 'Tidak ada pembelian untuk dipulihkan',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Pulihkan Pembelian'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Nanti'),
        ),
      ],
    );
  }

  Widget _buildPackageButton(BuildContext context, Package package) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () async {
          final purchased = await RevenueCatService.purchasePackage(package);
          if (context.mounted) {
            Navigator.pop(context, purchased);
          }
        },
        child: Text(
          '${package.storeProduct.title} - ${package.storeProduct.priceString}',
        ),
      ),
    );
  }
}
