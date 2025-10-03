import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineService {
  static const String _userCardKey = 'cached_user_card';
  static const String _profileKey = 'cached_profile';
  static const String _lastSyncKey = 'last_sync_timestamp';
  
  // Cache user card data offline
  static Future<void> cacheUserCard(Map<String, dynamic> cardData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userCardKey, jsonEncode(cardData));
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching user card: $e');
    }
  }
  
  // Get cached user card
  static Future<Map<String, dynamic>?> getCachedUserCard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cardData = prefs.getString(_userCardKey);
      
      if (cardData != null) {
        return jsonDecode(cardData) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error getting cached user card: $e');
    }
    return null;
  }
  
  // Cache profile data offline
  static Future<void> cacheProfile(Map<String, dynamic> profileData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileKey, jsonEncode(profileData));
    } catch (e) {
      print('Error caching profile: $e');
    }
  }
  
  // Get cached profile
  static Future<Map<String, dynamic>?> getCachedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileData = prefs.getString(_profileKey);
      
      if (profileData != null) {
        return jsonDecode(profileData) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error getting cached profile: $e');
    }
    return null;
  }
  
  // Check if data is available offline
  static Future<bool> isDataAvailableOffline() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cardData = prefs.getString(_userCardKey);
      return cardData != null;
    } catch (e) {
      return false;
    }
  }
  
  // Get last sync timestamp
  static Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastSyncKey);
      
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } catch (e) {
      print('Error getting last sync time: $e');
    }
    return null;
  }
  
  // Clear offline cache
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userCardKey);
      await prefs.remove(_profileKey);
      await prefs.remove(_lastSyncKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
  
  // Check if cache is stale (older than 24 hours)
  static Future<bool> isCacheStale() async {
    try {
      final lastSync = await getLastSyncTime();
      if (lastSync == null) return true;
      
      final now = DateTime.now();
      final difference = now.difference(lastSync);
      
      return difference.inHours > 24;
    } catch (e) {
      return true;
    }
  }
}
