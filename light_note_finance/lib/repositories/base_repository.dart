abstract class BaseRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> save(T item);
  Future<void> saveAll(List<T> items);
  Future<void> update(T item);
  Future<void> delete(String id);
  Future<void> clear();
}