import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shows interstitial ads at key moments (app open, mid-test, test finished)
/// while capping how many a single user sees per hour.
class AdManager {
  AdManager._();
  static final AdManager instance = AdManager._();

  static const String interstitialAdUnitId = 'ca-app-pub-4055951911872773/6899015998';

  static const _showTimesKey = 'avtotest:ad_show_times';
  static const _maxPerHour = 10; // hard cap; min-per-hour (5) target is met
  // by trigger frequency + the cooldown below, not by forcing extra shows.
  static const _hour = Duration(hours: 1);
  // Spreads out ads so an actively-used hour lands close to the min/max
  // band instead of always maxing out on the first few triggers.
  static const _minGapBetweenAds = Duration(minutes: 5);

  InterstitialAd? _ad;
  bool _loading = false;
  DateTime? _lastShownAt;

  Future<void> init() async {
    await MobileAds.instance.initialize();
    // Restrict to general-audience ads (no gambling/dating/alcohol/etc.) —
    // fine-grained category blocking is done in the AdMob console under
    // "Управление блокировкой".
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(maxAdContentRating: MaxAdContentRating.g),
    );
    _loadAd();
  }

  void _loadAd() {
    if (_loading || _ad != null) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _ad = ad;
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          _ad = null;
        },
      ),
    );
  }

  /// Shows a cached interstitial if the hourly quota allows it. Silently
  /// does nothing if no ad is ready yet or the quota/cooldown blocks it.
  Future<void> maybeShow() async {
    final ad = _ad;
    if (ad == null) {
      _loadAd();
      return;
    }
    if (_lastShownAt != null && DateTime.now().difference(_lastShownAt!) < _minGapBetweenAds) {
      return;
    }
    if (!await _quotaAllows()) return;

    _ad = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _loadAd();
      },
      onAdFailedToShowFullScreenContent: (a, error) {
        a.dispose();
        _loadAd();
      },
    );
    _lastShownAt = DateTime.now();
    await _recordShow();
    await ad.show();
  }

  Future<List<DateTime>> _recentShowTimes(SharedPreferences prefs) async {
    final raw = prefs.getStringList(_showTimesKey) ?? const [];
    final cutoff = DateTime.now().subtract(_hour);
    return raw.map((s) => DateTime.parse(s)).where((t) => t.isAfter(cutoff)).toList();
  }

  Future<bool> _quotaAllows() async {
    final prefs = await SharedPreferences.getInstance();
    final recent = await _recentShowTimes(prefs);
    return recent.length < _maxPerHour;
  }

  Future<void> _recordShow() async {
    final prefs = await SharedPreferences.getInstance();
    final recent = await _recentShowTimes(prefs);
    recent.add(DateTime.now());
    await prefs.setStringList(_showTimesKey, recent.map((t) => t.toIso8601String()).toList());
  }

  /// How many ads have been shown to this user in the last hour — exposed
  /// for diagnostics; the min/max band (5-10/hour) is achieved by pairing
  /// the [_minGapBetweenAds] cooldown with the trigger points (app open,
  /// mid-test, test finished) rather than by forcing extra ads.
  Future<int> shownInLastHour() async {
    final prefs = await SharedPreferences.getInstance();
    return (await _recentShowTimes(prefs)).length;
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}
