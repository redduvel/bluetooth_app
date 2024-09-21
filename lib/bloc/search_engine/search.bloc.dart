import 'package:bluetooth_app/bloc/search_engine/search.event.dart';
import 'package:bluetooth_app/bloc/search_engine/search.state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GenericSearchBloc<T>
    extends Bloc<GenericSearchEvent<T>, GenericSearchState<T>> {
  final Box<T> hiveBox;
  final bool Function(T, String) searchCondition;

  GenericSearchBloc(this.hiveBox, this.searchCondition)
      : super(SearchInitial<T>()) {
    on<SearchItems<T>>((event, emit) {
      try {
        emit(SearchLoading<T>());
        final query = event.query.toLowerCase();
        if (query == '') {
          emit(SearchError('Введите поисковой запрос'));
          return;
        }
        final filteredItems = hiveBox.values
            .where((item) => searchCondition(item, query))
            .toList();
        emit(SearchLoaded<T>(filteredItems));
      } catch (e) {
        emit(SearchError<T>("Ошибка поиска"));
      }
    });
  }
}
