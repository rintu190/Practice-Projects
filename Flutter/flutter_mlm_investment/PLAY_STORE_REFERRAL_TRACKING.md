# Referral Tracking via Play Store Downloads

## 🎯 Problem Statement

**Scenario:**
1. User A shares referral link on WhatsApp/Facebook
2. User B clicks the link
3. User B is redirected to Play Store
4. User B downloads and installs the app
5. **How does the app know User A referred User B?**

---

## ✅ Solution: Firebase Dynamic Links + Deep Linking

### **Technology Stack:**
- **Firebase Dynamic Links** (Recommended) - Free, reliable, works across platforms
- **Android App Links** - Native Android deep linking
- **Branch.io** (Alternative) - Paid but feature-rich

---

## 📱 Implementation Guide

### **Step 1: Setup Firebase Dynamic Links**

#### **1.1 Add Firebase to Your Flutter Project**

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_dynamic_links: ^5.4.8
  firebase_analytics: ^10.8.0  # Optional: Track referral conversions
```

#### **1.2 Configure Firebase Console**

1. Go to Firebase Console → Dynamic Links
2. Set up domain: `yourapp.page.link`
3. Configure Android app:
   - Package name: `com.yourcompany.mlm_investment`
   - SHA-256 fingerprint
   - Play Store link

---

### **Step 2: Create Dynamic Referral Links**

#### **2.1 Backend API - Generate Referral Link**

```php
// File: routes/referral.php

class ReferralController {
    public function generateReferralLink($userId) {
        // Get user's referral code
        $stmt = $this->conn->prepare("SELECT referral_code FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        $user = $stmt->fetch();
        
        if (!$user) {
            return ['success' => false, 'message' => 'User not found'];
        }
        
        $referralCode = $user['referral_code'];
        
        // Create Firebase Dynamic Link
        $dynamicLink = $this->createFirebaseDynamicLink($referralCode);
        
        // Also create a short link for easy sharing
        $shortLink = $this->createShortLink($referralCode);
        
        return [
            'success' => true,
            'data' => [
                'referral_code' => $referralCode,
                'dynamic_link' => $dynamicLink,
                'short_link' => $shortLink,
                'share_message' => "Join me on MLM Investment! Use my code {$referralCode} or click: {$shortLink}"
            ]
        ];
    }
    
    private function createFirebaseDynamicLink($referralCode) {
        // Firebase Dynamic Link API
        $apiKey = 'YOUR_FIREBASE_WEB_API_KEY';
        $domain = 'yourapp.page.link';
        
        $longLink = "https://{$domain}/?link=https://yourapp.com/register?ref={$referralCode}"
                  . "&apn=com.yourcompany.mlm_investment"
                  . "&afl=https://play.google.com/store/apps/details?id=com.yourcompany.mlm_investment"
                  . "&st=Join MLM Investment"
                  . "&sd=Use code {$referralCode} to get started"
                  . "&si=https://yourapp.com/logo.png";
        
        // Call Firebase API to shorten
        $url = "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key={$apiKey}";
        
        $data = [
            'longDynamicLink' => $longLink,
            'suffix' => ['option' => 'SHORT']
        ];
        
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
        
        $response = curl_exec($ch);
        curl_close($ch);
        
        $result = json_decode($response, true);
        
        return $result['shortLink'] ?? $longLink;
    }
    
    private function createShortLink($referralCode) {
        // Alternative: Use your own short link service
        // Example: https://yourapp.com/r/ABC123
        return "https://yourapp.com/r/{$referralCode}";
    }
}
```

#### **2.2 Flutter Service - Get Referral Link**

```dart
// File: lib/features/team/data/services/referral_service.dart

class ReferralService {
  Future<Map<String, dynamic>> getReferralLink() async {
    final token = await SharedPrefs.getToken();
    
    final response = await http.get(
      Uri.parse(ApiConfig.getUrl('/?action=get_referral_link')),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    final data = json.decode(response.body);
    
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
      // Returns:
      // {
      //   'referral_code': 'ABC123',
      //   'dynamic_link': 'https://yourapp.page.link/xyz',
      //   'short_link': 'https://yourapp.com/r/ABC123',
      //   'share_message': '...'
      // }
    } else {
      throw Exception(data['message'] ?? 'Failed to get referral link');
    }
  }
}
```

---

### **Step 3: Handle Dynamic Links in Flutter App**

#### **3.1 Initialize Firebase Dynamic Links**

```dart
// File: lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Handle dynamic links
  await _initDynamicLinks();
  
  runApp(const MyApp());
}

Future<void> _initDynamicLinks() async {
  // Handle link when app is opened from terminated state
  final PendingDynamicLinkData? initialLink = 
      await FirebaseDynamicLinks.instance.getInitialLink();
  
  if (initialLink != null) {
    _handleDynamicLink(initialLink);
  }
  
  // Handle link when app is in background/foreground
  FirebaseDynamicLinks.instance.onLink.listen(
    (dynamicLinkData) {
      _handleDynamicLink(dynamicLinkData);
    },
    onError: (error) {
      print('Dynamic Link Error: $error');
    },
  );
}

void _handleDynamicLink(PendingDynamicLinkData dynamicLinkData) {
  final Uri deepLink = dynamicLinkData.link;
  
  // Extract referral code from URL
  // Example: https://yourapp.com/register?ref=ABC123
  final referralCode = deepLink.queryParameters['ref'];
  
  if (referralCode != null && referralCode.isNotEmpty) {
    // Save referral code to local storage
    _saveReferralCode(referralCode);
    
    // Navigate to registration with pre-filled code
    // This will be handled in the app's routing logic
  }
}

Future<void> _saveReferralCode(String referralCode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('pending_referral_code', referralCode);
  
  // Also track in analytics
  FirebaseAnalytics.instance.logEvent(
    name: 'referral_link_opened',
    parameters: {'referral_code': referralCode},
  );
}
```

#### **3.2 Use Referral Code During Registration**

```dart
// File: lib/features/auth/presentation/screens/registration_details_screen.dart

class _RegistrationDetailsScreenState extends State<RegistrationDetailsScreen> {
  final _referralController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadPendingReferralCode();
  }
  
  Future<void> _loadPendingReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingCode = prefs.getString('pending_referral_code');
    
    if (pendingCode != null && pendingCode.isNotEmpty) {
      setState(() {
        _referralController.text = pendingCode;
      });
      
      // Show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Referral code "$pendingCode" applied!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Clear the pending code
      await prefs.remove('pending_referral_code');
    }
  }
  
  // Rest of the registration logic...
}
```

---

### **Step 4: Share Referral Link**

#### **4.1 Update Referral Screen**

```dart
// File: lib/features/team/presentation/screens/referral_screen.dart

import 'package:share_plus/share_plus.dart';

class _ReferralScreenState extends State<ReferralScreen> {
  Map<String, dynamic>? _referralData;
  
  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }
  
  Future<void> _loadReferralData() async {
    try {
      final data = await ReferralService().getReferralLink();
      setState(() {
        _referralData = data;
      });
    } catch (e) {
      print('Error loading referral data: $e');
    }
  }
  
  void _shareReferralLink() {
    if (_referralData == null) return;
    
    final message = _referralData!['share_message'];
    final link = _referralData!['dynamic_link'];
    
    Share.share(
      '$message\n\n$link',
      subject: 'Join MLM Investment',
    );
    
    // Track share event
    FirebaseAnalytics.instance.logEvent(
      name: 'referral_link_shared',
      parameters: {
        'referral_code': _referralData!['referral_code'],
        'method': 'share_button',
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refer & Earn')),
      body: _referralData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Referral Code Display
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Your Referral Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _referralData!['referral_code'],
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Share Button
                          ElevatedButton.icon(
                            onPressed: _shareReferralLink,
                            icon: const Icon(Icons.share),
                            label: const Text('Share Referral Link'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                          
                          const SizedBox(height: 10),
                          
                          // Copy Link Button
                          OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: _referralData!['dynamic_link'],
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Link copied to clipboard!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Link'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Short Link Display
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.link),
                      title: const Text('Your Referral Link'),
                      subtitle: Text(
                        _referralData!['short_link'],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  
                  // Analytics and other UI...
                ],
              ),
            ),
    );
  }
}
```

---

### **Step 5: Configure Android Manifest**

```xml
<!-- File: android/app/src/main/AndroidManifest.xml -->

<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <activity
            android:name=".MainActivity"
            android:launchMode="singleTask">
            
            <!-- Deep Link Intent Filter -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                
                <!-- Your app's domain -->
                <data
                    android:scheme="https"
                    android:host="yourapp.com"
                    android:pathPrefix="/register" />
                    
                <!-- Firebase Dynamic Links domain -->
                <data
                    android:scheme="https"
                    android:host="yourapp.page.link" />
            </intent-filter>
            
            <!-- Custom URL Scheme (fallback) -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                
                <data android:scheme="mlminvestment" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

---

## 🔄 Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  Step 1: User A Opens App → Referral Screen                │
│  - Clicks "Share Referral Link"                             │
│  - App calls backend API: GET /get_referral_link            │
│  - Backend generates Firebase Dynamic Link                  │
│  - Returns: https://yourapp.page.link/xyz123                │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 2: User A Shares Link                                 │
│  - Via WhatsApp, Facebook, SMS, etc.                        │
│  - Message: "Join MLM Investment! https://yourapp.page..."  │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 3: User B Clicks Link                                 │
│  - Firebase detects: App installed? NO                      │
│  - Redirects to: Play Store                                 │
│  - Stores referral code: ABC123 (in Firebase)               │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 4: User B Downloads & Installs App                    │
│  - Opens app for first time                                 │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 5: App Initialization                                 │
│  - Firebase Dynamic Links retrieves stored referral code    │
│  - Saves to local storage: 'pending_referral_code'          │
│  - Navigates to registration screen                         │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 6: Registration Screen                                │
│  - Auto-fills referral code: ABC123                         │
│  - User completes registration                              │
│  - Backend links User B to User A                           │
│  - Creates genealogy relationship                           │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 7: Success!                                           │
│  - User A sees User B in their referrals                    │
│  - Commission tracking begins                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Tracking & Analytics

### **Track Referral Performance**

```dart
// Track when link is shared
FirebaseAnalytics.instance.logEvent(
  name: 'referral_link_shared',
  parameters: {
    'referral_code': 'ABC123',
    'share_method': 'whatsapp',
  },
);

// Track when link is opened
FirebaseAnalytics.instance.logEvent(
  name: 'referral_link_opened',
  parameters: {
    'referral_code': 'ABC123',
  },
);

// Track when user registers via referral
FirebaseAnalytics.instance.logEvent(
  name: 'referral_conversion',
  parameters: {
    'referral_code': 'ABC123',
    'referrer_id': 123,
  },
);
```

### **Backend Tracking**

```php
// Track referral link clicks
CREATE TABLE referral_clicks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    referral_code VARCHAR(20),
    ip_address VARCHAR(45),
    user_agent TEXT,
    clicked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    converted BOOLEAN DEFAULT FALSE,
    converted_user_id INT,
    INDEX idx_code (referral_code)
);

// When user registers via referral
UPDATE referral_clicks 
SET converted = TRUE, converted_user_id = ? 
WHERE referral_code = ? AND converted = FALSE 
LIMIT 1;
```

---

## 🎯 Alternative Solutions

### **Option 1: Branch.io (Paid)**
- More features (attribution, A/B testing)
- Better analytics
- Cross-platform support
- Costs money after free tier

### **Option 2: Custom Short Links**
- Create your own URL shortener
- Full control over data
- Requires more development
- Example: `https://yourapp.com/r/ABC123`

```php
// Custom redirect handler
// File: public/r/index.php

$code = $_GET['code'] ?? null;

if ($code) {
    // Log the click
    logReferralClick($code);
    
    // Redirect to Play Store with referrer parameter
    $playStoreUrl = "https://play.google.com/store/apps/details"
                  . "?id=com.yourcompany.mlm_investment"
                  . "&referrer=utm_source%3Dreferral%26utm_content%3D{$code}";
    
    header("Location: $playStoreUrl");
    exit;
}
```

---

## ✅ Best Practices

### **1. Always Provide Fallback**
```dart
// If dynamic link fails, show manual code entry
if (referralCode == null) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Enter Referral Code'),
      content: TextField(
        controller: _referralController,
        decoration: InputDecoration(
          hintText: 'Optional',
        ),
      ),
    ),
  );
}
```

### **2. Test Thoroughly**
- Test on real devices
- Test Play Store flow
- Test with app installed vs not installed
- Test link expiration

### **3. Monitor Conversion Rates**
```sql
-- Analytics query
SELECT 
    r.referral_code,
    COUNT(rc.id) as total_clicks,
    SUM(rc.converted) as conversions,
    (SUM(rc.converted) / COUNT(rc.id) * 100) as conversion_rate
FROM users r
LEFT JOIN referral_clicks rc ON r.referral_code = rc.referral_code
GROUP BY r.id
ORDER BY conversion_rate DESC;
```

---

## 🚀 Summary

**To track referrals from Play Store downloads:**

1. ✅ Use **Firebase Dynamic Links** (Free & Reliable)
2. ✅ Generate unique links with referral code embedded
3. ✅ Handle links in app initialization
4. ✅ Auto-fill referral code during registration
5. ✅ Track conversions with analytics
6. ✅ Provide manual code entry as fallback

**The referral code survives the Play Store download** because:
- Firebase stores it temporarily
- Retrieved on first app launch
- Applied automatically during registration

This is the **industry-standard approach** used by apps like:
- PayTM
- PhonePe
- Google Pay
- Uber
- All major MLM apps

🎉 **Your users can now share links that work seamlessly through the Play Store!**
