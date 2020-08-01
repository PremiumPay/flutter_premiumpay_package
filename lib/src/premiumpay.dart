
/// Represents an application installation
abstract  class Install {
  /// unique installation identifier
  String get installId;

  /// application identifier as defined in premiumpay.site
  String get applicationId;

  /// list of all the application features present in the installation,
  /// each feature is represented by its identifier as defined in premiumpay.site
  List<String> get features;
}

enum ConnectStatus {

  /// installation linked to a valid account
  SUCCESSFUL_CONNECT,

  /// account must be validated by clicking on the link in the email received
  NEED_TO_VERIFY_EMAIL,

  /// connection with an invalid application id
  INVALID_APPLICATION_ID
}

/// Result of connection request
abstract class ConnectResult {

  /// state of the installation considering its linking to an account
  ConnectStatus get status;
}

/// A token associated to a feature
///
/// the token is used to unblock the feature in a specific installation
abstract class Token {

  /// feature identifier as defined in premiumpay.site
  String get featureId ;

  /// token acquired after activation of the feature in premiumpay.site
  String get token;
}

/// Result of sync request
abstract class SyncResult {

  /// state of the installation considering the activation of its features
  SyncStatus get status;

  /// list of the Tokens acquired for the installation
  List<Token> get tokens;

  /// link to access directly the website
  String get permanentLink;
}


enum SyncStatus {

  /// the installation has been linked to an account but no features have been activated
  INSTALLATION_LINKED,

  /// the installation hasn't been linked to any account
  INSTALLATION_NOT_LINKED,
}

abstract class PremiumPayAPI {

  /// Create a new random installId.
  ///
  /// This method executes locally.
  /// Typically this method is called only one time during all the life of the app installation
  /// and then the installId must be saved somewhere, so no more call is needed and the installId will not change over execution.
  String createInstallId();

  /// Create a new instance of Install class.
  ///
  /// This method executes locally.
  ///
  ///  [installId] is the installation identifier created by [createInstallId].
  ///  [applicationId] is the application identifier as defined in premiumpay.site.
  ///  [features] is the list of all the features existing in the app installation, each feature is represented by its id as defined in premiumpay.site.
  ///
  Install createInstall(String installId, String applicationId, List<String> features);


  /// Method called in order to link the installation to an account.
  ///
  /// This method is asynchronous and executes server side.
  /// In order to activate feature(s) in the installation it's necessary to link the installation to an account.
  /// An account is recognized or created with only an email address.
  /// On first connection to an account, the method sends an email including a link to the email address received
  /// and clicking on the link will validate the account and link the installation.
  /// The email's link gives access to the app website where features can be activated for a specific installation.
  /// In website, a feature activation generates a token which must be bring back to the app installation
  /// in order to unblock the feature in the installation.
  ///
  ///  [install] is an instance of Install created by [createInstall] which represents the installation we want to link.
  ///  [email] is the email address entered by the user, used to recognize or create the account to which the installation will be linked.
  ///  [resendEmail] is optional and set to false by default, it's the possibility to resend the email of linking if we lost the previous one.
  ///  [acceptPromoOffers] is optional and set to false by default, it's the possibility to receive promotional offers of the vendor's applications by email.
  ///  [lang] is optional and set to english by default, it defines the language to use in website.

  /// Returns [ConnectStatus.SUCCESSFUL_CONNECT] in [ConnectResult.status] if the installation has been linked to the account following email validation.
  /// Returns [ConnectStatus.NEED_TO_VERIFY_EMAIL] in [ConnectResult.status] if the user didn't click on the link in the email.
  /// Returns [ConnectStatus.INVALID_APPLICATION_ID] in [ConnectResult.status]  if [install] contains an invalid app id.
  Future<ConnectResult> connectRequest(Install install, String email, { bool resendEmail = false, bool acceptPromoOffers = false, String lang = 'en'});


  /// Request of synchronisation to update the installation activated features.
  ///
  /// This method is asynchronous and executes server side.
  /// This method is called to bring back all the acquired tokens for the installation regardless of the account use to acquire them,
  /// and to get the status of the account to which the installation is connected.
  /// Save the tokens somewhere so no more call is needed to unblock old acquired features.
  /// If the installation is linked to the account, this method returns a link to access directly the website logged in.
  /// The link must be saved somewhere to be always accessible while connected to this account.
  ///
  ///  [installId] is the installation identifier created by [createInstallId]
  ///  [email] is the address to which the installation is connected
  ///
  /// Returns [SyncStatus.INSTALLATION_NOT_LINKED] in [SyncResult.status] if the installation is not linked to the account.
  /// Returns [SyncStatus.INSTALLATION_LINKED] in [SyncResult.status] if the installation has been linked to the account,
  ///   and a link in [SyncResult.permanentLink] to access directly the website logged in.
  /// In all cases, the installation acquired tokens list is returned in [SyncResult.tokens].
  Future<SyncResult> syncRequest(String installId, String email);

  /// Check the validity of the token format.
  ///
  /// This method executes locally.
  /// This method must be called before checking the token verification in order to execute the verification on valid token format and avoid exception.
  /// Valid format must be of length 96 and encoded in base 64.
  bool checkTokenValidFormat(String token);

  /// Verify the validity of a token for a specific feature and a specific installation.
  ///
  /// This method executes locally.
  /// [token] must be of valid format as check in [checkTokenValidFormat], invalid format will throw exception.
  ///
  ///  [installId] is the installation identifier returned by [createInstallId].
  ///  [featureId] is the feature identifier as defined in premiumpay.site.
  ///  [token] is a token brought from premiumpay.site or returned by [syncRequest].
  ///
  /// Returns true if [token] is valid for the [featureId] and the [installId] associated  and false if it's invalid for them.
  bool verifyToken(String installId, String featureId, String token);

  /// Verify the validity of a Token for a specific installation.
  ///
  /// This method executes locally.
  /// Does the same like [verifyToken] method.
  bool verifyReceivedToken(String installId, Token token);


}
