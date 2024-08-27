abstract class Repository<T> {
  dynamic currentItem;

  Future<List<T>> getAll();
  Future<void> add(T item);
  Future<bool> update(int index, T item);
  Future<void> delete(int index);
  Future<void> reorderList(int newIndex, int oldIndex);
}
