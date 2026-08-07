String donorDisplayName(String donorId) {
  final cleaned = donorId.trim();

  if (cleaned.isEmpty) {
    return 'Community Member';
  }

  final words = cleaned.split(RegExp(r'[-_\s]+')).where((w) => w.isNotEmpty);

  if (words.isEmpty) {
    return 'Community Member';
  }

  return words
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}
