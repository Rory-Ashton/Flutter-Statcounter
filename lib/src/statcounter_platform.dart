import 'statcounter_platform_stub.dart'
    if (dart.library.html) 'statcounter_platform_web.dart';

abstract class StatcounterPlatform {
  static StatcounterPlatform instance = createPlatform();

  bool get isSupported;

Future<void> init({
  required int project,
  required String security,
  required int invisible,
  required int https,
  required String scriptUrl,
  bool manageConsent = false,
  String? cmp,
});


  void track(String urlOrPath);
}

