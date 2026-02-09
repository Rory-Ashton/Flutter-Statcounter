import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;
import '../consent/cookiebot_adapter.dart';
import '../consent/cookieyes_adapter.dart';
import 'statcounter_platform.dart';

@JS('console.warn')
external void _consoleWarn(String message);

void scWarn(String message) => _consoleWarn('[Statcounter] $message');

StatcounterPlatform createPlatform() => _WebStatcounterPlatform();

class _WebStatcounterPlatform implements StatcounterPlatform {
  bool _scriptLoaded = false;

  // Consent state (web only)
  bool _manageConsent = false;
  String? _cmp; // e.g. "cookieyes" | "cookiebot"
  bool _consentGranted = true;

  // Prevent double-loading if consent events fire multiple times
  Future<void>? _loadFuture;

  @override
  bool get isSupported => true;

  @override
  Future<void> init({
    required int project,
    required String security,
    required int invisible,
    required int https,
    required String scriptUrl,
    bool manageConsent = false,
    String? cmp,
  }) async {
    _manageConsent = manageConsent;
    _cmp = cmp?.trim().toLowerCase();

    // If managing consent, start "not granted" until proven otherwise.
    _consentGranted = !_manageConsent;

    final win = web.window as JSObject;

    // Set StatCounter globals on window (safe even before loading script)
    win['sc_project'] = project.toJS;
    win['sc_security'] = security.toJS;
    win['sc_invisible'] = invisible.toJS;
    win['sc_https'] = https.toJS;

    // Our dedupe helper
    if (win['__sc_last_url'] == null) {
      win['__sc_last_url'] = ''.toJS;
    }

    Future<void> loadScriptIfNeeded() {
      _loadFuture ??= () async {
        try {
          await _ensureScript(scriptUrl);

          // counter.js already recorded the first pageview on load.
          // Set dedupe baseline so we don't double count.
          win['__sc_last_url'] = web.window.location.href.toJS;
        } catch (_) {
          // Swallow: ad blockers/CSP/offline should not break app.
          // Leave _scriptLoaded=false so track() becomes a no-op.
        }
      }();
      return _loadFuture!;
    }

    // No consent management: kick off loading in the background (do NOT await).
    if (!_manageConsent) {
      unawaited(loadScriptIfNeeded());
      return;
    }

    // Consent-managed: load only after consent is granted

    if (_cmp == 'cookieyes') {
      CookieYesConsent(
        manageConsent: true,
        onConsentChange: (allowed) {
          _consentGranted = allowed;
          if (allowed) {
            unawaited(loadScriptIfNeeded());
          }
        },
      ).init();
      return;
    }

    if (_cmp == 'cookiebot') {
      CookiebotConsent(
        manageConsent: true,
        onConsentChange: (allowed) {
          _consentGranted = allowed;
          if (allowed) {
            unawaited(loadScriptIfNeeded());
          }
        },
      ).init();
      return;
    }

    // Unknown CMP: fail closed (don't load script)

    scWarn("Statcounter set to use Managed Consent but the CMP is not defined, or is invalid.  Accepted values are 'cookiebot' or 'cookieyes'.  Or change manageConsent to false if the site does not use it");

    _consentGranted = false;
  }

  Future<void> _ensureScript(String scriptUrl) async {
    final existing = web.document.querySelector(
      'script[data-statcounter="counter.js"]',
    );
    if (existing != null) {
      _scriptLoaded = true;
      return;
    }

    final script = web.HTMLScriptElement()
      ..src = scriptUrl
      ..async = true
      ..defer = true;

    script.setAttribute('data-statcounter', 'counter.js');

    final c = Completer<void>();

    void onLoad(web.Event _) {
      if (!c.isCompleted) c.complete();
    }

    void onError(web.Event _) {
      if (!c.isCompleted) {
        c.completeError(StateError('Failed to load StatCounter script'));
      }
    }

    script.addEventListener('load', onLoad.toJS);
    script.addEventListener('error', onError.toJS);

    final head = web.document.head;
    if (head == null) {
      throw StateError('document.head is null; cannot inject counter.js');
    }
    head.append(script);

    await c.future;
    _scriptLoaded = true;
  }

  @override
  void track(String urlOrPath) {
    // If consent-managed, do nothing until granted.
    if (_manageConsent && !_consentGranted) return;
    if (!_scriptLoaded) return;

    final url = _toAbsolute(urlOrPath);

    final win = web.window as JSObject;
    final lastAny = win['__sc_last_url'];
    final last = (lastAny is JSString) ? lastAny.toDart : '';

    if (url == last) return;

    win['__sc_last_url'] = url.toJS;

    final scAny = win['_statcounter'];
    if (scAny is JSObject) {
      scAny.callMethod<JSAny?>('record_pageview'.toJS);
    }
  }

  String _toAbsolute(String urlOrPath) {
    final uri = Uri.tryParse(urlOrPath);
    if (uri == null) return web.window.location.href;

    if (uri.hasScheme) return uri.toString();

    final base = Uri.parse(web.window.location.href);
    return base.resolveUri(uri).toString();
  }
}
