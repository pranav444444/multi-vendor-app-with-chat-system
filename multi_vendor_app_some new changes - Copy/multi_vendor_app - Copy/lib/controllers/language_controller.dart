import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class LanguageController extends GetxController {
  final _selectedLanguage = 'en_US'.obs;
  
  String get currentLanguage => _selectedLanguage.value;

  final Map<String, String> languageCodes = {
    'en': 'en_US',
    'hi': 'hi_IN',
    'gu': 'gu_IN',
  };

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language') ?? 'en_US';
    await changeLanguage(savedLanguage);
  }

  Future<void> changeLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    final fullCode = languageCodes[langCode] ?? langCode;
    await prefs.setString('language', fullCode);
    _selectedLanguage.value = fullCode;
    
    final parts = fullCode.split('_');
    await Get.updateLocale(Locale(parts[0], parts[1]));
  }
}