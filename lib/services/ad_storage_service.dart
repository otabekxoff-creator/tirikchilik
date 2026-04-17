import 'dart:convert';

import '../models/ad_model.dart';
import '../utils/app_logger.dart';
import 'storage_service.dart';

class AdStorageService {
  static final AdStorageService _instance = AdStorageService._internal();
  factory AdStorageService() => _instance;
  AdStorageService._internal();

  final StorageService _storage = StorageService();

  Future<List<AdModel>> getAllAds() async {
    try {
      final adsData = await _storage.read('all_ads');
      if (adsData != null) {
        final List<dynamic> decoded = jsonDecode(adsData);
        return decoded.map((e) => AdModel.fromJson(e)).toList();
      }
      return [];
    } catch (e, st) {
      AppLogger.error('Get all ads error', e, st);
      return [];
    }
  }

  Future<void> saveAds(List<AdModel> ads) async {
    try {
      final encoded = jsonEncode(ads.map((e) => e.toJson()).toList());
      await _storage.write('all_ads', encoded);
    } catch (e, st) {
      AppLogger.error('Save ads error', e, st);
    }
  }

  Future<void> deleteAd(String adId) async {
    try {
      final ads = await getAllAds();
      ads.removeWhere((ad) => ad.id == adId);
      await saveAds(ads);
    } catch (e, st) {
      AppLogger.error('Delete ad error', e, st);
    }
  }

  Future<void> toggleAdStatus(String adId) async {
    try {
      final ads = await getAllAds();
      final index = ads.indexWhere((ad) => ad.id == adId);
      if (index != -1) {
        final ad = ads[index];
        ads[index] = ad.copyWith(isWatched: !ad.isWatched);
        await saveAds(ads);
      }
    } catch (e, st) {
      AppLogger.error('Toggle ad status error', e, st);
    }
  }

  Future<void> saveAd(AdModel ad) async {
    try {
      final ads = await getAllAds();
      final index = ads.indexWhere((a) => a.id == ad.id);
      if (index != -1) {
        ads[index] = ad;
      } else {
        ads.add(ad);
      }
      await saveAds(ads);
    } catch (e, st) {
      AppLogger.error('Save ad error', e, st);
    }
  }
}
