import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'app_controller.dart';
import 'app_widget.dart';
import 'core/network/network_info.dart';
import 'core/util/input_converter.dart';
import 'modules/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'modules/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'modules/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'modules/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'modules/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'modules/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'modules/number_trivia/number_trivia_module.dart';
import 'modules/number_trivia/presenter/bloc/bloc.dart';

class AppModule extends MainModule {
  final SharedPreferences prefs;
  AppModule({@required this.prefs});

  @override
  List<Bind> get binds => [
        Bind((i) => AppController()),
        //! External
        Bind((i) => http.Client()),
        Bind((i) => SharedPreferences.getInstance()),
        Bind((i) => DataConnectionChecker()),

        //! Features - Number Trivia
        //? Blocs --> should never be singletons (factory are better)
        Bind(
          (i) => NumberTriviaBloc(
            concrete: i<GetConcreteNumberTrivia>(),
            random: i<GetRandomNumberTrivia>(),
            converter: i<InputConverter>(),
          ),
        ),

        //? Usecases --> should definetely be singletons (lazy sigletons better)
        Bind((i) => GetConcreteNumberTrivia(i<NumberTriviaRepository>())),
        Bind((i) => GetRandomNumberTrivia(i<NumberTriviaRepository>())),

        //? Repositories
        Bind<NumberTriviaRepository>(
          (i) => NumberTriviaRepositoryImpl(
            remoteDataSource: i<NumberTriviaRemoteDataSource>(),
            localDataSource: i<NumberTriviaLocalDataSource>(),
            networkInfo: i<NetworkInfo>(),
          ),
        ),

        //? Datasources
        Bind<NumberTriviaRemoteDataSource>(
          (i) => NumberTriviaRemoteDataSourceImpl(client: i()),
        ),
        Bind<NumberTriviaLocalDataSource>(
          // (i) => NumberTriviaLocalDataSourceImpl(sharedPreferences: prefs),
          (i) => NumberTriviaLocalDataSourceImpl(sharedPreferences: i.get(defaultValue: prefs)),
        ),

        //! Core
        Bind((i) => InputConverter()),
        Bind<NetworkInfo>(
          (i) => NetworkInfoImpl(i()),
        ),
      ];

  @override
  List<ModularRouter> get routers => [
        ModularRouter(Modular.initialRoute, module: NumberTriviaModule()),
      ];

  @override
  Widget get bootstrap => AppWidget();

  static Inject get to => Inject<AppModule>.of();
}
