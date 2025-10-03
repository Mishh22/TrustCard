import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_card.dart';

class CardProvider extends ChangeNotifier {
  List<UserCard> _cards = [];
  List<UserCard> _scannedCards = [];
  bool _isLoading = false;
  String? _error;

  List<UserCard> get cards => _cards;
  List<UserCard> get scannedCards => _scannedCards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Create a new card
  Future<bool> createCard(UserCard card) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      _cards.add(card);
      await _saveCardsToStorage();
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to create card: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Update an existing card
  Future<bool> updateCard(UserCard updatedCard) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _cards.indexWhere((card) => card.id == updatedCard.id);
      if (index != -1) {
        _cards[index] = updatedCard;
        await _saveCardsToStorage();
        notifyListeners();
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update card: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Delete a card
  Future<bool> deleteCard(String cardId) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _cards.removeWhere((card) => card.id == cardId);
      await _saveCardsToStorage();
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete card: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Scan a card (add to scanned cards)
  Future<bool> scanCard(UserCard card) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Check if card already exists in scanned cards
      final existingIndex = _scannedCards.indexWhere((c) => c.id == card.id);
      if (existingIndex != -1) {
        _scannedCards[existingIndex] = card; // Update existing
      } else {
        _scannedCards.insert(0, card); // Add to beginning
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to scan card: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Get card by ID
  UserCard? getCardById(String cardId) {
    try {
      return _cards.firstWhere((card) => card.id == cardId);
    } catch (e) {
      return null;
    }
  }

  // Get scanned card by ID
  UserCard? getScannedCardById(String cardId) {
    try {
      return _scannedCards.firstWhere((card) => card.id == cardId);
    } catch (e) {
      return null;
    }
  }

  // Rate a card
  Future<bool> rateCard(String cardId, double rating) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Update rating in both cards and scanned cards
      _updateCardRating(cardId, rating);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to rate card: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Report a card
  Future<bool> reportCard(String cardId, String reason) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, this would send a report to the server
      print('Card $cardId reported for: $reason');
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to report card: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Verify a card (upgrade verification level)
  Future<bool> verifyCard(String cardId, VerificationLevel newLevel) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Update verification level in both cards and scanned cards
      _updateCardVerification(cardId, newLevel);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to verify card: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Load cards from storage
  Future<void> loadCards() async {
    _setLoading(true);
    _clearError();

    try {
      // Load from SharedPreferences
      await _loadCardsFromStorage();
      
      // If no cards found, add some default cards for demonstration
      if (_cards.isEmpty) {
        _cards = [
          UserCard(
            id: 'card_1',
            fullName: 'Rahul Kumar',
            phoneNumber: '+91 9876543210',
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
          ),
          UserCard(
            id: 'card_2',
            fullName: 'Priya Sharma',
            phoneNumber: '+91 9876543211',
            companyName: 'Zomato',
            designation: 'Delivery Executive',
            companyId: 'ZOM67890',
            verificationLevel: VerificationLevel.peer,
            isCompanyVerified: false,
            customerRating: 4.8,
            totalRatings: 89,
            verifiedByColleagues: ['colleague3', 'colleague4', 'colleague5'],
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
            expiryDate: DateTime.now().add(const Duration(days: 75)),
            version: 1,
            isActive: true,
          ),
        ];
        await _saveCardsToStorage();
      }
      
      notifyListeners();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load cards: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Clear all data
  void clearAll() {
    _cards.clear();
    _scannedCards.clear();
    _clearError();
    notifyListeners();
  }

  void _updateCardRating(String cardId, double rating) {
    // Update in cards list
    final cardIndex = _cards.indexWhere((card) => card.id == cardId);
    if (cardIndex != -1) {
      final card = _cards[cardIndex];
      final newTotalRatings = (card.totalRatings ?? 0) + 1;
      final newRating = ((card.customerRating ?? 0) * (card.totalRatings ?? 0) + rating) / newTotalRatings;
      
      _cards[cardIndex] = card.copyWith(
        customerRating: newRating,
        totalRatings: newTotalRatings,
      );
    }
    
    // Update in scanned cards list
    final scannedCardIndex = _scannedCards.indexWhere((card) => card.id == cardId);
    if (scannedCardIndex != -1) {
      final card = _scannedCards[scannedCardIndex];
      final newTotalRatings = (card.totalRatings ?? 0) + 1;
      final newRating = ((card.customerRating ?? 0) * (card.totalRatings ?? 0) + rating) / newTotalRatings;
      
      _scannedCards[scannedCardIndex] = card.copyWith(
        customerRating: newRating,
        totalRatings: newTotalRatings,
      );
    }
    
    notifyListeners();
  }

  void _updateCardVerification(String cardId, VerificationLevel newLevel) {
    // Update in cards list
    final cardIndex = _cards.indexWhere((card) => card.id == cardId);
    if (cardIndex != -1) {
      _cards[cardIndex] = _cards[cardIndex].copyWith(verificationLevel: newLevel);
    }
    
    // Update in scanned cards list
    final scannedCardIndex = _scannedCards.indexWhere((card) => card.id == cardId);
    if (scannedCardIndex != -1) {
      _scannedCards[scannedCardIndex] = _scannedCards[scannedCardIndex].copyWith(verificationLevel: newLevel);
    }
    
    notifyListeners();
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

  // Save cards to SharedPreferences
  Future<void> _saveCardsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cardsJson = _cards.map((card) => _cardToJson(card)).toList();
      await prefs.setString('user_cards', jsonEncode(cardsJson));
    } catch (e) {
      print('Error saving cards: $e');
    }
  }

  // Load cards from SharedPreferences
  Future<void> _loadCardsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cardsJson = prefs.getString('user_cards');
      
      if (cardsJson != null) {
        final List<dynamic> cardsList = jsonDecode(cardsJson);
        _cards = cardsList.map((cardJson) => _cardFromJson(cardJson)).toList();
      }
    } catch (e) {
      print('Error loading cards: $e');
    }
  }

  // Convert UserCard to JSON
  Map<String, dynamic> _cardToJson(UserCard card) {
    return {
      'id': card.id,
      'fullName': card.fullName,
      'phoneNumber': card.phoneNumber,
      'profilePhotoUrl': card.profilePhotoUrl,
      'companyName': card.companyName,
      'designation': card.designation,
      'companyId': card.companyId,
      'companyPhone': card.companyPhone,
      'verificationLevel': card.verificationLevel.name,
      'isCompanyVerified': card.isCompanyVerified,
      'customerRating': card.customerRating,
      'totalRatings': card.totalRatings,
      'verifiedByColleagues': card.verifiedByColleagues,
      'createdAt': card.createdAt.toIso8601String(),
      'expiryDate': card.expiryDate?.toIso8601String(),
      'version': card.version,
      'isActive': card.isActive,
      'companyEmail': card.companyEmail,
      'workLocation': card.workLocation,
      'uploadedDocuments': card.uploadedDocuments,
      'additionalInfo': card.additionalInfo,
    };
  }

  // Convert JSON to UserCard
  UserCard _cardFromJson(Map<String, dynamic> json) {
    return UserCard(
      id: json['id'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      profilePhotoUrl: json['profilePhotoUrl'],
      companyName: json['companyName'],
      designation: json['designation'],
      companyId: json['companyId'],
      companyPhone: json['companyPhone'],
      verificationLevel: VerificationLevel.values.firstWhere(
        (e) => e.name == json['verificationLevel'],
        orElse: () => VerificationLevel.basic,
      ),
      isCompanyVerified: json['isCompanyVerified'] ?? false,
      customerRating: json['customerRating']?.toDouble(),
      totalRatings: json['totalRatings'],
      verifiedByColleagues: List<String>.from(json['verifiedByColleagues'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      version: json['version'] ?? 1,
      isActive: json['isActive'] ?? true,
      companyEmail: json['companyEmail'],
      workLocation: json['workLocation'],
      uploadedDocuments: List<String>.from(json['uploadedDocuments'] ?? []),
      additionalInfo: Map<String, dynamic>.from(json['additionalInfo'] ?? {}),
    );
  }
}
