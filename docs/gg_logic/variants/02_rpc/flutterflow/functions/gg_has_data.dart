bool ggHasData(dynamic response) {
  return response is Map && (response['period'] is Map ||
      response['user_id'] is String && (response['user_id'] as String).isNotEmpty);
}
