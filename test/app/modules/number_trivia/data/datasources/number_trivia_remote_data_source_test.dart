import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:tdd_clean_arch/app/core/errors/exceptions.dart';
import 'package:tdd_clean_arch/app/modules/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdd_clean_arch/app/modules/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  NumberTriviaRemoteDataSourceImpl dataSource;
  MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final jsonString = fixture('trivia.json');
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(jsonString));

    test(
      '''should perform a get request on a URL with number being the endpoint and with application/json''',
      () async {
        // arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(jsonString, 200));
        // act
        await dataSource.getConcreteNumberTriva(tNumber);
        // assert
        verify(mockHttpClient.get(
          'http://numbersapi.com/$tNumber',
          headers: {'Content-Type': 'application/json'},
        ));
      },
    );

    test(
      'should return NumberTrivia when response code is 200 (success)',
      () async {
        // arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(jsonString, 200));
        // act
        final result = await dataSource.getConcreteNumberTriva(tNumber);
        // assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code aint 200 (failure)',
      () async {
        // arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response('Something went wrong', 404));
        // act
        final call = dataSource.getConcreteNumberTriva;
        // assert
        expect(() => call(tNumber), throwsA(isA<ServerException>()));
      },
    );
  });

  group('getRandomNumberTrivia', () {
    final jsonString = fixture('trivia.json');
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(jsonString));

    test(
      '''should perform a get request on a URL with number being the endpoint and with application/json''',
      () async {
        // arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(jsonString, 200));
        // act
        await dataSource.getRandomNumberTriva();
        // assert
        verify(mockHttpClient.get(
          'http://numbersapi.com/random',
          headers: {'Content-Type': 'application/json'},
        ));
      },
    );

    test(
      'should return NumberTrivia when response code is 200 (success)',
      () async {
        // arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(jsonString, 200));
        // act
        final result = await dataSource.getRandomNumberTriva();
        // assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code aint 200 (failure)',
      () async {
        // arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response('Something went wrong', 404));
        // act
        final call = dataSource.getRandomNumberTriva;
        // assert
        expect(() => call(), throwsA(isA<ServerException>()));
      },
    );
  });
}
