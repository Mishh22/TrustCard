import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('en', 'US');
  
  Locale get currentLocale => _currentLocale;
  
  String get currentLanguageCode => _currentLocale.languageCode;
  
  // Supported languages
  static const Map<String, Locale> _supportedLanguages = {
    'English': Locale('en', 'US'),
    'Hindi': Locale('hi', 'IN'),
    'Marathi': Locale('mr', 'IN'),
    'Gujarati': Locale('gu', 'IN'),
    'Tamil': Locale('ta', 'IN'),
    'Telugu': Locale('te', 'IN'),
    'Kannada': Locale('kn', 'IN'),
    'Bengali': Locale('bn', 'IN'),
  };
  
  Map<String, Locale> get supportedLanguages => _supportedLanguages;
  
  // Localized strings
  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'app_title': 'TrustCard',
      'welcome': 'Welcome to TrustCard',
      'create_card': 'Create Digital Card',
      'scan_card': 'Scan QR Code',
      'profile': 'Profile',
      'settings': 'Settings',
      'verification': 'Verification',
      'company_admin': 'Company Admin',
      'notifications': 'Notifications',
      'activity_feed': 'Activity Feed',
      'phone_number': 'Phone Number',
      'enter_otp': 'Enter OTP',
      'verify': 'Verify',
      'name': 'Name',
      'company': 'Company',
      'position': 'Position',
      'email': 'Email',
      'save': 'Save',
      'cancel': 'Cancel',
      'upload_document': 'Upload Document',
      'verification_level': 'Verification Level',
      'basic': 'Basic',
      'document': 'Document',
      'peer': 'Peer',
      'company_verified': 'Company Verified',
      'qr_code': 'QR Code',
      'scan_to_verify': 'Scan to Verify',
      'trust_score': 'Trust Score',
      'verified': 'Verified',
      'pending': 'Pending',
      'rejected': 'Rejected',
      'theme': 'Theme',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'dark_mode_subtitle': 'Switch between light and dark themes',
      'select_language': 'Select Language',
      'edit_profile': 'Edit Profile',
      'sign_out': 'Sign Out',
    },
    'hi': {
      'app_title': 'ट्रस्टकार्ड',
      'welcome': 'ट्रस्टकार्ड में आपका स्वागत है',
      'create_card': 'डिजिटल कार्ड बनाएं',
      'scan_card': 'QR कोड स्कैन करें',
      'profile': 'प्रोफाइल',
      'settings': 'सेटिंग्स',
      'verification': 'सत्यापन',
      'company_admin': 'कंपनी एडमिन',
      'notifications': 'सूचनाएं',
      'activity_feed': 'गतिविधि फीड',
      'phone_number': 'फोन नंबर',
      'enter_otp': 'OTP दर्ज करें',
      'verify': 'सत्यापित करें',
      'name': 'नाम',
      'company': 'कंपनी',
      'position': 'पद',
      'email': 'ईमेल',
      'save': 'सेव करें',
      'cancel': 'रद्द करें',
      'upload_document': 'दस्तावेज अपलोड करें',
      'verification_level': 'सत्यापन स्तर',
      'basic': 'बेसिक',
      'document': 'दस्तावेज',
      'peer': 'सहकर्मी',
      'company_verified': 'कंपनी सत्यापित',
      'qr_code': 'QR कोड',
      'scan_to_verify': 'सत्यापन के लिए स्कैन करें',
      'trust_score': 'ट्रस्ट स्कोर',
      'verified': 'सत्यापित',
      'pending': 'लंबित',
      'rejected': 'अस्वीकृत',
      'theme': 'थीम',
      'language': 'भाषा',
      'dark_mode': 'डार्क मोड',
      'dark_mode_subtitle': 'लाइट और डार्क थीम के बीच स्विच करें',
      'select_language': 'भाषा चुनें',
      'edit_profile': 'प्रोफाइल संपादित करें',
      'sign_out': 'साइन आउट',
    },
  };
  
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    
    if (savedLanguage != null && _supportedLanguages.containsValue(Locale(savedLanguage))) {
      _currentLocale = Locale(savedLanguage);
    }
    
    notifyListeners();
  }
  
  Future<void> changeLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    
    notifyListeners();
  }
  
  String getLocalizedString(String key) {
    final languageCode = _currentLocale.languageCode;
    return _localizedStrings[languageCode]?[key] ?? 
           _localizedStrings['en']?[key] ?? 
           key;
  }
  
  List<String> getSupportedLanguageNames() {
    return _supportedLanguages.keys.toList();
  }
  
  String getLanguageName(String languageCode) {
    for (final entry in _supportedLanguages.entries) {
      if (entry.value.languageCode == languageCode) {
        return entry.key;
      }
    }
    return 'English';
  }
}
