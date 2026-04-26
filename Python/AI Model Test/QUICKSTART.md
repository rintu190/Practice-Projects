# Quick Start Guide - Polymarket Clone Flutter App

## 📋 Overview

This is a fully functional Flutter prediction market app inspired by Polymarket. The app allows users to browse prediction markets, place bets, and track their portfolio in real-time.

## 🚀 Quick Setup

### Step 1: Install Dependencies
```bash
cd "/home/rintu/Developer/Practice-Projects/Python/AI Model Test"
flutter pub get
```

### Step 2: Run the App
```bash
# For development (requires device or emulator running)
flutter run

# For web development
flutter run -d chrome

# For iOS (macOS only)
flutter run -d ios

# For Android
flutter run -d android
```

### Step 3: Explore the App

#### Home Screen (Markets Tab)
- Browse all available prediction markets
- Search for markets by question
- Filter by category (Cryptocurrency, Economics, Technology)
- Tap any market to view details

#### Market Detail Screen
- View market image and detailed description
- Check real-time probability chart
- See current price per share
- Place a prediction (buy YES or NO shares)

#### Portfolio Screen (Wallet Tab)
- View your total portfolio value
- Check available balance
- See total profit/loss
- Manage your positions
- View detailed statistics for each position

## 📁 Project Structure Explained

### Core Files
- **main.dart**: App entry point and navigation setup
- **models/**: Data models (Market, Position, User)
- **screens/**: Three main screens (Home, Market Detail, Portfolio)
- **services/**: Mock data service (replace with real API)
- **widgets/**: Reusable UI components
- **providers/**: State management setup (for future use with Provider package)

### Key Components

#### Market Model
```dart
Market(
  id: '1',
  question: 'Will Bitcoin reach $100K by end of 2024?',
  yesPrice: 0.68,        // 68% probability
  noPrice: 0.32,         // 32% probability
  volume: 2500000,       // 24H volume
  traders: 12500,        // Number of traders
)
```

#### Position Model
```dart
Position(
  outcome: 'YES',        // YES or NO
  shares: 50,            // Number of shares owned
  averagePrice: 0.62,    // Entry price (cents)
  currentPrice: 0.68,    // Current market price
  cost: 3100,            // Total invested
  currentValue: 3400,    // Current value
  profit: 300,           // P&L
  profitPercent: 9.68,   // Return percentage
)
```

## 🎨 UI Components

### Market Card
Shows a quick preview of a market:
- Market image
- Question
- Probability bar
- Volume, traders, time remaining

### Market Chart
Custom price chart showing historical movements:
- Gradient fill area
- Price line
- Grid overlay
- Min/Max/Current price

### Trading Panel
Interactive trading interface:
- YES/NO outcome selection
- Share quantity input
- Cost calculator
- Order placement button

### Position Card
Detailed position information:
- Question and outcome
- P&L and return percentage
- Share details (quantity, prices)
- Sell and View Market buttons

## 💾 Mock Data

The app comes pre-loaded with:
- **10 Markets** across 3 categories
- **Sample User Account**:
  - Username: trader_pro
  - Balance: $5,234.50
  - Total Profit: $1,245.75
  - 3 Open Positions
- **Real-looking market data** with volume, traders, etc.

## 🔧 Customization Tips

### Change App Name
In `pubspec.yaml`:
```yaml
name: your_app_name
```

### Change App Colors
In `main.dart`:
```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,  // Change this
  ),
),
```

### Update Market Categories
In `lib/utils/app_constants.dart`:
```dart
static const List<String> marketCategories = [
  'All',
  'Your Category 1',
  'Your Category 2',
];
```

### Replace Mock Data with Real API

1. Create `lib/services/api_service.dart`
2. Implement HTTP requests using the `http` package
3. Update screens to call API instead of MockDataService

Example:
```dart
// Old: using mock data
final markets = _dataService.getMockMarkets();

// New: using API
final markets = await _apiService.fetchMarkets();
```

## 📊 Features Walkthrough

### 1. Browsing Markets
- Home screen displays all markets
- Use search bar to find markets
- Filter by category using chips
- Markets show real-time probability

### 2. Market Analysis
- Tap market card to see details
- View historical price chart
- Check market statistics
- See countdown timer

### 3. Placing Trades
- Select YES or NO outcome
- Enter number of shares
- See total cost calculation
- Tap "BUY" to place order

### 4. Portfolio Tracking
- Switch to Portfolio tab
- See total portfolio value
- Check available balance
- View all open positions
- Track P&L in real-time

## 🐛 Common Issues & Solutions

### Issue: App won't run
```bash
# Clean build
flutter clean
flutter pub get
flutter run
```

### Issue: Image not loading
Mock images use placeholder.com. If offline:
- Images will show error icon
- Doesn't affect app functionality

### Issue: Hot reload issues
- Use `flutter run` instead of VS Code play button
- Or restart the app completely

## 📱 Testing the App

### Test Market Search
1. Type "Bitcoin" in search bar
2. Should filter to Bitcoin market

### Test Trading
1. Open any market
2. Select YES/NO
3. Enter share quantity
4. Tap BUY button
5. See confirmation message

### Test Portfolio
1. Go to Portfolio tab
2. Should see user info and positions
3. Check profit/loss calculations

## 🔌 Integration Steps (When Ready)

### Step 1: API Integration
```dart
// Add http dependency to pubspec.yaml
http: ^1.1.0

// Create API service
class ApiService {
  Future<List<Market>> fetchMarkets() async {
    final response = await http.get(Uri.parse('$baseUrl/markets'));
    // Parse and return markets
  }
}
```

### Step 2: Authentication
```dart
// Add Firebase or similar
// Implement login/signup screens
// Store auth tokens securely
```

### Step 3: State Management
```dart
// Use Provider package (already in pubspec.yaml)
// Wrap app with MultiProvider
// Replace direct service calls with provider
```

### Step 4: Real-time Updates
```dart
// Add WebSocket support
// Implement market price updates
// Show live probability changes
```

## 📚 Code Examples

### Adding a New Market Category
1. Update `AppConstants.marketCategories`
2. Update `MockDataService._generateMockMarkets()`
3. Add markets with that category
4. Filtering will work automatically

### Creating a Custom Chart
Replace `MarketChart` widget:
```dart
// Use fl_chart package for advanced charts
import 'package:fl_chart/fl_chart.dart';

LineChart(
  LineChartData(
    // Configure your chart
  ),
)
```

### Adding Authentication
1. Install Firebase: `flutter pub add firebase_core firebase_auth`
2. Create auth screen
3. Update main.dart to check authentication
4. Store user data in Firestore

## 🚀 Deployment

### Android APK
```bash
flutter build apk --split-per-abi
```

### iOS App
```bash
flutter build ios
# Then upload via Xcode
```

### Web App
```bash
flutter build web
# Deploy 'build/web' folder to hosting
```

## 📖 Next Steps

1. **Replace Mock Data**: Integrate with real API
2. **Add Authentication**: Implement user accounts
3. **Real-time Updates**: Add WebSocket for live prices
4. **Payment Integration**: Add wallet/payment system
5. **Analytics**: Track user behavior
6. **Notifications**: Push notifications for events

## 🤝 Support

For Flutter help:
- [Flutter Docs](https://docs.flutter.dev/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Flutter Community](https://www.flutter.dev/community)

---

**Happy Trading! 📈**
