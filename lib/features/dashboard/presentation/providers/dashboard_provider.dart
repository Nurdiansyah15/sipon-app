import 'package:flutter/material.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../article/domain/entities/article.dart';
import '../../../article/domain/usecases/get_recent_articles_usecase.dart';
import '../../../kesantrian/domain/entities/santri_profile.dart';
import '../../../kesantrian/domain/usecases/get_my_santri_profile_usecase.dart';
import '../../../keuangan/domain/entities/billing_summary.dart';
import '../../../keuangan/domain/usecases/get_my_billing_summary_usecase.dart';

/// Drives the dashboard's three cards. Each section tracks its own
/// loading/data/error state independently so a failure in one (e.g. the
/// billing API being down) doesn't block the others from rendering.
class DashboardProvider extends ChangeNotifier {
  final GetRecentArticlesUseCase _getRecentArticlesUseCase;
  final GetMySantriProfileUseCase _getMySantriProfileUseCase;
  final GetMyBillingSummaryUseCase _getMyBillingSummaryUseCase;

  DashboardProvider(
    this._getRecentArticlesUseCase,
    this._getMySantriProfileUseCase,
    this._getMyBillingSummaryUseCase,
  );

  bool _isLoadingArticles = true;
  List<Article> _articles = const [];
  String? _articlesError;

  bool _isLoadingSantri = true;
  SantriProfile? _santriProfile;
  String? _santriError;

  bool _isLoadingBilling = true;
  BillingSummary? _billingSummary;
  String? _billingError;

  bool get isLoadingArticles => _isLoadingArticles;
  List<Article> get articles => _articles;
  String? get articlesError => _articlesError;

  bool get isLoadingSantri => _isLoadingSantri;
  SantriProfile? get santriProfile => _santriProfile;
  String? get santriError => _santriError;

  bool get isLoadingBilling => _isLoadingBilling;
  BillingSummary? get billingSummary => _billingSummary;
  String? get billingError => _billingError;

  Future<void> loadAll() {
    return Future.wait([_loadArticles(), _loadSantri(), _loadBilling()]);
  }

  Future<void> _loadArticles() async {
    _isLoadingArticles = true;
    _articlesError = null;
    notifyListeners();

    final result = await _getRecentArticlesUseCase.call(const NoParams());
    result.fold(
      (failure) => _articlesError = failure.message,
      (articles) => _articles = articles,
    );
    _isLoadingArticles = false;
    notifyListeners();
  }

  Future<void> _loadSantri() async {
    _isLoadingSantri = true;
    _santriError = null;
    notifyListeners();

    final result = await _getMySantriProfileUseCase.call(const NoParams());
    result.fold(
      (failure) => _santriError = failure.message,
      (profile) => _santriProfile = profile,
    );
    _isLoadingSantri = false;
    notifyListeners();
  }

  Future<void> _loadBilling() async {
    _isLoadingBilling = true;
    _billingError = null;
    notifyListeners();

    final result = await _getMyBillingSummaryUseCase.call(const NoParams());
    result.fold(
      (failure) => _billingError = failure.message,
      (summary) => _billingSummary = summary,
    );
    _isLoadingBilling = false;
    notifyListeners();
  }
}
