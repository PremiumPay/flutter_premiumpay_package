import 'package:flutter_premiumpay_package/src/premiumpay_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_premiumpay_package/flutter_premiumpay_package.dart';

void main() {

  // values use for testing
  // In your code use application id and features id as defined in premiumpay.site.
  // For testing purpose, app-test#1 and app-test#2 features had been activated for install-id-test installation
  //  and install-id-test linked to premiumpaytest@gmail.com account.
  String installId = "install-id-test";
  String email = "premiumpaytest@gmail.com";
  String applicationId = "app-test";
  String featureId_1 = "app-test#1";
  String featureId_2 = "app-test#2";
  String tokenForFeature_1 = "MEUCIQCnAhiuSmVAUEcqXEsmr2RGtTDE9vmAsPsJCTmRzVqO3QIgBNK/5E6jHq8JMzOsqm0Em0SA1PevlOBai6h/UYkHYTA=";
  String tokenForFeature_2 = "MEUCIHwlVszfmwfH9PzpXz8J8YyXdF/slp/zyWoj5vgy97o8AiEAsrlE7v+B9BDEH9GE2ATx+z077gUKq8TqC8dtW2WthQg=";

  group("test premiupayAPI", () {
    test('Create InstallId', () {
      String installId = premiumPayAPI.createInstallId();
      print('InstallId = $installId');
      expect(installId, isNotEmpty);
    });


    test('Create Install', () {
      List<String> features = [
        featureId_1,
        featureId_2
      ];
      Install install = premiumPayAPI.createInstall(
          installId, applicationId, features);
      print('Install = $install');
      expect(install, isNotNull);
      expect(install.installId, installId);
      expect(install.applicationId , applicationId);
      expect(install.features , hasLength(features.length));
      expect(install.features[0] , features[0]);
      expect(install.features[1] , features[1]);
    });

    /// connect request with incorrect application id returns INVALID_APPLICATION_ID status
    test('Connect Request v1', () async {
      String invalidApplicationId = 'INVALID APPLICATION ID';
      List<String> features = [
        featureId_1,
        featureId_2
      ];
      Install install = premiumPayAPI.createInstall(
          installId, invalidApplicationId, features);
      ConnectResult connectResult = await premiumPayAPI.connectRequest(
          install, email);
      print('connectResult = $connectResult');
      expect(connectResult.status , ConnectStatus.INVALID_APPLICATION_ID);
    });

    /// connect request with email not verified returns NEED_TO_VERIFY_EMAIL status
    test('Connect Request v2', () async {
      String newInstallId = premiumPayAPI.createInstallId();
      List<String> features = [
        featureId_1,
        featureId_2
      ];
      Install install = premiumPayAPI.createInstall(
          newInstallId, applicationId, features);
      ConnectResult connectResult = await premiumPayAPI.connectRequest(
          install, email);
      print('connectResult = $connectResult');
      expect(connectResult.status , ConnectStatus.NEED_TO_VERIFY_EMAIL, reason: "user didn't click on the link in the email received to validate his email address");
    });

    /// connect request with email already verified returns SUCCESSFUL_CONNECT status
    test('Connect Request v3', () async {
      List<String> features = [
        featureId_1,
        featureId_2
      ];
      Install install = premiumPayAPI.createInstall(
          installId, applicationId, features);
      ConnectResult connectResult = await premiumPayAPI.connectRequest(
          install, email);
      print('connectResult = $connectResult');
      expect(connectResult.status , ConnectStatus.SUCCESSFUL_CONNECT);
    });

    /// sync request with installation not linked to the email account returns INSTALLATION_NOT_LINKED status
    test('Sync Request v1', () async {
      String newInstallId = premiumPayAPI.createInstallId();
      SyncResult syncResult = await premiumPayAPI.syncRequest(newInstallId, email);
      print('syncResult = $syncResult');
      expect(syncResult.status , SyncStatus.INSTALLATION_NOT_LINKED, reason: "didn't previously do connect request of $newInstallId with $email and validate email address");
      expect(syncResult.tokens, isEmpty, reason: 'no feature activated for $newInstallId newly created');
      expect(syncResult.permanentLink , isNull, reason: 'no direct access to website for account not validated');
    });

    /// sync request with install id of installation linked to an account returns INSTALLATION_LINKED status
    test('Sync Request v2', () async {
      SyncResult syncResult = await premiumPayAPI.syncRequest(installId, email);
      print('syncResult = $syncResult');
      expect(syncResult.status , SyncStatus.INSTALLATION_LINKED);
      expect(syncResult.tokens, isNotEmpty, reason: "features have been activated for $installId");
      expect(syncResult.tokens[0].featureId, featureId_1);
      expect(syncResult.tokens[0].token, tokenForFeature_1);
      expect(syncResult.tokens[1].featureId,featureId_2);
      expect(syncResult.tokens[1].token,tokenForFeature_2);
      expect(syncResult.permanentLink , isNotNull);
    });

    // checkTokenValidFormat returns true on valid format of token
    test('Check Token Valid Format v1', () {
      bool tokenValidFormat = premiumPayAPI.checkTokenValidFormat(tokenForFeature_1);
      expect(tokenValidFormat , isTrue);
    });

    // checkTokenValidFormat returns false on invalid format of token
    test('Check Token Valid Format v2', () {
      String token = "MEUCIQDD3vmG6qdg442QI6yYOzxQd";
      bool tokenValidFormat = premiumPayAPI.checkTokenValidFormat(token);
      expect(tokenValidFormat , isFalse);
    });

    // verifyToken with token suitable to installId and featureId returns true
    test('Verify Token v1', () {
      bool tokenValid = premiumPayAPI.checkTokenValidFormat(tokenForFeature_1) &&
          premiumPayAPI.verifyToken(installId, featureId_1, tokenForFeature_1);
      expect(tokenValid , isTrue);
    });

    // verifyToken with token unsuitable to installId and featureId returns false
    test('Verify Token v2', () {
      String token = "MPOCIQHJ7vmG6qdg442QI6yYOzxQdoXaH41eIFmG2DXWvG+9BwIgdJdkk4W14J4GLNF4WCKTJNlkiCo+QB0WuO+NBVUlPAM=";
      bool tokenValid = premiumPayAPI.checkTokenValidFormat(token) &&
          premiumPayAPI.verifyToken(installId, featureId_2, token);
      expect(tokenValid , isFalse);
    });
  }


  );
}