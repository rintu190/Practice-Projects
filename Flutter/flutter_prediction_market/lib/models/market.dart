class Market {
  final String id;
  final String category;
  final String title;
  final int yesPrice;
  final int noPrice;
  final String volume;
  final String volume24h;
  final String startDate;
  final String endDate;
  final bool isEndingSoon;

  Market({
    required this.id,
    required this.category,
    required this.title,
    required this.yesPrice,
    required this.noPrice,
    required this.volume,
    this.volume24h = '₹0',
    this.startDate = 'Jan 1, 2026',
    this.endDate = 'Dec 31, 2026',
    this.isEndingSoon = false,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['id'].toString(),
      category: json['category'] ?? 'General',
      title: json['title'] ?? '',
      yesPrice: json['yesPrice'] is int ? json['yesPrice'] : int.tryParse(json['yesPrice'].toString()) ?? 50,
      noPrice: json['noPrice'] is int ? json['noPrice'] : int.tryParse(json['noPrice'].toString()) ?? 50,
      volume: json['volume']?.toString() ?? '₹0',
      volume24h: json['volume24h']?.toString() ?? '₹0',
      startDate: json['startDate'] ?? 'Unspecified',
      endDate: json['endDate'] ?? 'Unspecified',
      isEndingSoon: json['isEndingSoon'] == true || json['isEndingSoon'] == 1 || json['isEndingSoon'] == '1',
    );
  }
}
