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
    return _singleton!._entries
        .putIfAbsent('${T.runtimeType}$name', createFunction);
  }
}

/// Create or retrieve a singleton instance with a specific value.
///
/// This is a shorthand function to simplify creating a singleton with a constant value.
T singleton<T>(T Function() createFunction, [String? name]) {
  return Singleton.instance(createFunction, name);
}
