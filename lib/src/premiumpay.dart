

/// An installation defined by its necessary properties
abstract  class Install {

  /// unique installation identifier
  String get installId;

  /// application identifier as defined in premiumpay.site
  String get applicationId;

  /// list of application features identifiers as defined in premiumpay.site
  List<String> get features;
}

enum ConnectStatus {

  /// account validate and installation linked to it
  SUCCESSFUL_CONNECT,

  /// the email address must be verified by clicking on the link in the email received
  NEED_TO_VERIFY_EMAIL,

  /// not use
  INVALID_EMAIL,

  /// server request failure
  CONNEXION_FAILURE,

  /// connection with an invalid application id
  INVALID_APPLICATION_ID
}

/// Result of connection request
abstract class ConnectResult {

  /// the state of the installation linking to an account
  ConnectStatus get status;
}

/// A token associated to an application feature
///
/// the token is use to unblock the suitable feature for the installation chosen when the token was acquired
abstract class Token {

  /// feature identifier as defined in premiumpay.site
  String get featureId ;

  /// token brought by user from premiumpay.site as proof of his purchase of the associated feature for the specified installation
  String get token;
}

/// Result of sync request
///
/// if the installation has been linked to any account, the sync result gives :
///  * all the tokens acquired for the installation regardless of the account which acquired them
///  * a link to access directly the website logged into an account to which the installation is linked
abstract class SyncResult {

  /// state of the installation considering its linking to an account and its acquired tokens
  SyncStatus get status;

  /// list of Tokens acquired for the installation
  List<Token> get tokens;

  /// link to access directly the website logged into an account to which the installation is linked
  String get permanentLink;
}


enum SyncStatus {

  /// the installation has been linked to an account but no features have been acquired for the installation
  INSTALLATION_LINKED,

  /// the installation hasn't been linked to any account
  INSTALLATION_NOT_LINKED,

  /// the installation has been linked to an account and features have been acquired for the installation
  ACTIVATED_TOKEN
}

abstract class PremiumPayAPI {

  /// Create a new random installId.
  ///
  /// This method executes locally.
  /// Typically this method is called only one time during all the life of the app installation
  /// and then the installId must be saved somewhere, so no more call is needed and the installId will not change over execution.
  String createInstallId();

  /// Create a new instance of Install.
  ///
  /// This method executes locally.
  ///
  ///  [installId] is the installation identifier returned by [createInstallId].
  ///  [applicationId] is the application identifier as defined in premiumpay.site.
  ///  [features] is the list of all the features existing in the app installation, each feature is represented by its id as defined in premiumpay.site.
  ///
  /// Returns an instance of Install which represents the installation.
  Install createInstall(String installId, String applicationId, List<String> features);

  /// Create a new instance of Token.
  ///
  /// This method executes locally.
  ///
  ///  [featureId] is the identifier of a feature existing in the app installation as defined in premiumpay.site.
  ///  [token] is a token brought from premiumpay.site or returned by [syncRequest].
  ///
  /// Returns an instance of Token which represents a feature and its associated token use to unblock it in the appropriate installation.
  Token createToken(String featureId, String token);

  /// Method called in order to link the installation to an account.
  ///
  /// This method is asynchronous and executes server side.
  /// In order to activate feature(s) in the installation it's necessary to link the installation to an account.
  /// An account is recognized or created only with an email address.
  /// The method sends an email including a link to the email address received
  /// and clicking on the link will validated the email address and linked the installation.
  /// The email's link gives access to the app website where features can be purchase for a specific installation.
  /// In website, a feature purchase generates a token which must be bring back to the app installation
  /// in order to unblock the feature in the installation.
  ///
  ///  [install] is an instance of Install returned by [createInstall] which represents the installation we want to link.
  ///  [email] is the email address entered by the user, used to recognize or create the account to which the installation will be linked.
  ///  [resendEmail] is optional and set to false by default, it's the possibility to resend the email of linking if we lost the previous one.
  ///  [acceptPromoOffers] is optional and set to false by default, it's the possibility to receive promotional offers of the vendor's applications by email.
  ///  [lang] is optional and set to english by default, it defines the language to use in website.

  /// Returns a ConnectResult on future completed.
  Future<ConnectResult> connectRequest(Install install, String email, { bool resendEmail = false, bool acceptPromoOffers = false, String lang = 'en'});


  /// Request of synchronisation to update the installation activated features.
  ///
  /// This method is asynchronous and executes server side.
  /// This method is called to bring back the acquired tokens for the installation.
  /// Save the tokens somewhere so no more call is needed to unblock old acquired features.
  /// This method executes according to the received installation regardless of the account.
  ///
  ///  [installId] is the installation identifier returned by [createInstallId]
  ///
  /// Returns [INSTALLATION_NOT_LINKED] in [status] of [SyncResult] if the installation has never been linked to any account.
  /// Returns [INSTALLATION_LINKED] in [status] of [SyncResult] if the installation has been linked to an account but not feature(s) have been activated for it,
  ///  and a link in [permanentLink] to access directly the website.
  /// Returns [ACTIVATED_TOKEN] in [status] of [SyncResult] if the installation has been linked to an account and feature(s) have been activated for it,
  ///   a link in [permanentLink] to access directly the website, and a list of acquired tokens in [tokens].
  Future<SyncResult> syncRequest(String installId);

  /// Check the validity of the token format.
  ///
  /// This method executes locally.
  /// This method must be called before checking the token verification in order to execute the verification on valid token format and avoid exceptions.
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
  /// [token] in [token] must be of valid format as check in [checkTokenValidFormat], invalid format will throw exception.
  ///
  ///  [installId] is the installation identifier returned by [createInstallId].
  ///  [token] is a feature and its associated token.
  ///
  /// Returns true if [token] is valid for the [installId] and false if it's invalid for it.
  bool verifyReceivedToken(String installId, Token token);


}
