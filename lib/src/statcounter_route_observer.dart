import 'package:flutter/widgets.dart';
import 'statcounter_core.dart';


class StatcounterRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  void _send(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null || name.isEmpty) return;

    // If user passes "about", normalize to "/about"
    final path = name.startsWith('/') ? name : '/$name';
    Statcounter.track(path);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _send(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _send(newRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _send(previousRoute);
  }
}
