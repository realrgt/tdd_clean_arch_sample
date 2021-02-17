import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  @override
  List<Object> get props => [];
}

// General failures
class ServerException extends Failure {}

class CacheException extends Failure {}
