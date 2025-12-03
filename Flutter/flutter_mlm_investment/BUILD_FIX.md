# Build Fix Notes

## Android Build Fixes Applied

### Issue 1: qr_code_scanner Android Build Error

**Problem:**
The `qr_code_scanner` package (v1.0.1) is no longer maintained and incompatible with newer Android Gradle Plugin versions. It was causing a build error:
```
Namespace not specified. Specify a namespace in the module's build file
```

**Solution:**
Replaced `qr_code_scanner` with `mobile_scanner` (v3.5.5+), which is:
- ✅ Actively maintained
- ✅ Compatible with latest Android Gradle Plugin
- ✅ Better performance
- ✅ More features (supports both cameras, torch, zoom, etc.)

**Changes Made:**
1. Updated `pubspec.yaml`:
   - Removed: `qr_code_scanner: ^1.0.1`
   - Added: `mobile_scanner: ^3.5.5`

---

### Issue 2: Core Library Desugaring Required

**Problem:**
`flutter_local_notifications` required core library desugaring:
```
Dependency ':flutter_local_notifications' requires core library desugaring to be enabled
```

**Solution:**
Enabled core library desugaring in Android build configuration.

**Changes Made:**
1. Updated `android/app/build.gradle.kts`:
   ```kotlin
   compileOptions {
       sourceCompatibility = JavaVersion.VERSION_17
       targetCompatibility = JavaVersion.VERSION_17
       isCoreLibraryDesugaringEnabled = true  // Added this
   }
   
   dependencies {
       coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")  // Added this
   }
   ```

---

### Issue 3: Deprecated v1 Embedding Issues

**Problem:**
Multiple packages using deprecated Flutter v1 embedding causing compilation errors:
- `file_picker` v6.2.1 - Cannot find symbol PluginRegistry.Registrar
- `flutter_local_notifications` v16.3.3 - Ambiguous method reference

**Solution:**
Removed packages not needed for Phase 1-2. These will be added back in later phases when needed:

**Changes Made:**
1. Updated `pubspec.yaml`:
   - Removed: `file_picker: ^6.1.1` (not needed - `image_picker` handles KYC uploads)
   - Commented out Firebase and notification packages (will add in Phase 11)
   
2. Packages removed/commented:
   ```yaml
   # file_picker: ^6.1.1
   # firebase_core: ^2.24.2
   # firebase_messaging: ^14.7.9
   # flutter_local_notifications: ^16.3.0
   ```

---

## Current Working Dependencies

### Essential Packages (Phase 1-2)
- ✅ provider: ^6.1.1 (State management)
- ✅ http: ^1.1.0 (API calls)
- ✅ shared_preferences: ^2.2.2 (Local storage)
- ✅ google_fonts: ^6.1.0 (Typography)
- ✅ fl_chart: ^0.65.0 (Charts)
- ✅ image_picker: ^1.0.5 (Image selection for KYC)
- ✅ qr_flutter: ^4.1.0 (QR code generation)
- ✅ mobile_scanner: ^3.5.5 (QR code scanning)
- ✅ intl: ^0.18.1 (Internationalization)
- ✅ url_launcher: ^6.2.2 (URL handling)
- ✅ encrypt: ^5.0.3 (Encryption)
- ✅ crypto: ^3.0.3 (Cryptography)
- ✅ pinput: ^3.0.1 (OTP input)
- ✅ shimmer: ^3.0.0 (Loading effects)
- ✅ pdf: ^3.10.7 (PDF generation)
- ✅ printing: ^5.11.1 (PDF printing)

### Deferred to Later Phases
- 📅 **Phase 11:** Firebase & Notifications
  - firebase_core
  - firebase_messaging
  - flutter_local_notifications
  
- 📅 **Phase 9+:** File Picker (if needed)
  - Will evaluate newer version or alternative

---

## Build Status

✅ **Android Debug Build:** SUCCESS  
✅ **Flutter Analyze:** No issues found  
✅ **APK Generated:** `build/app/outputs/flutter-apk/app-debug.apk`

---

## Migration Notes for Future Development

### QR Code Scanning (Phase 4)

When implementing QR code scanning for referral codes:

**Old Code (qr_code_scanner):**
```dart
import 'package:qr_code_scanner/qr_code_scanner.dart';

QRView(
  key: qrKey,
  onQRViewCreated: _onQRViewCreated,
)
```

**New Code (mobile_scanner):**
```dart
import 'package:mobile_scanner/mobile_scanner.dart';

MobileScanner(
  onDetect: (capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      debugPrint('Barcode found! ${barcode.rawValue}');
    }
  },
)
```

**Benefits of mobile_scanner:**
- Better camera control
- Supports both front and back cameras
- Torch/flash support
- Zoom functionality
- Better error handling
- Active community support

---

## Notes

- The file_picker warnings during `flutter pub get` can be safely ignored (they're from the package maintainers)
- Desugaring is now enabled, allowing use of Java 8+ APIs
- All removed packages can be added back when needed in their respective phases
- Consider using newer versions of Firebase packages when implementing Phase 11

