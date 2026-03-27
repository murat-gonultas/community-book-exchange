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
  String get transactions => 'Vorgänge';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get submit => 'Senden';

  @override
  String get noTransactions => 'Keine Vorgänge';

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
  String get bookReservedSuccessfully => 'Buch erfolgreich reserviert';

  @override
  String get bookLoanedSuccessfully => 'Buch erfolgreich verliehen';

  @override
  String get bookReturnedSuccessfully => 'Buch erfolgreich zurückgenommen';

  @override
  String get bookGiftedSuccessfully => 'Buch erfolgreich übertragen';

  @override
  String get bookDonatedSuccessfully =>
      'Buch erfolgreich an die Community gespendet';

  @override
  String get pleaseEnterValidNumbers => 'Bitte gültige Zahlen eingeben';

  @override
  String get pleaseEnterValidUserId =>
      'Bitte eine gültige Benutzer-ID eingeben';

  @override
  String get pleaseEnterValidCommunityId =>
      'Bitte eine gültige Community-ID eingeben';

  @override
  String get reserve => 'Reservieren';

  @override
  String get loan => 'Verleihen';

  @override
  String get returnAction => 'Zurücknehmen';

  @override
  String get gift => 'Übertragen';

  @override
  String get donate => 'Spenden';

  @override
  String get reserveBook => 'Buch reservieren';

  @override
  String get loanBook => 'Buch verleihen';

  @override
  String get returnBook => 'Buch zurücknehmen';

  @override
  String get giftBook => 'Buch übertragen';

  @override
  String get donateBook => 'Buch spenden';

  @override
  String get reservedForUserId => 'Reserviert für Benutzer-ID';

  @override
  String get reservedDays => 'Reservierungstage';

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
  String get ownershipType => 'Eigentumstyp';

  @override
  String get ownerUserId => 'Eigentümer Benutzer-ID';

  @override
  String get ownerCommunityId => 'Eigentümer Community-ID';

  @override
  String get currentHolderUserId => 'Aktuelle Benutzer-ID';

  @override
  String get reservedForUserIdLabel => 'Reserviert für Benutzer-ID';

  @override
  String get reservedUntil => 'Reserviert bis';

  @override
  String get loanStart => 'Leihbeginn';

  @override
  String get dueAt => 'Fällig am';

  @override
  String get whyActionsUnavailable =>
      'Warum sind einige Aktionen nicht verfügbar?';

  @override
  String hintReserveUnavailable(String status) {
    return 'Reservieren ist nur möglich, wenn das Buch den Status $status hat.';
  }

  @override
  String hintLoanUnavailable(String availableStatus, String reservedStatus) {
    return 'Verleihen ist nur möglich, wenn das Buch den Status $availableStatus oder $reservedStatus hat.';
  }

  @override
  String hintReturnUnavailable(String status) {
    return 'Zurücknehmen ist nur möglich, wenn das Buch den Status $status hat.';
  }

  @override
  String hintGiftUnavailable(String status, String ownership) {
    return 'Übertragen ist nur für $ownership Bücher im Status $status möglich.';
  }

  @override
  String hintDonateUnavailable(String status, String ownership) {
    return 'Spenden ist nur für $ownership Bücher im Status $status möglich.';
  }

  @override
  String hintReservedLoanRule(String reservedStatus) {
    return 'Bei Büchern mit Status $reservedStatus ist Verleihen aktiviert, aber das Backend erlaubt das Verleihen nur an den reservierten Benutzer.';
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
  String get statusReserved => 'Reserviert';

  @override
  String get statusOnLoan => 'Verliehen';

  @override
  String get ownershipUser => 'Privatbesitz';

  @override
  String get ownershipCommunity => 'Gemeinschaftseigentum';

  @override
  String get transactionReservation => 'Reservierung';

  @override
  String get transactionLoan => 'Ausleihe';

  @override
  String get transactionReturn => 'Rückgabe';

  @override
  String get transactionGift => 'Übergabe';

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
