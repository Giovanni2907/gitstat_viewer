/// Formate une date en durée relative courte, façon GitHub
/// ("à l'instant", "5 min", "3 h", "2 j", "3 sem"...).
String relativeTime(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date.toLocal());

  if (diff.inSeconds < 60) return "à l'instant";
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
  if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
  if (diff.inDays < 30) return 'il y a ${(diff.inDays / 7).floor()} sem';
  if (diff.inDays < 365) return 'il y a ${(diff.inDays / 30).floor()} mois';
  final years = (diff.inDays / 365).floor();
  return 'il y a $years an${years > 1 ? 's' : ''}';
}