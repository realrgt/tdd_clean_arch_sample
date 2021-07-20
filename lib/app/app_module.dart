import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_widget.dart';
import 'modules/number_trivia/number_trivia_module.dart';

class AppModule extends MainModule {
  final SharedPreferences prefs;
  AppModule({@required this.prefs});

  @override
  List<Bind> get binds => [];

  @override
  List<ModularRouter> get routers => [
        ModularRouter(Modular.initialRoute, module: NumberTriviaModule(prefs: prefs)),
      ];

  @override
  Widget get bootstrap => AppWidget();

  static Inject get to => Inject<AppModule>.of();
}
