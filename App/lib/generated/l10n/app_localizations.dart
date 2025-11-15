import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Glitrip AI'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Travel, Light.'**
  String get tagline;

  /// No description provided for @destinations.
  ///
  /// In en, this message translates to:
  /// **'Destinations'**
  String get destinations;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @packing.
  ///
  /// In en, this message translates to:
  /// **'Packing'**
  String get packing;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travel;

  /// No description provided for @travelDocuments.
  ///
  /// In en, this message translates to:
  /// **'Travel Documents'**
  String get travelDocuments;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account & Support'**
  String get accountSettings;

  /// No description provided for @logoutAction.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutAction;

  /// No description provided for @logoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your current account'**
  String get logoutDescription;

  /// No description provided for @logoutSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get logoutSuccessMessage;

  /// No description provided for @deleteAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountAction;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your account and local data'**
  String get deleteAccountDescription;

  /// No description provided for @deleteAccountSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted'**
  String get deleteAccountSuccessMessage;

  /// No description provided for @contactUsAction.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUsAction;

  /// No description provided for @contactUsDescription.
  ///
  /// In en, this message translates to:
  /// **'Get support or send feedback'**
  String get contactUsDescription;

  /// No description provided for @contactDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'We are here to help. Reach out anytime and we will respond as soon as possible.'**
  String get contactDialogMessage;

  /// No description provided for @contactEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Support Email'**
  String get contactEmailLabel;

  /// No description provided for @supportEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'support@glitrip.com'**
  String get supportEmailAddress;

  /// No description provided for @emailCopiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Email copied to clipboard'**
  String get emailCopiedMessage;

  /// No description provided for @confirmLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogoutTitle;

  /// No description provided for @confirmLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get confirmLogoutMessage;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This action will permanently remove your account and related data. This cannot be undone. Continue?'**
  String get confirmDeleteMessage;

  /// No description provided for @searchDestinations.
  ///
  /// In en, this message translates to:
  /// **'Search destinations...'**
  String get searchDestinations;

  /// No description provided for @searchDocuments.
  ///
  /// In en, this message translates to:
  /// **'Search documents...'**
  String get searchDocuments;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @visited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get visited;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @noDestinationsYet.
  ///
  /// In en, this message translates to:
  /// **'No destinations yet'**
  String get noDestinationsYet;

  /// No description provided for @startPlanningNextAdventure.
  ///
  /// In en, this message translates to:
  /// **'Start planning your next adventure!'**
  String get startPlanningNextAdventure;

  /// No description provided for @addFirstDestination.
  ///
  /// In en, this message translates to:
  /// **'Add first destination'**
  String get addFirstDestination;

  /// No description provided for @addDestination.
  ///
  /// In en, this message translates to:
  /// **'Add Destination'**
  String get addDestination;

  /// No description provided for @editDestination.
  ///
  /// In en, this message translates to:
  /// **'Edit Destination'**
  String get editDestination;

  /// No description provided for @newDestination.
  ///
  /// In en, this message translates to:
  /// **'New Destination'**
  String get newDestination;

  /// No description provided for @planYourNextAdventure.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Next Adventure'**
  String get planYourNextAdventure;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @destinationName.
  ///
  /// In en, this message translates to:
  /// **'Destination Name'**
  String get destinationName;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @travelDetails.
  ///
  /// In en, this message translates to:
  /// **'Travel Details'**
  String get travelDetails;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @budgetLevel.
  ///
  /// In en, this message translates to:
  /// **'Budget Level'**
  String get budgetLevel;

  /// No description provided for @estimatedCost.
  ///
  /// In en, this message translates to:
  /// **'Estimated Cost'**
  String get estimatedCost;

  /// No description provided for @recommendedDays.
  ///
  /// In en, this message translates to:
  /// **'Recommended {days} days'**
  String recommendedDays(int days);

  /// No description provided for @bestTimeToVisit.
  ///
  /// In en, this message translates to:
  /// **'Best Time to Visit'**
  String get bestTimeToVisit;

  /// No description provided for @bestTimeExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., April-June'**
  String get bestTimeExample;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @addTagAndPressReturn.
  ///
  /// In en, this message translates to:
  /// **'Add tag and press return'**
  String get addTagAndPressReturn;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @travelNotes.
  ///
  /// In en, this message translates to:
  /// **'Travel Notes'**
  String get travelNotes;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @pleaseEnterDestinationName.
  ///
  /// In en, this message translates to:
  /// **'Please enter destination name'**
  String get pleaseEnterDestinationName;

  /// No description provided for @pleaseEnterCountry.
  ///
  /// In en, this message translates to:
  /// **'Please enter country'**
  String get pleaseEnterCountry;

  /// No description provided for @pleaseEnterValidCost.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid cost'**
  String get pleaseEnterValidCost;

  /// No description provided for @startDateMustBeBeforeEndDate.
  ///
  /// In en, this message translates to:
  /// **'Start date must be before end date'**
  String get startDateMustBeBeforeEndDate;

  /// No description provided for @destinationsTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} destinations'**
  String destinationsTotal(int count);

  /// No description provided for @noDocumentsYet.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get noDocumentsYet;

  /// No description provided for @addTravelDocuments.
  ///
  /// In en, this message translates to:
  /// **'Add your travel documents like passport,\nvisa, tickets and bookings to keep them organized'**
  String get addTravelDocuments;

  /// No description provided for @addFirstDocument.
  ///
  /// In en, this message translates to:
  /// **'Add first document'**
  String get addFirstDocument;

  /// No description provided for @addDocumentsDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your travel documents like passport,\nvisa, tickets and bookings to keep them organized'**
  String get addDocumentsDescription;

  /// No description provided for @addDocument.
  ///
  /// In en, this message translates to:
  /// **'Add Document'**
  String get addDocument;

  /// No description provided for @editDocument.
  ///
  /// In en, this message translates to:
  /// **'Edit Document'**
  String get editDocument;

  /// No description provided for @documentInformation.
  ///
  /// In en, this message translates to:
  /// **'Document Information'**
  String get documentInformation;

  /// No description provided for @documentName.
  ///
  /// In en, this message translates to:
  /// **'Document Name'**
  String get documentName;

  /// No description provided for @documentType.
  ///
  /// In en, this message translates to:
  /// **'Document Type'**
  String get documentType;

  /// No description provided for @hasExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Has Expiry Date'**
  String get hasExpiryDate;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @selectExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Select expiry date'**
  String get selectExpiryDate;

  /// No description provided for @pleaseEnterDocumentName.
  ///
  /// In en, this message translates to:
  /// **'Please enter document name'**
  String get pleaseEnterDocumentName;

  /// No description provided for @pleaseSelectExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Please select expiry date'**
  String get pleaseSelectExpiryDate;

  /// No description provided for @addNotesAboutDocument.
  ///
  /// In en, this message translates to:
  /// **'Add notes about this document...'**
  String get addNotesAboutDocument;

  /// No description provided for @documentsTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} documents'**
  String documentsTotal(int count);

  /// No description provided for @passport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get passport;

  /// No description provided for @idCard.
  ///
  /// In en, this message translates to:
  /// **'ID Card'**
  String get idCard;

  /// No description provided for @visa.
  ///
  /// In en, this message translates to:
  /// **'Visa'**
  String get visa;

  /// No description provided for @insurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get insurance;

  /// No description provided for @ticket.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get ticket;

  /// No description provided for @hotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel Booking'**
  String get hotel;

  /// No description provided for @hotelBooking.
  ///
  /// In en, this message translates to:
  /// **'Hotel Booking'**
  String get hotelBooking;

  /// No description provided for @carRental.
  ///
  /// In en, this message translates to:
  /// **'Car Rental'**
  String get carRental;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @noExpiry.
  ///
  /// In en, this message translates to:
  /// **'No expiry'**
  String get noExpiry;

  /// No description provided for @expiresSoon.
  ///
  /// In en, this message translates to:
  /// **'Expires soon'**
  String get expiresSoon;

  /// No description provided for @hasNotes.
  ///
  /// In en, this message translates to:
  /// **'Has notes'**
  String get hasNotes;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @attachedImages.
  ///
  /// In en, this message translates to:
  /// **'Attached Images'**
  String get attachedImages;

  /// No description provided for @noImagesAttached.
  ///
  /// In en, this message translates to:
  /// **'No images attached'**
  String get noImagesAttached;

  /// No description provided for @imageCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No images} =1{1 image} other{{count} images}}'**
  String imageCount(int count);

  /// No description provided for @deleteDocument.
  ///
  /// In en, this message translates to:
  /// **'Delete Document'**
  String get deleteDocument;

  /// No description provided for @deleteDocumentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String deleteDocumentConfirm(String name);

  /// No description provided for @documentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Document deleted successfully'**
  String get documentDeleted;

  /// No description provided for @noDocumentsOfType.
  ///
  /// In en, this message translates to:
  /// **'No {type} documents yet'**
  String noDocumentsOfType(String type);

  /// No description provided for @addDocumentsToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Add some documents to get started!'**
  String get addDocumentsToGetStarted;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose Photo'**
  String get choosePhoto;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String errorPickingImage(Object error);

  /// No description provided for @packingProgress.
  ///
  /// In en, this message translates to:
  /// **'Packing Progress'**
  String get packingProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completed;

  /// No description provided for @clothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get clothing;

  /// No description provided for @electronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get electronics;

  /// No description provided for @cosmetics.
  ///
  /// In en, this message translates to:
  /// **'Cosmetics'**
  String get cosmetics;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @accessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get accessories;

  /// No description provided for @books.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get books;

  /// No description provided for @entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// No description provided for @packingTotal.
  ///
  /// In en, this message translates to:
  /// **'{total} items total'**
  String packingTotal(int total);

  /// No description provided for @noItemsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No {category} items yet'**
  String noItemsInCategory(String category);

  /// No description provided for @addItemsToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Add some items to get started!'**
  String get addItemsToGetStarted;

  /// No description provided for @noPackingItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No packing items yet'**
  String get noPackingItemsYet;

  /// No description provided for @startAddingItemsToPackingList.
  ///
  /// In en, this message translates to:
  /// **'Start adding items to your packing list'**
  String get startAddingItemsToPackingList;

  /// No description provided for @addFirstItem.
  ///
  /// In en, this message translates to:
  /// **'Add first item'**
  String get addFirstItem;

  /// No description provided for @addPackingItem.
  ///
  /// In en, this message translates to:
  /// **'Add Packing Item'**
  String get addPackingItem;

  /// No description provided for @editPackingItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Packing Item'**
  String get editPackingItem;

  /// No description provided for @itemDetails.
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get itemDetails;

  /// No description provided for @selectDestination.
  ///
  /// In en, this message translates to:
  /// **'Select Destination'**
  String get selectDestination;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @pleaseEnterItemName.
  ///
  /// In en, this message translates to:
  /// **'Please enter item name'**
  String get pleaseEnterItemName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @essentialItem.
  ///
  /// In en, this message translates to:
  /// **'Essential Item'**
  String get essentialItem;

  /// No description provided for @noDestinationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No destinations available'**
  String get noDestinationsAvailable;

  /// No description provided for @errorLoadingDestinations.
  ///
  /// In en, this message translates to:
  /// **'Error loading destinations'**
  String get errorLoadingDestinations;

  /// No description provided for @pleaseSelectDestination.
  ///
  /// In en, this message translates to:
  /// **'Please select a destination'**
  String get pleaseSelectDestination;

  /// No description provided for @itemAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Item added successfully'**
  String get itemAddedSuccessfully;

  /// No description provided for @itemUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Item updated successfully'**
  String get itemUpdatedSuccessfully;

  /// No description provided for @errorSavingItem.
  ///
  /// In en, this message translates to:
  /// **'Error saving item: {error}'**
  String errorSavingItem(Object error);

  /// No description provided for @travelExplorer.
  ///
  /// In en, this message translates to:
  /// **'Travel Explorer'**
  String get travelExplorer;

  /// No description provided for @adventureAwaits.
  ///
  /// In en, this message translates to:
  /// **'Adventure awaits!'**
  String get adventureAwaits;

  /// No description provided for @travelStatistics.
  ///
  /// In en, this message translates to:
  /// **'Travel Statistics'**
  String get travelStatistics;

  /// No description provided for @membershipLevel.
  ///
  /// In en, this message translates to:
  /// **'Membership Level'**
  String get membershipLevel;

  /// No description provided for @membershipFree.
  ///
  /// In en, this message translates to:
  /// **'Free Member'**
  String get membershipFree;

  /// No description provided for @membershipVip.
  ///
  /// In en, this message translates to:
  /// **'VIP Member'**
  String get membershipVip;

  /// No description provided for @membershipExpiry.
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String membershipExpiry(String date);

  /// No description provided for @aiUsageLimit.
  ///
  /// In en, this message translates to:
  /// **'AI quota: used {used}/{total}, remaining {remaining}'**
  String aiUsageLimit(int used, int total, int remaining);

  /// No description provided for @upgradeOrRenewMembership.
  ///
  /// In en, this message translates to:
  /// **'Upgrade / Renew Membership'**
  String get upgradeOrRenewMembership;

  /// No description provided for @upgradeMembership.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Membership'**
  String get upgradeMembership;

  /// No description provided for @renewMembership.
  ///
  /// In en, this message translates to:
  /// **'Renew Membership'**
  String get renewMembership;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @addTravelBuddy.
  ///
  /// In en, this message translates to:
  /// **'Add Travel Buddy'**
  String get addTravelBuddy;

  /// No description provided for @travelBuddies.
  ///
  /// In en, this message translates to:
  /// **'Travel Buddies'**
  String get travelBuddies;

  /// No description provided for @noTravelBuddiesYet.
  ///
  /// In en, this message translates to:
  /// **'No travel buddies yet'**
  String get noTravelBuddiesYet;

  /// No description provided for @addTravelBuddyLink.
  ///
  /// In en, this message translates to:
  /// **'Add Travel Buddy'**
  String get addTravelBuddyLink;

  /// No description provided for @selectedTravelBuddies.
  ///
  /// In en, this message translates to:
  /// **'Selected {count} travel buddies'**
  String selectedTravelBuddies(Object count);

  /// No description provided for @loadingTravelBuddiesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load travel buddies: {error}'**
  String loadingTravelBuddiesFailed(Object error);

  /// No description provided for @noTravelBuddyInfo.
  ///
  /// In en, this message translates to:
  /// **'No travel buddy information'**
  String get noTravelBuddyInfo;

  /// No description provided for @findSomeoneToTravelWith.
  ///
  /// In en, this message translates to:
  /// **'Find someone to travel with'**
  String get findSomeoneToTravelWith;

  /// No description provided for @dontForgetEssentials.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget essentials'**
  String get dontForgetEssentials;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @itinerary.
  ///
  /// In en, this message translates to:
  /// **'Itinerary'**
  String get itinerary;

  /// No description provided for @memories.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get memories;

  /// No description provided for @budgetOverview.
  ///
  /// In en, this message translates to:
  /// **'Budget Overview'**
  String get budgetOverview;

  /// No description provided for @tapToManageExpenses.
  ///
  /// In en, this message translates to:
  /// **'Tap to manage expenses'**
  String get tapToManageExpenses;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @deleteDestination.
  ///
  /// In en, this message translates to:
  /// **'Delete Destination'**
  String get deleteDestination;

  /// No description provided for @deleteDestinationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String deleteDestinationConfirm(String name);

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItem;

  /// No description provided for @deleteItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteItemConfirm(String name);

  /// No description provided for @errorSavingDestination.
  ///
  /// In en, this message translates to:
  /// **'Error saving destination: {error}'**
  String errorSavingDestination(Object error);

  /// No description provided for @errorSavingDocument.
  ///
  /// In en, this message translates to:
  /// **'Error saving document: {error}'**
  String errorSavingDocument(Object error);

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{query}\"'**
  String noSearchResults(String query);

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'Search error: {error}'**
  String searchError(Object error);

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get errorLoadingProfile;

  /// No description provided for @featureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Feature in development...'**
  String get featureInDevelopment;

  /// No description provided for @itemsTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} items total'**
  String itemsTotal(int count);

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability (e.g., June 2024)'**
  String get availability;

  /// No description provided for @confirmedToTravel.
  ///
  /// In en, this message translates to:
  /// **'Confirmed to travel'**
  String get confirmedToTravel;

  /// No description provided for @travelPreferences.
  ///
  /// In en, this message translates to:
  /// **'Travel Preferences'**
  String get travelPreferences;

  /// No description provided for @adventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get adventure;

  /// No description provided for @relaxation.
  ///
  /// In en, this message translates to:
  /// **'Relaxation'**
  String get relaxation;

  /// No description provided for @culture.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get culture;

  /// No description provided for @foodie.
  ///
  /// In en, this message translates to:
  /// **'Foodie'**
  String get foodie;

  /// No description provided for @nature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get nature;

  /// No description provided for @urban.
  ///
  /// In en, this message translates to:
  /// **'Urban'**
  String get urban;

  /// No description provided for @dreamDestinations.
  ///
  /// In en, this message translates to:
  /// **'Dream Destinations'**
  String get dreamDestinations;

  /// No description provided for @addDestinationAndPressReturn.
  ///
  /// In en, this message translates to:
  /// **'Add destination and press return'**
  String get addDestinationAndPressReturn;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter name'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone'**
  String get pleaseEnterPhone;

  /// No description provided for @travelBuddyAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Travel buddy added successfully'**
  String get travelBuddyAddedSuccessfully;

  /// No description provided for @travelBuddyUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Travel buddy updated successfully'**
  String get travelBuddyUpdatedSuccessfully;

  /// No description provided for @errorSavingTravelBuddy.
  ///
  /// In en, this message translates to:
  /// **'Error saving travel buddy: {error}'**
  String errorSavingTravelBuddy(Object error);

  /// No description provided for @editTravelBuddy.
  ///
  /// In en, this message translates to:
  /// **'Edit Travel Buddy'**
  String get editTravelBuddy;

  /// No description provided for @deleteTravelBuddy.
  ///
  /// In en, this message translates to:
  /// **'Delete Travel Buddy'**
  String get deleteTravelBuddy;

  /// No description provided for @deleteTravelBuddyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String deleteTravelBuddyConfirm(String name);

  /// No description provided for @travelBuddyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Travel buddy deleted successfully'**
  String get travelBuddyDeleted;

  /// No description provided for @addTravelBuddiesToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Add some travel buddies to get started!'**
  String get addTravelBuddiesToGetStarted;

  /// No description provided for @addFirstTravelBuddy.
  ///
  /// In en, this message translates to:
  /// **'Add first travel buddy'**
  String get addFirstTravelBuddy;

  /// No description provided for @travelBuddiesTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} travel buddies'**
  String travelBuddiesTotal(int count);

  /// No description provided for @searchTravelBuddies.
  ///
  /// In en, this message translates to:
  /// **'Search travel buddies...'**
  String get searchTravelBuddies;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @budgetLevelCard.
  ///
  /// In en, this message translates to:
  /// **'Budget Level'**
  String get budgetLevelCard;

  /// No description provided for @comfort.
  ///
  /// In en, this message translates to:
  /// **'Comfort'**
  String get comfort;

  /// No description provided for @luxury.
  ///
  /// In en, this message translates to:
  /// **'Luxury'**
  String get luxury;

  /// No description provided for @budgetOption.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetOption;

  /// No description provided for @budgetAndExpenses.
  ///
  /// In en, this message translates to:
  /// **'Budget & Expenses'**
  String get budgetAndExpenses;

  /// No description provided for @totalBudget.
  ///
  /// In en, this message translates to:
  /// **'Total Budget'**
  String get totalBudget;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// No description provided for @expensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get expensesByCategory;

  /// No description provided for @recentExpenses.
  ///
  /// In en, this message translates to:
  /// **'Recent Expenses'**
  String get recentExpenses;

  /// No description provided for @noExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No Expenses Yet'**
  String get noExpensesYet;

  /// No description provided for @addFirstExpenseToStartTracking.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense to start tracking'**
  String get addFirstExpenseToStartTracking;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @expenseDetails.
  ///
  /// In en, this message translates to:
  /// **'Expense Details'**
  String get expenseDetails;

  /// No description provided for @expenseName.
  ///
  /// In en, this message translates to:
  /// **'Expense Name'**
  String get expenseName;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @alreadyPaid.
  ///
  /// In en, this message translates to:
  /// **'Already Paid'**
  String get alreadyPaid;

  /// No description provided for @accommodation.
  ///
  /// In en, this message translates to:
  /// **'Accommodation'**
  String get accommodation;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @noItineraryYet.
  ///
  /// In en, this message translates to:
  /// **'No itinerary yet'**
  String get noItineraryYet;

  /// No description provided for @planYourTripDayByDay.
  ///
  /// In en, this message translates to:
  /// **'Plan your trip day by day'**
  String get planYourTripDayByDay;

  /// No description provided for @addFirstDay.
  ///
  /// In en, this message translates to:
  /// **'Add First Day'**
  String get addFirstDay;

  /// No description provided for @addItineraryDay.
  ///
  /// In en, this message translates to:
  /// **'Add Itinerary Day'**
  String get addItineraryDay;

  /// No description provided for @editItineraryDay.
  ///
  /// In en, this message translates to:
  /// **'Edit Itinerary Day'**
  String get editItineraryDay;

  /// No description provided for @dayInformation.
  ///
  /// In en, this message translates to:
  /// **'Day Information'**
  String get dayInformation;

  /// No description provided for @dayTitle.
  ///
  /// In en, this message translates to:
  /// **'Day Title'**
  String get dayTitle;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day {number}'**
  String day(int number);

  /// No description provided for @addActivity.
  ///
  /// In en, this message translates to:
  /// **'Add Activity'**
  String get addActivity;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity Title'**
  String get activityTitle;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @costOptional.
  ///
  /// In en, this message translates to:
  /// **'Cost (optional)'**
  String get costOptional;

  /// No description provided for @alreadyBooked.
  ///
  /// In en, this message translates to:
  /// **'Already Booked'**
  String get alreadyBooked;

  /// No description provided for @noActivitiesPlanned.
  ///
  /// In en, this message translates to:
  /// **'No activities planned'**
  String get noActivitiesPlanned;

  /// No description provided for @deleteDay.
  ///
  /// In en, this message translates to:
  /// **'Delete Day'**
  String get deleteDay;

  /// No description provided for @deleteDayConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String deleteDayConfirm(String title);

  /// No description provided for @dayDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Day deleted successfully'**
  String get dayDeletedSuccessfully;

  /// No description provided for @timeExample.
  ///
  /// In en, this message translates to:
  /// **'Time (e.g., 9:00 AM)'**
  String get timeExample;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String days(int count);

  /// No description provided for @packingList.
  ///
  /// In en, this message translates to:
  /// **'Packing List'**
  String get packingList;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @noItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get noItemsYet;

  /// No description provided for @addItemsToPackingList.
  ///
  /// In en, this message translates to:
  /// **'Add items to your packing list'**
  String get addItemsToPackingList;

  /// No description provided for @essential.
  ///
  /// In en, this message translates to:
  /// **'Essential'**
  String get essential;

  /// No description provided for @itemDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Item deleted successfully'**
  String get itemDeletedSuccessfully;

  /// No description provided for @travelMemories.
  ///
  /// In en, this message translates to:
  /// **'Travel Memories'**
  String get travelMemories;

  /// No description provided for @noMemoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No memories yet'**
  String get noMemoriesYet;

  /// No description provided for @addPhotosAndStories.
  ///
  /// In en, this message translates to:
  /// **'Add photos and stories from your trip'**
  String get addPhotosAndStories;

  /// No description provided for @addFirstMemory.
  ///
  /// In en, this message translates to:
  /// **'Add First Memory'**
  String get addFirstMemory;

  /// No description provided for @addMemory.
  ///
  /// In en, this message translates to:
  /// **'Add Memory'**
  String get addMemory;

  /// No description provided for @editMemory.
  ///
  /// In en, this message translates to:
  /// **'Edit Memory'**
  String get editMemory;

  /// No description provided for @deleteMemory.
  ///
  /// In en, this message translates to:
  /// **'Delete Memory'**
  String get deleteMemory;

  /// No description provided for @deleteMemoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String deleteMemoryConfirm(String title);

  /// No description provided for @memoryDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Memory deleted successfully'**
  String get memoryDeletedSuccessfully;

  /// No description provided for @memoryDetails.
  ///
  /// In en, this message translates to:
  /// **'Memory Details'**
  String get memoryDetails;

  /// No description provided for @memoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Memory Title'**
  String get memoryTitle;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @shareYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Share your experience...'**
  String get shareYourExperience;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @currentTrips.
  ///
  /// In en, this message translates to:
  /// **'Current Trips'**
  String get currentTrips;

  /// No description provided for @templates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templates;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @addItems.
  ///
  /// In en, this message translates to:
  /// **'Add Items'**
  String get addItems;

  /// No description provided for @noCurrentTrips.
  ///
  /// In en, this message translates to:
  /// **'No Current Trips'**
  String get noCurrentTrips;

  /// No description provided for @planTripToStartPacking.
  ///
  /// In en, this message translates to:
  /// **'Plan a trip to start packing'**
  String get planTripToStartPacking;

  /// No description provided for @noTemplatesYet.
  ///
  /// In en, this message translates to:
  /// **'No Templates Yet'**
  String get noTemplatesYet;

  /// No description provided for @createTemplateToReuse.
  ///
  /// In en, this message translates to:
  /// **'Create templates to reuse items'**
  String get createTemplateToReuse;

  /// No description provided for @noCompletedTrips.
  ///
  /// In en, this message translates to:
  /// **'No completed trips yet'**
  String get noCompletedTrips;

  /// No description provided for @completedTripsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Completed trips will appear here'**
  String get completedTripsWillAppearHere;

  /// No description provided for @pleaseEnterExpenseName.
  ///
  /// In en, this message translates to:
  /// **'Please enter expense name'**
  String get pleaseEnterExpenseName;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount'**
  String get pleaseEnterAmount;

  /// No description provided for @expenseAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Expense added successfully'**
  String get expenseAddedSuccessfully;

  /// No description provided for @expenseUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Expense updated successfully'**
  String get expenseUpdatedSuccessfully;

  /// No description provided for @errorSavingExpense.
  ///
  /// In en, this message translates to:
  /// **'Error saving expense: {error}'**
  String errorSavingExpense(Object error);

  /// No description provided for @deleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpense;

  /// No description provided for @deleteExpenseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String deleteExpenseConfirm(String name);

  /// No description provided for @viewPacking.
  ///
  /// In en, this message translates to:
  /// **'View Packing'**
  String get viewPacking;

  /// No description provided for @addFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'Add from Template'**
  String get addFromTemplate;

  /// No description provided for @addFromTemplateDescription.
  ///
  /// In en, this message translates to:
  /// **'Select items from templates to quickly add to packing list'**
  String get addFromTemplateDescription;

  /// No description provided for @selectFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'Select from Template'**
  String get selectFromTemplate;

  /// No description provided for @addSelected.
  ///
  /// In en, this message translates to:
  /// **'Add Selected'**
  String get addSelected;

  /// No description provided for @errorLoadingItems.
  ///
  /// In en, this message translates to:
  /// **'Error loading items'**
  String get errorLoadingItems;

  /// No description provided for @errorLoadingStats.
  ///
  /// In en, this message translates to:
  /// **'Error loading stats'**
  String get errorLoadingStats;

  /// No description provided for @errorLoadingTemplates.
  ///
  /// In en, this message translates to:
  /// **'Error loading templates'**
  String get errorLoadingTemplates;

  /// No description provided for @totalItems.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get totalItems;

  /// No description provided for @packed.
  ///
  /// In en, this message translates to:
  /// **'Packed'**
  String get packed;

  /// No description provided for @selectAllTemplateItems.
  ///
  /// In en, this message translates to:
  /// **'Select all template items'**
  String get selectAllTemplateItems;

  /// No description provided for @createTemplateFirst.
  ///
  /// In en, this message translates to:
  /// **'Please create templates first'**
  String get createTemplateFirst;

  /// No description provided for @pleaseSelectItems.
  ///
  /// In en, this message translates to:
  /// **'Please select items'**
  String get pleaseSelectItems;

  /// No description provided for @addingItems.
  ///
  /// In en, this message translates to:
  /// **'Adding items...'**
  String get addingItems;

  /// No description provided for @creatingTemplateItem.
  ///
  /// In en, this message translates to:
  /// **'Creating template item'**
  String get creatingTemplateItem;

  /// No description provided for @addToDestination.
  ///
  /// In en, this message translates to:
  /// **'Add to Destination'**
  String get addToDestination;

  /// No description provided for @addItemToSpecificDestination.
  ///
  /// In en, this message translates to:
  /// **'Add item to specific destination'**
  String get addItemToSpecificDestination;

  /// No description provided for @addToTemplate.
  ///
  /// In en, this message translates to:
  /// **'Add to Template'**
  String get addToTemplate;

  /// No description provided for @addItemToTemplate.
  ///
  /// In en, this message translates to:
  /// **'Add item to template'**
  String get addItemToTemplate;

  /// No description provided for @deleteTemplateItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Template Item'**
  String get deleteTemplateItem;

  /// No description provided for @deleteTemplateItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete template item \"{name}\"?'**
  String deleteTemplateItemConfirm(String name);

  /// No description provided for @templateItemDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Template item deleted successfully'**
  String get templateItemDeletedSuccessfully;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon'**
  String get featureComingSoon;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @errorDeletingItem.
  ///
  /// In en, this message translates to:
  /// **'Error deleting item: {error}'**
  String errorDeletingItem(Object error);

  /// No description provided for @itemsAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Successfully added {count} items'**
  String itemsAddedSuccessfully(int count);

  /// No description provided for @errorAddingItems.
  ///
  /// In en, this message translates to:
  /// **'Error adding items: {error}'**
  String errorAddingItems(Object error);

  /// No description provided for @aiSmartCreateDestination.
  ///
  /// In en, this message translates to:
  /// **'AI Smart Create Destination'**
  String get aiSmartCreateDestination;

  /// No description provided for @aiPlanPreview.
  ///
  /// In en, this message translates to:
  /// **'AI Plan Preview'**
  String get aiPlanPreview;

  /// No description provided for @letAiPlanYourTrip.
  ///
  /// In en, this message translates to:
  /// **'Let AI Plan Your Trip'**
  String get letAiPlanYourTrip;

  /// No description provided for @fourStepsAutoGenerate.
  ///
  /// In en, this message translates to:
  /// **'4 steps, AI auto-generates complete itinerary'**
  String get fourStepsAutoGenerate;

  /// No description provided for @aiPlanning.
  ///
  /// In en, this message translates to:
  /// **'AI is planning your trip...'**
  String get aiPlanning;

  /// No description provided for @aiPlanningTime.
  ///
  /// In en, this message translates to:
  /// **'This may take 10-30 seconds'**
  String get aiPlanningTime;

  /// No description provided for @pleaseSelectTravelDates.
  ///
  /// In en, this message translates to:
  /// **'Please select travel dates'**
  String get pleaseSelectTravelDates;

  /// No description provided for @aiFailed.
  ///
  /// In en, this message translates to:
  /// **'AI generation failed'**
  String get aiFailed;

  /// No description provided for @remainingAiPlans.
  ///
  /// In en, this message translates to:
  /// **'{count} AI plans remaining'**
  String remainingAiPlans(int count);

  /// No description provided for @aiQuotaExhausted.
  ///
  /// In en, this message translates to:
  /// **'AI planning quota exhausted, please upgrade to VIP'**
  String get aiQuotaExhausted;

  /// No description provided for @destinationNameLabel.
  ///
  /// In en, this message translates to:
  /// **'1. Destination Name'**
  String get destinationNameLabel;

  /// No description provided for @destinationNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Tokyo, Paris, New York...'**
  String get destinationNameHint;

  /// No description provided for @budgetLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'2. Budget Level'**
  String get budgetLevelLabel;

  /// No description provided for @budgetEconomy.
  ///
  /// In en, this message translates to:
  /// **'Economy'**
  String get budgetEconomy;

  /// No description provided for @budgetComfort.
  ///
  /// In en, this message translates to:
  /// **'Comfort'**
  String get budgetComfort;

  /// No description provided for @budgetLuxury.
  ///
  /// In en, this message translates to:
  /// **'Luxury'**
  String get budgetLuxury;

  /// No description provided for @travelDatesLabel.
  ///
  /// In en, this message translates to:
  /// **'3. Travel Dates'**
  String get travelDatesLabel;

  /// No description provided for @startDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDateLabel;

  /// No description provided for @endDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDateLabel;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @aiSmartPlanButton.
  ///
  /// In en, this message translates to:
  /// **'4. AI Smart Planning'**
  String get aiSmartPlanButton;

  /// No description provided for @aiAutoDetectCountry.
  ///
  /// In en, this message translates to:
  /// **'* AI will automatically detect the destination\'s country and generate a detailed travel plan'**
  String get aiAutoDetectCountry;

  /// No description provided for @planGeneratedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Plan generated successfully!'**
  String get planGeneratedSuccessfully;

  /// No description provided for @savePlan.
  ///
  /// In en, this message translates to:
  /// **'Save Plan'**
  String get savePlan;

  /// No description provided for @savingPlan.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get savingPlan;

  /// No description provided for @planSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Plan saved successfully!'**
  String get planSavedSuccess;

  /// No description provided for @dayNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Day {number}'**
  String dayNumberLabel(int number);

  /// No description provided for @packagedItems.
  ///
  /// In en, this message translates to:
  /// **'Packing Items'**
  String get packagedItems;

  /// No description provided for @todoItems.
  ///
  /// In en, this message translates to:
  /// **'To-do Items'**
  String get todoItems;

  /// No description provided for @detailedItinerary.
  ///
  /// In en, this message translates to:
  /// **'Detailed Itinerary'**
  String get detailedItinerary;

  /// No description provided for @aiGeneratedPlan.
  ///
  /// In en, this message translates to:
  /// **'AI Generated Travel Plan'**
  String get aiGeneratedPlan;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(int count);

  /// No description provided for @categoryClothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get categoryClothing;

  /// No description provided for @categoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// No description provided for @categoryCosmetics.
  ///
  /// In en, this message translates to:
  /// **'Cosmetics'**
  String get categoryCosmetics;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get categoryAccessories;

  /// No description provided for @categoryBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get categoryBooks;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'\$'**
  String get currencySymbol;

  /// No description provided for @currencyCode.
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get currencyCode;

  /// No description provided for @todos.
  ///
  /// In en, this message translates to:
  /// **'To Do'**
  String get todos;

  /// No description provided for @currentTodoTrips.
  ///
  /// In en, this message translates to:
  /// **'Current Trips'**
  String get currentTodoTrips;

  /// No description provided for @completedTodos.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedTodos;

  /// No description provided for @allTodos.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTodos;

  /// No description provided for @todoCategoryPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get todoCategoryPassport;

  /// No description provided for @todoCategoryIdCard.
  ///
  /// In en, this message translates to:
  /// **'ID Card'**
  String get todoCategoryIdCard;

  /// No description provided for @todoCategoryVisa.
  ///
  /// In en, this message translates to:
  /// **'Visa'**
  String get todoCategoryVisa;

  /// No description provided for @todoCategoryInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get todoCategoryInsurance;

  /// No description provided for @todoCategoryTicket.
  ///
  /// In en, this message translates to:
  /// **'Flight Ticket'**
  String get todoCategoryTicket;

  /// No description provided for @todoCategoryHotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel Booking'**
  String get todoCategoryHotel;

  /// No description provided for @todoCategoryCarRental.
  ///
  /// In en, this message translates to:
  /// **'Car Rental'**
  String get todoCategoryCarRental;

  /// No description provided for @todoCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get todoCategoryOther;

  /// No description provided for @todoDetails.
  ///
  /// In en, this message translates to:
  /// **'To Do Details'**
  String get todoDetails;

  /// No description provided for @todoStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get todoStats;

  /// No description provided for @totalTodos.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalTodos;

  /// No description provided for @completedCount.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedCount;

  /// No description provided for @pendingCount.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingCount;

  /// No description provided for @highPriorityCount.
  ///
  /// In en, this message translates to:
  /// **'High Priority'**
  String get highPriorityCount;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get byCategory;

  /// No description provided for @addTodo.
  ///
  /// In en, this message translates to:
  /// **'Add To Do'**
  String get addTodo;

  /// No description provided for @editTodo.
  ///
  /// In en, this message translates to:
  /// **'Edit To Do'**
  String get editTodo;

  /// No description provided for @todoTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get todoTitle;

  /// No description provided for @todoCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get todoCategory;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @todoDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get todoDescription;

  /// No description provided for @todoPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get todoPriority;

  /// No description provided for @todoDeadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get todoDeadline;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @markAsComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete'**
  String get markAsComplete;

  /// No description provided for @markAsIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as Incomplete'**
  String get markAsIncomplete;

  /// No description provided for @deleteTodo.
  ///
  /// In en, this message translates to:
  /// **'Delete To Do'**
  String get deleteTodo;

  /// No description provided for @todoDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this to do item?'**
  String get todoDeleteConfirm;

  /// No description provided for @noTodosYet.
  ///
  /// In en, this message translates to:
  /// **'No to do items yet'**
  String get noTodosYet;

  /// No description provided for @noTodosInCategory.
  ///
  /// In en, this message translates to:
  /// **'No to do items in this category'**
  String get noTodosInCategory;

  /// No description provided for @addFirstTodo.
  ///
  /// In en, this message translates to:
  /// **'Add your first to do item'**
  String get addFirstTodo;

  /// No description provided for @todoTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get todoTitleRequired;

  /// No description provided for @todoCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get todoCategoryRequired;

  /// No description provided for @selectDeadline.
  ///
  /// In en, this message translates to:
  /// **'Select Deadline'**
  String get selectDeadline;

  /// No description provided for @clearDeadline.
  ///
  /// In en, this message translates to:
  /// **'Clear Deadline'**
  String get clearDeadline;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get dueToday;

  /// No description provided for @dueSoon.
  ///
  /// In en, this message translates to:
  /// **'Due Soon'**
  String get dueSoon;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get updateSuccess;

  /// No description provided for @addSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added successfully'**
  String get addSuccess;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deleteSuccess;

  /// No description provided for @noPlannedDestinations.
  ///
  /// In en, this message translates to:
  /// **'No planned destinations yet'**
  String get noPlannedDestinations;

  /// No description provided for @createDestinationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Create your first travel plan!'**
  String get createDestinationPrompt;

  /// No description provided for @completeFirstTrip.
  ///
  /// In en, this message translates to:
  /// **'Complete your first trip!'**
  String get completeFirstTrip;

  /// No description provided for @noDestinations.
  ///
  /// In en, this message translates to:
  /// **'No destinations yet'**
  String get noDestinations;

  /// No description provided for @createFirstDestination.
  ///
  /// In en, this message translates to:
  /// **'Start planning your trip!'**
  String get createFirstDestination;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
