class MemoryManager {
  double _memoryValue = 0.0;

  void store(double value) => _memoryValue = value;
  void add(double value) => _memoryValue += value;
  void subtract(double value) => _memoryValue -= value;
  void clear() => _memoryValue = 0.0;
  double get value => _memoryValue;
  bool get hasValue => _memoryValue != 0.0;
}