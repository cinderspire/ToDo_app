import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../constants/app_constants.dart';

/// RevenueCat subscription state
class SubscriptionState {
  final bool isPremium;
  final bool isLoading;
  final String? errorMessage;
  final List<Package> availablePackages;

  const SubscriptionState({
    this.isPremium = false,
    this.isLoading = true,
    this.errorMessage,
    this.availablePackages = const [],
  });

  SubscriptionState copyWith({
    bool? isPremium,
    bool? isLoading,
    String? errorMessage,
    List<Package>? availablePackages,
  }) {
    return SubscriptionState(
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      availablePackages: availablePackages ?? this.availablePackages,
    );
  }
}

/// Main subscription provider
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier();
});

/// Convenience provider for premium check
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).isPremium;
});

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(SubscriptionState(isPremium: kDebugMode)) {
    _init();
  }

  bool _configured = false;

  Future<void> _init() async {
    try {
      final apiKey = Platform.isIOS
          ? AppConstants.revenueCatApiKeyIOS
          : AppConstants.revenueCatApiKeyAndroid;

      // Skip configure if using placeholder keys
      if (apiKey.contains('REPLACE') || apiKey.contains('your_') || apiKey.isEmpty) {
        debugPrint('[RevenueCat] Skipping — placeholder API key detected');
        state = state.copyWith(isLoading: false);
        return;
      }

      final configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);
      _configured = true;

      // Listen for customer info updates
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      // Check current status
      await checkSubscription();
      await loadOfferings();
    } catch (e) {
      debugPrint('RevenueCat init error: $e');
      // Gracefully degrade - app works without RevenueCat
      state = state.copyWith(isLoading: false, isPremium: false);
    }
  }

  void _onCustomerInfoUpdated(CustomerInfo info) {
    final isPremium =
        info.entitlements.active.containsKey(AppConstants.entitlementId);
    state = state.copyWith(isPremium: isPremium);
  }

  Future<void> checkSubscription() async {
    try {
      final info = await Purchases.getCustomerInfo();
      final isPremium =
          info.entitlements.active.containsKey(AppConstants.entitlementId);
      state = state.copyWith(isPremium: isPremium, isLoading: false);
    } catch (e) {
      debugPrint('Check subscription error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current != null) {
        state = state.copyWith(availablePackages: current.availablePackages);
      }
    } catch (e) {
      debugPrint('Load offerings error: $e');
    }
  }

  Future<bool> purchase(Package package) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final result = await Purchases.purchasePackage(package);
      final isPremium = result
          .entitlements.active
          .containsKey(AppConstants.entitlementId);
      state = state.copyWith(isPremium: isPremium, isLoading: false);
      return isPremium;
    } on PurchasesErrorCode catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Purchase failed: $e',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Purchase failed: $e',
      );
      return false;
    }
  }

  void simulatePurchase() {
    state = state.copyWith(isPremium: true, isLoading: false);
  }

  Future<bool> restorePurchases() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final info = await Purchases.restorePurchases();
      final isPremium =
          info.entitlements.active.containsKey(AppConstants.entitlementId);
      state = state.copyWith(isPremium: isPremium, isLoading: false);
      return isPremium;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Restore failed: $e',
      );
      return false;
    }
  }
}
