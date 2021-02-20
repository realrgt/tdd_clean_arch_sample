import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_clean_arch/app/core/errors/exceptions.dart';
import 'package:tdd_clean_arch/app/core/errors/failure.dart';
import 'package:tdd_clean_arch/app/core/platform/network_info.dart';
import 'package:tdd_clean_arch/app/modules/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd_clean_arch/app/modules/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdd_clean_arch/app/modules/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_clean_arch/app/modules/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:tdd_clean_arch/app/modules/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  NumberTriviaRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();

    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTriva', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'test');
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    runTestsOnline(() {
      test('should check if the device is online', () async {
        // arrange
        when(mockRemoteDataSource.getConcreteNumberTriva(tNumber))
            .thenAnswer((_) async => tNumberTrivia);
        // act
        await repository.getConcreteNumberTriva(tNumber);
        // assert
        verify(mockNetworkInfo.isConnected);
      });

      test(
        'should return data when remote datasource is called successfully',
        () async {
          // arrange
          when(mockRemoteDataSource.getConcreteNumberTriva(tNumber))
              .thenAnswer((_) async => tNumberTrivia);
          // act
          final result = await repository.getConcreteNumberTriva(tNumber);
          // assert
          verify(mockRemoteDataSource.getConcreteNumberTriva(tNumber));
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should cache data locally if device is connected',
        () async {
          // arrange
          when(mockRemoteDataSource.getConcreteNumberTriva(tNumber))
              .thenAnswer((_) async => tNumberTrivia);
          // act
          await repository.getConcreteNumberTriva(tNumber);
          // assert
          verify(mockRemoteDataSource.getConcreteNumberTriva(tNumber));
          verify(mockLocalDataSource.cacheNumberTrivia(tNumberTrivia));
        },
      );

      test(
        'should return server failure when remote datasource is unsuccessful',
        () async {
          // arrange
          when(mockRemoteDataSource.getConcreteNumberTriva(tNumber))
              .thenThrow(ServerException());
          // act
          final result = await repository.getConcreteNumberTriva(tNumber);
          // assert
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally cached data when the cache data is present ',
        () async {
          // arrange
          when(mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTrivia);
          // act
          final result = await repository.getConcreteNumberTriva(tNumber);
          // assert
          verifyNoMoreInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia()); // verify one call
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should return cache exception when cache data is not present',
        () async {
          // arrange
          when(mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          // act
          final result = await repository.getConcreteNumberTriva(tNumber);
          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });

  group('getRandomNumberTriva', () {
    final tNumberTriviaModel = NumberTriviaModel(text: 'test', number: 1);
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    runTestsOnline(() {
      test(
        'should return data when remote datasource is successful',
        () async {
          // arrange
          when(mockRemoteDataSource.getRandomNumberTriva())
              .thenAnswer((realInvocation) async => tNumberTrivia);
          // act
          final result = await repository.getRandomNumberTriva();
          // assert
          verify(mockRemoteDataSource.getRandomNumberTriva());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should cache data locally when the divice is connected',
        () async {
          // arrange
          when(mockRemoteDataSource.getRandomNumberTriva())
              .thenAnswer((realInvocation) async => tNumberTrivia);
          // act
          await repository.getRandomNumberTriva();
          // assert
          verify(mockRemoteDataSource.getRandomNumberTriva());
          verify(mockLocalDataSource.cacheNumberTrivia(tNumberTrivia));
        },
      );

      test(
        'should return a server exception when remote datasource is unsuccessful',
        () async {
          // arrange
          when(mockRemoteDataSource.getRandomNumberTriva())
              .thenThrow(ServerException());
          // act
          final result = await repository.getRandomNumberTriva();
          // assert
          verify(mockRemoteDataSource.getRandomNumberTriva());
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return the last cached data when device is offline',
        () async {
          // arrange
          when(mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((realInvocation) async => tNumberTrivia);
          // act
          final result = await repository.getRandomNumberTriva();
          // assert
          verify(mockLocalDataSource.getLastNumberTrivia());
          verifyZeroInteractions(mockRemoteDataSource);
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should return a cache exception when no cached data is present',
        () async {
          // arrange
          when(mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          // act
          final result = await repository.getRandomNumberTriva();
          // assert
          verify(mockLocalDataSource.getLastNumberTrivia());
          verifyZeroInteractions(mockRemoteDataSource);
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });
}
