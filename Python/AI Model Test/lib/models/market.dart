class Market {
  final String id;
  final String question;
  final String description;
  final String category;
  final DateTime endDate;
  final double yesPrice;
  final double noPrice;
  final double volume;
  final int traders;
  final String imageUrl;
  final bool resolved;
  final String? resolution;

  Market({
    required this.id,
    required this.question,
    required this.description,
    required this.category,
    required this.endDate,
    required this.yesPrice,
    required this.noPrice,
    required this.volume,
    required this.traders,
    required this.imageUrl,
    this.resolved = false,
    this.resolution,
  });

  double get probability => yesPrice;

  bool get isClosing {
    final now = DateTime.now();
    final daysUntilClose = endDate.difference(now).inDays;
    return daysUntilClose <= 7;
  }

  String get timeUntilClose {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    
    if (difference.isNegative) {
      return 'Closed';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours.remainder(24)}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inMinutes}m';
    }
  }
}
