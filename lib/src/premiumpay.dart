
abstract class ConnectResult {
  ConnectStatus get status;
}

abstract class Token {
  String get feature_id ;
  String get token;
}

abstract class SyncResult {
  SyncStatus get status;
  bool get emailVerified;
  List<Token> get tokens;
  String get permanentLink;
}

abstract  class Install {
  String get install_id;
  String get application_id;
  List<String> get features;
}

enum SyncStatus {
  SUCCESSFUL_SYNC,
  NOT_CONNECTED,
  ACTIVATED_TOKEN
}

enum ConnectStatus {
  SUCCESSFUL_CONNECT,
  NEED_TO_VERIFY_EMAIL,
  INVALID_EMAIL,
  NOT_CONNECTED
}

abstract class PremiumPayAPI {

  String createInstallId();

  Install createInstall(String installId, String applicationId, List<String> features);

  Future<ConnectResult> connectRequest(Install install, String email, { bool resendEmail = false, bool acceptPromoOffers = false, String lang = 'en'});

  Future<SyncResult> syncRequest(String installId);

  bool checkTokenValidFormat(String token);

  bool verifyToken(String installId, String featureId, String token);

  bool verifyReceivedToken(String installId, Token token);

}
