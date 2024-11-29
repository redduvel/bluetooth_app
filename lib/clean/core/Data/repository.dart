abstract class IRepository<T> {
  T? currentItem;
  Future<List<T>> sync();
  Future<void> save(T model, {bool sync = false});
  List<T> getAll();
  List<T> search(String query);
  Future<void> update(T model, {bool sync = false});
  Future<void> delete(String id, {bool sync = false});
  Future<void> reorderList(int newIndex, int oldIndex, {bool sync = false});
}
