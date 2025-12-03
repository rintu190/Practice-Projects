# Profile Page Implementation Guide

## Quick Start

### What Changed?
The profile page now shows the **actual logged-in user's name and membership rank** instead of hardcoded "John Doe" and "Gold Member".

### How It Works

1. **Page Load**: `initState()` creates a Future to fetch user data
2. **Data Fetch**: `DashboardService` calls backend `/dashboard` endpoint  
3. **Display**: `FutureBuilder` renders UI with real data
4. **Fallbacks**: If data unavailable, shows "User" and "Member"

---

## Code Changes Overview

### Before (Hardcoded)
```dart
Text('John Doe')           // Same for everyone
Text('ID: USR001 • Gold Member')  // Same for everyone
```

### After (Dynamic)
```dart
Text(userName)             // Actual user name
Text('$userRank Member')   // Actual rank
```

---

## Key Components

### 1. Data Fetching
```dart
@override
void initState() {
  super.initState();
  _dashboardFuture = DashboardService().getDashboardData();
}
```

### 2. FutureBuilder Implementation
```dart
FutureBuilder<Map<String, dynamic>>(
  future: _dashboardFuture,
  builder: (context, snapshot) {
    // 3 states: loading, error, success
  }
)
```

### 3. State Handling
```dart
if (snapshot.connectionState == ConnectionState.waiting) {
  return _buildLoadingProfile();  // Show spinner
}

if (snapshot.hasError) {
  return _buildErrorProfile();    // Show error
}

// Success - display data
final userName = snapshot.data?['user']?['name'] ?? 'User';
final userRank = snapshot.data?['user']?['rank'] ?? 'Member';
```

---

## Display Format

### User Name
- **Source**: `dashboard_data['user']['name']`
- **Location**: Bold headline above rank
- **Fallback**: "User"

### Membership Rank
- **Source**: `dashboard_data['user']['rank']`
- **Location**: Gray secondary text below name
- **Format**: "{rank} Member" (e.g., "Gold Member")
- **Fallback**: "Member"

---

## Example Data Flow

### Request
```
GET /api/dashboard
Authorization: Bearer <token>
```

### Response
```json
{
  "user": {
    "name": "John Doe",
    "rank": "Gold",
    "profile_image": null
  },
  "wallet": {...},
  "investment": {...}
}
```

### Display
```
Profile Screen
├── User Icon (blue circle)
├── Name: "John Doe"
├── Rank: "Gold Member"
└── KYC Badge: "✓ KYC Verified"
```

---

## Error Handling

### Loading State
- Shows profile icon with spinner
- No data displayed yet

### Error State
- Shows profile icon with error styling
- Error message: "Error Loading Profile"

### Success State
- Shows user's actual information
- All menu options available

---

## Testing Guide

### Test 1: Basic Display
1. Login to app
2. Open Profile
3. **Verify**: See your actual name and rank (not "John Doe")

### Test 2: Multiple Users
1. Login as User A
2. Check profile name and rank
3. Logout, Login as User B
4. Check profile name and rank
5. **Verify**: Each user sees their own data

### Test 3: Loading
1. Slow connection
2. Open Profile
3. **Verify**: See loading spinner briefly

### Test 4: Error Handling
1. Disconnect internet
2. Open Profile
3. **Verify**: Error state displays gracefully

---

## API Dependency

The profile page depends on the Dashboard API endpoint:

**Endpoint**: `GET /api/dashboard`

**Status**: ✅ Already implemented in backend
- Located in: `routes/dashboard.php`
- Returns user data with calculated rank

---

## File Location

```
flutter_mlm_investment/
└── lib/
    └── features/
        └── dashboard/
            ├── data/
            │   └── services/
            │       └── dashboard_service.dart  ← API calls
            └── presentation/
                └── screens/
                    └── profile_screen.dart     ← Updated file
```

---

## UI Components

### Profile Header Section
```dart
Center(
  child: Column(
    children: [
      // User Icon
      Container(
        width: 100,
        height: 100,
        // Circular blue icon
      ),
      // User Name
      Text(userName, headline style),
      // Membership Rank
      Text('$userRank Member', secondary style),
      // KYC Badge
      Container(badge),
    ],
  ),
)
```

### Menu Sections
- Account (Personal Details, Bank Details, KYC Status)
- Security (Change Password, Transaction PIN)
- Support (Help, Terms, Privacy)
- Logout Button

---

## Important Notes

1. **Real-Time Update**: Profile refreshes on every screen load
2. **Backend Rank Calculation**: Rank is calculated server-side using RankCalculator
3. **Fallback Values**: If data unavailable, shows "User" and "Member"
4. **Type Safe**: Uses null coalescing operator (??) for safety
5. **No Hardcoding**: All user data comes from backend

---

## Related Files

| File | Purpose |
|------|---------|
| `profile_screen.dart` | Profile page UI |
| `dashboard_service.dart` | API communication |
| `app_colors.dart` | Color scheme |
| `dashboard.php` | Backend endpoint |

---

## Future Enhancements

- [ ] Pull-to-refresh functionality
- [ ] Profile image display
- [ ] Edit profile details
- [ ] Update notification on rank change
- [ ] Offline caching

---

## Troubleshooting

### Issue: Still Shows "John Doe"
- **Solution**: Hot reload the app (`r` in terminal)
- **Check**: Ensure DashboardService is called

### Issue: Loading spinner never stops
- **Solution**: Check internet connection
- **Check**: Verify backend API is responding

### Issue: Shows "Error Loading Profile"
- **Solution**: Check authentication token
- **Check**: Verify backend `/dashboard` endpoint is working

---

## Questions?

For more details, see:
- `PROFILE_PAGE_UPDATE.md` - Detailed documentation
- `PROFILE_UPDATE_BEFORE_AFTER.md` - Before/after comparison
- Backend: `/routes/dashboard.php` - API implementation
