import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:issaf/language/appLanguage.dart';
import 'package:issaf/redux/store.dart';
import 'package:issaf/views/root.dart';
import 'package:provider/provider.dart';
import 'package:issaf/language/appLocalizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Redux.init();
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
  await Firebase.initializeApp();
  runApp(MyApp(
    appLanguage: appLanguage,
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final AppLanguage appLanguage;

  MyApp({this.appLanguage});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppLanguage>(
      create: (_) => appLanguage,
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              scaffoldBackgroundColor: Colors.white,
              primaryColor: Colors.orange[400],
              primarySwatch: Colors.orange),
          locale: model.appLocale,
          supportedLocales: [
            const Locale('ar', 'TN'), // Arab
            const Locale('fr', 'FR'), //Frensh
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: StoreProvider<AppState>(store: Redux.store, child: RootPage()),
        );
      }),
    );
  }
}
