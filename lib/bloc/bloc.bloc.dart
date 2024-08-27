import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bluetooth_app/bloc/repository.dart';


// ======EVENTS======
abstract class GenericEvent<T> {}

class LoadItems<T> extends GenericEvent<T> {}

class AddItem<T> extends GenericEvent<T> {
  final T item;
  AddItem(this.item);
}

class UpdateItem<T> extends GenericEvent<T> {
  final int index;
  final T item;
  UpdateItem(this.index, this.item);
}

class DeleteItem<T> extends GenericEvent<T> {
  final int index;
  DeleteItem(this.index);
}

class ReorderList<T> extends GenericEvent<T> {
  final int newIndex;
  final int oldIndex;
  ReorderList(this.newIndex, this.oldIndex);
}



// ======STATES======
abstract class GenericState<T> {}

class ItemsLoading<T> extends GenericState<T> {}

class ItemsLoaded<T> extends GenericState<T> {
  final List<T> items;
  ItemsLoaded(this.items);
}

class ItemOperationFailed<T> extends GenericState<T> {
  final String error;
  ItemOperationFailed(this.error);
}

// ======BLOC======
class GenericBloc<T> extends Bloc<GenericEvent<T>, GenericState<T>> {
  final Repository<T> repository;

  GenericBloc(this.repository) : super(ItemsLoading<T>()) {
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
        await repository.add(event.item);
        add(LoadItems<T>());
      } catch (e) {
        emit(ItemOperationFailed<T>(e.toString()));
      }
    });

    on<UpdateItem<T>>((event, emit) async {
      try {
        await repository.update(event.index, event.item);
        add(LoadItems<T>());
      } catch (e) {
        emit(ItemOperationFailed<T>(e.toString()));
      }
    });

    on<DeleteItem<T>>((event, emit) async {
      try {
        await repository.delete(event.index);
        add(LoadItems<T>());
      } catch (e) {
        emit(ItemOperationFailed<T>(e.toString()));
      }
    });

    on<ReorderList<T>>((event, emit) async {
      try {
        await repository.reorderList(event.newIndex, event.oldIndex);
        add(LoadItems<T>());
      } catch (e) {
        emit(ItemOperationFailed<T>(e.toString()));
      }
    });
  }
}
