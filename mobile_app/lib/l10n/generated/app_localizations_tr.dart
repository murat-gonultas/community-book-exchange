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
  String get bookExtendedSuccessfully => 'Ödünç süresi başarıyla uzatıldı.';

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
  String get extendLoan => 'Ödünç süresini uzat';

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
  String get returnedByUserId => 'İade eden kullanıcı ID';

  @override
  String get newOwnerUserId => 'Yeni sahip kullanıcı ID';

  @override
  String get requesterUserId => 'İşlemi yapan kullanıcı';

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
  String get loanExtendedCount => 'Uzatma sayısı';

  @override
  String get overdueDaysLabel => 'Gecikme günü';

  @override
  String get overdueBadge => 'Gecikmiş';

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
  String hintExtendUnavailableNotOnLoan(String status) {
    return 'Süre uzatma sadece kitap durumu $status olduğunda mümkündür.';
  }

  @override
  String get hintExtendUnavailableOverdue => 'Gecikmiş ödünçler uzatılamaz.';

  @override
  String get hintExtendUnavailableMaxReached =>
      'Maksimum uzatma sayısına ulaşıldı.';

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
  String get transactionLoanExtension => 'Ödünç uzatma';

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

  @override
  String bookOverdueMessage(int days) {
    return 'Bu kitap $days gündür gecikmiş durumda.';
  }

  @override
  String get login => 'Giriş yap';

  @override
  String get register => 'Kayıt ol';

  @override
  String get authNoAccountYetRegister => 'Henüz hesabın yok mu? Kayıt ol';

  @override
  String get authAlreadyHaveAccountLogin => 'Zaten hesabın var mı? Giriş yap';

  @override
  String get authVerificationRequiredNote =>
      'Not: Eğer backend e-posta doğrulaması istiyorsa, önce kayıt olmalı ve giriş yapmadan önce e-postanı doğrulamalısın.';

  @override
  String get navMyRequests => 'Taleplerim';

  @override
  String get navIncomingRequests => 'Gelen Talepler';

  @override
  String get borrowRequestAction => 'Ödünç alma talebi';

  @override
  String get borrowRequestCreateTitle => 'Ödünç alma talebi oluştur';

  @override
  String get borrowRequestCreatedSuccess =>
      'Ödünç alma talebi başarıyla oluşturuldu.';

  @override
  String get borrowRequestHintSignInRequired =>
      'Ödünç alma talebi oluşturmak için giriş yapmalısın.';

  @override
  String get borrowRequestHintAvailableOnly =>
      'Ödünç alma talepleri yalnızca uygun durumdaki kitaplar için oluşturulabilir.';

  @override
  String get borrowRequestHintOwnBook =>
      'Kendi kitabın için ödünç alma talebi oluşturamazsın.';

  @override
  String get myBorrowRequestsTitle => 'Ödünç Alma Taleplerim';

  @override
  String get myBorrowRequestsEmpty => 'Henüz hiç ödünç alma talebin yok.';

  @override
  String myBorrowRequestsLoadError(Object error) {
    return 'Ödünç alma taleplerin yüklenemedi.\n\n$error';
  }

  @override
  String get borrowRequestCancelTitle => 'Ödünç alma talebini iptal et';

  @override
  String get borrowRequestCancelledSuccess =>
      'Ödünç alma talebi başarıyla iptal edildi.';

  @override
  String get incomingBorrowRequestsTitle => 'Gelen Ödünç Alma Talepleri';

  @override
  String get incomingBorrowRequestsEmpty =>
      'Şu anda gelen bir ödünç alma talebi yok.';

  @override
  String incomingBorrowRequestsLoadError(Object error) {
    return 'Gelen ödünç alma talepleri yüklenemedi.\n\n$error';
  }

  @override
  String get borrowRequestRejectTitle => 'Ödünç alma talebini reddet';

  @override
  String get borrowRequestApproveTitle => 'Ödünç alma talebini onayla';

  @override
  String get borrowRequestApprovedSuccess =>
      'Ödünç alma talebi başarıyla onaylandı.';

  @override
  String get borrowRequestRejectedSuccess =>
      'Ödünç alma talebi başarıyla reddedildi.';

  @override
  String get borrowRequestFulfillTitle => 'Ödünç alma talebini ödünce dönüştür';

  @override
  String get borrowRequestFulfilledSuccess =>
      'Ödünç alma talebi başarıyla ödünce dönüştürüldü.';
}
