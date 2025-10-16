import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

class DocumentStorageService {
  // Calculate SHA-256 hash of a file
  static Future<String> calculateFileHash(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final hash = sha256.convert(bytes);
      return hash.toString();
    } catch (e) {
      print('Error calculating file hash: $e');
      rethrow;
    }
  }

  // Get local documents directory
  static Future<Directory> getDocumentsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final docsDir = Directory('${appDir.path}/verification_documents');
    
    if (!await docsDir.exists()) {
      await docsDir.create(recursive: true);
    }
    
    return docsDir;
  }

  // Save file to local storage
  static Future<String> saveFileLocally(
    File file,
    String userId,
    String cardId,
    String documentId,
  ) async {
    try {
      final docsDir = await getDocumentsDirectory();
      final fileName = file.path.split('/').last;
      final localPath = '${docsDir.path}/$userId/$cardId/$documentId/$fileName';
      
      final localFile = File(localPath);
      await localFile.create(recursive: true);
      await file.copy(localPath);
      
      return localPath;
    } catch (e) {
      print('Error saving file locally: $e');
      rethrow;
    }
  }

  // Get local file
  static Future<File?> getLocalFile(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('Error getting local file: $e');
      return null;
    }
  }

  // Delete local file
  static Future<void> deleteLocalFile(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting local file: $e');
    }
  }

  // Check if file exists locally
  static Future<bool> fileExistsLocally(String localPath) async {
    try {
      final file = File(localPath);
      return await file.exists();
    } catch (e) {
      print('Error checking file existence: $e');
      return false;
    }
  }

  // Get file size
  static Future<int> getFileSize(File file) async {
    try {
      return await file.length();
    } catch (e) {
      print('Error getting file size: $e');
      return 0;
    }
  }

  // Clean up old documents (optional - for managing storage)
  static Future<void> cleanupOldDocuments({int daysOld = 30}) async {
    try {
      final docsDir = await getDocumentsDirectory();
      final now = DateTime.now();
      
      await for (final entity in docsDir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          final age = now.difference(stat.modified).inDays;
          
          if (age > daysOld) {
            await entity.delete();
            print('Deleted old document: ${entity.path}');
          }
        }
      }
    } catch (e) {
      print('Error cleaning up old documents: $e');
    }
  }

  // Get total size of local documents
  static Future<int> getTotalLocalStorageSize() async {
    try {
      final docsDir = await getDocumentsDirectory();
      int totalSize = 0;
      
      await for (final entity in docsDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      print('Error calculating total storage size: $e');
      return 0;
    }
  }

  // Format storage size for display
  static String formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

