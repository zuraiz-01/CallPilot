class HistoryRepository {
  final List<String> _items = [];

  List<String> getAll() => List<String>.unmodifiable(_items);

  void add(String number) {
    _items.insert(0, number);
  }

  void clear() {
    _items.clear();
  }
}
