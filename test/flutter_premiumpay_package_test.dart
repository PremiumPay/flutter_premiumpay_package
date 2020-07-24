import 'package:flutter_premiumpay_package/src/premiumpay_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_premiumpay_package/flutter_premiumpay_package.dart';

void main() {

  test('Create InstallId', () {
    String  installId = premiumPayAPI.createInstallId();
    print('InstallId = $installId');
    assert(installId != null);
  });

  test('Create Install', () {
    String applicationId = 'YOUR APPLICATION ID'; //As defined in premiumpay.site
    String  installId = premiumPayAPI.createInstallId();
    List<String> features = ['FEATURE_ID_1', 'FEATURE_ID_2']; //As defined in premiumpay.site
    Install install = premiumPayAPI.createInstall(installId, applicationId, features);
    print('Install = $install');
    assert(install != null);
    assert(install.installId == installId);
    assert(install.applicationId == applicationId);
    assert(install.features.length == features.length);
    assert(install.features[0] == features[0]);
    assert(install.features[1] == features[1]);
  });
  /// connect request with incorrect application id returns INVALID_APPLICATION_ID status
  test('Connect Request v1', () async {
    String applicationId = 'YOUR APPLICATION ID'; //As defined in premiumpay.site
    String  installId = premiumPayAPI.createInstallId();
    List<String> features = ['FEATURE_ID_1', 'FEATURE_ID_2']; //As defined in premiumpay.site
    Install install = premiumPayAPI.createInstall(installId, applicationId, features);
    ConnectResult connectResult = await premiumPayAPI.connectRequest(install, "frank.afriat@gmail.com");
    print('connectResult = $connectResult');
    assert(connectResult.status == ConnectStatus.INVALID_APPLICATION_ID);

  });

  /// connect request with email not verified returns NEED_TO_VERIFY_EMAIL status
  test('Connect Request v2', () async {
    String applicationId = 'app-test'; // application id given for testing
    String  installId = premiumPayAPI.createInstallId();
    List<String> features = ['app-test#1', 'app-test#2']; // features id given for testing
    Install install = premiumPayAPI.createInstall(installId, applicationId, features);
    ConnectResult connectResult = await premiumPayAPI.connectRequest(install, "sarahcoriat96@gmail.com");
    print('connectResult = $connectResult');
    assert(connectResult.status == ConnectStatus.NEED_TO_VERIFY_EMAIL);

  });

  /// connect request with email already verified returns SUCCESSFUL_CONNECT status
  test('Connect Request v3', () async {
    String applicationId = 'app-test'; // application id given for testing
    String  installId = "fd973561-3e9c-44c9-9e39-fbf778dcd527";  //  install id of installation linked to sarahcoriat96@gmail.com account use for testing
    List<String> features = ['app-test#1', 'app-test#2']; // features id given for testing
    Install install = premiumPayAPI.createInstall(installId, applicationId, features);
    ConnectResult connectResult = await premiumPayAPI.connectRequest(install, "sarahcoriat96@gmail.com");
    print('connectResult = $connectResult');
    assert(connectResult.status == ConnectStatus.SUCCESSFUL_CONNECT);

  });

  /// sync request with install id of installation not linked to any account returns INSTALLATION_NOT_LINKED status
  test('Sync Request v1', () async {
    String  installId = premiumPayAPI.createInstallId();
    SyncResult syncResult = await premiumPayAPI.syncRequest(installId);
    print('syncResult = $syncResult');
    assert(syncResult.status == SyncStatus.INSTALLATION_NOT_LINKED);
    assert(syncResult.tokens == []);
    assert(syncResult.permanentLink == null);

  });

  /// sync request with install id of installation linked to an account but with any bought tokens returns INSTALLATION_LINKED status
  test('Sync Request v2', () async {
    String  installId = "fd973561-3e9c-44c9-9e39-fbf778dcd527";  // install id of installation linked to an account but without bought features given for testing
    SyncResult syncResult = await premiumPayAPI.syncRequest(installId);
    print('syncResult = $syncResult');
    assert(syncResult.status == SyncStatus.INSTALLATION_LINKED);
    assert(syncResult.tokens == []);
    assert(syncResult.permanentLink != null);

  });

  /// sync request with install id of installation linked to an account and with at least one bought token returns ACTIVATED_TOKEN status
  test('Sync Request v3', () async {
    String  installId = "059b5243-79c0-4f06-8999-87214c3aa960";  // install id of installation linked to an account and with one bought feature given for testing
    SyncResult syncResult = await premiumPayAPI.syncRequest(installId);
    print('syncResult = $syncResult');
    assert(syncResult.status == SyncStatus.ACTIVATED_TOKEN);
    assert(syncResult.tokens != []);
    assert(syncResult.permanentLink != null);

  });

  // checkTokenValidFormat returns true on valid format of token
  test('Check Token Valid Format v1', () {
    bool  tokenValidFormat = premiumPayAPI.checkTokenValidFormat("MEUCIQDD3vmG6qdg442QI6yYOzxQdoXaH55eIFmG2DXWvG+9BwIgdJdik4W14J4GLNF2WCKTJNossCo+QB0WuO+DDDUrYAE="); // token with valid format given for testing
    assert(tokenValidFormat == true);
  });

  // checkTokenValidFormat returns false on invalid format of token
  test('Check Token Valid Format v2', () {
    bool  tokenValidFormat = premiumPayAPI.checkTokenValidFormat("MEUCIQDD3vmG6qdg442QI6yYOzxQd"); // token with invalid format given for testing
    assert(tokenValidFormat == false);
  });

  // verifyToken with token suitable to installId and featureId returns true
  test('Verify Token v1', () {
    bool  tokenValid = premiumPayAPI.verifyToken("fd973561-3e9c-44c9-9e39-fbf778dcd520","app-test#1","MEUCIQDD3vmG6qdg442QI6yYOzxQdoXaH55eIFmG2DXWvG+9BwIgdJdik4W14J4GLNF2WCKTJNossCo+QB0WuO+DDDUrYAE="); // installId, featureId and token suitable given for testing
    assert(tokenValid == true);
  });

  // verifyToken with token unsuitable to installId and featureId returns false
  test('Verify Token v2', () {
    bool  tokenValid = premiumPayAPI.verifyToken("fd973561-3e9c-44c9-9e39-fbf778dcd520","app-test#1","MEUCIQDD3vmG6qdg442QI6yYOzxQdoXaH55eIFmG2DXWvG+9BwIgdJdik4W14J4GLNF2WCKTJNossCo+QB0WuO+DDDUrPAE="); // installId, featureId and token unsuitable given for testing
    assert(tokenValid == false);
  });

  // verifyReceivedToken with token suitable to installId returns true
  test('Verify Token v1', () {
    Token token = premiumPayAPI.createToken("app-test#1","MEUCIQDD3vmG6qdg442QI6yYOzxQdoXaH55eIFmG2DXWvG+9BwIgdJdik4W14J4GLNF2WCKTJNossCo+QB0WuO+DDDUrYAE="); // featureId and token given for testing
    bool  tokenValid = premiumPayAPI.verifyReceivedToken("fd973561-3e9c-44c9-9e39-fbf778dcd520", token); // installId and token suitable given for testing
    assert(tokenValid == true);
  });

  // verifyReceivedToken with token unsuitable to installId returns false
  test('Verify Token v2', () {
    Token token = premiumPayAPI.createToken("app-test#1","MEUCIQDD3vmG6qdg442QI6yYOzxQdoXaH55eIFmG2DXWvG+9BwIgdJdik4W14J4GLNF2WCKTJNossCo+QB0PuO+DDDUrYAE=");  // // featureId and token given for testing
    bool  tokenValid = premiumPayAPI.verifyReceivedToken("fd973561-3e9c-44c9-9e39-fbf778dcd520", token); // installId and token unsuitable given for testing
    assert(tokenValid == false);
  });

}
