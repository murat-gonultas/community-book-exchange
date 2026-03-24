// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Community Book Exchange';

  @override
  String bookTitleWithId(int bookId) {
    return 'Book #$bookId';
  }

  @override
  String get actions => 'Actions';

  @override
  String get transactions => 'Transactions';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get noTransactions => 'No transactions';

  @override
  String get notAvailable => '-';

  @override
  String failedToLoadBookDetail(String error) {
    return 'Failed to load book detail.\n$error';
  }

  @override
  String failedToLoadBooks(String error) {
    return 'Failed to load books.\n$error';
  }

  @override
  String actionFailed(String error) {
    return 'Action failed: $error';
  }

  @override
  String get bookReservedSuccessfully => 'Book reserved successfully';

  @override
  String get bookLoanedSuccessfully => 'Book loaned successfully';

  @override
  String get bookReturnedSuccessfully => 'Book returned successfully';

  @override
  String get bookGiftedSuccessfully => 'Book gifted successfully';

  @override
  String get bookDonatedSuccessfully => 'Book donated successfully';

  @override
  String get pleaseEnterValidNumbers => 'Please enter valid numbers';

  @override
  String get pleaseEnterValidUserId => 'Please enter a valid user ID';

  @override
  String get pleaseEnterValidCommunityId => 'Please enter a valid community ID';

  @override
  String get reserve => 'Reserve';

  @override
  String get loan => 'Loan';

  @override
  String get returnAction => 'Return';

  @override
  String get gift => 'Gift';

  @override
  String get donate => 'Donate';

  @override
  String get reserveBook => 'Reserve Book';

  @override
  String get loanBook => 'Loan Book';

  @override
  String get returnBook => 'Return Book';

  @override
  String get giftBook => 'Gift Book';

  @override
  String get donateBook => 'Donate Book';

  @override
  String get reservedForUserId => 'Reserved For User ID';

  @override
  String get reservedDays => 'Reserved Days';

  @override
  String get note => 'Note';

  @override
  String get loanedToUserId => 'Loaned To User ID';

  @override
  String get loanDays => 'Loan Days';

  @override
  String get returnedByUserId => 'Returned By User ID';

  @override
  String get newOwnerUserId => 'New Owner User ID';

  @override
  String get communityId => 'Community ID';

  @override
  String get author => 'Author';

  @override
  String get isbn => 'ISBN';

  @override
  String get language => 'Language';

  @override
  String get category => 'Category';

  @override
  String get condition => 'Condition';

  @override
  String get notes => 'Notes';

  @override
  String get status => 'Status';

  @override
  String get ownershipType => 'Ownership Type';

  @override
  String get ownerUserId => 'Owner User ID';

  @override
  String get ownerCommunityId => 'Owner Community ID';

  @override
  String get currentHolderUserId => 'Current Holder User ID';

  @override
  String get reservedForUserIdLabel => 'Reserved For User ID';

  @override
  String get reservedUntil => 'Reserved Until';

  @override
  String get loanStart => 'Loan Start';

  @override
  String get dueAt => 'Due At';

  @override
  String get whyActionsUnavailable => 'Why are some actions unavailable?';

  @override
  String get hintReserveUnavailable =>
      'Reserve is only available when the book is AVAILABLE.';

  @override
  String get hintLoanUnavailable =>
      'Loan is only available when the book is AVAILABLE or RESERVED.';

  @override
  String get hintReturnUnavailable =>
      'Return is only available when the book is ON_LOAN.';

  @override
  String get hintGiftUnavailable =>
      'Gift is only available for USER-owned books that are AVAILABLE.';

  @override
  String get hintDonateUnavailable =>
      'Donate is only available for USER-owned books that are AVAILABLE.';

  @override
  String get hintReservedLoanRule =>
      'Loan is enabled for RESERVED books, but the backend only allows lending to the reserved user.';

  @override
  String get idLabel => 'ID';

  @override
  String get fromUser => 'From User';

  @override
  String get toUser => 'To User';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get books => 'Books';

  @override
  String get noBooksFound => 'No books found';

  @override
  String get unknownAuthor => 'Unknown';

  @override
  String get systemLanguage => 'System language';

  @override
  String get german => 'Deutsch';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Türkçe';

  @override
  String get statusAvailable => 'Available';

  @override
  String get statusReserved => 'Reserved';

  @override
  String get statusOnLoan => 'On loan';

  @override
  String get ownershipUser => 'User-owned';

  @override
  String get ownershipCommunity => 'Community-owned';

  @override
  String get transactionReservation => 'Reservation';

  @override
  String get transactionLoan => 'Loan';

  @override
  String get transactionReturn => 'Return';

  @override
  String get transactionGift => 'Gift';

  @override
  String get transactionDonation => 'Donation';
}
