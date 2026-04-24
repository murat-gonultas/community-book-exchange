import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Community Book Exchange'**
  String get appTitle;

  /// No description provided for @bookTitleWithId.
  ///
  /// In en, this message translates to:
  /// **'Book #{bookId}'**
  String bookTitleWithId(int bookId);

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get noTransactions;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'-'**
  String get notAvailable;

  /// No description provided for @failedToLoadBookDetail.
  ///
  /// In en, this message translates to:
  /// **'Failed to load book detail.\n{error}'**
  String failedToLoadBookDetail(String error);

  /// No description provided for @failedToLoadBooks.
  ///
  /// In en, this message translates to:
  /// **'Failed to load books.\n{error}'**
  String failedToLoadBooks(String error);

  /// No description provided for @actionFailed.
  ///
  /// In en, this message translates to:
  /// **'Action failed: {error}'**
  String actionFailed(String error);

  /// No description provided for @bookLoanedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Book loaned successfully'**
  String get bookLoanedSuccessfully;

  /// No description provided for @bookReturnedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Book returned successfully'**
  String get bookReturnedSuccessfully;

  /// No description provided for @bookGiftedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Book gifted successfully'**
  String get bookGiftedSuccessfully;

  /// No description provided for @bookDonatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Book donated successfully'**
  String get bookDonatedSuccessfully;

  /// No description provided for @bookExtendedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Loan extended successfully.'**
  String get bookExtendedSuccessfully;

  /// No description provided for @pleaseEnterValidNumbers.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid numbers'**
  String get pleaseEnterValidNumbers;

  /// No description provided for @pleaseEnterValidUserId.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid user ID'**
  String get pleaseEnterValidUserId;

  /// No description provided for @pleaseEnterValidCommunityId.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid community ID'**
  String get pleaseEnterValidCommunityId;

  /// No description provided for @loan.
  ///
  /// In en, this message translates to:
  /// **'Loan'**
  String get loan;

  /// No description provided for @returnAction.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnAction;

  /// No description provided for @gift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get gift;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// No description provided for @extendLoan.
  ///
  /// In en, this message translates to:
  /// **'Extend loan'**
  String get extendLoan;

  /// No description provided for @loanBook.
  ///
  /// In en, this message translates to:
  /// **'Loan Book'**
  String get loanBook;

  /// No description provided for @returnBook.
  ///
  /// In en, this message translates to:
  /// **'Return Book'**
  String get returnBook;

  /// No description provided for @giftBook.
  ///
  /// In en, this message translates to:
  /// **'Gift Book'**
  String get giftBook;

  /// No description provided for @donateBook.
  ///
  /// In en, this message translates to:
  /// **'Donate Book'**
  String get donateBook;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @loanedToUserId.
  ///
  /// In en, this message translates to:
  /// **'Loaned To User ID'**
  String get loanedToUserId;

  /// No description provided for @returnedByUserId.
  ///
  /// In en, this message translates to:
  /// **'Returned By User ID'**
  String get returnedByUserId;

  /// No description provided for @newOwnerUserId.
  ///
  /// In en, this message translates to:
  /// **'New Owner User ID'**
  String get newOwnerUserId;

  /// No description provided for @requesterUserId.
  ///
  /// In en, this message translates to:
  /// **'Requester user'**
  String get requesterUserId;

  /// No description provided for @communityId.
  ///
  /// In en, this message translates to:
  /// **'Community ID'**
  String get communityId;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @isbn.
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get isbn;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @ownershipType.
  ///
  /// In en, this message translates to:
  /// **'Ownership Type'**
  String get ownershipType;

  /// No description provided for @ownerUserId.
  ///
  /// In en, this message translates to:
  /// **'Owner User ID'**
  String get ownerUserId;

  /// No description provided for @ownerCommunityId.
  ///
  /// In en, this message translates to:
  /// **'Owner Community ID'**
  String get ownerCommunityId;

  /// No description provided for @currentHolderUserId.
  ///
  /// In en, this message translates to:
  /// **'Current Holder User ID'**
  String get currentHolderUserId;

  /// No description provided for @loanStart.
  ///
  /// In en, this message translates to:
  /// **'Loan Start'**
  String get loanStart;

  /// No description provided for @dueAt.
  ///
  /// In en, this message translates to:
  /// **'Due At'**
  String get dueAt;

  /// No description provided for @loanExtendedCount.
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get loanExtendedCount;

  /// No description provided for @overdueDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Overdue days'**
  String get overdueDaysLabel;

  /// No description provided for @overdueBadge.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdueBadge;

  /// No description provided for @whyActionsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Why are some actions unavailable?'**
  String get whyActionsUnavailable;

  /// No description provided for @hintLoanUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Loan is only available when the book is {availableStatus}.'**
  String hintLoanUnavailable(String availableStatus);

  /// No description provided for @hintReturnUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Return is only available when the book is {status}.'**
  String hintReturnUnavailable(String status);

  /// No description provided for @hintGiftUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Gift is only available for {ownership} books.'**
  String hintGiftUnavailable(String ownership);

  /// No description provided for @hintDonateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Donate is only available for {ownership} books.'**
  String hintDonateUnavailable(String ownership);

  /// No description provided for @hintExtendUnavailableNotOnLoan.
  ///
  /// In en, this message translates to:
  /// **'Extension is only available when the book status is {status}.'**
  String hintExtendUnavailableNotOnLoan(String status);

  /// No description provided for @hintExtendUnavailableOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue loans cannot be extended.'**
  String get hintExtendUnavailableOverdue;

  /// No description provided for @hintExtendUnavailableMaxReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum number of loan extensions reached.'**
  String get hintExtendUnavailableMaxReached;

  /// No description provided for @idLabel.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get idLabel;

  /// No description provided for @fromUser.
  ///
  /// In en, this message translates to:
  /// **'From User'**
  String get fromUser;

  /// No description provided for @toUser.
  ///
  /// In en, this message translates to:
  /// **'To User'**
  String get toUser;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @books.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get books;

  /// No description provided for @noBooksFound.
  ///
  /// In en, this message translates to:
  /// **'No books match your current filters.'**
  String get noBooksFound;

  /// No description provided for @unknownAuthor.
  ///
  /// In en, this message translates to:
  /// **'Unknown author'**
  String get unknownAuthor;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get systemLanguage;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @statusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get statusAvailable;

  /// No description provided for @statusOnLoan.
  ///
  /// In en, this message translates to:
  /// **'On loan'**
  String get statusOnLoan;

  /// No description provided for @ownershipUser.
  ///
  /// In en, this message translates to:
  /// **'User-owned'**
  String get ownershipUser;

  /// No description provided for @ownershipCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community-owned'**
  String get ownershipCommunity;

  /// No description provided for @transactionLoan.
  ///
  /// In en, this message translates to:
  /// **'Loan'**
  String get transactionLoan;

  /// No description provided for @transactionReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get transactionReturn;

  /// No description provided for @transactionGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get transactionGift;

  /// No description provided for @transactionDonation.
  ///
  /// In en, this message translates to:
  /// **'Donation'**
  String get transactionDonation;

  /// No description provided for @transactionLoanExtension.
  ///
  /// In en, this message translates to:
  /// **'Loan extension'**
  String get transactionLoanExtension;

  /// No description provided for @booksSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by title or author'**
  String get booksSearchHint;

  /// No description provided for @filterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get filterStatus;

  /// No description provided for @filterOwnership.
  ///
  /// In en, this message translates to:
  /// **'Ownership'**
  String get filterOwnership;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get allStatuses;

  /// No description provided for @allOwnershipTypes.
  ///
  /// In en, this message translates to:
  /// **'All ownership types'**
  String get allOwnershipTypes;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @bookListTitle.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get bookListTitle;

  /// No description provided for @bookOverdueMessage.
  ///
  /// In en, this message translates to:
  /// **'This book is overdue by {days} days.'**
  String bookOverdueMessage(int days);

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @authNoAccountYetRegister.
  ///
  /// In en, this message translates to:
  /// **'No account yet? Register'**
  String get authNoAccountYetRegister;

  /// No description provided for @authAlreadyHaveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get authAlreadyHaveAccountLogin;

  /// No description provided for @authVerificationRequiredNote.
  ///
  /// In en, this message translates to:
  /// **'Note: if your backend requires email verification, register first and then verify before logging in.'**
  String get authVerificationRequiredNote;

  /// No description provided for @navMyRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get navMyRequests;

  /// No description provided for @navIncomingRequests.
  ///
  /// In en, this message translates to:
  /// **'Incoming Requests'**
  String get navIncomingRequests;

  /// No description provided for @borrowRequestAction.
  ///
  /// In en, this message translates to:
  /// **'Borrow request'**
  String get borrowRequestAction;

  /// No description provided for @borrowRequestCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create borrow request'**
  String get borrowRequestCreateTitle;

  /// No description provided for @borrowRequestCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Borrow request created successfully.'**
  String get borrowRequestCreatedSuccess;

  /// No description provided for @borrowRequestHintSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'You must be signed in to create a borrow request.'**
  String get borrowRequestHintSignInRequired;

  /// No description provided for @borrowRequestHintAvailableOnly.
  ///
  /// In en, this message translates to:
  /// **'Borrow requests can only be created for available books.'**
  String get borrowRequestHintAvailableOnly;

  /// No description provided for @borrowRequestHintOwnBook.
  ///
  /// In en, this message translates to:
  /// **'You cannot create a borrow request for your own book.'**
  String get borrowRequestHintOwnBook;

  /// No description provided for @myBorrowRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Borrow Requests'**
  String get myBorrowRequestsTitle;

  /// No description provided for @myBorrowRequestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You do not have any borrow requests yet.'**
  String get myBorrowRequestsEmpty;

  /// No description provided for @myBorrowRequestsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load your borrow requests.\n\n{error}'**
  String myBorrowRequestsLoadError(Object error);

  /// No description provided for @borrowRequestCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel borrow request'**
  String get borrowRequestCancelTitle;

  /// No description provided for @borrowRequestCancelledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Borrow request cancelled successfully.'**
  String get borrowRequestCancelledSuccess;

  /// No description provided for @incomingBorrowRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Incoming Borrow Requests'**
  String get incomingBorrowRequestsTitle;

  /// No description provided for @incomingBorrowRequestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no incoming borrow requests right now.'**
  String get incomingBorrowRequestsEmpty;

  /// No description provided for @incomingBorrowRequestsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load incoming borrow requests.\n\n{error}'**
  String incomingBorrowRequestsLoadError(Object error);

  /// No description provided for @borrowRequestRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject borrow request'**
  String get borrowRequestRejectTitle;

  /// No description provided for @borrowRequestApproveTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve borrow request'**
  String get borrowRequestApproveTitle;

  /// No description provided for @borrowRequestApprovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Borrow request approved successfully.'**
  String get borrowRequestApprovedSuccess;

  /// No description provided for @borrowRequestRejectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Borrow request rejected successfully.'**
  String get borrowRequestRejectedSuccess;

  /// No description provided for @borrowRequestFulfillTitle.
  ///
  /// In en, this message translates to:
  /// **'Fulfill borrow request'**
  String get borrowRequestFulfillTitle;

  /// No description provided for @borrowRequestFulfilledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Borrow request fulfilled and converted to loan.'**
  String get borrowRequestFulfilledSuccess;
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
      <String>['de', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
