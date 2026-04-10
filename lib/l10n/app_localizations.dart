import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// The name of the application
  ///
  /// In uz, this message translates to:
  /// **'Tirikchilik'**
  String get appName;

  /// Application description
  ///
  /// In uz, this message translates to:
  /// **'Reklama ko\'rib pul ishlash ilovasi'**
  String get appDescription;

  /// No description provided for @login.
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get login;

  /// No description provided for @register.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxatdan o\'tish'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In uz, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In uz, this message translates to:
  /// **'Parol'**
  String get password;

  /// No description provided for @name.
  ///
  /// In uz, this message translates to:
  /// **'Ism'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In uz, this message translates to:
  /// **'Telefon'**
  String get phone;

  /// No description provided for @confirmPassword.
  ///
  /// In uz, this message translates to:
  /// **'Parolni tasdiqlang'**
  String get confirmPassword;

  /// No description provided for @referralCode.
  ///
  /// In uz, this message translates to:
  /// **'Taklif kodi'**
  String get referralCode;

  /// No description provided for @loginTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tizimga kirish'**
  String get loginTitle;

  /// No description provided for @registerTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxatdan o\'tish'**
  String get registerTitle;

  /// No description provided for @noAccount.
  ///
  /// In uz, this message translates to:
  /// **'Akkauntingiz yo\'qmi?'**
  String get noAccount;

  /// No description provided for @hasAccount.
  ///
  /// In uz, this message translates to:
  /// **'Akkauntingiz bormi?'**
  String get hasAccount;

  /// No description provided for @loginButton.
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxatdan o\'tish'**
  String get registerButton;

  /// No description provided for @forgotPassword.
  ///
  /// In uz, this message translates to:
  /// **'Parolni unutdingizmi?'**
  String get forgotPassword;

  /// No description provided for @home.
  ///
  /// In uz, this message translates to:
  /// **'Bosh sahifa'**
  String get home;

  /// No description provided for @wallet.
  ///
  /// In uz, this message translates to:
  /// **'Hamyon'**
  String get wallet;

  /// No description provided for @profile.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @admin.
  ///
  /// In uz, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @leaderboard.
  ///
  /// In uz, this message translates to:
  /// **'Liderlar'**
  String get leaderboard;

  /// No description provided for @watchAd.
  ///
  /// In uz, this message translates to:
  /// **'Reklama ko\'rish'**
  String get watchAd;

  /// No description provided for @watchAdEarn.
  ///
  /// In uz, this message translates to:
  /// **'Reklama ko\'rib ishlang'**
  String get watchAdEarn;

  /// No description provided for @dailyAdsWatched.
  ///
  /// In uz, this message translates to:
  /// **'Kunlik ko\'rilgan reklamar'**
  String get dailyAdsWatched;

  /// No description provided for @totalEarned.
  ///
  /// In uz, this message translates to:
  /// **'Jami ishlangan'**
  String get totalEarned;

  /// No description provided for @totalAdsWatched.
  ///
  /// In uz, this message translates to:
  /// **'Jami ko\'rilgan reklamar'**
  String get totalAdsWatched;

  /// No description provided for @balance.
  ///
  /// In uz, this message translates to:
  /// **'Balans'**
  String get balance;

  /// No description provided for @pendingBalance.
  ///
  /// In uz, this message translates to:
  /// **'Kutilayotgan balans'**
  String get pendingBalance;

  /// No description provided for @deposit.
  ///
  /// In uz, this message translates to:
  /// **'Hisobni to\'ldirish'**
  String get deposit;

  /// No description provided for @withdraw.
  ///
  /// In uz, this message translates to:
  /// **'Yechib olish'**
  String get withdraw;

  /// No description provided for @transactionHistory.
  ///
  /// In uz, this message translates to:
  /// **'Tranzaksiyalar tarixi'**
  String get transactionHistory;

  /// No description provided for @upgradeToPremium.
  ///
  /// In uz, this message translates to:
  /// **'Premium ga o\'tish'**
  String get upgradeToPremium;

  /// No description provided for @premiumBenefits.
  ///
  /// In uz, this message translates to:
  /// **'Premium imtiyozlari'**
  String get premiumBenefits;

  /// No description provided for @dailyAdLimit.
  ///
  /// In uz, this message translates to:
  /// **'Kunlik reklama limiti'**
  String get dailyAdLimit;

  /// No description provided for @earnMore.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'proq ishlang'**
  String get earnMore;

  /// No description provided for @yourReferralCode.
  ///
  /// In uz, this message translates to:
  /// **'Sizning taklif kodingiz'**
  String get yourReferralCode;

  /// No description provided for @shareAndEarn.
  ///
  /// In uz, this message translates to:
  /// **'Do\'stlaringizni taklif qiling va ishlang'**
  String get shareAndEarn;

  /// No description provided for @loading.
  ///
  /// In uz, this message translates to:
  /// **'Yuklanmoqda...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik'**
  String get error;

  /// No description provided for @success.
  ///
  /// In uz, this message translates to:
  /// **'Muvaffaqiyatli'**
  String get success;

  /// No description provided for @cancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In uz, this message translates to:
  /// **'Tahrirlash'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In uz, this message translates to:
  /// **'Orqaga'**
  String get back;

  /// No description provided for @next.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi'**
  String get next;

  /// No description provided for @noInternet.
  ///
  /// In uz, this message translates to:
  /// **'Internet aloqasi yo\'q'**
  String get noInternet;

  /// No description provided for @somethingWentWrong.
  ///
  /// In uz, this message translates to:
  /// **'Nimadir xato ketdi'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinib ko\'ring'**
  String get tryAgain;

  /// No description provided for @welcome.
  ///
  /// In uz, this message translates to:
  /// **'Xush kelibsiz!'**
  String get welcome;

  /// No description provided for @startWatching.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rishni boshlang'**
  String get startWatching;

  /// No description provided for @keepWatching.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rishda davom eting'**
  String get keepWatching;

  /// No description provided for @copyReferralCode.
  ///
  /// In uz, this message translates to:
  /// **'Taklif kodini nusxalash'**
  String get copyReferralCode;

  /// No description provided for @referralCodeCopied.
  ///
  /// In uz, this message translates to:
  /// **'Taklif kodi nusxalandi'**
  String get referralCodeCopied;

  /// No description provided for @adminPanel.
  ///
  /// In uz, this message translates to:
  /// **'Admin paneli'**
  String get adminPanel;

  /// No description provided for @manageUsers.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchilarni boshqarish'**
  String get manageUsers;

  /// No description provided for @manageAds.
  ///
  /// In uz, this message translates to:
  /// **'Reklamalarni boshqarish'**
  String get manageAds;

  /// No description provided for @totalUsers.
  ///
  /// In uz, this message translates to:
  /// **'Jami foydalanuvchilar'**
  String get totalUsers;

  /// No description provided for @totalPremiumUsers.
  ///
  /// In uz, this message translates to:
  /// **'Jami premium foydalanuvchilar'**
  String get totalPremiumUsers;

  /// No description provided for @totalTransactions.
  ///
  /// In uz, this message translates to:
  /// **'Jami tranzaksiyalar'**
  String get totalTransactions;

  /// No description provided for @userManagement.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchi boshqaruvi'**
  String get userManagement;

  /// No description provided for @adManagement.
  ///
  /// In uz, this message translates to:
  /// **'Reklama boshqaruvi'**
  String get adManagement;

  /// No description provided for @darkMode.
  ///
  /// In uz, this message translates to:
  /// **'Qorong\'i rejim'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In uz, this message translates to:
  /// **'Yorug\' rejim'**
  String get lightMode;

  /// No description provided for @toggleTheme.
  ///
  /// In uz, this message translates to:
  /// **'Mavzuni o\'zgartirish'**
  String get toggleTheme;

  /// No description provided for @language.
  ///
  /// In uz, this message translates to:
  /// **'Til'**
  String get language;

  /// No description provided for @uzbek.
  ///
  /// In uz, this message translates to:
  /// **'O\'zbekcha'**
  String get uzbek;

  /// No description provided for @russian.
  ///
  /// In uz, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @english.
  ///
  /// In uz, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @selectLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Tilni tanlang'**
  String get selectLanguage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
