import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_card.dart';
import '../services/firebase_service.dart';
import '../services/account_lifecycle_service.dart';
import '../services/company_approval_service.dart';
import '../services/company_service.dart';

class CardProvider extends ChangeNotifier {
  List<UserCard> _cards = [];
  List<UserCard> _scannedCards = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _cardsSubscription;

  List<UserCard> get cards => _cards;
  List<UserCard> get scannedCards => _scannedCards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _cardsSubscription?.cancel();
    super.dispose();
  }

  // Create a new card
  Future<bool> createCard(UserCard card) async {
    _setLoading(true);
    _clearError();

    try {
      // Check card limit (excluding demo cards)
      final currentUser = FirebaseService.getCurrentUser();
      if (currentUser != null) {
        final limit = await FirebaseService.getCardLimit();
        final userCreatedCards = _cards.where((c) => !c.isDemoCard).length;
        
        if (userCreatedCards >= limit) {
          _setError('Card limit reached. Maximum $limit cards allowed.');
          _setLoading(false);
          return false;
        }
        
        // Check abuse prevention measures
        final canCreate = await _checkAbusePrevention(currentUser.uid);
        if (!canCreate) {
          _setError('Card creation temporarily restricted. Please try again later.');
          _setLoading(false);
          return false;
        }
      }
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      _cards.add(card);
      await _saveCardsToStorage();
      
      // Track card creation for abuse prevention
      if (currentUser != null) {
        await _trackCardCreation(currentUser.uid, card.id);
      }
      
      // Check for existing company and create approval request
      if (card.companyName != null && card.companyName!.isNotEmpty) {
        await _handleCompanyDetection(card, currentUser?.uid);
      }
      
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
      final currentUser = FirebaseService.getCurrentUser();
      
      // Get card data before deletion for tracking
      final cardToDelete = _cards.firstWhere((card) => card.id == cardId);
      
      // Delete from Firebase if authenticated
      if (currentUser != null) {
        await FirebaseService.deleteScannedCard(currentUser.uid, cardId);
        
        // Track card deletion for abuse prevention
        await _trackCardDeletion(
          currentUser.uid, 
          cardId, 
          cardToDelete.trustScore, 
          cardToDelete.totalRatings ?? 0
        );
      }
      
      // Delete from local list
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

  // Load cards from storage and setup real-time sync
  Future<void> loadCards() async {
    _setLoading(true);
    _clearError();

    try {
      // Load from Firebase or SharedPreferences
      await _loadCardsFromStorage();
      
      // Setup real-time Firebase sync
      setupRealtimeSync();
      
      // If no cards found, add some default cards for demonstration
      if (_cards.isEmpty) {
        final currentUser = FirebaseService.getCurrentUser();
        final demoUserId = currentUser?.uid ?? 'demo_user';
        
        _cards = [
          UserCard(
            id: 'card_1',
            userId: demoUserId,
            fullName: 'Rahul Kumar',
            phoneNumber: '8888888888',
            companyName: 'Company 1',
            designation: 'Delivery Partner',
            companyId: 'COMP001',
            verificationLevel: VerificationLevel.document,
            isCompanyVerified: false,
            customerRating: 4.5,
            totalRatings: 120,
            verifiedByColleagues: ['colleague1', 'colleague2'],
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            expiryDate: DateTime.now().add(const Duration(days: 60)),
            version: 1,
            isActive: true,
            isDemoCard: true,
          ),
          UserCard(
            id: 'card_2',
            userId: demoUserId,
            fullName: 'Priya Sharma',
            phoneNumber: '9999999999',
            companyName: 'Company 2',
            designation: 'Delivery Executive',
            companyId: 'COMP002',
            verificationLevel: VerificationLevel.peer,
            isCompanyVerified: false,
            customerRating: 4.8,
            totalRatings: 89,
            verifiedByColleagues: ['colleague3', 'colleague4', 'colleague5'],
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
            expiryDate: DateTime.now().add(const Duration(days: 75)),
            version: 1,
            isActive: true,
            isDemoCard: true,
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

  // Set up real-time Firebase sync for cards
  void setupRealtimeSync() {
    final currentUser = FirebaseService.getCurrentUser();
    if (currentUser != null) {
      _cardsSubscription?.cancel();
      _cardsSubscription = FirebaseService.getScannedCardsStream(currentUser.uid).listen(
        (cardsData) {
          _cards = cardsData.map((cardJson) => _cardFromJson(cardJson)).toList();
          print('Cards synced from Firebase: ${_cards.length} cards');
          notifyListeners();
        },
        onError: (error) {
          print('Error in cards real-time sync: $error');
        },
      );
    }
  }

  // Save cards to Firebase with local backup
  Future<void> _saveCardsToStorage() async {
    try {
      final currentUser = FirebaseService.getCurrentUser();
      
      if (currentUser != null) {
        // Save to Firebase (primary storage)
        await _saveToFirebaseAsync();
        print('Cards saved to Firebase successfully');
      } else {
        // Fallback to local storage if not authenticated
        final prefs = await SharedPreferences.getInstance();
        final cardsJson = _cards.map((card) => _cardToJson(card)).toList();
        await prefs.setString('user_cards', jsonEncode(cardsJson));
        print('Cards saved to local storage (user not authenticated)');
      }
    } catch (e) {
      print('Error saving cards: $e');
      // Fallback to local storage on error
      try {
        final prefs = await SharedPreferences.getInstance();
        final cardsJson = _cards.map((card) => _cardToJson(card)).toList();
        await prefs.setString('user_cards', jsonEncode(cardsJson));
        print('Cards saved to local storage (Firebase failed)');
      } catch (localError) {
        print('Error saving to local storage: $localError');
      }
    }
  }

  // Save to Firebase
  Future<void> _saveToFirebaseAsync() async {
    try {
      final currentUser = FirebaseService.getCurrentUser();
      if (currentUser == null) {
        print('No current user found, cannot save to Firebase');
        return;
      }
      
      print('Saving ${_cards.length} cards to Firebase for user: ${currentUser.uid}');
      
      for (final card in _cards) {
        final cardData = _cardToJson(card);
        print('Saving card ${card.id} with userId: ${card.userId}');
        
        // Save to old collection for backward compatibility
        await FirebaseService.saveScannedCard(currentUser.uid, card.id, cardData);
        print('Saved to scannedCards collection');
        
        // Save to new user_cards collection (for QR code scanning)
        await FirebaseService.saveUserCardToCardsCollection(cardData);
        print('Saved to user_cards collection');
      }
    } catch (e) {
      print('Error saving cards to Firebase: $e');
      rethrow;
    }
  }

  // Load cards from Firebase Firestore (with local fallback)
  Future<void> _loadCardsFromStorage() async {
    try {
      final currentUser = FirebaseService.getCurrentUser();
      
      if (currentUser != null) {
        // Load from Firebase - use getUserCards instead of getScannedCards
        print('Loading cards for user: ${currentUser.uid}');
        final cardsData = await FirebaseService.getUserCards(currentUser.uid);
        print('Found ${cardsData.length} cards in user_cards collection');
        if (cardsData.isNotEmpty) {
          _cards = cardsData.map((cardJson) => _cardFromJson(cardJson)).toList();
          print('Cards loaded from Firebase: ${_cards.length} cards');
          return;
        }
        print('No cards found in Firebase, checking local storage');
      }
      
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final cardsJson = prefs.getString('user_cards');
      
      if (cardsJson != null) {
        final List<dynamic> cardsList = jsonDecode(cardsJson);
        _cards = cardsList.map((cardJson) => _cardFromJson(cardJson)).toList();
        print('Cards loaded from local storage: ${_cards.length} cards');
        
        // If user is authenticated, migrate local cards to Firebase
        if (currentUser != null && _cards.isNotEmpty) {
          print('Migrating local cards to Firebase...');
          await _saveToFirebaseAsync();
          print('Local cards migrated to Firebase');
        }
      }
    } catch (e) {
      print('Error loading cards: $e');
    }
  }

  // Convert UserCard to JSON
  Map<String, dynamic> _cardToJson(UserCard card) {
    return {
      'id': card.id,
      'userId': card.userId,
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
      // Company approval fields
      'verifiedBy': card.verifiedBy,
      'verifiedAt': card.verifiedAt?.toIso8601String(),
      'rejectedBy': card.rejectedBy,
      'rejectedAt': card.rejectedAt?.toIso8601String(),
      'rejectionReason': card.rejectionReason,
    };
  }

  // Convert JSON to UserCard
  UserCard _cardFromJson(Map<String, dynamic> json) {
    return UserCard(
      id: json['id'],
      userId: json['userId'] ?? json['id'], // Fallback for backward compatibility
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
      // Company approval fields
      verifiedBy: json['verifiedBy'],
      verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt']) : null,
      rejectedBy: json['rejectedBy'],
      rejectedAt: json['rejectedAt'] != null ? DateTime.parse(json['rejectedAt']) : null,
      rejectionReason: json['rejectionReason'],
    );
  }
  
  // Abuse prevention helper methods
  Future<bool> _checkAbusePrevention(String userId) async {
    try {
      return await AccountLifecycleService.canCreateNewCard(userId);
    } catch (e) {
      print("Error checking abuse prevention: $e");
      return true; // Allow creation on error to avoid blocking legitimate users
    }
  }

  Future<void> _trackCardCreation(String userId, String cardId) async {
    try {
      await AccountLifecycleService.trackCardCreation(userId, cardId);
    } catch (e) {
      print("Error tracking card creation: $e");
    }
  }

  Future<void> _trackCardDeletion(String userId, String cardId, double trustScore, int totalRatings) async {
    try {
      await AccountLifecycleService.trackCardDeletion(userId, cardId, trustScore, totalRatings);
    } catch (e) {
      print("Error tracking card deletion: $e");
    }
  }

  /// Handle company detection and approval request creation
  Future<void> _handleCompanyDetection(UserCard card, String? userId) async {
    try {
      if (userId == null) {
        print('Cannot handle company detection: userId is null');
        return;
      }

      // Find or create company using CompanyService
      final company = await CompanyService.findOrCreateCompany(
        companyName: card.companyName!,
        userId: userId,
        userFullName: card.fullName,
        userPhone: card.phoneNumber,
      );
      
      print('Company found/created: ${company.companyName} (Status: ${company.verificationStatus.name})');
      
      // If company is verified, create approval request
      if (company.isVerified && company.hasAdmin) {
        print('Company is verified, creating approval request...');
        
        final requestId = await CompanyApprovalService.createApprovalRequest(
          cardId: card.id,
          companyId: company.id,
          companyAdminId: company.adminUserId,
          requesterId: userId,
          companyName: card.companyName!,
          requesterName: card.fullName,
          requesterPhone: card.phoneNumber,
          designation: card.designation,
        );
        
        if (requestId != null) {
          print('Company approval request created: $requestId');
        } else {
          print('Failed to create company approval request');
        }
      } else {
        print('Company is unverified, no approval request needed');
      }
    } catch (e) {
      print('Error handling company detection: $e');
    }
  }
}
