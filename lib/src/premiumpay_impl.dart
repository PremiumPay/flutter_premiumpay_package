import 'premiumpay.dart';

import 'dart:async';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import "package:asn1lib/asn1lib.dart";
import 'package:pointycastle/export.dart' as pointy;

PremiumPayAPI premiumPayAPI = new _PremiumPayAPI();

class ConnectResultImpl implements ConnectResult {
  final ConnectStatus status;

  @override
  String toString() {
    return json.encode({"status": "$status"});
  }

  ConnectResultImpl._internal(this.status);
}

class TokenImpl implements Token {
  final String featureId;
  final String token;

  TokenImpl._internal(this.featureId, this.token);
}

class SyncResultImpl  implements SyncResult {
  final SyncStatus status;
  final bool emailVerified;
  final List<Token> tokens;
  final String permanentLink;

  SyncResultImpl._internal(this.status, this.emailVerified, List<Token> tokens, this.permanentLink): tokens = List.unmodifiable(tokens);
}

class InstallImpl implements Install  {
  final String installId;
  final String applicationId;
  final List<String> features;

  @override
  String toString() {
    return json.encode({
      "installId" : installId,
      "applicationId" : applicationId,
      "features" : features
    });
  }

  InstallImpl._internal(this.installId, this.applicationId, this.features);
}

class  _PremiumPayAPI implements PremiumPayAPI {

  @override
  String createInstallId() {
    var uuid = Uuid();
    return uuid.v4();
  }

  @override
  Install createInstall(String installId, String applicationId, List<String> features) {
    return InstallImpl._internal(installId, applicationId, features);
  }

  @override
  Future<ConnectResult> connectRequest(Install install, String email, { bool resendEmail = false, bool acceptPromoOffers = false, String lang = 'en'}) async {
    String connectUrl = "https://api.premiumpay.site/connect";
    String jsonBody =
        '{ "email": "$email", "install_id": "${install.installId}", "application_id":"${install.applicationId}" , "resend_email": $resendEmail , "features": "${install.features}", "accept_promo_offers": "$acceptPromoOffers","from":"application"}';
    Map<String, String> headers = {"Content-type": "application/json"};
    ConnectStatus status;
    http.Response response =
    await http.post(connectUrl, headers: headers, body: jsonBody);
    dynamic responseBody = jsonDecode(response.body);
    if (responseBody["result"] == "ok" && responseBody["verified"]) {
      status = ConnectStatus.SUCCESSFUL_CONNECT;
    } else {
      if (responseBody["result"] == "ok" && !responseBody["verified"]) {
        status = ConnectStatus.NEED_TO_VERIFY_EMAIL;
      } else {
        status = ConnectStatus.NOT_CONNECTED;
      }
    }
    ConnectResult connectResult = ConnectResultImpl._internal(status);
    return connectResult;
  }

  @override
  Future<SyncResult> syncRequest(String install_id) async {
    String installIdEncoded = Uri.encodeComponent(install_id);
    Map<String, String> headers = {"Content-type": "application/json"};
    String url =
        "https://api.premiumpay.site/sync/?install_id=$installIdEncoded";
    http.Response response = await http.get(url, headers: headers);
    dynamic responseBody = jsonDecode(response.body);
    List<Token> list = List<Token>();

    SyncStatus status = _decode(responseBody["result"]);

    if (status == SyncStatus.ACTIVATED_TOKEN) {
      //TODO FAF: You need to return directly a json list instead!
      int number_of_token = responseBody["number_of_token"];
      for (int i = 0; i < number_of_token; i++) {
        Token token = TokenImpl._internal(responseBody["feature_${i + 1}"], responseBody["token_${i + 1}"]);
        list.add(token);
      }
    }

    SyncResult syncResult = SyncResultImpl._internal(status, responseBody["verified"], list, responseBody["permanentLink"]);
    return syncResult;
  }

  /// fast local test
  @override
  bool checkTokenValidFormat(String token) {
    return token.length == 96;
  }

  static SyncStatus _decode(String str) {
    switch (str) {
      case "NOT_CONNECTED":
        return SyncStatus.NOT_CONNECTED;
      case "SUCCESSFUL_SYNC":
        return SyncStatus.SUCCESSFUL_SYNC;
      case "ACTIVATED_TOKEN":
        return SyncStatus.ACTIVATED_TOKEN;
      default:
        throw Exception("incorrect SyncStatus value: $str");
    }
  }

  @override
  bool verifyReceivedToken(String installId, Token token) {
    return verifyToken(installId, token.featureId, token.token);
  }

  @override
  bool verifyToken(String installId, String featureId, String token) {
    return _PremiumPayCrypto.tokenVerification(featureId + '@' + installId, token);
  }

}

class _PremiumPayCrypto {

  static final pointy.ECCurve_secp256k1 secp256k1 = pointy.ECCurve_secp256k1();

  static bool tokenVerification(String msg, String token) {
    var signatureToken = base64Decode(token);
    //verify signature of token
    pointy.ECPublicKey publicKey = fromPoint(
        BigInt.parse(
            '70649223788745836880507028022574014426179915224666556089367819961918974845892'),
        BigInt.parse(
            '25378690514866426415915286385950639614503729041791884911790462128279276790876'));
    String message = msg;
    List<int> messageBytes = utf8.encode(message);
    var p = ASN1Parser(signatureToken);
    ASN1Sequence seq1 = p.nextObject();
    ASN1Integer s1Int = seq1.elements[0];
    ASN1Integer s2Int = seq1.elements[1];

    var s1IntHex = hex.encode(s1Int.contentBytes());
    var s2IntHex = hex.encode(s2Int.contentBytes());
    if ((s1Int.contentBytes().length == 33) && s1IntHex.startsWith("00")) {
      s1IntHex = s1IntHex.substring(2);
    }
    if ((s2Int.contentBytes().length == 33) && s2IntHex.startsWith("00")) {
      s2IntHex = s2IntHex.substring(2);
    }

    String signature = s1IntHex + s2IntHex;

    bool verified = verifySignature(messageBytes, signature, publicKey);
    return verified;
  }

  static bool verifySignature(List<int> messageBytes, String signatureString,
      pointy.ECPublicKey _publicKey) {
    var sigLength = (signatureString.length / 2).round();
    var r = BigInt.parse(signatureString.substring(0, sigLength), radix: 16);
    var s = BigInt.parse(signatureString.substring(sigLength), radix: 16);
    var signature = pointy.ECSignature(r, s);
    var signer = pointy.Signer('SHA-256/ECDSA');
    signer.init(false, pointy.PublicKeyParameter(_publicKey));
    return signer.verifySignature(messageBytes, signature);
  }

  static pointy.ECPublicKey publicKeyfromString(String publicKeyString) {
    var Q = secp256k1.curve.decodePoint(base64Decode(publicKeyString));
    return pointy.ECPublicKey(Q, secp256k1);
  }

  static pointy.ECPublicKey fromPoint(BigInt x, BigInt y) {
    var c = secp256k1.curve;
    var Q = c.createPoint(x, y);
    return pointy.ECPublicKey(Q, secp256k1);
  }

}
