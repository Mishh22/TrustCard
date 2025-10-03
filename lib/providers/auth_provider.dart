import 'package:flutter/foundation.dart';
import '../models/user_card.dart';

class AuthProvider extends ChangeNotifier {
  UserCard? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserCard? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Simulate user login
  Future<bool> login(String phoneNumber, String otp) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock user data
      _currentUser = UserCard(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        fullName: 'John Doe',
        phoneNumber: phoneNumber,
        companyName: 'Swiggy',
        designation: 'Delivery Partner',
        companyId: 'SWG12345',
        verificationLevel: VerificationLevel.document,
        isCompanyVerified: false,
        customerRating: 4.5,
        totalRatings: 120,
        verifiedByColleagues: ['colleague1', 'colleague2'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        expiryDate: DateTime.now().add(const Duration(days: 60)),
        version: 1,
        isActive: true,
        uploadedDocuments: ['id_card.jpg', 'offer_letter.pdf'],
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Simulate user logout
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = null;
      _setLoading(false);
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? companyName,
    String? designation,
    String? profilePhotoUrl,
  }) async {
    if (_currentUser == null) return false;
    
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = _currentUser!.copyWith(
        fullName: fullName ?? _currentUser!.fullName,
        companyName: companyName ?? _currentUser!.companyName,
        designation: designation ?? _currentUser!.designation,
        profilePhotoUrl: profilePhotoUrl ?? _currentUser!.profilePhotoUrl,
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Profile update failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Send OTP
  Future<bool> sendOTP(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to send OTP: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock verification (in real app, verify with server)
      if (otp == '1234') {
        // Create mock user after successful verification
        _currentUser = UserCard(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          fullName: 'John Doe',
          phoneNumber: phoneNumber,
          companyName: 'Swiggy',
          designation: 'Delivery Partner',
          companyId: 'SWG12345',
          verificationLevel: VerificationLevel.basic,
          isCompanyVerified: false,
          customerRating: 4.5,
          totalRatings: 120,
          verifiedByColleagues: ['colleague1', 'colleague2'],
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          expiryDate: DateTime.now().add(const Duration(days: 60)),
          version: 1,
          isActive: true,
          uploadedDocuments: ['id_card.jpg', 'offer_letter.pdf'],
        );
        
        _setLoading(false);
        return true;
      } else {
        _setError('Invalid OTP');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('OTP verification failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
