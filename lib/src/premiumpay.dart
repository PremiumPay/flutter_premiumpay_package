
abstract  class Install {
  String get installId;
  String get applicationId;
  List<String> get features;
}

enum ConnectStatus {
  SUCCESSFUL_CONNECT,
  NEED_TO_VERIFY_EMAIL,
  INVALID_EMAIL,
  NOT_CONNECTED
}

abstract class ConnectResult {
  ConnectStatus get status;
}

abstract class Token {
  String get featureId ;
  String get token;
}

abstract class SyncResult {
  SyncStatus get status;
  bool get emailVerified;
  List<Token> get tokens;
  String get permanentLink;
}


enum SyncStatus {
  SUCCESSFUL_SYNC,
  NOT_CONNECTED,
  ACTIVATED_TOKEN
}

abstract class PremiumPayAPI {

  /// Create a new random installId
  /// This method execute locally
  /// Typically this method is called only one time during all the life of the app installation
  /// and then the installId must be saved somewhere, so no more call is needed and the installId will not change pver execution.
  String createInstallId();

  Install createInstall(String installId, String applicationId, List<String> features);

  Future<ConnectResult> connectRequest(Install install, String email, { bool resendEmail = false, bool acceptPromoOffers = false, String lang = 'en'});

  Future<SyncResult> syncRequest(String installId);

  bool checkTokenValidFormat(String token);

  bool verifyToken(String installId, String featureId, String token);

  bool verifyReceivedToken(String installId, Token token);

}
