// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Community Book Exchange';

  @override
  String bookTitleWithId(int bookId) {
    return 'Kitap #$bookId';
  }

  @override
  String get actions => 'İşlemler';

  @override
  String get transactions => 'İşlem geçmişi';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get cancel => 'İptal';

  @override
  String get submit => 'Onayla';

  @override
  String get noTransactions => 'İşlem yok';

  @override
  String get notAvailable => '-';

  @override
  String failedToLoadBookDetail(String error) {
    return 'Kitap detayı yüklenemedi.\n$error';
  }

  @override
  String failedToLoadBooks(String error) {
    return 'Kitaplar yüklenemedi.\n$error';
  }

  @override
  String actionFailed(String error) {
    return 'İşlem başarısız oldu: $error';
  }

  @override
  String get bookLoanedSuccessfully => 'Kitap başarıyla ödünç verildi';

  @override
  String get bookReturnedSuccessfully => 'Kitap başarıyla iade alındı';

  @override
  String get bookGiftedSuccessfully => 'Kitap başarıyla devredildi';

  @override
  String get bookDonatedSuccessfully => 'Kitap başarıyla bağışlandı';

  @override
  String get pleaseEnterValidNumbers => 'Lütfen geçerli sayılar girin';

  @override
  String get pleaseEnterValidUserId => 'Lütfen geçerli bir kullanıcı ID girin';

  @override
  String get pleaseEnterValidCommunityId =>
      'Lütfen geçerli bir topluluk ID girin';

  @override
  String get loan => 'Ödünç ver';

  @override
  String get returnAction => 'İade al';

  @override
  String get gift => 'Devret';

  @override
  String get donate => 'Bağışla';

  @override
  String get loanBook => 'Kitabı ödünç ver';

  @override
  String get returnBook => 'Kitabı iade al';

  @override
  String get giftBook => 'Kitabı devret';

  @override
  String get donateBook => 'Kitabı bağışla';

  @override
  String get note => 'Not';

  @override
  String get loanedToUserId => 'Ödünç verilen kullanıcı ID';

  @override
  String get loanDays => 'Ödünç gün sayısı';

  @override
  String get returnedByUserId => 'İade eden kullanıcı ID';

  @override
  String get newOwnerUserId => 'Yeni sahip kullanıcı ID';

  @override
  String get communityId => 'Topluluk ID';

  @override
  String get author => 'Yazar';

  @override
  String get isbn => 'ISBN';

  @override
  String get language => 'Dil';

  @override
  String get category => 'Kategori';

  @override
  String get condition => 'Durum';

  @override
  String get notes => 'Notlar';

  @override
  String get status => 'Statü';

  @override
  String get ownershipType => 'Sahiplik türü';

  @override
  String get ownerUserId => 'Sahip kullanıcı ID';

  @override
  String get ownerCommunityId => 'Sahip topluluk ID';

  @override
  String get currentHolderUserId => 'Şu an elinde tutan kullanıcı ID';

  @override
  String get loanStart => 'Ödünç başlangıcı';

  @override
  String get dueAt => 'Son teslim tarihi';

  @override
  String get whyActionsUnavailable => 'Bazı işlemler neden kullanılamıyor?';

  @override
  String hintLoanUnavailable(String availableStatus) {
    return 'Ödünç verme yalnızca kitap $availableStatus durumundayken mümkündür.';
  }

  @override
  String hintReturnUnavailable(String status) {
    return 'İade alma yalnızca kitap $status durumundayken mümkündür.';
  }

  @override
  String hintGiftUnavailable(String ownership) {
    return 'Devretme yalnızca $ownership kitaplar için mümkündür.';
  }

  @override
  String hintDonateUnavailable(String ownership) {
    return 'Bağışlama yalnızca $ownership kitaplar için mümkündür.';
  }

  @override
  String get idLabel => 'ID';

  @override
  String get fromUser => 'Gönderen kullanıcı';

  @override
  String get toUser => 'Alan kullanıcı';

  @override
  String get start => 'Başlangıç';

  @override
  String get end => 'Bitiş';

  @override
  String get books => 'Kitaplar';

  @override
  String get noBooksFound => 'Mevcut filtrelere uygun kitap bulunamadı.';

  @override
  String get unknownAuthor => 'Yazar bilinmiyor';

  @override
  String get systemLanguage => 'Sistem dili';

  @override
  String get german => 'Deutsch';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Türkçe';

  @override
  String get statusAvailable => 'Uygun';

  @override
  String get statusOnLoan => 'Ödünçte';

  @override
  String get ownershipUser => 'Kullanıcıya ait';

  @override
  String get ownershipCommunity => 'Topluluğa ait';

  @override
  String get transactionLoan => 'Ödünç verme';

  @override
  String get transactionReturn => 'İade';

  @override
  String get transactionGift => 'Devir';

  @override
  String get transactionDonation => 'Bağış';

  @override
  String get booksSearchHint => 'Başlık veya yazara göre ara';

  @override
  String get filterStatus => 'Durum';

  @override
  String get filterOwnership => 'Sahiplik';

  @override
  String get allStatuses => 'Tüm durumlar';

  @override
  String get allOwnershipTypes => 'Tüm sahiplik türleri';

  @override
  String get clearFilters => 'Filtreleri temizle';

  @override
  String get bookListTitle => 'Kitaplar';
}
