bool ggHasMore(dynamic response) {
  // Next page exists for a paginated v2 response (ranking or games history).
  if (response is! Map) return false;
  final page = response['pagination'];
  return page is Map && page['has_more'] == true;
}
