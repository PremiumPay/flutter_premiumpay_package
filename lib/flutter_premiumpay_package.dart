library flutter_premiumpay_package;

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' as conv;
import 'package:convert/convert.dart';
import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import "package:asn1lib/asn1lib.dart";
import 'package:pointycastle/export.dart' as pointy;




pointy.ECCurve_secp256k1 secp256k1 = pointy.ECCurve_secp256k1();

String createInstallId(){
  var uuid=  Uuid();
  return uuid.v4();
}
enum SyncStatus{SUCCESSFUL_SYNC, NOT_CONNECTED, ACTIVATED_TOKEN}
enum ConnectStatus{SUCCESSFUL_CONNECT, NEED_TO_VERIFY_EMAIL, INVALID_EMAIL, NOT_CONNECTED}

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

class Feature {
  String feature_id;
  String feature_name;
  bool activated;
  String token;
  Feature(this.feature_id,this.feature_name);
}

class Sync {

  String install_id;
  Sync(this.install_id);

  Future<SyncResult> syncRequest () async
  {
    SyncResult syncResult=new SyncResult();
    String installIdEncoded=Uri.encodeComponent(install_id);
    Map<String, String> headers = {"Content-type": "application/json"};
    String url ="https://api.premiumpay.site/sync/?install_id=$installIdEncoded";
    http.Response response = await http.get(url, headers: headers);
    dynamic responseBody = jsonDecode(response.body);
    if(responseBody["result"]=="NOT_CONNECTED"){
      syncResult.status=SyncStatus.NOT_CONNECTED;
    }
    if(responseBody["result"]=="SUCCESSFUL_SYNC"){
      syncResult.status=SyncStatus.SUCCESSFUL_SYNC;
    }
    if(responseBody["result"]=="ACTIVATED_TOKEN"){
      syncResult.status=SyncStatus.ACTIVATED_TOKEN;
      for(int i=0;i<responseBody["number_of_token"];i++){
        List<String> list = new List<String>();
        list.add(responseBody["feature_${i+1}"]);
        list.add(responseBody["token_${i+1}"]);
        syncResult.tokens.add(list);
      }

    }
    syncResult.emailVerified=responseBody["verified"];
    syncResult.permanentLink=responseBody["permanentLink"];
    return syncResult;

  }


}

class SyncResult{

  SyncStatus status;
  bool emailVerified;
  List<List<String>> tokens;
  String permanentLink;
  SyncResult(){tokens=new List<List<String>>();
  emailVerified=false;}


}

class Connect {

  Install install;
  String email;

  Connect(this.install,this.email);

  Future<ConnectResult> connectRequest(bool resend_email,bool accept_promo_offers,{String lang ='en'}) async {
    ConnectResult connectResult=new ConnectResult();
    String connectUrl ="https://api.premiumpay.site/connect";
    String jsonBody='{ "email": "$email", "install_id": "${install.install_id}", "application_id":"${install.application_id}" , "resend_email": $resend_email , "features": "${install.features}", "accept_promo_offers": "$accept_promo_offers","from":"application"}';
    Map<String, String> headers = {"Content-type": "application/json"};

    http.Response response = await http.post(connectUrl, headers: headers, body:jsonBody);
    dynamic responseBody = jsonDecode(response.body);
    if(responseBody["result"]=="ok" && responseBody["verified"]){
      connectResult.status=ConnectStatus.SUCCESSFUL_CONNECT;
    }
    else{
      if(responseBody["result"]=="ok" && !responseBody["verified"]){
        connectResult.status=ConnectStatus.NEED_TO_VERIFY_EMAIL;
      }
      else{
        connectResult.status=ConnectStatus.NOT_CONNECTED;
      }
    }




    return connectResult;
  }
}

class ConnectResult{

  ConnectStatus status;
}

class Install{

  String install_id;
  String application_id;
  List<String> features;

  Install(this.install_id,this.application_id,this.features);
}

