abstract class Repository<T> {
  dynamic currentItem;

  List<T> getAll();
  Future<void> add(T item);
  Future<bool> update(T item);
  Future<void> delete(String id);
  void reorderList(int newIndex, int oldIndex);
}
