import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_clean_arch/app/core/usecases/usecase.dart';
import 'package:tdd_clean_arch/app/modules/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd_clean_arch/app/modules/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:tdd_clean_arch/app/modules/number_trivia/domain/usecases/get_random_number_trivia.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  GetRandomNumberTrivia usecase;
  MockNumberTriviaRepository mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetRandomNumberTrivia(mockNumberTriviaRepository);
  });

  final tNumnerTrivia = NumberTrivia(number: 1, text: 'test');

  test('should get a random trivia from repository', () async {
    // arrange
    when(mockNumberTriviaRepository.getRandomNumberTriva())
        .thenAnswer((_) async => Right(tNumnerTrivia));
    // act
    final result = await usecase.call(NoParams());
    // assert
    expect(result, Right(tNumnerTrivia));
    verify(mockNumberTriviaRepository.getRandomNumberTriva());
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}
