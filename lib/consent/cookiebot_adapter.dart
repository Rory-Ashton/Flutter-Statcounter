import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

typedef ConsentChangeCallback = void Function(bool allowed);

class CookiebotConsent {
  CookiebotConsent({
    required this.manageConsent,
    required this.onConsentChange,
  });

  final bool manageConsent;
  final ConsentChangeCallback onConsentChange;

  void init() {
    if (!manageConsent) return;

    final win = web.window as JSObject;
    final doc = web.document;

    void handler(web.Event _) {
      onConsentChange(_getAnalyticsAllowed(win));
    }

    // Avoid double-listening
    final already = win['__sc_cookiebot_listening'];
    final alreadyListening =
        already is JSBoolean && already.toDart == true;

    if (!alreadyListening) {
      win['__sc_cookiebot_listening'] = true.toJS;

      // Cookiebot commonly dispatches these events
      const events = <String>[
        'CookiebotOnConsentReady',
        'CookiebotOnAccept',
        'CookiebotOnDecline',
        'CookiebotOnPreferences',
      ];

      for (final e in events) {
        web.window.addEventListener(e, handler.toJS);
        doc.addEventListener(e, handler.toJS);
      }
    }

    // Immediate read
    handler(web.Event('init'));
  }

  bool _getAnalyticsAllowed(JSObject win) {
    final cbAny = win['Cookiebot'];
    if (cbAny is! JSObject) return false;

    // Most common: Cookiebot.consent.statistics === true
    final consentAny = cbAny['consent'];
    if (consentAny is JSObject) {
      final statsAny = consentAny['statistics'];
      if (statsAny is JSBoolean) return statsAny.toDart;
    }

    // Fallback seen in some setups: Cookiebot.statistics === true
    final stats2Any = cbAny['statistics'];
    return stats2Any is JSBoolean ? stats2Any.toDart : false;
  }
}
