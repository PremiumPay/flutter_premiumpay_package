
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:asn1lib/asn1lib.dart';
import 'package:pointycastle/export.dart' as pointy;
import 'premiumpay.dart';

PremiumPayAPI premiumPayAPI =  _PremiumPayAPI();

class ConnectResultImpl implements ConnectResult {

  final ConnectStatus status;

  ConnectResultImpl._internal(this.status);

  @override
  String toString() {
    return json.encode({'status': '$status'});
  }


}

class TokenImpl implements Token {
  final String featureId;
  final String token;

  TokenImpl._internal(this.featureId, this.token);

  @override
  String toString() {
    return json.encode({
      'featureId' : featureId,
      'token' : token,
    });
  }

}

class SyncResultImpl  implements SyncResult {

  final SyncStatus status;
  final List<Token> tokens;
  final String permanentLink;

  @override
  String toString() {
    return json.encode({'status': '$status' , 'tokens': '$tokens', 'permanentLink': "$permanentLink"});
  }

  SyncResultImpl._internal(this.status, List<Token> tokens, this.permanentLink): tokens = List.unmodifiable(tokens);
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
  Token createToken(String featureId, String token) {
    return TokenImpl._internal(featureId, token);

  }

  @override
  Future<ConnectResult> connectRequest(Install install, String email, { bool resendEmail = false, bool acceptPromoOffers = false, String lang = 'en'}) async {
    String connectUrl = "https://api.premiumpay.site/connect";
    String jsonBody =
        '{ "email": "$email", "install_id": "${install.installId}", "application_id":"${install.applicationId}" , "resend_email": $resendEmail , "features": ${install.features}, "accept_promo_offers": "$acceptPromoOffers","from":"application"}';
    Map<String, String> headers = {"Content-type": "application/json"};
    ConnectStatus status;
    http.Response response =
    await http.post(connectUrl, headers: headers, body: jsonBody);
    dynamic responseBody = jsonDecode(response.body);
    switch(responseBody['result'].toString()){

      case 'ok': {
        if( responseBody['verified'].toString().toLowerCase()== 'true'){
          status = ConnectStatus.SUCCESSFUL_CONNECT;
        }
        else{
          status = ConnectStatus.NEED_TO_VERIFY_EMAIL;
        }
        break;
      }

      case "invalid_app_id": {
        status= ConnectStatus.INVALID_APPLICATION_ID;
        break;
      }
      default:
        throw Exception("incorrect ConnectResult result value: ${responseBody['result'].toString()}");
    }
    ConnectResult connectResult = ConnectResultImpl._internal(status);
    return connectResult;
  }

  static SyncStatus _decode(String str) {
    switch (str) {
      case "INSTALLATION_NOT_LINKED":
        return SyncStatus.INSTALLATION_NOT_LINKED;
      case "INSTALLATION_LINKED":
        return SyncStatus.INSTALLATION_LINKED;
      default:
        throw Exception("incorrect SyncStatus value: $str");
    }
  }

  @override
  Future<SyncResult> syncRequest(String install_id, email) async {
    String installIdEncoded = Uri.encodeComponent(install_id);
    String emailEncoded = Uri.encodeComponent(email);
    Map<String, String> headers = {"Content-type": "application/json"};
    String url =
        "https://api.premiumpay.site/sync/?install_id=$installIdEncoded&email=$emailEncoded";
    http.Response response = await http.get(url, headers: headers);
    dynamic responseBody = jsonDecode(response.body);
    List<Token> list = [];

    SyncStatus status = _decode(responseBody["result"].toString());

      int len = responseBody["tokens"].toList().length;
      for(int i=0; i< len ;i++) {

        Token token = TokenImpl._internal(responseBody["tokens"][i]["feature_id"].toString(), responseBody["tokens"][i]["token"].toString());
        list.add(token);

      }

    SyncResult syncResult = SyncResultImpl._internal(status, list, responseBody["permanentLink"]);
    return syncResult;
  }

  /// fast local test
  @override
  bool checkTokenValidFormat(String token) {

    if(token.length != 96)
      return false;
    var signatureToken = base64Decode(token);
    var p = ASN1Parser(signatureToken);
    try{
      ASN1Object seq1 = p.nextObject();
    }catch(e){
      return false;
    }

    return true;
  }



  @override
  bool verifyReceivedToken(String installId, Token token) {
    return verifyToken(installId, token.featureId, token.token);
  }

  @override
  bool verifyToken(String installId, String featureId, String token) {
    return true;// _PremiumPayCrypto.tokenVerification(featureId + '@' + installId, token);
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
    ASN1Sequence seq1 = p.nextObject() as ASN1Sequence;
    ASN1Integer s1Int =seq1.elements[0]  as ASN1Integer;
    ASN1Integer s2Int = seq1.elements[1] as ASN1Integer;
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
    return signer.verifySignature(Uint8List.fromList(messageBytes), signature);
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
