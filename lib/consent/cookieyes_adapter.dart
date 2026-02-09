import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

typedef ConsentChangeCallback = void Function(bool allowed);

class CookieYesConsent {
  CookieYesConsent({
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
    final already = win['__sc_cookieyes_listening'];
    final alreadyListening =
        already is JSBoolean && already.toDart == true;

    if (!alreadyListening) {
      win['__sc_cookieyes_listening'] = true.toJS;

      // CookieYes fires non-bubbling document events
      doc.addEventListener('cookieyes_consent_update', handler.toJS);
      doc.addEventListener('cookieyes_banner_load', handler.toJS);
    }

    // Immediate read: if consent is already set, we don't wait for an event
    handler(web.Event('init'));
  }

  bool _getAnalyticsAllowed(JSObject win) {
    final fnAny = win['getCkyConsent'];
    if (fnAny is! JSFunction) return false;

    final consentAny = fnAny.callAsFunction(null);
    if (consentAny is! JSObject) return false;

    final categoriesAny = consentAny['categories'];
    if (categoriesAny is! JSObject) return false;

    final analyticsAny = categoriesAny['analytics'];
    return analyticsAny is JSBoolean ? analyticsAny.toDart : false;
  }
}
