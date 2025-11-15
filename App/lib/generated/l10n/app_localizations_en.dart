// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Glitrip AI';

  @override
  String get tagline => 'Travel, Light.';

  @override
  String get destinations => 'Destinations';

  @override
  String get documents => 'Documents';

  @override
  String get packing => 'Packing';

  @override
  String get profile => 'Profile';

  @override
  String get travel => 'Travel';

  @override
  String get travelDocuments => 'Travel Documents';

  @override
  String get myProfile => 'My Profile';

  @override
  String get accountSettings => 'Account & Support';

  @override
  String get logoutAction => 'Log Out';

  @override
  String get logoutDescription => 'Sign out of your current account';

  @override
  String get logoutSuccessMessage => 'Logged out successfully';

  @override
  String get deleteAccountAction => 'Delete Account';

  @override
  String get deleteAccountDescription => 'Permanently remove your account and local data';

  @override
  String get deleteAccountSuccessMessage => 'Your account has been deleted';

  @override
  String get contactUsAction => 'Contact Us';

  @override
  String get contactUsDescription => 'Get support or send feedback';

  @override
  String get contactDialogMessage => 'We are here to help. Reach out anytime and we will respond as soon as possible.';

  @override
  String get contactEmailLabel => 'Support Email';

  @override
  String get supportEmailAddress => 'support@glitrip.com';

  @override
  String get emailCopiedMessage => 'Email copied to clipboard';

  @override
  String get confirmLogoutTitle => 'Confirm Logout';

  @override
  String get confirmLogoutMessage => 'Are you sure you want to log out of your account?';

  @override
  String get confirmDeleteTitle => 'Delete Account';

  @override
  String get confirmDeleteMessage => 'This action will permanently remove your account and related data. This cannot be undone. Continue?';

  @override
  String get searchDestinations => 'Search destinations...';

  @override
  String get searchDocuments => 'Search documents...';

  @override
  String get all => 'All';

  @override
  String get visited => 'Visited';

  @override
  String get planned => 'Planned';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get noDestinationsYet => 'No destinations yet';

  @override
  String get startPlanningNextAdventure =>
      'Start planning your next adventure!';

  @override
  String get addFirstDestination => 'Add first destination';

  @override
  String get addDestination => 'Add Destination';

  @override
  String get editDestination => 'Edit Destination';

  @override
  String get newDestination => 'New Destination';

  @override
  String get planYourNextAdventure => 'Plan Your Next Adventure';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get destinationName => 'Destination Name';

  @override
  String get country => 'Country';

  @override
  String get description => 'Description';

  @override
  String get travelDetails => 'Travel Details';

  @override
  String get status => 'Status';

  @override
  String get budgetLevel => 'Budget Level';

  @override
  String get estimatedCost => 'Estimated Cost';

  @override
  String recommendedDays(int days) {
    return 'Recommended $days days';
  }

  @override
  String get bestTimeToVisit => 'Best Time to Visit';

  @override
  String get bestTimeExample => 'e.g., April-June';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get tags => 'Tags';

  @override
  String get addTagAndPressReturn => 'Add tag and press return';

  @override
  String get notes => 'Notes';

  @override
  String get travelNotes => 'Travel Notes';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get copy => 'Copy';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get retry => 'Retry';

  @override
  String get pleaseEnterDestinationName => 'Please enter destination name';

  @override
  String get pleaseEnterCountry => 'Please enter country';

  @override
  String get pleaseEnterValidCost => 'Please enter valid cost';

  @override
  String get startDateMustBeBeforeEndDate =>
      'Start date must be before end date';

  @override
  String destinationsTotal(int count) {
    return '$count destinations';
  }

  @override
  String get noDocumentsYet => 'No documents yet';

  @override
  String get addTravelDocuments =>
      'Add your travel documents like passport,\nvisa, tickets and bookings to keep them organized';

  @override
  String get addFirstDocument => 'Add first document';

  @override
  String get addDocumentsDescription =>
      'Add your travel documents like passport,\nvisa, tickets and bookings to keep them organized';

  @override
  String get addDocument => 'Add Document';

  @override
  String get editDocument => 'Edit Document';

  @override
  String get documentInformation => 'Document Information';

  @override
  String get documentName => 'Document Name';

  @override
  String get documentType => 'Document Type';

  @override
  String get hasExpiryDate => 'Has Expiry Date';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get selectExpiryDate => 'Select expiry date';

  @override
  String get pleaseEnterDocumentName => 'Please enter document name';

  @override
  String get pleaseSelectExpiryDate => 'Please select expiry date';

  @override
  String get addNotesAboutDocument => 'Add notes about this document...';

  @override
  String documentsTotal(int count) {
    return '$count documents';
  }

  @override
  String get passport => 'Passport';

  @override
  String get idCard => 'ID Card';

  @override
  String get visa => 'Visa';

  @override
  String get insurance => 'Insurance';

  @override
  String get ticket => 'Ticket';

  @override
  String get hotel => 'Hotel Booking';

  @override
  String get hotelBooking => 'Hotel Booking';

  @override
  String get carRental => 'Car Rental';

  @override
  String get other => 'Other';

  @override
  String get noExpiry => 'No expiry';

  @override
  String get expiresSoon => 'Expires soon';

  @override
  String get hasNotes => 'Has notes';

  @override
  String get created => 'Created';

  @override
  String get attachedImages => 'Attached Images';

  @override
  String get noImagesAttached => 'No images attached';

  @override
  String imageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count images',
      one: '1 image',
      zero: 'No images',
    );
    return '$_temp0';
  }

  @override
  String get deleteDocument => 'Delete Document';

  @override
  String deleteDocumentConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get documentDeleted => 'Document deleted successfully';

  @override
  String noDocumentsOfType(String type) {
    return 'No $type documents yet';
  }

  @override
  String get addDocumentsToGetStarted => 'Add some documents to get started!';

  @override
  String get images => 'Images';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get choosePhoto => 'Choose Photo';

  @override
  String errorPickingImage(Object error) {
    return 'Error picking image: $error';
  }

  @override
  String get packingProgress => 'Packing Progress';

  @override
  String get completed => 'Complete';

  @override
  String get clothing => 'Clothing';

  @override
  String get electronics => 'Electronics';

  @override
  String get cosmetics => 'Cosmetics';

  @override
  String get health => 'Health';

  @override
  String get accessories => 'Accessories';

  @override
  String get books => 'Books';

  @override
  String get entertainment => 'Entertainment';

  @override
  String packingTotal(int total) {
    return '$total items total';
  }

  @override
  String noItemsInCategory(String category) {
    return 'No $category items yet';
  }

  @override
  String get addItemsToGetStarted => 'Add some items to get started!';

  @override
  String get noPackingItemsYet => 'No packing items yet';

  @override
  String get startAddingItemsToPackingList =>
      'Start adding items to your packing list';

  @override
  String get addFirstItem => 'Add first item';

  @override
  String get addPackingItem => 'Add Packing Item';

  @override
  String get editPackingItem => 'Edit Packing Item';

  @override
  String get itemDetails => 'Item Details';

  @override
  String get selectDestination => 'Select Destination';

  @override
  String get itemName => 'Item Name';

  @override
  String get pleaseEnterItemName => 'Please enter item name';

  @override
  String get category => 'Category';

  @override
  String get quantity => 'Quantity';

  @override
  String get essentialItem => 'Essential Item';

  @override
  String get noDestinationsAvailable => 'No destinations available';

  @override
  String get errorLoadingDestinations => 'Error loading destinations';

  @override
  String get pleaseSelectDestination => 'Please select a destination';

  @override
  String get itemAddedSuccessfully => 'Item added successfully';

  @override
  String get itemUpdatedSuccessfully => 'Item updated successfully';

  @override
  String errorSavingItem(Object error) {
    return 'Error saving item: $error';
  }

  @override
  String get travelExplorer => 'Travel Explorer';

  @override
  String get adventureAwaits => 'Adventure awaits!';

  @override
  String get travelStatistics => 'Travel Statistics';

  @override
  String get membershipLevel => 'Membership Level';

  @override
  String get membershipFree => 'Free Member';

  @override
  String get membershipVip => 'VIP Member';

  @override
  String membershipExpiry(String date) {
    return 'Valid until $date';
  }

  @override
  String aiUsageLimit(int used, int total, int remaining) {
    return 'AI quota: used $used/$total, remaining $remaining';
  }

  @override
  String get upgradeOrRenewMembership => 'Upgrade / Renew Membership';

  @override
  String get upgradeMembership => 'Upgrade Membership';

  @override
  String get renewMembership => 'Renew Membership';

  @override
  String get total => 'Total';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get addTravelBuddy => 'Add Travel Buddy';

  @override
  String get travelBuddies => 'Travel Buddies';

  @override
  String get noTravelBuddiesYet => 'No travel buddies yet';

  @override
  String get addTravelBuddyLink => 'Add Travel Buddy';

  @override
  String selectedTravelBuddies(Object count) {
    return 'Selected $count travel buddies';
  }

  @override
  String loadingTravelBuddiesFailed(Object error) {
    return 'Failed to load travel buddies: $error';
  }

  @override
  String get noTravelBuddyInfo => 'No travel buddy information';

  @override
  String get findSomeoneToTravelWith => 'Find someone to travel with';

  @override
  String get dontForgetEssentials => 'Don\'t forget essentials';

  @override
  String get overview => 'Overview';

  @override
  String get budget => 'Budget';

  @override
  String get itinerary => 'Itinerary';

  @override
  String get memories => 'Memories';

  @override
  String get budgetOverview => 'Budget Overview';

  @override
  String get tapToManageExpenses => 'Tap to manage expenses';

  @override
  String get spent => 'Spent';

  @override
  String get deleteDestination => 'Delete Destination';

  @override
  String deleteDestinationConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get deleteItem => 'Delete Item';

  @override
  String deleteItemConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String errorSavingDestination(Object error) {
    return 'Error saving destination: $error';
  }

  @override
  String errorSavingDocument(Object error) {
    return 'Error saving document: $error';
  }

  @override
  String noSearchResults(String query) {
    return 'No results found for \"$query\"';
  }

  @override
  String searchError(Object error) {
    return 'Search error: $error';
  }

  @override
  String get errorLoadingProfile => 'Error loading profile';

  @override
  String get featureInDevelopment => 'Feature in development...';

  @override
  String itemsTotal(int count) {
    return '$count items total';
  }

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get availability => 'Availability (e.g., June 2024)';

  @override
  String get confirmedToTravel => 'Confirmed to travel';

  @override
  String get travelPreferences => 'Travel Preferences';

  @override
  String get adventure => 'Adventure';

  @override
  String get relaxation => 'Relaxation';

  @override
  String get culture => 'Culture';

  @override
  String get foodie => 'Foodie';

  @override
  String get nature => 'Nature';

  @override
  String get urban => 'Urban';

  @override
  String get dreamDestinations => 'Dream Destinations';

  @override
  String get addDestinationAndPressReturn => 'Add destination and press return';

  @override
  String get pleaseEnterName => 'Please enter name';

  @override
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get pleaseEnterPhone => 'Please enter phone';

  @override
  String get travelBuddyAddedSuccessfully => 'Travel buddy added successfully';

  @override
  String get travelBuddyUpdatedSuccessfully =>
      'Travel buddy updated successfully';

  @override
  String errorSavingTravelBuddy(Object error) {
    return 'Error saving travel buddy: $error';
  }

  @override
  String get editTravelBuddy => 'Edit Travel Buddy';

  @override
  String get deleteTravelBuddy => 'Delete Travel Buddy';

  @override
  String deleteTravelBuddyConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get travelBuddyDeleted => 'Travel buddy deleted successfully';

  @override
  String get addTravelBuddiesToGetStarted =>
      'Add some travel buddies to get started!';

  @override
  String get addFirstTravelBuddy => 'Add first travel buddy';

  @override
  String travelBuddiesTotal(int count) {
    return '$count travel buddies';
  }

  @override
  String get searchTravelBuddies => 'Search travel buddies...';

  @override
  String get low => 'Low';

  @override
  String get medium => 'Medium';

  @override
  String get high => 'High';

  @override
  String get budgetLevelCard => 'Budget Level';

  @override
  String get comfort => 'Comfort';

  @override
  String get luxury => 'Luxury';

  @override
  String get budgetOption => 'Budget';

  @override
  String get budgetAndExpenses => 'Budget & Expenses';

  @override
  String get totalBudget => 'Total Budget';

  @override
  String get remaining => 'Remaining';

  @override
  String get used => 'Used';

  @override
  String get expensesByCategory => 'Expenses by Category';

  @override
  String get recentExpenses => 'Recent Expenses';

  @override
  String get noExpensesYet => 'No Expenses Yet';

  @override
  String get addFirstExpenseToStartTracking =>
      'Add your first expense to start tracking';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get expenseDetails => 'Expense Details';

  @override
  String get expenseName => 'Expense Name';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get alreadyPaid => 'Already Paid';

  @override
  String get accommodation => 'Accommodation';

  @override
  String get transport => 'Transport';

  @override
  String get food => 'Food';

  @override
  String get activities => 'Activities';

  @override
  String get shopping => 'Shopping';

  @override
  String get paid => 'Paid';

  @override
  String get unpaid => 'Unpaid';

  @override
  String get noItineraryYet => 'No itinerary yet';

  @override
  String get planYourTripDayByDay => 'Plan your trip day by day';

  @override
  String get addFirstDay => 'Add First Day';

  @override
  String get addItineraryDay => 'Add Itinerary Day';

  @override
  String get editItineraryDay => 'Edit Itinerary Day';

  @override
  String get dayInformation => 'Day Information';

  @override
  String get dayTitle => 'Day Title';

  @override
  String day(int number) {
    return 'Day $number';
  }

  @override
  String get addActivity => 'Add Activity';

  @override
  String get time => 'Time';

  @override
  String get activityTitle => 'Activity Title';

  @override
  String get location => 'Location';

  @override
  String get cost => 'Cost';

  @override
  String get costOptional => 'Cost (optional)';

  @override
  String get alreadyBooked => 'Already Booked';

  @override
  String get noActivitiesPlanned => 'No activities planned';

  @override
  String get deleteDay => 'Delete Day';

  @override
  String deleteDayConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get dayDeletedSuccessfully => 'Day deleted successfully';

  @override
  String get timeExample => 'Time (e.g., 9:00 AM)';

  @override
  String days(int count) {
    return '$count days';
  }

  @override
  String get packingList => 'Packing List';

  @override
  String get progress => 'Progress';

  @override
  String get noItemsYet => 'No items yet';

  @override
  String get addItemsToPackingList => 'Add items to your packing list';

  @override
  String get essential => 'Essential';

  @override
  String get itemDeletedSuccessfully => 'Item deleted successfully';

  @override
  String get travelMemories => 'Travel Memories';

  @override
  String get noMemoriesYet => 'No memories yet';

  @override
  String get addPhotosAndStories => 'Add photos and stories from your trip';

  @override
  String get addFirstMemory => 'Add First Memory';

  @override
  String get addMemory => 'Add Memory';

  @override
  String get editMemory => 'Edit Memory';

  @override
  String get deleteMemory => 'Delete Memory';

  @override
  String deleteMemoryConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get memoryDeletedSuccessfully => 'Memory deleted successfully';

  @override
  String get memoryDetails => 'Memory Details';

  @override
  String get memoryTitle => 'Memory Title';

  @override
  String get rating => 'Rating';

  @override
  String get shareYourExperience => 'Share your experience...';

  @override
  String get items => 'items';

  @override
  String get currentTrips => 'Current Trips';

  @override
  String get templates => 'Templates';

  @override
  String get history => 'History';

  @override
  String get viewDetails => 'View Details';

  @override
  String get addItems => 'Add Items';

  @override
  String get noCurrentTrips => 'No Current Trips';

  @override
  String get planTripToStartPacking => 'Plan a trip to start packing';

  @override
  String get noTemplatesYet => 'No Templates Yet';

  @override
  String get createTemplateToReuse => 'Create templates to reuse items';

  @override
  String get noCompletedTrips => 'No completed trips yet';

  @override
  String get completedTripsWillAppearHere => 'Completed trips will appear here';

  @override
  String get pleaseEnterExpenseName => 'Please enter expense name';

  @override
  String get pleaseEnterAmount => 'Please enter amount';

  @override
  String get expenseAddedSuccessfully => 'Expense added successfully';

  @override
  String get expenseUpdatedSuccessfully => 'Expense updated successfully';

  @override
  String errorSavingExpense(Object error) {
    return 'Error saving expense: $error';
  }

  @override
  String get deleteExpense => 'Delete Expense';

  @override
  String deleteExpenseConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get viewPacking => 'View Packing';

  @override
  String get addFromTemplate => 'Add from Template';

  @override
  String get addFromTemplateDescription =>
      'Select items from templates to quickly add to packing list';

  @override
  String get selectFromTemplate => 'Select from Template';

  @override
  String get addSelected => 'Add Selected';

  @override
  String get errorLoadingItems => 'Error loading items';

  @override
  String get errorLoadingStats => 'Error loading stats';

  @override
  String get errorLoadingTemplates => 'Error loading templates';

  @override
  String get totalItems => 'Total Items';

  @override
  String get packed => 'Packed';

  @override
  String get selectAllTemplateItems => 'Select all template items';

  @override
  String get createTemplateFirst => 'Please create templates first';

  @override
  String get pleaseSelectItems => 'Please select items';

  @override
  String get addingItems => 'Adding items...';

  @override
  String get creatingTemplateItem => 'Creating template item';

  @override
  String get addToDestination => 'Add to Destination';

  @override
  String get addItemToSpecificDestination => 'Add item to specific destination';

  @override
  String get addToTemplate => 'Add to Template';

  @override
  String get addItemToTemplate => 'Add item to template';

  @override
  String get deleteTemplateItem => 'Delete Template Item';

  @override
  String deleteTemplateItemConfirm(String name) {
    return 'Are you sure you want to delete template item \"$name\"?';
  }

  @override
  String get templateItemDeletedSuccessfully =>
      'Template item deleted successfully';

  @override
  String get featureComingSoon => 'Feature coming soon';

  @override
  String get select => 'Select';

  @override
  String errorDeletingItem(Object error) {
    return 'Error deleting item: $error';
  }

  @override
  String itemsAddedSuccessfully(int count) {
    return 'Successfully added $count items';
  }

  @override
  String errorAddingItems(Object error) {
    return 'Error adding items: $error';
  }

  @override
  String get aiSmartCreateDestination => 'AI Smart Create Destination';

  @override
  String get aiPlanPreview => 'AI Plan Preview';

  @override
  String get letAiPlanYourTrip => 'Let AI Plan Your Trip';

  @override
  String get fourStepsAutoGenerate =>
      '4 steps, AI auto-generates complete itinerary';

  @override
  String get aiPlanning => 'AI is planning your trip...';

  @override
  String get aiPlanningTime => 'This may take 10-30 seconds';

  @override
  String get pleaseSelectTravelDates => 'Please select travel dates';

  @override
  String get aiFailed => 'AI generation failed';

  @override
  String remainingAiPlans(int count) {
    return '$count AI plans remaining';
  }

  @override
  String get aiQuotaExhausted =>
      'AI planning quota exhausted, please upgrade to VIP';

  @override
  String get destinationNameLabel => '1. Destination Name';

  @override
  String get destinationNameHint => 'e.g., Tokyo, Paris, New York...';

  @override
  String get budgetLevelLabel => '2. Budget Level';

  @override
  String get budgetEconomy => 'Economy';

  @override
  String get budgetComfort => 'Comfort';

  @override
  String get budgetLuxury => 'Luxury';

  @override
  String get travelDatesLabel => '3. Travel Dates';

  @override
  String get startDateLabel => 'Start Date';

  @override
  String get endDateLabel => 'End Date';

  @override
  String get selectDate => 'Select date';

  @override
  String get aiSmartPlanButton => '4. AI Smart Planning';

  @override
  String get aiAutoDetectCountry =>
      '* AI will automatically detect the destination\'s country and generate a detailed travel plan';

  @override
  String get planGeneratedSuccessfully => 'Plan generated successfully!';

  @override
  String get savePlan => 'Save Plan';

  @override
  String get savingPlan => 'Saving...';

  @override
  String get planSavedSuccess => 'Plan saved successfully!';

  @override
  String dayNumberLabel(int number) {
    return 'Day $number';
  }

  @override
  String get packagedItems => 'Packing Items';

  @override
  String get todoItems => 'To-do Items';

  @override
  String get detailedItinerary => 'Detailed Itinerary';

  @override
  String get aiGeneratedPlan => 'AI Generated Travel Plan';

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String itemsCount(int count) {
    return '$count items';
  }

  @override
  String get categoryClothing => 'Clothing';

  @override
  String get categoryElectronics => 'Electronics';

  @override
  String get categoryCosmetics => 'Cosmetics';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryAccessories => 'Accessories';

  @override
  String get categoryBooks => 'Books';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryOther => 'Other';

  @override
  String get currencySymbol => '\$';

  @override
  String get currencyCode => 'USD';

  @override
  String get todos => 'To Do';

  @override
  String get currentTodoTrips => 'Current Trips';

  @override
  String get completedTodos => 'Completed';

  @override
  String get allTodos => 'All';

  @override
  String get todoCategoryPassport => 'Passport';

  @override
  String get todoCategoryIdCard => 'ID Card';

  @override
  String get todoCategoryVisa => 'Visa';

  @override
  String get todoCategoryInsurance => 'Insurance';

  @override
  String get todoCategoryTicket => 'Flight Ticket';

  @override
  String get todoCategoryHotel => 'Hotel Booking';

  @override
  String get todoCategoryCarRental => 'Car Rental';

  @override
  String get todoCategoryOther => 'Other';

  @override
  String get todoDetails => 'To Do Details';

  @override
  String get todoStats => 'Statistics';

  @override
  String get totalTodos => 'Total';

  @override
  String get completedCount => 'Completed';

  @override
  String get pendingCount => 'Pending';

  @override
  String get highPriorityCount => 'High Priority';

  @override
  String get byCategory => 'By Category';

  @override
  String get addTodo => 'Add To Do';

  @override
  String get editTodo => 'Edit To Do';

  @override
  String get todoTitle => 'Title';

  @override
  String get todoCategory => 'Category';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get todoDescription => 'Description';

  @override
  String get todoPriority => 'Priority';

  @override
  String get todoDeadline => 'Deadline';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get markAsComplete => 'Mark as Complete';

  @override
  String get markAsIncomplete => 'Mark as Incomplete';

  @override
  String get deleteTodo => 'Delete To Do';

  @override
  String get todoDeleteConfirm => 'Delete this to do item?';

  @override
  String get noTodosYet => 'No to do items yet';

  @override
  String get noTodosInCategory => 'No to do items in this category';

  @override
  String get addFirstTodo => 'Add your first to do item';

  @override
  String get todoTitleRequired => 'Please enter a title';

  @override
  String get todoCategoryRequired => 'Please select a category';

  @override
  String get selectDeadline => 'Select Deadline';

  @override
  String get clearDeadline => 'Clear Deadline';

  @override
  String get overdue => 'Overdue';

  @override
  String get dueToday => 'Due Today';

  @override
  String get dueSoon => 'Due Soon';

  @override
  String get optional => 'Optional';

  @override
  String get updateSuccess => 'Updated successfully';

  @override
  String get addSuccess => 'Added successfully';

  @override
  String get error => 'Error';

  @override
  String get deleteSuccess => 'Deleted successfully';

  @override
  String get noPlannedDestinations => 'No planned destinations yet';

  @override
  String get createDestinationPrompt => 'Create your first travel plan!';

  @override
  String get completeFirstTrip => 'Complete your first trip!';

  @override
  String get noDestinations => 'No destinations yet';

  @override
  String get createFirstDestination => 'Start planning your trip!';
}
