abstract class Repository<T> {
  dynamic currentItem;

  Future<List<T>> getAll();
  Future<void> add(T item);
  Future<bool> update(T item);
  Future<void> delete(String id);
  Future<void> reorderList(int newIndex, int oldIndex);
}
