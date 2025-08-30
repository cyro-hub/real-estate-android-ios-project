import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('fr'),
  ];

  /// No description provided for @selectTown.
  ///
  /// In en, this message translates to:
  /// **'Select town'**
  String get selectTown;

  /// No description provided for @searchProperties.
  ///
  /// In en, this message translates to:
  /// **'Search properties'**
  String get searchProperties;

  /// No description provided for @apartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get apartment;

  /// No description provided for @house.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get house;

  /// No description provided for @studio.
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get studio;

  /// No description provided for @office.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get office;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @land.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get land;

  /// No description provided for @duplex.
  ///
  /// In en, this message translates to:
  /// **'Duplex'**
  String get duplex;

  /// No description provided for @villa.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get villa;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @access.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get access;

  /// No description provided for @favourite.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get favourite;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @properties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get properties;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @propertyFilter.
  ///
  /// In en, this message translates to:
  /// **'Property filter'**
  String get propertyFilter;

  /// No description provided for @towns.
  ///
  /// In en, this message translates to:
  /// **'Towns'**
  String get towns;

  /// No description provided for @selectATown.
  ///
  /// In en, this message translates to:
  /// **'Select a town'**
  String get selectATown;

  /// No description provided for @maxRent.
  ///
  /// In en, this message translates to:
  /// **'Max Rent'**
  String get maxRent;

  /// No description provided for @upTo.
  ///
  /// In en, this message translates to:
  /// **'Up to'**
  String get upTo;

  /// No description provided for @paymentFrequency.
  ///
  /// In en, this message translates to:
  /// **'Payment Frequency'**
  String get paymentFrequency;

  /// No description provided for @any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get any;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @shared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get shared;

  /// No description provided for @toilet.
  ///
  /// In en, this message translates to:
  /// **'Toilet'**
  String get toilet;

  /// No description provided for @bathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get bathrooms;

  /// No description provided for @kitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get kitchen;

  /// No description provided for @waterAvailable.
  ///
  /// In en, this message translates to:
  /// **'Water Available'**
  String get waterAvailable;

  /// No description provided for @electricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get electricity;

  /// No description provided for @parking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get parking;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account'**
  String get dontHaveAnAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @noFavouriteYet.
  ///
  /// In en, this message translates to:
  /// **'No Favourite yet'**
  String get noFavouriteYet;

  /// No description provided for @amenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// No description provided for @houseRules.
  ///
  /// In en, this message translates to:
  /// **'House Rules'**
  String get houseRules;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @expiresAt.
  ///
  /// In en, this message translates to:
  /// **'Expires at'**
  String get expiresAt;

  /// No description provided for @buyToken.
  ///
  /// In en, this message translates to:
  /// **'Buy Token'**
  String get buyToken;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @availableTokens.
  ///
  /// In en, this message translates to:
  /// **'Available Tokens'**
  String get availableTokens;

  /// No description provided for @tokensBought.
  ///
  /// In en, this message translates to:
  /// **'Tokens Bought'**
  String get tokensBought;

  /// No description provided for @propertiesLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Properties Last Month'**
  String get propertiesLastMonth;

  /// No description provided for @recentActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get recentActivities;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @addProperty.
  ///
  /// In en, this message translates to:
  /// **'Add Property'**
  String get addProperty;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @mySubscriptions.
  ///
  /// In en, this message translates to:
  /// **'My Subscriptions'**
  String get mySubscriptions;

  /// No description provided for @noPropertiesFound.
  ///
  /// In en, this message translates to:
  /// **'No Properties found'**
  String get noPropertiesFound;

  /// No description provided for @privacyPolicies.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policies'**
  String get privacyPolicies;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @last3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get last3Months;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @btnContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get btnContinue;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @detail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detail;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact info'**
  String get contactInfo;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// No description provided for @addVideo.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get addVideo;

  /// No description provided for @noMediaAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No media added yet'**
  String get noMediaAddedYet;

  /// No description provided for @addImagesOrVideosToDisplayHere.
  ///
  /// In en, this message translates to:
  /// **'Add images or videos to display here'**
  String get addImagesOrVideosToDisplayHere;

  /// No description provided for @submitMedia.
  ///
  /// In en, this message translates to:
  /// **'Submit Media'**
  String get submitMedia;

  /// No description provided for @addPropertyMedia.
  ///
  /// In en, this message translates to:
  /// **'Add Property Media'**
  String get addPropertyMedia;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
