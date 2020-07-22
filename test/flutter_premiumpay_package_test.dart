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

  test('Create Install', () async {
    String applicationId = 'YOUR APPLICATION ID'; //As defined in premiumpay.site
    String  installId = premiumPayAPI.createInstallId();
    List<String> features = ['FEATURE_ID_1', 'FEATURE_ID_2']; //As defined in premiumpay.site
    Install install = premiumPayAPI.createInstall(installId, applicationId, features);
    ConnectResult connectResult = await premiumPayAPI.connectRequest(install, "frank.afriat@gmail.com");
    print('connectResult = $connectResult');
    //TODO FAF: Waiting here a result like: INVALID_APPLICATION_ID, not only NOT_CONNECTED !!!!!

  });
}
