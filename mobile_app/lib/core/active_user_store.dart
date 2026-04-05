import 'package:flutter/foundation.dart';

class ActiveUserStore {
  static final ValueNotifier<int?> currentUserId = ValueNotifier<int?>(null);

  static void setUserId(int? userId) {
    currentUserId.value = userId;
  }
}
