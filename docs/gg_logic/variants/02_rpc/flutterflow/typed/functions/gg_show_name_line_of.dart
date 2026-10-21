bool ggShowNameLineOf(
  String? userId,
  String? firstName,
  String? surname,
) {
  // Line under the nick in the profile header: "Gastnutzer" for the guest,
  // otherwise first name + surname. Hidden when both are empty (it printed a
  // blank line that kept its height).
  if (userId == 'guest') return true;
  return '${firstName ?? ''}${surname ?? ''}'.trim().isNotEmpty;
}
