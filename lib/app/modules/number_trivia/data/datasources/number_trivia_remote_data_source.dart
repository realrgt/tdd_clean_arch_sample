import '../models/number_trivia_model.dart';

abstract class NumberTriviaRemoteDataSource {
  Future<NumberTriviaModel> getConcreteNumberTriva(int number);
  Future<NumberTriviaModel> getRandomNumberTriva();
}
