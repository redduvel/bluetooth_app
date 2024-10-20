
abstract class IRepository<T> {
  dynamic currentItem;
  Future<void> sync();
  Future<void> save(T model, {bool sync = false});
  List<T> getAll();
  Future<void> update(T model, {bool sync = false});
  Future<void> delete(String id, {bool sync = false});
  Future<void> reorderList(int newIndex, int oldIndex, {bool sync = false});
}
