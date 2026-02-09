import 'statcounter_platform.dart';


/// Main public API.
class Statcounter {
  static bool _initialized = false;

  /// Initialize StatCounter for Flutter Web.
  ///
  /// This method is safe to call during startup. It will never throw.
  static Future<void> init({
    required int project,
    required String security,
    int invisible = 1,
    int https = 1,
    String scriptUrl = 'https://www.statcounter.com/counter/counter.js',
    bool manageConsent = false,
    String? cmp,
  }) async {
    if (_initialized) return;

    try {
      await StatcounterPlatform.instance.init(
        project: project,
        security: security,
        invisible: invisible,
        https: https,
        scriptUrl: scriptUrl,
        manageConsent: manageConsent,
        cmp: cmp,
      );
    } catch (_) {
      // Intentionally swallow: analytics must never break app startup.
      // (Ad blockers, CSP, offline, etc.)
    } finally {
      // Mark initialized so startup code doesn't repeatedly retry / spam.
      _initialized = true;
    }
  }

  /// Track a virtual pageview (SPA route change).
  ///
  /// Pass a path like `/about` or a full URL.
  
  static void track(String urlOrPath) {
    StatcounterPlatform.instance.track(urlOrPath);
  }

  /// Whether the platform implementation is active (true on web).
  
  static bool get isSupported => StatcounterPlatform.instance.isSupported;
}
