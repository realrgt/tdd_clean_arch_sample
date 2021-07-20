import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/network_info.dart';
import '../../core/util/input_converter.dart';
import 'data/datasources/number_trivia_local_data_source.dart';
import 'data/datasources/number_trivia_remote_data_source.dart';
import 'data/repositories/number_trivia_repository_impl.dart';
import 'domain/repositories/number_trivia_repository.dart';
import 'domain/usecases/get_concrete_number_trivia.dart';
import 'domain/usecases/get_random_number_trivia.dart';
import 'presenter/bloc/number_trivia_bloc.dart';
import 'presenter/pages/number_trivia_page.dart';

class NumberTriviaModule extends ChildModule {
  final SharedPreferences prefs;
  NumberTriviaModule({@required this.prefs});

  @override
  List<Bind> get binds => [
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
        ModularRouter(Modular.initialRoute, child: (_, __) => NumberTriviaPage()),
      ];
}
