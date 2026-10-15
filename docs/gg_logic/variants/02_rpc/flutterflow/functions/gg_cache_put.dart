dynamic ggCachePut(dynamic cache, String key, dynamic value) {
  // Stores the latest response under key; keeps the 12 most recent keys.
  final next = <String, dynamic>{};
  if (cache is Map) {
    cache.forEach((k, v) {
      if ('$k' != key) next['$k'] = v;
    });
  }
  if (value is Map && value.isNotEmpty) next[key] = value;
  while (next.length > 12) {
    next.remove(next.keys.first);
  }
  return next;
}
