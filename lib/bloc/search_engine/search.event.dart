import 'package:equatable/equatable.dart';

abstract class GenericSearchEvent<T> extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchItems<T> extends GenericSearchEvent<T> {
  final String query;

  SearchItems(this.query);

  @override
  List<Object?> get props => [query];
}
