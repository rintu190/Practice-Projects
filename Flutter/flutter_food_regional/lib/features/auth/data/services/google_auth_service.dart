import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/services/api_client.dart';
import '../../../auth/data/services/auth_service.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Get the ID token
      final String? idToken = googleAuth.idToken;
      
      if (idToken == null) {
        throw Exception('Failed to get ID token');
      }

      // Send the ID token to your backend
      final apiClient = ApiClient();
      final response = await apiClient.post(
        '/auth/google',
        body: {'idToken': idToken},
        requiresAuth: false,
      );

      // Save the token using AuthService
      if (response['token'] != null) {
        await AuthService().saveToken(response['token']);
      }

      return response;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
