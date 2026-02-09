# statcounter_flutter

Official Statcounter integration for Flutter Web.

This package provides a simple API to load Statcounter on Flutter Web apps and
track virtual pageviews in single-page applications (SPA). It includes built-in
support for common Consent Management Platforms (CMPs) so analytics are only
loaded after user consent.

## Features

- Flutter Web support for Statcounter
- Automatic initial pageview on script load
- Automatic SPA route tracking
- Consent-aware loading (no analytics before consent)
- Non-blocking by default
- Built-in CMP adapters:
  - CookieYes
  - Cookiebot
- Future-proof web interop using `package:web` and `dart:js_interop`

## Platform Support

- ✅ Flutter Web

This package injects StatCounter’s JavaScript and therefore only works on Flutter Web.


## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  statcounter_flutter: ^0.1.0
```

Then run

```bash
flutter pub get
```

## Basic Usage

1.  Open your root app file that contains your MaterialApp or GoRouter
(often lib/main.dart or lib/app.dart) and add this to the top:

```dart
import 'package:statcounter_flutter/statcounter.dart';
```

If you use the GoRouter also import this

```dart
import 'package:statcounter_flutter_gorouter/statcounter_flutter_gorouter.dart';
```

2.  In that same file add this to your main() , using your own project ID and security code (found in your statcounter project settings).  The cmp options are 'cookiebot' or 'cookieyes'

```dart
Statcounter.init(
  project: 123456, 
  security: 'abcdef', 
  manageConsent:true, 
  cmp: 'cookiebot'
);
```

3.  Add the Statcounter route observer to your app’s root widget so SPA route changes are tracked:

```dart
navigatorObservers: [StatcounterRouteObserver()],
```

## Material Router Example Code

```dart

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Statcounter.init(   // <--- STATCOUNTER BLOCK HERE
    project: 123456,
    security: 'abcdef',
    manageConsent: true,
    cmp: 'cookiebot',
  );

  runApp(const MyAppMaterial());
}

class MyAppMaterial extends StatelessWidget {
  const MyAppMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo (Material Routes)',
      navigatorObservers: [StatcounterRouteObserver()],  // <--- STATCOUNTER ADDED HERE
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePageMaterial(),
        '/second': (context) => const SecondPageMaterial(),
      },
    );
  }
}
```

## GoRouter Example Code

```dart

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Statcounter.init(   // <--- STATCOUNTER BLOCK HERE
    project: 123456,
    security: 'abcdef',
    manageConsent: true,
    cmp: 'cookiebot',
  );

  runApp(const MyAppGoRouter());
}

class MyAppGoRouter extends StatelessWidget {
  const MyAppGoRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MyHomePageGo(),
        ),
        GoRoute(
          path: '/second',
          builder: (context, state) => const SecondPageGo(),
        ),
      ],
    );

    StatcounterGoRouter.attach(router);  // <--- STATCOUNTER ADDED HERE

    return MaterialApp.router(
      title: 'Flutter Demo (GoRouter)',
      routerConfig: router,
    );
  }
}
```

## Consent Management

When consent is denied, Statcounter will not load and no pageviews are recorded.
When consent is granted, the Statcounter script is loaded right away.

To enable consent-aware loading setup the Statcounter code like this

```dart
Statcounter.init(
  project: 123456,
  security: 'abcdef',
  manageConsent: true,
  cmp: 'cookieyes', // or 'cookiebot'
);
```

Supported CMPs:

* CookieYes
* CookieBot

cmp values: 'cookiebot' | 'cookieyes'

If you don't use a CMP you can leave that line out and remove the comma at the end of the ```manageConsent``` line.

```dart
Statcounter.init(
  project: 123456,
  security: 'abcdef',
  manageConsent: false  // <--- no comma here as seen in prev example code
);
```