import '../models/market.dart';
import '../models/position.dart';
import '../models/user.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();

  factory MockDataService() {
    return _instance;
  }

  MockDataService._internal();

  late List<Market> _markets;
  late List<Position> _positions;
  late User _user;
  double _balance = 5234.50;

  void initialize() {
    _markets = _generateMockMarkets();
    _positions = _generateMockPositions();
    _user = _generateMockUser();
  }

  List<Market> getMockMarkets() {
    return _markets;
  }

  Market getMarketById(String id) {
    return _markets.firstWhere((m) => m.id == id);
  }

  List<Market> getMarketsByCategory(String category) {
    return _markets.where((m) => m.category == category).toList();
  }

  List<Position> getUserPositions() {
    return _positions;
  }

  User getUser() {
    return _user;
  }

  void updateMarketPrice(String marketId, double yesPrice) {
    final index = _markets.indexWhere((m) => m.id == marketId);
    if (index != -1) {
      final market = _markets[index];
      _markets[index] = Market(
        id: market.id,
        question: market.question,
        description: market.description,
        category: market.category,
        endDate: market.endDate,
        yesPrice: yesPrice,
        noPrice: 1.0 - yesPrice,
        volume: market.volume,
        traders: market.traders,
        imageUrl: market.imageUrl,
        resolved: market.resolved,
        resolution: market.resolution,
      );
    }
  }

  bool placeOrder({
    required String marketId,
    required String outcome,
    required double shares,
    required double price,
  }) {
    final cost = shares * price * 100;
    if (cost > _balance) {
      return false;
    }

    _balance -= cost;
    _positions.add(Position(
      id: 'pos_${DateTime.now().millisecondsSinceEpoch}',
      marketId: marketId,
      marketQuestion: getMarketById(marketId).question,
      outcome: outcome,
      shares: shares,
      averagePrice: price,
      currentPrice: price,
      boughtAt: DateTime.now(),
    ));

    final market = getMarketById(marketId);
    final newPrice = outcome == 'YES'
        ? (market.yesPrice + 0.02).clamp(0.1, 0.9)
        : (market.yesPrice - 0.02).clamp(0.1, 0.9);
    updateMarketPrice(marketId, newPrice);

    return true;
  }

  bool sellPosition(String positionId) {
    final index = _positions.indexWhere((p) => p.id == positionId);
    if (index == -1) return false;

    final position = _positions[index];
    final sellValue = position.shares * position.currentPrice * 100;
    _balance += sellValue;
    _positions.removeAt(index);

    return true;
  }

  double getAvailableBalance() {
    return _balance;
  }

  List<Market> _generateMockMarkets() {
    return [
      Market(
        id: '1',
        question: 'Will Bitcoin reach \$100K by end of 2024?',
        description: 'Bitcoin price prediction for year-end 2024',
        category: 'Cryptocurrency',
        endDate: DateTime.now().add(const Duration(days: 200)),
        yesPrice: 0.68,
        noPrice: 0.32,
        volume: 2500000,
        traders: 12500,
        imageUrl: 'https://via.placeholder.com/400x200?text=Bitcoin',
      ),
      Market(
        id: '2',
        question: 'Will the Fed cut rates in Q2 2024?',
        description: 'Federal Reserve interest rate decision prediction',
        category: 'Economics',
        endDate: DateTime.now().add(const Duration(days: 60)),
        yesPrice: 0.72,
        noPrice: 0.28,
        volume: 1850000,
        traders: 8900,
        imageUrl: 'https://via.placeholder.com/400x200?text=Fed+Rates',
      ),
      Market(
        id: '3',
        question: 'Will Ethereum outperform Bitcoin in 2024?',
        description: 'Ethereum performance compared to Bitcoin',
        category: 'Cryptocurrency',
        endDate: DateTime.now().add(const Duration(days: 280)),
        yesPrice: 0.35,
        noPrice: 0.65,
        volume: 1200000,
        traders: 6200,
        imageUrl: 'https://via.placeholder.com/400x200?text=Ethereum',
      ),
      Market(
        id: '4',
        question: 'Will Apple stock hit \$200 by Q3 2024?',
        description: 'Apple Inc. stock price prediction',
        category: 'Technology',
        endDate: DateTime.now().add(const Duration(days: 150)),
        yesPrice: 0.55,
        noPrice: 0.45,
        volume: 3100000,
        traders: 15000,
        imageUrl: 'https://via.placeholder.com/400x200?text=Apple+Stock',
      ),
      Market(
        id: '5',
        question: 'Will AI breakthroughs accelerate in 2024?',
        description: 'Major AI advancement predictions',
        category: 'Technology',
        endDate: DateTime.now().add(const Duration(days: 200)),
        yesPrice: 0.82,
        noPrice: 0.18,
        volume: 950000,
        traders: 5100,
        imageUrl: 'https://via.placeholder.com/400x200?text=AI+Tech',
      ),
      Market(
        id: '6',
        question: 'Will ChatGPT have 1B users by EOY 2024?',
        description: 'ChatGPT user growth prediction',
        category: 'Technology',
        endDate: DateTime.now().add(const Duration(days: 260)),
        yesPrice: 0.44,
        noPrice: 0.56,
        volume: 680000,
        traders: 3400,
        imageUrl: 'https://via.placeholder.com/400x200?text=ChatGPT',
      ),
      Market(
        id: '7',
        question: 'Will the S&P 500 end 2024 above 5500?',
        description: 'S&P 500 year-end price prediction',
        category: 'Economics',
        endDate: DateTime.now().add(const Duration(days: 220)),
        yesPrice: 0.61,
        noPrice: 0.39,
        volume: 2200000,
        traders: 11000,
        imageUrl: 'https://via.placeholder.com/400x200?text=SP500',
      ),
      Market(
        id: '8',
        question: 'Will Tesla stock outperform the market in 2024?',
        description: 'Tesla performance vs broader market',
        category: 'Technology',
        endDate: DateTime.now().add(const Duration(days: 190)),
        yesPrice: 0.48,
        noPrice: 0.52,
        volume: 1650000,
        traders: 8200,
        imageUrl: 'https://via.placeholder.com/400x200?text=Tesla+Stock',
      ),
      Market(
        id: '9',
        question: 'Will unemployment stay below 4% in 2024?',
        description: 'US unemployment rate prediction',
        category: 'Economics',
        endDate: DateTime.now().add(const Duration(days: 240)),
        yesPrice: 0.58,
        noPrice: 0.42,
        volume: 1100000,
        traders: 5500,
        imageUrl: 'https://via.placeholder.com/400x200?text=Unemployment',
      ),
      Market(
        id: '10',
        question: 'Will Solana hit \$200 by end of 2024?',
        description: 'Solana price prediction for year-end',
        category: 'Cryptocurrency',
        endDate: DateTime.now().add(const Duration(days: 250)),
        yesPrice: 0.42,
        noPrice: 0.58,
        volume: 780000,
        traders: 3900,
        imageUrl: 'https://via.placeholder.com/400x200?text=Solana',
      ),
    ];
  }

  List<Position> _generateMockPositions() {
    return [
      Position(
        id: 'pos1',
        marketId: '1',
        marketQuestion: 'Will Bitcoin reach \$100K by end of 2024?',
        outcome: 'YES',
        shares: 50,
        averagePrice: 0.62,
        currentPrice: 0.68,
        boughtAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Position(
        id: 'pos2',
        marketId: '4',
        marketQuestion: 'Will Apple stock hit \$200 by Q3 2024?',
        outcome: 'NO',
        shares: 100,
        averagePrice: 0.48,
        currentPrice: 0.45,
        boughtAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      Position(
        id: 'pos3',
        marketId: '7',
        marketQuestion: 'Will the S&P 500 end 2024 above 5500?',
        outcome: 'YES',
        shares: 75,
        averagePrice: 0.57,
        currentPrice: 0.61,
        boughtAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }

  User _generateMockUser() {
    return User(
      id: 'user_001',
      username: 'trader_pro',
      email: 'user@example.com',
      balance: 5234.50,
      totalProfit: 1245.75,
      totalTrades: 47,
    );
  }
}
