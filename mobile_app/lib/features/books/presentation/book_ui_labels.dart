import 'package:mobile_app/l10n/generated/app_localizations.dart';

class BookUiLabels {
  static String status(String rawStatus, AppLocalizations l10n) {
    switch (rawStatus) {
      case 'AVAILABLE':
        return l10n.statusAvailable;
      case 'ON_LOAN':
        return l10n.statusOnLoan;
      default:
        return rawStatus;
    }
  }

  static String ownershipType(String rawOwnershipType, AppLocalizations l10n) {
    switch (rawOwnershipType) {
      case 'USER':
        return l10n.ownershipUser;
      case 'COMMUNITY':
        return l10n.ownershipCommunity;
      default:
        return rawOwnershipType;
    }
  }

  static String transactionType(
    String rawTransactionType,
    AppLocalizations l10n,
  ) {
    switch (rawTransactionType) {
      case 'LOAN':
        return l10n.transactionLoan;
      case 'RETURN':
        return l10n.transactionReturn;
      case 'GIFT':
        return l10n.transactionGift;
      case 'DONATION':
        return l10n.transactionDonation;
      default:
        return rawTransactionType;
    }
  }
}
