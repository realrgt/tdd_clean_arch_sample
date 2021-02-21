import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:tdd_clean_arch/app/core/errors/exceptions.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/repositories/number_trivia_repository.dart';
import '../datasources/number_trivia_local_data_source.dart';
import '../datasources/number_trivia_remote_data_source.dart';

typedef Future<NumberTrivia> _ConcreteOrRandomChooser();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteDataSource remoteDataSource;
  final NumberTriviaLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl({
    @required this.remoteDataSource,
    @required this.localDataSource,
    @required this.networkInfo,
  });

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTriva(
    int number,
  ) async {
    return await _getTrivia(
      () => remoteDataSource.getConcreteNumberTriva(number),
    );
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTriva() async {
    return await _getTrivia(
      () => remoteDataSource.getRandomNumberTriva(),
    );
  }

  Future<Either<Failure, NumberTrivia>> _getTrivia(
    // Future<NumberTrivia> Function() getConcreteOrRandom,
    _ConcreteOrRandomChooser getConcreteOrRandom,
  ) async {
    // networkInfo.isConnected
    // final isConnected = await networkInfo.isConnected;

    if (await networkInfo.isConnected) {
      try {
        final remoteTrivia = await getConcreteOrRandom();
        await localDataSource.cacheNumberTrivia(remoteTrivia);
        return Right(remoteTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localTrivia = await localDataSource.getLastNumberTrivia();
        return Right(localTrivia);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
