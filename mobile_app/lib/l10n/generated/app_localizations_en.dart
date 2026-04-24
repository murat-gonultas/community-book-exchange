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
  String get bookLoanedSuccessfully => 'Book loaned successfully';

  @override
  String get bookReturnedSuccessfully => 'Book returned successfully';

  @override
  String get bookGiftedSuccessfully => 'Book gifted successfully';

  @override
  String get bookDonatedSuccessfully => 'Book donated successfully';

  @override
  String get bookExtendedSuccessfully => 'Loan extended successfully.';

  @override
  String get pleaseEnterValidNumbers => 'Please enter valid numbers';

  @override
  String get pleaseEnterValidUserId => 'Please enter a valid user ID';

  @override
  String get pleaseEnterValidCommunityId => 'Please enter a valid community ID';

  @override
  String get loan => 'Loan';

  @override
  String get returnAction => 'Return';

  @override
  String get gift => 'Gift';

  @override
  String get donate => 'Donate';

  @override
  String get extendLoan => 'Extend loan';

  @override
  String get loanBook => 'Loan Book';

  @override
  String get returnBook => 'Return Book';

  @override
  String get giftBook => 'Gift Book';

  @override
  String get donateBook => 'Donate Book';

  @override
  String get note => 'Note';

  @override
  String get loanedToUserId => 'Loaned To User ID';

  @override
  String get returnedByUserId => 'Returned By User ID';

  @override
  String get newOwnerUserId => 'New Owner User ID';

  @override
  String get requesterUserId => 'Requester user';

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
  String get loanStart => 'Loan Start';

  @override
  String get dueAt => 'Due At';

  @override
  String get loanExtendedCount => 'Extensions';

  @override
  String get overdueDaysLabel => 'Overdue days';

  @override
  String get overdueBadge => 'Overdue';

  @override
  String get whyActionsUnavailable => 'Why are some actions unavailable?';

  @override
  String hintLoanUnavailable(String availableStatus) {
    return 'Loan is only available when the book is $availableStatus.';
  }

  @override
  String hintReturnUnavailable(String status) {
    return 'Return is only available when the book is $status.';
  }

  @override
  String hintGiftUnavailable(String ownership) {
    return 'Gift is only available for $ownership books.';
  }

  @override
  String hintDonateUnavailable(String ownership) {
    return 'Donate is only available for $ownership books.';
  }

  @override
  String hintExtendUnavailableNotOnLoan(String status) {
    return 'Extension is only available when the book status is $status.';
  }

  @override
  String get hintExtendUnavailableOverdue =>
      'Overdue loans cannot be extended.';

  @override
  String get hintExtendUnavailableMaxReached =>
      'Maximum number of loan extensions reached.';

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
  String get noBooksFound => 'No books match your current filters.';

  @override
  String get unknownAuthor => 'Unknown author';

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
  String get statusOnLoan => 'On loan';

  @override
  String get ownershipUser => 'User-owned';

  @override
  String get ownershipCommunity => 'Community-owned';

  @override
  String get transactionLoan => 'Loan';

  @override
  String get transactionReturn => 'Return';

  @override
  String get transactionGift => 'Gift';

  @override
  String get transactionDonation => 'Donation';

  @override
  String get transactionLoanExtension => 'Loan extension';

  @override
  String get booksSearchHint => 'Search by title or author';

  @override
  String get filterStatus => 'Status';

  @override
  String get filterOwnership => 'Ownership';

  @override
  String get allStatuses => 'All statuses';

  @override
  String get allOwnershipTypes => 'All ownership types';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get bookListTitle => 'Books';

  @override
  String bookOverdueMessage(int days) {
    return 'This book is overdue by $days days.';
  }

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get authNoAccountYetRegister => 'No account yet? Register';

  @override
  String get authAlreadyHaveAccountLogin => 'Already have an account? Login';

  @override
  String get authVerificationRequiredNote =>
      'Note: if your backend requires email verification, register first and then verify before logging in.';

  @override
  String get navMyRequests => 'My Requests';

  @override
  String get navIncomingRequests => 'Incoming Requests';

  @override
  String get borrowRequestAction => 'Borrow request';

  @override
  String get borrowRequestCreateTitle => 'Create borrow request';

  @override
  String get borrowRequestCreatedSuccess =>
      'Borrow request created successfully.';

  @override
  String get borrowRequestHintSignInRequired =>
      'You must be signed in to create a borrow request.';

  @override
  String get borrowRequestHintAvailableOnly =>
      'Borrow requests can only be created for available books.';

  @override
  String get borrowRequestHintOwnBook =>
      'You cannot create a borrow request for your own book.';

  @override
  String get myBorrowRequestsTitle => 'My Borrow Requests';

  @override
  String get myBorrowRequestsEmpty =>
      'You do not have any borrow requests yet.';

  @override
  String myBorrowRequestsLoadError(Object error) {
    return 'Failed to load your borrow requests.\n\n$error';
  }

  @override
  String get borrowRequestCancelTitle => 'Cancel borrow request';

  @override
  String get borrowRequestCancelledSuccess =>
      'Borrow request cancelled successfully.';

  @override
  String get incomingBorrowRequestsTitle => 'Incoming Borrow Requests';

  @override
  String get incomingBorrowRequestsEmpty =>
      'There are no incoming borrow requests right now.';

  @override
  String incomingBorrowRequestsLoadError(Object error) {
    return 'Failed to load incoming borrow requests.\n\n$error';
  }

  @override
  String get borrowRequestRejectTitle => 'Reject borrow request';

  @override
  String get borrowRequestApproveTitle => 'Approve borrow request';

  @override
  String get borrowRequestApprovedSuccess =>
      'Borrow request approved successfully.';

  @override
  String get borrowRequestRejectedSuccess =>
      'Borrow request rejected successfully.';

  @override
  String get borrowRequestFulfillTitle => 'Fulfill borrow request';

  @override
  String get borrowRequestFulfilledSuccess =>
      'Borrow request fulfilled and converted to loan.';
}
