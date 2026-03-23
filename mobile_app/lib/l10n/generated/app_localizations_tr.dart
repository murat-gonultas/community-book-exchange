// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Topluluk Kitap Değişimi';

  @override
  String bookTitleWithId(int bookId) {
    return 'Kitap #$bookId';
  }

  @override
  String get actions => 'İşlemler';

  @override
  String get transactions => 'Hareketler';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get cancel => 'İptal';

  @override
  String get submit => 'Gönder';

  @override
  String get noTransactions => 'Henüz işlem yok';

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
  String get bookReservedSuccessfully => 'Kitap başarıyla rezerve edildi';

  @override
  String get bookLoanedSuccessfully => 'Kitap başarıyla ödünç verildi';

  @override
  String get bookReturnedSuccessfully => 'Kitap başarıyla iade edildi';

  @override
  String get bookGiftedSuccessfully => 'Kitap başarıyla devredildi';

  @override
  String get bookDonatedSuccessfully => 'Kitap başarıyla topluluğa bağışlandı';

  @override
  String get pleaseEnterValidNumbers => 'Lütfen geçerli sayılar girin';

  @override
  String get pleaseEnterValidUserId => 'Lütfen geçerli bir kullanıcı ID girin';

  @override
  String get pleaseEnterValidCommunityId =>
      'Lütfen geçerli bir topluluk ID girin';

  @override
  String get reserve => 'Rezerve Et';

  @override
  String get loan => 'Ödünç Ver';

  @override
  String get returnAction => 'İade Al';

  @override
  String get gift => 'Devret';

  @override
  String get donate => 'Bağışla';

  @override
  String get reserveBook => 'Kitabı Rezerve Et';

  @override
  String get loanBook => 'Kitabı Ödünç Ver';

  @override
  String get returnBook => 'Kitabı İade Al';

  @override
  String get giftBook => 'Kitabı Devret';

  @override
  String get donateBook => 'Kitabı Bağışla';

  @override
  String get reservedForUserId => 'Rezerve Edilen Kullanıcı ID';

  @override
  String get reservedDays => 'Rezervasyon Günü';

  @override
  String get note => 'Not';

  @override
  String get loanedToUserId => 'Ödünç Verilen Kullanıcı ID';

  @override
  String get loanDays => 'Ödünç Gün Sayısı';

  @override
  String get returnedByUserId => 'İade Eden Kullanıcı ID';

  @override
  String get newOwnerUserId => 'Yeni Sahip Kullanıcı ID';

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
  String get ownershipType => 'Sahiplik Türü';

  @override
  String get ownerUserId => 'Sahip Kullanıcı ID';

  @override
  String get ownerCommunityId => 'Sahip Topluluk ID';

  @override
  String get currentHolderUserId => 'Şu Anki Kullanıcı ID';

  @override
  String get reservedForUserIdLabel => 'Rezerve Edilen Kullanıcı ID';

  @override
  String get reservedUntil => 'Rezervasyon Bitişi';

  @override
  String get loanStart => 'Ödünç Başlangıcı';

  @override
  String get dueAt => 'Son Tarih';

  @override
  String get whyActionsUnavailable => 'Bazı işlemler neden kullanılamıyor?';

  @override
  String get hintReserveUnavailable =>
      'Rezerve etme yalnızca kitap AVAILABLE durumundayken mümkündür.';

  @override
  String get hintLoanUnavailable =>
      'Ödünç verme yalnızca kitap AVAILABLE veya RESERVED durumundayken mümkündür.';

  @override
  String get hintReturnUnavailable =>
      'İade alma yalnızca kitap ON_LOAN durumundayken mümkündür.';

  @override
  String get hintGiftUnavailable =>
      'Devretme yalnızca AVAILABLE durumundaki USER sahipli kitaplar için mümkündür.';

  @override
  String get hintDonateUnavailable =>
      'Bağışlama yalnızca AVAILABLE durumundaki USER sahipli kitaplar için mümkündür.';

  @override
  String get hintReservedLoanRule =>
      'RESERVED durumundaki kitaplarda ödünç verme butonu açıktır, ancak backend sadece rezervasyonu olan kullanıcıya ödünç vermeye izin verir.';

  @override
  String get idLabel => 'ID';

  @override
  String get fromUser => 'Gönderen Kullanıcı';

  @override
  String get toUser => 'Alan Kullanıcı';

  @override
  String get start => 'Başlangıç';

  @override
  String get end => 'Bitiş';

  @override
  String get books => 'Kitaplar';

  @override
  String get noBooksFound => 'Kitap bulunamadı';

  @override
  String get unknownAuthor => 'Bilinmiyor';

  @override
  String get systemLanguage => 'Sistem Dili';

  @override
  String get german => 'Deutsch';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Türkçe';
}
