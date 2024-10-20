import 'package:bluetooth_app/clean/core/Data/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


// ======EVENTS======
abstract class DBEvent<T> {}

class Init<T> extends DBEvent<T> {}

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
  ReorderList(this.newIndex, this.oldIndex);
}

class Sync<T> extends DBEvent<T> {
  
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
        await repository.sync().whenComplete(() {
          add(LoadItems<T>());
        });
      } catch (e) {
        emit(ItemOperationFailed(e.toString()));
      }
    },);

    on<LoadItems<T>>((event, emit) async {
      try {
        final items = await repository.getAll();
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
        await repository.update(event.item);
        add(LoadItems<T>());
      } catch (e) {
        emit(ItemOperationFailed<T>(e.toString()));
      }
    });

    on<DeleteItem<T>>((event, emit) async {
      try {
        await repository.delete(event.id);
        add(LoadItems<T>());
      } catch (e) {
        emit(ItemOperationFailed<T>(e.toString()));
      }
    });

    on<ReorderList<T>>((event, emit) {
      try {
        repository.reorderList(event.newIndex, event.oldIndex);
        add(LoadItems<T>());
      } catch (e) {
        emit(ItemOperationFailed<T>(e.toString()));
      }
    });
  }
}
