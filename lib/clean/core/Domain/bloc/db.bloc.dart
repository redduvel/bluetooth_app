import 'package:bluetooth_app/clean/core/Data/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


// ======EVENTS======
abstract class DBEvent<T> {}

class LoadItems<T> extends DBEvent<T> {}

class AddItem<T> extends DBEvent<T> {
  final T item;
  AddItem(this.item);
}

class UpdateItem<T> extends DBEvent<T> {
  final T item;
  UpdateItem(this.item);
}

class DeleteItem<T> extends DBEvent<T> {
  final String id;
  DeleteItem(this.id);
}

class ReorderList<T> extends DBEvent<T> {
  final int newIndex;
  final int oldIndex;
  final bool sync;
  ReorderList(this.newIndex, this.oldIndex, this.sync);
}

class Sync<T> extends DBEvent<T> {
  
}

class Search<T> extends DBEvent<T> {
  final String query;

  Search(this.query);
}



// ======STATES======
abstract class DBState<T> {}

class ItemsLoading<T> extends DBState<T> {}

class ItemsLoaded<T> extends DBState<T> {
  final List<T> items;
  ItemsLoaded(this.items);
}

class ItemOperationFailed<T> extends DBState<T> {
  final String error;
  ItemOperationFailed(this.error);
}

// ======BLOC======
class DBBloc<T> extends Bloc<DBEvent<T>, DBState<T>> {
  final IRepository<T> repository;

  DBBloc(this.repository) : super(ItemsLoading<T>()) {
    on<Sync<T>>((event, emit) async {
      try {
        emit(ItemsLoading<T>());
        await repository.sync().then((value) {
          emit(ItemsLoaded<T>(value));
        });
      } catch (e) {
        emit(ItemOperationFailed(e.toString()));
      }
    });

    on<LoadItems<T>>((event, emit) async {
      try {
        final items = repository.getAll();
        emit(ItemsLoaded<T>(items));
      } catch (e) {
        emit(ItemOperationFailed<T>(e.toString()));
      }
    });

    on<AddItem<T>>((event, emit) async {
      try {
        await repository.save(event.item, sync: true);
        add(LoadItems<T>());
      } catch (e) {
        emit(ItemOperationFailed<T>(e.toString()));
      }
    });

    on<UpdateItem<T>>((event, emit) async {
      try {
        await repository.update(event.item, sync: true);
        add(LoadItems<T>());
      } catch (e) {
        emit(ItemOperationFailed<T>(e.toString()));
      }
    });

    on<DeleteItem<T>>((event, emit) async {
      try {
        await repository.delete(event.id, sync: true);
        add(LoadItems<T>());
      } catch (e) {
        emit(ItemOperationFailed<T>(e.toString()));
      }
    });

    on<ReorderList<T>>((event, emit) {
      try {
        repository.reorderList(event.newIndex, event.oldIndex, sync: event.sync);
        add(LoadItems<T>());
      } catch (e) {
        emit(ItemOperationFailed<T>(e.toString()));
      }
    });

    on<Search<T>>((event, emit) {
      try {
        emit(ItemsLoaded(repository.search(event.query)));
      } catch (e) {
        emit(ItemOperationFailed(e.toString()));
      }
    });
  }
}
