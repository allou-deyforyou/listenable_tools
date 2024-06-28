import 'dart:collection';

class Singleton {
  const Singleton._(this._entries);

  final HashMap<String, dynamic> _entries;
  static Singleton? _singleton;

  /// Get a singleton instance of type [T].
  ///
  /// If an instance with the same type and name exists, it returns the existing instance;
  /// otherwise, it creates a new instance using the provided [createFunction].
  static T instance<T>(T Function() createFunction, [String? name]) {
    _singleton ??= Singleton._(HashMap<String, dynamic>());
    String key = _generateKey<T>(name);
    return _singleton!._entries.putIfAbsent(key, createFunction) as T;
  }

  /// Generates a unique key for the type [T] and an optional [name].
  static String _generateKey<T>([String? name]) {
    return '${T.toString()}${name ?? ''}';
  }
}

/// Create or retrieve a singleton instance with a specific value.
///
/// This is a shorthand function to simplify creating a singleton with a constant value.
T singleton<T>(T Function() createFunction, [String? name]) {
  return Singleton.instance(createFunction, name);
}
