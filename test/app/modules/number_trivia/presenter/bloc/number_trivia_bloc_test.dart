import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_clean_arch/app/core/util/input_converter.dart';
import 'package:tdd_clean_arch/app/modules/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd_clean_arch/app/modules/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tdd_clean_arch/app/modules/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:tdd_clean_arch/app/modules/number_trivia/presenter/bloc/bloc.dart';

class MockGetConcreteNumberTrivia extends Mock implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      converter: mockInputConverter,
    );
  });

  test('initialState should be empty', () {
    // assert
    expect(bloc.initialState, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    test(
      'should call the InputConverter to validate and convert the string to an unsigned integer ',
      () async {
        // arrange
        when(mockInputConverter.stringToUnsignedInteger(any)).thenReturn(Right(tNumberParsed));
        // act
        bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
        // assert
        verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
      },
    );

    test(
      'should emit [Error] when the input is invalid',
      () async {
        // arrange
        when(mockInputConverter.stringToUnsignedInteger(any)).thenReturn(Left(InvalidInputFailure()));

        // assert
        final expected = [
          Empty(),
          Error(message: INVALID_INPUT_FAILURE_MESSAGE),
        ];
        // expect later
        expectLater(bloc.state, emitsInOrder(expected));

        // act
        bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
      },
    );
  });
}
