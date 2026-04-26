# Polymarket Clone - Flutter App

A comprehensive Flutter application that replicates the core features of Polymarket, a prediction market platform. Users can browse prediction markets, place bets on outcomes, track their portfolio, and monitor profit/loss in real-time.

## Features

### Markets Browse
- 📊 **Market Listing**: Browse all available prediction markets
- 🔍 **Search & Filter**: Search markets by question and filter by category (Cryptocurrency, Economics, Technology)
- 📈 **Probability Visualization**: Real-time probability bars showing YES/NO odds
- 💰 **Market Statistics**: View volume, trader count, and time remaining
- 📅 **Category Badges**: Easy identification of market types

### Market Details
- 🖼️ **Market Image**: Visual representation of each prediction market
- 📊 **Price Charts**: Interactive candlestick-style charts showing historical price movements
- 📋 **Market Description**: Detailed information about the prediction
- 💹 **Probability Display**: Clear YES/NO probability percentages
- ⏰ **Countdown Timer**: Shows time remaining until market closes

### Trading
- 🛒 **Place Predictions**: Buy YES or NO shares for any market
- 💵 **Flexible Sizing**: Specify custom number of shares to purchase
- 📊 **Cost Calculator**: Real-time calculation of total investment cost
- ✅ **Order Confirmation**: Clear feedback on successful orders

### Portfolio Management
- 👤 **User Dashboard**: View profile information and total portfolio value
- 💰 **Balance Tracking**: Monitor available balance and total profit
- 📈 **Position Monitoring**: View all open positions with detailed stats
- 📊 **Performance Metrics**: Track P&L, profit percentage, and entry prices
- 🔄 **Quick Actions**: Sell positions or view market details from portfolio

## Project Structure

```
lib/
├── main.dart                          # App entry point and navigation
├── models/
│   ├── market.dart                    # Market model with probability logic
│   ├── position.dart                  # User position/trade model
│   └── user.dart                      # User profile model
├── screens/
│   ├── home_screen.dart               # Markets listing page
│   ├── market_detail_screen.dart      # Individual market details
│   └── portfolio_screen.dart          # User portfolio and positions
├── services/
│   └── mock_data_service.dart         # Mock data generation (replace with API)
└── widgets/
    ├── market_card.dart               # Market card in listing
    ├── market_chart.dart              # Price chart visualization
    ├── trading_panel.dart             # Trading interface
    └── position_card.dart             # Position display component
```

## Getting Started

### Prerequisites
- Flutter SDK 3.11.0 or higher
- Dart 3.11.0 or higher
- Android Studio / Xcode (for development)

### Installation

1. **Clone the repository**
   ```bash
   cd "/home/rintu/Developer/Practice-Projects/Python/AI Model Test"
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android
   flutter run -d <device-id>
   
   # For iOS
   flutter run -d <device-id>
   
   # For web
   flutter run -d chrome
   ```

## Project Components

### Models

#### `Market` Model
- Represents a prediction market with question, outcomes, and probabilities
- Properties: `question`, `category`, `endDate`, `yesPrice`, `noPrice`, `volume`, `traders`
- Methods: `timeUntilClose`, `isClosing` (checks if market closes within 7 days)

#### `Position` Model
- Represents a user's bet/position on a market outcome
- Tracks: shares, average price, current price, entry date
- Calculates: profit, loss, profit percentage

#### `User` Model
- Stores user profile and portfolio summary
- Tracks: username, email, balance, total profit, trade count

### Services

#### `MockDataService`
- Singleton service providing mock market and position data
- Methods:
  - `getMockMarkets()`: Returns list of 10 sample markets
  - `getMarketById(id)`: Fetch specific market
  - `getUserPositions()`: Get user's current positions
  - `updateMarketPrice()`: Update market probability

### Screens

#### `HomeScreen`
- Primary interface for market discovery
- Features: market search, category filtering, market listing
- Navigation to market details on card tap

#### `MarketDetailScreen`
- Detailed view of a single market
- Components: image, description, chart, probabilities, trading panel
- Allows placing new trades

#### `PortfolioScreen`
- User portfolio dashboard
- Shows: profile info, balance, open positions
- Position management: view details, sell, check market

### Widgets

#### `MarketCard`
- Displays market in list format
- Shows: market image, category, question, probability bar, key metrics
- Interactive and tap-able

#### `MarketChart`
- Custom chart showing historical price movements
- Generated with mock price history
- Displays: high, current, low prices
- Uses CustomPaint for rendering

#### `TradingPanel`
- Interactive trading interface
- Features: outcome selection, share quantity input, cost calculation
- Immediate order feedback

#### `PositionCard`
- Displays user's positions with performance metrics
- Shows: shares, prices, P&L, buttons for sell/view market

## Mock Data

The app comes with 10 pre-populated markets across multiple categories:
- **Cryptocurrency**: Bitcoin, Ethereum, Solana predictions
- **Economics**: Fed rates, S&P 500, unemployment predictions
- **Technology**: Apple stock, AI breakthroughs, ChatGPT growth

Users start with:
- Balance: $5,234.50
- Total Profit: $1,245.75
- 3 Open Positions
- 47 Total Trades

## Customization & Integration

### Replacing Mock Data
The app uses `MockDataService` for all data. To integrate a real API:

1. Create a new `ApiService` class
2. Replace `MockDataService` calls in screens with API calls
3. Use packages like `http` or `dio` for API communication

### Adding Real Authentication
Implement user authentication by:
1. Adding Firebase Auth or similar package
2. Wrapping app with authentication flow
3. Storing user tokens securely

### Market Updates
Implement real-time market updates using:
- WebSocket connections (package: `web_socket_channel`)
- Server-sent events
- Polling mechanism

## Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.0.0           # State management
  http: ^1.1.0              # HTTP requests
  shared_preferences: ^2.2.0 # Local storage
  intl: ^0.19.0             # Date/time utilities
  fl_chart: ^0.65.0         # Advanced charting
```

## Testing

To run tests:
```bash
flutter test
```

## Build

### Android
```bash
flutter build apk
flutter build appbundle
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

## Future Enhancements

- 🔐 User authentication and accounts
- 💬 Real-time chat and market discussions
- 📱 Push notifications for market events
- 📊 Advanced charting with technical indicators
- 🏆 Leaderboards and competition tracking
- 🔔 Custom alerts for market milestones
- 🌙 Dark mode theme optimization
- 🌍 Multiple language support

## Architecture Notes

The app follows a clean architecture pattern:
- **Models**: Data representation
- **Services**: Business logic and data access
- **Screens**: UI pages
- **Widgets**: Reusable UI components

Navigation is handled through Flutter's routing system with bottom tab navigation.

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Polymarket Official](https://polymarket.com/)
- [Dart Documentation](https://dart.dev/)

## License

This project is provided as-is for educational purposes.

---

**Developed as a Flutter practice project** 🚀
