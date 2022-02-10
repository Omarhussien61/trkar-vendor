import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trkar_vendor/screens/onboarding_page.dart';
import 'package:trkar_vendor/splash_screen.dart';
import 'package:trkar_vendor/utils/Provider/provider.dart';
import 'package:trkar_vendor/utils/Provider/provider_data.dart';
import 'package:trkar_vendor/utils/local/AppLocalizations.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("configurations");
  print("base_url: ${GlobalConfiguration().getString('base_url')}");
   runApp(MultiProvider(providers: [
     ChangeNotifierProvider<Provider_control>(
       create: (_) => Provider_control(),
     ),
     ChangeNotifierProvider<Provider_Data>(
       create: (_) => Provider_Data(),
     ),
   ], child:MyApp()));

  // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  // OneSignal.shared.init(
  //     "b2f7f966-d8cc-11e4-bed1-df8f05be55ba",
  //     iOSSettings: {
  //       OSiOSSettings.autoPrompt: false,
  //       OSiOSSettings.inAppLaunchUrl: false
  //     }
  // );
  // OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
  // await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
}

class MyApp extends StatefulWidget {
  static void setlocal(BuildContext context, Locale locale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setlocal(locale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();
  bool onboard = false;

  void setlocal(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        onboard = prefs.getBool("onboard") ?? true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<Provider_control>(context);
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: _locale,
      localeResolutionCallback: (devicelocale, supportedLocales) {
        WidgetsBinding.instance.addPostFrameCallback((_){
          themeColor.setLocal(devicelocale.languageCode);
        });
        for (var locale in supportedLocales) {
          if (locale.languageCode == devicelocale.languageCode ) {

            return Locale(devicelocale.languageCode,'');
          }
        }
        return supportedLocales.first;
      },
      supportedLocales: [
        Locale("en", ""),
        Locale("ar", ""),
      ],
      theme: ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
        primaryColor: themeColor.getColor(),
        fontFamily: 'Cairo',
        snackBarTheme: SnackBarThemeData(
          backgroundColor: themeColor.getColor(),
          behavior: SnackBarBehavior.floating,
        ),
        appBarTheme: AppBarTheme(
            color: themeColor.getColor(),
            actionsIconTheme: IconThemeData(color: Colors.white),
            iconTheme: IconThemeData(color: Colors.white),titleTextStyle: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Cairo')),
     colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.lightGreen,
        ),
      ),
      home: onboard ? OnboardingPage() : SplashScreen(),
    );
  }
}
