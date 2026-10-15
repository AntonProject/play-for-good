dynamic ggCacheGet(dynamic cache, String key) {
  // Last stored RPC response for this request key, or {} when absent.
  if (cache is! Map) return <String, dynamic>{};
  final hit = cache[key];
  return hit is Map ? hit : <String, dynamic>{};
}
