import 'dart:convert';
import '../models/ad_model.dart';
import 'shared_preferences_service.dart';
import '../constants/app_constants.dart';

class AdStorageService {
  static const String _adsKey = AppConstants.adsKey;

  Future<List<Map<String, dynamic>>> getAllAds() async {
    final prefs = SharedPreferencesService.instance.prefs;
    final adsJson = prefs.getString(_adsKey);
    if (adsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(adsJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> getAdById(String id) async {
    final ads = await getAllAds();
    try {
      return ads.firstWhere((ad) => ad['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveAd(Map<String, dynamic> adData) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final ads = await getAllAds();

    final existingIndex = ads.indexWhere((a) => a['id'] == adData['id']);
    if (existingIndex >= 0) {
      ads[existingIndex] = adData;
    } else {
      ads.add(adData);
    }

    await prefs.setString(_adsKey, jsonEncode(ads));
  }

  Future<void> deleteAd(String id) async {
    final prefs = SharedPreferencesService.instance.prefs;
    final ads = await getAllAds();
    ads.removeWhere((ad) => ad['id'] == id);
    await prefs.setString(_adsKey, jsonEncode(ads));
  }

  Future<void> toggleAdStatus(String id) async {
    final ads = await getAllAds();
    final index = ads.indexWhere((ad) => ad['id'] == id);
    if (index >= 0) {
      ads[index]['isActive'] = !(ads[index]['isActive'] ?? true);
      await saveAllAds(ads);
    }
  }

  Future<void> saveAllAds(List<Map<String, dynamic>> ads) async {
    final prefs = SharedPreferencesService.instance.prefs;
    await prefs.setString(_adsKey, jsonEncode(ads));
  }

  Future<List<Map<String, dynamic>>> getActiveAds() async {
    final ads = await getAllAds();
    return ads.where((ad) => ad['isActive'] ?? true).toList();
  }

  Future<List<Map<String, dynamic>>> getAdsByLevel(AdLevel level) async {
    final ads = await getAllAds();
    return ads
        .where(
          (ad) =>
              ad['level'] == level.toString().split('.').last &&
              (ad['isActive'] ?? true),
        )
        .toList();
  }
}
