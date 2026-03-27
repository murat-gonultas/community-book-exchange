// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Community Book Exchange';

  @override
  String bookTitleWithId(int bookId) {
    return 'Buch #$bookId';
  }

  @override
  String get actions => 'Aktionen';

  @override
  String get transactions => 'Transaktionen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get submit => 'Bestätigen';

  @override
  String get noTransactions => 'Keine Transaktionen';

  @override
  String get notAvailable => '-';

  @override
  String failedToLoadBookDetail(String error) {
    return 'Buchdetails konnten nicht geladen werden.\n$error';
  }

  @override
  String failedToLoadBooks(String error) {
    return 'Bücher konnten nicht geladen werden.\n$error';
  }

  @override
  String actionFailed(String error) {
    return 'Aktion fehlgeschlagen: $error';
  }

  @override
  String get bookLoanedSuccessfully => 'Buch erfolgreich verliehen';

  @override
  String get bookReturnedSuccessfully => 'Buch erfolgreich zurückgenommen';

  @override
  String get bookGiftedSuccessfully => 'Buch erfolgreich übertragen';

  @override
  String get bookDonatedSuccessfully => 'Buch erfolgreich gespendet';

  @override
  String get pleaseEnterValidNumbers => 'Bitte gültige Zahlen eingeben';

  @override
  String get pleaseEnterValidUserId =>
      'Bitte eine gültige Benutzer-ID eingeben';

  @override
  String get pleaseEnterValidCommunityId =>
      'Bitte eine gültige Community-ID eingeben';

  @override
  String get loan => 'Verleihen';

  @override
  String get returnAction => 'Zurücknehmen';

  @override
  String get gift => 'Übertragen';

  @override
  String get donate => 'Spenden';

  @override
  String get loanBook => 'Buch verleihen';

  @override
  String get returnBook => 'Buch zurücknehmen';

  @override
  String get giftBook => 'Buch übertragen';

  @override
  String get donateBook => 'Buch spenden';

  @override
  String get note => 'Notiz';

  @override
  String get loanedToUserId => 'Verliehen an Benutzer-ID';

  @override
  String get loanDays => 'Leihdauer in Tagen';

  @override
  String get returnedByUserId => 'Zurückgegeben von Benutzer-ID';

  @override
  String get newOwnerUserId => 'Neue Eigentümer-Benutzer-ID';

  @override
  String get communityId => 'Community-ID';

  @override
  String get author => 'Autor';

  @override
  String get isbn => 'ISBN';

  @override
  String get language => 'Sprache';

  @override
  String get category => 'Kategorie';

  @override
  String get condition => 'Zustand';

  @override
  String get notes => 'Notizen';

  @override
  String get status => 'Status';

  @override
  String get ownershipType => 'Besitzart';

  @override
  String get ownerUserId => 'Eigentümer-Benutzer-ID';

  @override
  String get ownerCommunityId => 'Eigentümer-Community-ID';

  @override
  String get currentHolderUserId => 'Aktueller Besitzer-Benutzer-ID';

  @override
  String get loanStart => 'Leihbeginn';

  @override
  String get dueAt => 'Fällig am';

  @override
  String get whyActionsUnavailable =>
      'Warum sind einige Aktionen nicht verfügbar?';

  @override
  String hintLoanUnavailable(String availableStatus) {
    return 'Verleihen ist nur möglich, wenn das Buch den Status $availableStatus hat.';
  }

  @override
  String hintReturnUnavailable(String status) {
    return 'Zurücknehmen ist nur möglich, wenn das Buch den Status $status hat.';
  }

  @override
  String hintGiftUnavailable(String ownership) {
    return 'Übertragen ist nur für $ownership Bücher möglich.';
  }

  @override
  String hintDonateUnavailable(String ownership) {
    return 'Spenden ist nur für $ownership Bücher möglich.';
  }

  @override
  String get idLabel => 'ID';

  @override
  String get fromUser => 'Von Benutzer';

  @override
  String get toUser => 'An Benutzer';

  @override
  String get start => 'Beginn';

  @override
  String get end => 'Ende';

  @override
  String get books => 'Bücher';

  @override
  String get noBooksFound => 'Keine Bücher passen zu den aktuellen Filtern.';

  @override
  String get unknownAuthor => 'Unbekannter Autor';

  @override
  String get systemLanguage => 'Systemsprache';

  @override
  String get german => 'Deutsch';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Türkçe';

  @override
  String get statusAvailable => 'Verfügbar';

  @override
  String get statusOnLoan => 'Verliehen';

  @override
  String get ownershipUser => 'In Benutzerbesitz';

  @override
  String get ownershipCommunity => 'In Gemeinschaftsbesitz';

  @override
  String get transactionLoan => 'Ausleihe';

  @override
  String get transactionReturn => 'Rückgabe';

  @override
  String get transactionGift => 'Übertragung';

  @override
  String get transactionDonation => 'Spende';

  @override
  String get booksSearchHint => 'Nach Titel oder Autor suchen';

  @override
  String get filterStatus => 'Status';

  @override
  String get filterOwnership => 'Besitz';

  @override
  String get allStatuses => 'Alle Status';

  @override
  String get allOwnershipTypes => 'Alle Besitzarten';

  @override
  String get clearFilters => 'Filter zurücksetzen';

  @override
  String get bookListTitle => 'Bücher';
}
