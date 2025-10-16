import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import '../models/verification_document.dart';
import '../services/firebase_service.dart';
import '../services/document_storage_service.dart';

class DocumentProvider extends ChangeNotifier {
  final Map<String, List<VerificationDocument>> _cardDocuments = {};
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get documents for a specific card
  List<VerificationDocument> getDocumentsForCard(String cardId) {
    return _cardDocuments[cardId] ?? [];
  }

  // Load documents for a specific card
  Future<void> loadCardDocuments(String userId, String cardId) async {
    _setLoading(true);
    _clearError();

    try {
      final documentsData = await FirebaseService.getCardDocuments(userId, cardId);
      final documents = documentsData
          .map((data) => VerificationDocument.fromMap(data))
          .toList();

      _cardDocuments[cardId] = documents;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load documents: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Upload a new document
  Future<bool> uploadDocument({
    required String userId,
    required String cardId,
    required File file,
    required DocumentType documentType,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Calculate file hash
      final fileHash = await DocumentStorageService.calculateFileHash(file);

      // Check if document with same hash already exists for this card
      final existingDocs = getDocumentsForCard(cardId);
      final duplicate = existingDocs.any((doc) => 
        doc.fileHash == fileHash && doc.documentType == documentType
      );

      if (duplicate) {
        _setError('This document has already been uploaded for this card type');
        _setLoading(false);
        return false;
      }

      // Generate document ID
      final documentId = const Uuid().v4();

      // Get file size
      final fileSize = await DocumentStorageService.getFileSize(file);
      final fileName = file.path.split('/').last;

      // Save file locally
      final localPath = await DocumentStorageService.saveFileLocally(
        file,
        userId,
        cardId,
        documentId,
      );

      // Upload to Firebase Storage
      final firebaseUrl = await FirebaseService.uploadDocumentFile(
        file,
        userId,
        cardId,
        documentId,
      );

      if (firebaseUrl == null) {
        _setError('Failed to upload document to cloud storage');
        _setLoading(false);
        return false;
      }

      // Create document object
      final document = VerificationDocument(
        id: documentId,
        userId: userId,
        cardId: cardId,
        documentType: documentType,
        fileName: fileName,
        fileSize: fileSize,
        fileHash: fileHash,
        firebaseStorageUrl: firebaseUrl,
        localPath: localPath,
        uploadedAt: DateTime.now(),
      );

      // Save metadata to Firestore
      await FirebaseService.saveVerificationDocument(
        userId,
        cardId,
        document.toMap(),
      );

      // Add to local list
      if (_cardDocuments[cardId] == null) {
        _cardDocuments[cardId] = [];
      }
      _cardDocuments[cardId]!.add(document);

      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to upload document: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Delete a document
  Future<bool> deleteDocument({
    required String userId,
    required String cardId,
    required String documentId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Find the document
      final documents = getDocumentsForCard(cardId);
      final document = documents.firstWhere((doc) => doc.id == documentId);

      // Delete from Firebase Storage
      await FirebaseService.deleteDocumentFile(
        userId,
        cardId,
        documentId,
        document.fileName,
      );

      // Delete from Firestore
      await FirebaseService.deleteVerificationDocument(userId, cardId, documentId);

      // Delete local file
      if (document.localPath != null) {
        await DocumentStorageService.deleteLocalFile(document.localPath!);
      }

      // Remove from local list
      _cardDocuments[cardId]?.removeWhere((doc) => doc.id == documentId);

      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete document: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Download document from cloud to local storage
  Future<bool> downloadDocument({
    required String userId,
    required String cardId,
    required String documentId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // This would involve downloading from Firebase Storage URL
      // and saving to local storage
      // Implementation depends on how you want to handle downloads
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to download document: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Sync documents - check for documents that exist locally but not in cloud, or vice versa
  Future<void> syncDocuments(String userId, String cardId) async {
    _setLoading(true);
    _clearError();

    try {
      await loadCardDocuments(userId, cardId);
      
      // Check each document's sync status
      final documents = getDocumentsForCard(cardId);
      
      for (final doc in documents) {
        // If document has local path but file doesn't exist, update metadata
        if (doc.localPath != null) {
          final exists = await DocumentStorageService.fileExistsLocally(doc.localPath!);
          if (!exists) {
            // Update document to mark as cloud-only
            final updatedDoc = doc.copyWith(localPath: null);
            await FirebaseService.saveVerificationDocument(
              userId,
              cardId,
              updatedDoc.toMap(),
            );
          }
        }
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to sync documents: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Get document by ID
  VerificationDocument? getDocument(String cardId, String documentId) {
    final documents = getDocumentsForCard(cardId);
    try {
      return documents.firstWhere((doc) => doc.id == documentId);
    } catch (e) {
      return null;
    }
  }

  // Check if a document type already exists for a card
  bool hasDocumentType(String cardId, DocumentType documentType) {
    final documents = getDocumentsForCard(cardId);
    return documents.any((doc) => doc.documentType == documentType);
  }

  // Get total storage used by documents for a card
  int getTotalStorageForCard(String cardId) {
    final documents = getDocumentsForCard(cardId);
    return documents.fold(0, (sum, doc) => sum + doc.fileSize);
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    // Use post-frame callback to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setError(String error) {
    _error = error;
    // Use post-frame callback to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _clearError() {
    _error = null;
  }

  // Clear all documents (for logout)
  void clearAll() {
    _cardDocuments.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}

