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
  String get hintReserveUnavailable =>
      'Reservieren ist nur möglich, wenn das Buch den Status AVAILABLE hat.';

  @override
  String get hintLoanUnavailable =>
      'Verleihen ist nur möglich, wenn das Buch den Status AVAILABLE oder RESERVED hat.';

  @override
  String get hintReturnUnavailable =>
      'Zurücknehmen ist nur möglich, wenn das Buch den Status ON_LOAN hat.';

  @override
  String get hintGiftUnavailable =>
      'Übertragen ist nur für USER-eigene Bücher im Status AVAILABLE möglich.';

  @override
  String get hintDonateUnavailable =>
      'Spenden ist nur für USER-eigene Bücher im Status AVAILABLE möglich.';

  @override
  String get hintReservedLoanRule =>
      'Bei RESERVED-Büchern ist Verleihen aktiviert, aber das Backend erlaubt das Verleihen nur an den reservierten Benutzer.';

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
  String get noBooksFound => 'Keine Bücher gefunden';

  @override
  String get unknownAuthor => 'Unbekannt';

  @override
  String get systemLanguage => 'Systemsprache';

  @override
  String get german => 'Deutsch';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Türkçe';
}
