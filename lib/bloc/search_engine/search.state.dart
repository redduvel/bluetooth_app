import 'package:equatable/equatable.dart';

abstract class GenericSearchState<T> extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchInitial<T> extends GenericSearchState<T> {}

class SearchLoading<T> extends GenericSearchState<T> {}

class SearchLoaded<T> extends GenericSearchState<T> {
  final List<T> items;

  SearchLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class SearchError<T> extends GenericSearchState<T> {
  final String message;

  SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
