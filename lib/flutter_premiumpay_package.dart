library flutter_premiumpay_package;

import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' as conv;
import 'package:convert/convert.dart';
import "package:asn1lib/asn1lib.dart";
import 'package:pointycastle/export.dart' as pointy;


enum SyncStatus{SUCCESSFUL_SYNC, NOT_CONNECTED, ACTIVATED_TOKEN}
enum ConnectStatus{SUCCESSFUL_CONNECT, NEED_TO_VERIFY_EMAIL, INVALID_EMAIL, NOT_CONNECTED}


String createInstallId(){
  var uuid=  Uuid();
  return uuid.v4();
}


class Feature {

  final String feature_id;
  final String feature_name;
  bool activated;
  String token;

  Feature(this.feature_id,this.feature_name)
  {
    activated=false;
  }

}

class Sync {

  final String install_id;
  Sync(this.install_id);

  static SyncStatus decode(String str){

    switch(str){
      case "NOT_CONNECTED": return SyncStatus.NOT_CONNECTED;
      case "SUCCESSFUL_SYNC": return SyncStatus.SUCCESSFUL_SYNC;
      case "ACTIVATED_TOKEN": return SyncStatus.ACTIVATED_TOKEN;
      default: throw Exception("incorrect SyncStatus value: $str");
    }

  }

  Future<SyncResult> syncRequest () async
  {

    String installIdEncoded=Uri.encodeComponent(install_id);
    Map<String, String> headers = {"Content-type": "application/json"};
    String url ="https://api.premiumpay.site/sync/?install_id=$installIdEncoded";
    http.Response response = await http.get(url, headers: headers);
    dynamic responseBody = jsonDecode(response.body);
    List<Token> list =  List<Token>();


    SyncStatus status=decode(responseBody["result"]);

    if( status == SyncStatus.ACTIVATED_TOKEN){
      int number_of_token = responseBody["number_of_token"];
      for(int i=0; i< number_of_token ;i++){
        Token token= Token(responseBody["feature_${i+1}"],responseBody["token_${i+1}"]);
        list.add(token);
      }

    }

    SyncResult syncResult= SyncResult(status,responseBody["verified"],list,responseBody["permanentLink"]);
    return syncResult;

  }


}

class Token {

  final feature_id;
  final token;

  Token(this.feature_id,this.token);
}

class SyncResult{

  final SyncStatus status;
  final bool emailVerified;
  final List<Token> tokens;
  final String permanentLink;

  SyncResult(this.status,this.emailVerified,List<Token> tokens,this.permanentLink):tokens=List.unmodifiable(tokens);


}

class Connect {

  final Install install;
  final String email;

  Connect(this.install,this.email);

  Future<ConnectResult> connectRequest(bool resend_email,bool accept_promo_offers,{String lang ='en'}) async {

    String connectUrl ="https://api.premiumpay.site/connect";
    String jsonBody='{ "email": "$email", "install_id": "${install.install_id}", "application_id":"${install.application_id}" , "resend_email": $resend_email , "features": "${install.features}", "accept_promo_offers": "$accept_promo_offers","from":"application"}';
    Map<String, String> headers = {"Content-type": "application/json"};
    ConnectStatus status;
    http.Response response = await http.post(connectUrl, headers: headers, body:jsonBody);
    dynamic responseBody = jsonDecode(response.body);
    if(responseBody["result"]=="ok" && responseBody["verified"]){
      status=ConnectStatus.SUCCESSFUL_CONNECT;
    }
    else{
      if(responseBody["result"]=="ok" && !responseBody["verified"]){
        status=ConnectStatus.NEED_TO_VERIFY_EMAIL;
      }
      else{
        status=ConnectStatus.NOT_CONNECTED;
      }
    }
    ConnectResult connectResult=new ConnectResult(status);
    return connectResult;
  }
}

class ConnectResult{

  final ConnectStatus status;
  ConnectResult(this.status);
}

class Install{

  final String install_id;
  final String application_id;
  final List<String> features;

  Install(this.install_id,this.application_id,this.features);
}


pointy.ECCurve_secp256k1 secp256k1 = pointy.ECCurve_secp256k1();


/// fast local test
bool checkTokenValidFormat(String token){

     return token.length == 96;
}

bool tokenVerification(String msg,String token){
  var signatureToken=conv.base64Decode(token);
  //verify signature of token
  pointy.ECPublicKey  publicKey = fromPoint(BigInt.parse('70649223788745836880507028022574014426179915224666556089367819961918974845892'),BigInt.parse('25378690514866426415915286385950639614503729041791884911790462128279276790876'));
  String message = msg;
  List<int> messageBytes=conv.utf8.encode(message);
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


bool verifySignature(List<int> messageBytes, String signatureString, pointy.ECPublicKey  _publicKey) {

  var sigLength = (signatureString.length / 2).round();
  var r = BigInt.parse(signatureString.substring(0, sigLength), radix: 16);
  var s = BigInt.parse(signatureString.substring(sigLength), radix: 16);
  var signature = pointy.ECSignature(r, s);
  var signer = pointy.Signer('SHA-256/ECDSA');
  signer.init(false, pointy.PublicKeyParameter(_publicKey));
  return signer.verifySignature(messageBytes, signature);
}

pointy.ECPublicKey publicKeyfromString(String publicKeyString) {
  var Q = secp256k1.curve.decodePoint(conv.base64Decode(publicKeyString));
  return pointy.ECPublicKey(Q, secp256k1);
}

pointy.ECPublicKey fromPoint(BigInt x, BigInt y) {
  var c = secp256k1.curve;
  var Q = c.createPoint(x, y);
  return pointy.ECPublicKey(Q, secp256k1);
}