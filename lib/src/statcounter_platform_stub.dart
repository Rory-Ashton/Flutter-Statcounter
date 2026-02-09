import 'statcounter_platform.dart';

StatcounterPlatform createPlatform() => _StubStatcounterPlatform();

class _StubStatcounterPlatform implements StatcounterPlatform {
  @override
  bool get isSupported => false;

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
    // no-op
  }

  @override
  void track(String urlOrPath) {
    // no-op
  }
}
