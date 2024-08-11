abstract class Repository<T> {
  dynamic currentItem;

  Future<List<T>> getAll();
  Future<void> add(T item);
  Future<void> update(T item);
  Future<void> delete(String id);
}
