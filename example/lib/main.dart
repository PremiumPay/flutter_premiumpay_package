
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_premiumpay_package/flutter_premiumpay_package.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';


class Feature {
  final String feature_id;
  final String feature_name;
  bool activated;
  String token;

  Feature(this.feature_id, this.feature_name) {
    activated = false;
  }
}

class Data extends ChangeNotifier{
  String application_id ;
  String install_id;
  Feature feature_1 ;
  Feature feature_2 ;
  List<String> features ;
  String email;
  bool connected;
  String permanentLink;

  Data(){
    application_id = "jewish-time";
    feature_1 = new Feature("jewish-time#1", "Jewish Time Premium");
    feature_2 = new Feature("jewish-time#2", "Custom background");
    features = [feature_1.feature_id, feature_2.feature_id];
    init();
  }

  Future<bool> init() async {

    feature_1.activated = await _getFeatureActivationFromSharedPref(feature_1);
    feature_2.activated = await _getFeatureActivationFromSharedPref(feature_2);
    if (feature_1.activated) {
      feature_1.token = await _getTokenFromSharedPref(feature_1);
    }
    if (feature_2.activated) {
      feature_2.token = await _getTokenFromSharedPref(feature_2);
    }

    email = await _getEmailFromSharedPref();
    connected = await _getConnectedFromSharedPref();
    install_id =await  _getInstallIdFromSharedPref();
    permanentLink = await _getPermanentLinkFromSharedPref();
    return true;
  }

  String get getAppId {
    return application_id;
  }
  String get getInstallId {
    return install_id;
  }
  Feature get getFeature_1 {
    return feature_1;
  }
  Feature get getFeature_2 {
    return feature_2;
  }
  void activateFeature_1 ( String token) {
     feature_1.activated = true;
     feature_1.token = token;
     _resetFeatureActivation(feature_1);
     _resetToken(feature_1, token);
     notifyListeners();
  }
  void activateFeature_2 ( String token) {
    feature_2.activated = true;
    feature_2.token = token;
    _resetFeatureActivation(feature_2);
    _resetToken(feature_2, token);
    notifyListeners();
  }
  String get getEmail {
    return email;
  }
  void setEmail ( String address) {
    email = address;
    _resetEmail(address);
    notifyListeners();
  }
  bool get getConnected {
    return connected;
  }
  void setConnected (bool connect) {
    connected = connect;
    _resetConnected(connect);
    notifyListeners();
  }
  String get getPermanentLink {
    return permanentLink;
  }
  void setPermanentLink (String link) {
    permanentLink = link;
    _resetPermanentLink(link);
    notifyListeners();
  }


}

Future<String> _getPermanentLinkFromSharedPref() async {
  final prefs = await SharedPreferences.getInstance();
  final link = prefs.getString('permanent_link');
  return link;
}

Future<void> _resetPermanentLink(String link) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('permanent_link', link);
}

Future<String> _getEmailFromSharedPref() async {
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email');
  if (email == null) {
    return "";
  }
  return email;
}

Future<void> _resetEmail(String email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('email', email);
}

Future<bool> _getConnectedFromSharedPref() async {
  final prefs = await SharedPreferences.getInstance();
  bool connected = prefs.getBool('connected');
  if (connected == null) {
    return false;
  }
  return connected;
}

Future<void> _resetConnected(bool connected) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('connected', connected);
}


Future<String> _getInstallIdFromSharedPref() async {
  final prefs = await SharedPreferences.getInstance();
  String installId = prefs.getString('install_id');
  if (installId == null) {
    installId = premiumPayAPI.createInstallId();
    await prefs.setString('install_id', installId);
  }
  return installId;
}

Future<bool> _getFeatureActivationFromSharedPref(Feature value) async {
  final prefs = await SharedPreferences.getInstance();
  bool activated = prefs.getBool(value.feature_id + "_activated");
  if (activated == null) {
    activated = false;
    await prefs.setBool(value.feature_id + "_activated", false);
  }
  return activated;
}

Future<String> _getTokenFromSharedPref(Feature value) async {
  final prefs = await SharedPreferences.getInstance();
  String token = prefs.getString(value.feature_id + "_token");
  return token;
}


Future<void> _resetFeatureActivation(Feature value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(value.feature_id + "_activated", true);
}

Future<void> _resetToken(Feature value, String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(value.feature_id + "_token", token);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
        ChangeNotifierProvider.value(
        value: Data(),
    ),
    ],
    child: MaterialApp(
      title: 'App Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DemoAccessPage(),
    )
    );
  }
}

class DemoAccessPage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Jewish Time",
            style: TextStyle(fontSize: 25),
          ),
        ),
        body: FutureBuilder<bool>(
            future: Provider.of<Data>(context).init(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                Feature feat_1 = Provider.of<Data>(context).getFeature_1;
                Feature feat_2 = Provider.of<Data>(context).getFeature_2;
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.6,
                                  child:
                                  Text(
                                  feat_1.feature_name + " feature: ",
                                  softWrap: true,
                                  maxLines: 3,
                                  style: TextStyle(
                                      color: Colors.blue[900], fontSize: 18),
                                )),
                                feat_1.activated
                                    ? Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 30,
                                )
                                    : FlatButton(
                                  child: Text(
                                    'activate',
                                    style: TextStyle(
                                        color: Colors.blue[900],
                                        fontSize: 20,
                                        fontStyle: FontStyle.italic,
                                        decoration: TextDecoration.underline),
                                  ),
                                  onPressed: ()  {
                                     Navigator.push<Object>(
                                      context,
                                      MaterialPageRoute<dynamic>(
                                          builder: (context) => DemoConnectPage()),
                                    );
                                  },
                                )
                              ],
                            )

                      ,
                      SizedBox(
                        height: 60,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            feat_2.feature_name + " feature: ",
                            softWrap: true,
                            maxLines: 3,
                            style: TextStyle(
                                color: Colors.blue[900], fontSize: 18),
                          )),
                          feat_2.activated
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 30,
                                )
                              : FlatButton(
                            child: Text(
                              'activate',
                              style: TextStyle(
                                  color: Colors.blue[900],
                                  fontSize: 20,
                                  fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.underline),
                            ),
                            onPressed: ()  {
                              Navigator.push<Object>(
                                context,
                                MaterialPageRoute<dynamic>(
                                    builder: (context) => DemoConnectPage()),
                              ) ;
                            },
                          )
                        ],
                      ),
                          SizedBox(height: 40,),
                          FlatButton(
                            child: Text(
                              'access to my account',
                              style: TextStyle(
                                  color: Colors.blue[900],
                                  fontSize: 17,
                                  fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.underline),
                            ),
                            onPressed: ()  {
                              Navigator.push<Object>(
                                context,
                                MaterialPageRoute<dynamic>(
                                    builder: (context) => DemoConnectPage()),
                              );
                            },
                          )

                    ]));
              } else {
                return Center(child:Text("Loading...",style: TextStyle( color: Colors.blue[900], fontSize: 18),) ,);
              }
            }));
  }
}

class DemoConnectPage extends StatefulWidget {


  DemoConnectPage(
      {Key key})
      : super(key: key);

  @override
  _DemoConnectPageState createState() => _DemoConnectPageState();

}

class _DemoConnectPageState extends State<DemoConnectPage> {
  TextEditingController email_controller = new TextEditingController();
  bool resend_email;
  bool accept_promo_offers;
  String msg;
  bool showIcon;
  bool accept_conditions_of_utilisation;
  bool need_to_accept_conditions;
//  bool accountValidate;
  bool invalidToken_1;
  bool invalidToken_2;
  SyncResult syncResult ;
  ConnectResult connectResult;
  TextEditingController token_controller_1;
  TextEditingController token_controller_2;

  @override
  void initState() {
    /*   if(syncResult.status==SyncStatus.SUCCESSFUL_SYNC || connectResult.status==ConnectStatus.SUCCESSFUL_CONNECT || connectResult.status==ConnectStatus.NEED_TO_VERIFY_EMAIL){
      connected=true;
    }
    else{
      connected=false;
    }*/
    super.initState();
    resend_email = false;
    accept_promo_offers = false;
    msg = "";
    showIcon = false;
    accept_conditions_of_utilisation = false;
    need_to_accept_conditions = false;
 //   accountValidate = false;
    invalidToken_1 = false;
    invalidToken_2 = false;
    token_controller_1 = new TextEditingController();
    token_controller_2 = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    bool connected = Provider.of<Data>(context).getConnected;
    String application_id = Provider.of<Data>(context).getAppId;
    String install_id = Provider.of<Data>(context).getInstallId;
    String email = Provider.of<Data>(context).getEmail;
    Feature feat_1 = Provider.of<Data>(context).getFeature_1;
    Feature feat_2 = Provider.of<Data>(context).getFeature_2;
    String permanentLink = Provider.of<Data>(context).getPermanentLink;
    List<String> features = [feat_1.feature_id, feat_2.feature_id];
    email_controller.text = Provider.of<Data>(context).getEmail;
    if(feat_1.activated){
      token_controller_1.text =  feat_1.token;
    }
    if(feat_2.activated){
      token_controller_2.text =  feat_2.token;
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Premium features',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Visibility(
                visible: !connected,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Text(
                          "To activate premium features you need to link your installation to your account.",
                          softWrap: true,
                          maxLines: 3,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.blue[900], fontSize: 18)),
                    ),
                  ],
                )),
            SizedBox(height: 20),

            (connected)?

            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Container(
                      height: 400,
                      width: MediaQuery.of(context).size.width * 0.85,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1.5, color: Colors.blue[700])),
                      child:Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                              "Your install ID: \n$install_id",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.blue[900]))

                          ,
                          SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * 0.70,
                                decoration: BoxDecoration(
                                  //  border: Border.all(color: Colors.blue[700],width: 1),
                                    color: Colors.grey[300]
                                ),
                                child: TextField(
                                  keyboardType: TextInputType.emailAddress,
                                  readOnly: true,
                                  controller: email_controller,
                                  decoration: InputDecoration(
                                    prefixStyle:
                                    TextStyle(color: Colors.blue[900]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                   SizedBox(
                                      width: 150,
                                      height: 45,
                                      child: RaisedButton(
                                        textColor: Colors.white,
                                        padding: const EdgeInsets.all(0.0),
                                        child: Center(
                                          child: Container(
                                            constraints:
                                            BoxConstraints.expand(),
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: <Color>[
                                                  Color(0xFF0D47A1),
                                                  Color(0xFF1976D2),
                                                  Color(0xFF42A5F5),
                                                ],
                                              ),
                                            ),
                                            padding:
                                            const EdgeInsets.all(10.0),
                                            child: Center(
                                                child: Text(
                                                  "Disconnect",
                                                  style: TextStyle(fontSize: 20),
                                                )),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            Provider.of<Data>(context, listen: false).setConnected(false);
                                            Provider.of<Data>(context, listen: false).setPermanentLink("");
                                            //  connectResult.status =
                                            //     ConnectStatus.NOT_CONNECTED;
                                            //  syncResult.status =
                                            //      SyncStatus.NOT_CONNECTED;
                                            msg = "";

                                          });
                                        },
                                      )),
                              SizedBox(
                                width: 10,
                              ),
                              SizedBox(
                                  width: 150,
                                  height: 45,
                                  child: new RaisedButton(
                                    textColor: Colors.white,
                                    padding: const EdgeInsets.all(0.0),
                                    child: Center(
                                      child: Container(
                                        constraints: BoxConstraints.expand(),
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: <Color>[
                                              Color(0xFF0D47A1),
                                              Color(0xFF1976D2),
                                              Color(0xFF42A5F5),
                                            ],
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(10.0),
                                        child: Center(
                                            child: Text(
                                                 "Sync",
                                                style:
                                                TextStyle(fontSize: 20))),
                                      ),
                                    ),
                                    onPressed: () async {
                                        setState(() {
                                          showIcon = true;
                                          msg = "";
                                        });

                                         syncResult = await premiumPayAPI.syncRequest(install_id,email);

                                        Provider.of<Data>(context, listen: false).setPermanentLink(syncResult.permanentLink);

                                      if(syncResult.tokens.isNotEmpty){

                                      (syncResult.tokens.length == 1) ?
                                      msg = syncResult.tokens.length.toString() + " token loaded.\n"
                                          :
                                      msg = syncResult.tokens.length.toString() + " tokens loaded.\n";

                                      for (int i = 0; i < syncResult.tokens.length; i++) {

                                      if (feat_1.feature_id == syncResult.tokens[i].featureId) {

                                        Provider.of<Data>(context, listen: false).activateFeature_1(syncResult.tokens[i].token);
                                      token_controller_1.text = feat_1.token;
                                      }
                                      if (feat_2.feature_id == syncResult.tokens[i].featureId) {

                                        Provider.of<Data>(context, listen: false).activateFeature_2(syncResult.tokens[i].token);
                                      token_controller_2.text = feat_2.token;
                                      }
                                      }
                                      setState(() {
                                      showIcon = false;
                                      });
                                      }

                                        switch(syncResult.status){

                                          case SyncStatus.INSTALLATION_LINKED : {
                                            setState(() {
                                              showIcon = false;
                                              msg = msg +
                                              "The installation is linked to the account.";
                                            });
                                            break;
                                          }
                                          case SyncStatus.INSTALLATION_NOT_LINKED : {
                                            setState(() {
                                              showIcon = false;
                                              msg = msg +
                                              "The installation is not linked to the account.";
                                            });
                                            break;
                                          }
                                        }
                                    },
                                  )),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Visibility(
                            visible: showIcon,
                            child: SizedBox(
                              child: CircularProgressIndicator(),
                              width: 30,
                              height: 30,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                           Padding(
                              padding:
                              EdgeInsets.only(right: 12, left: 10),
                              child: Text(msg,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: ((syncResult != null &&  syncResult.status ==
                                          SyncStatus.INSTALLATION_NOT_LINKED) || ( connectResult != null && connectResult.status != ConnectStatus.SUCCESSFUL_CONNECT  ))
                                          ? Colors.red
                                          : Colors.green))),
                          Visibility(
                              visible: (permanentLink != null),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text("Activate premium features in",
                                      style: TextStyle(
                                          color: Colors.blue[900],
                                          fontSize: 18)),
                                  FlatButton(
                                    onPressed: () async {
                                      String url = permanentLink;
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    },
                                    child: Text(
                                      "website.",
                                      style: TextStyle(
                                          color: Colors.blue[900],
                                          fontSize: 18,
                                          decoration:
                                          TextDecoration.underline),
                                    ),
                                  )
                                ],
                              )),
                        ],
                      )),

                ])
                :
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: 600,
                        width: MediaQuery.of(context).size.width * 0.85,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1.5, color: Colors.blue[700])),
                        child: SingleChildScrollView(child:Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                                      Text(
                                        "Your install ID: \n${install_id}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.blue[900]))

                                ,
                            SizedBox(height: 20),
                             Text(
                                  "Enter your email address:",
                                  style: TextStyle(
                                      color: Colors.blue[900], fontSize: 18),
                                ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width * 0.70,
                                  decoration: BoxDecoration(
                                      //  border: Border.all(color: Colors.blue[700],width: 1),
                                      color: Colors.white),
                                  child: TextField(
                                    keyboardType: TextInputType.emailAddress,
                                    readOnly: false,
                                    controller: email_controller,
                                    onEditingComplete: () {
                                      if (!EmailValidator.validate(
                                          email_controller.text)) {
                                        setState(() {
                                          msg =
                                              "Please enter a valid email address.";
                                        });
                                      } else {
                                        setState(() {
                                          msg = "";
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      prefixStyle:
                                          TextStyle(color: Colors.blue[900]),
                                      errorText:
                                          (msg != "" )
                                              ? msg
                                              : null,
                                      hintText: 'address@mail.com',
                                      hintStyle: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey,
                                          fontSize: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Checkbox(
                                      value: resend_email,
                                      onChanged: (newValue) {
                                        setState(() {
                                          resend_email = newValue;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text("Resend email.",
                                        style:
                                            TextStyle(color: Colors.blue[900]))
                                  ],
                                ),
                             LayoutBuilder(
                                builder: (context, constraints) => Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Checkbox(
                                      value: accept_promo_offers,
                                      onChanged: (newValue) {
                                        setState(() {
                                          accept_promo_offers = newValue;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      width: constraints.maxWidth - 5 - 48,
                                      child: Text(
                                          "I accept to receive promotional offers emails.",
                                          softWrap: true,
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: Colors.blue[900])),
                                    ),
                                  ],
                                ),
                              ),
                            Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Checkbox(
                                      value: accept_conditions_of_utilisation,
                                      onChanged: (newValue) {
                                        setState(() {
                                          accept_conditions_of_utilisation =
                                              newValue;
                                          if (accept_conditions_of_utilisation) {
                                            need_to_accept_conditions = false;
                                          }
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                        "I accept the conditions of use.",
                                        style: TextStyle(
                                            color: (need_to_accept_conditions)
                                                ? Colors.red
                                                : Colors.blue[900]))
                                  ],
                                ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                    width: 150,
                                    height: 45,
                                    child: new RaisedButton(
                                      textColor: Colors.white,
                                      padding: const EdgeInsets.all(0.0),
                                      child: Center(
                                        child: Container(
                                          constraints: BoxConstraints.expand(),
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: <Color>[
                                                Color(0xFF0D47A1),
                                                Color(0xFF1976D2),
                                                Color(0xFF42A5F5),
                                              ],
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(10.0),
                                          child: Center(
                                              child: Text(
                                                  "Connect",
                                                  style:
                                                      TextStyle(fontSize: 20))),
                                        ),
                                      ),
                                      onPressed: () async {
                                          if (!accept_conditions_of_utilisation) {
                                            setState(() {
                                              need_to_accept_conditions = true;
                                            });
                                          }
                                          if (EmailValidator.validate(
                                                  email_controller.text) &&
                                              accept_conditions_of_utilisation) {
                                            setState(() {
                                              showIcon = true;
                                            });
                                            Provider.of<Data>(context, listen: false).setEmail(email_controller.text);
                                            Install install = premiumPayAPI.createInstall(
                                                install_id,
                                                 application_id,
                                                features);
                                             connectResult =
                                                await premiumPayAPI.connectRequest(install, email,
                                                    resendEmail: resend_email,
                                                    acceptPromoOffers: accept_promo_offers);
                                            setState(() {
                                              showIcon = false;
                                            });
                                            switch(connectResult.status){
                                              case ConnectStatus.NEED_TO_VERIFY_EMAIL:{
                                                setState(() {
                                                  Provider.of<Data>(context, listen: false).setConnected(true);
                                                  msg =
                                                  "Check your email and click on the link provided to link your installation.";
                                                });
                                                break;
                                              }
                                              case ConnectStatus.SUCCESSFUL_CONNECT: {
                                                setState(() {
                                                  Provider.of<Data>(context, listen: false).setConnected(true);
                                                });
                                                break;
                                              }

                                            }

                                          }

                                      },
                                    )),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Visibility(
                              visible: showIcon,
                              child: SizedBox(
                                child: CircularProgressIndicator(),
                                width: 30,
                                height: 30,
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                             Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                      "After connecting, an email will be sent to the address email given above.\nIn order to link your installation to your account, you need to click on the link in the email sent.",
                                      style: TextStyle(
                                          color: Colors.blue[900],
                                          fontSize: 18)),
                                ),
                          ],
                        ))),

                  ]),
            SizedBox(
              height: 10,
            ),
            Text("Tokens to deblock features:",
                style:
                TextStyle(color: Colors.blue[900], fontSize: 18)),
            SizedBox(
              height: 20,
            ),
            Text(feat_1.feature_name,
                style:
                TextStyle(color: Colors.blue[900], fontSize: 18)),
            SizedBox(
              height: 10,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.75,
                    decoration: BoxDecoration(
                      border: new Border.all(color: Colors.blue[600]),
                      color: feat_1.activated
                          ? Colors.grey
                          : Colors.white,
                    ),
                    child: TextField(
                      controller: token_controller_1,
                      readOnly: feat_1.activated,
                      onEditingComplete: () async {
                        bool verified =
                        premiumPayAPI.checkTokenValidFormat(token_controller_1.text) &&
                             premiumPayAPI.verifyToken(install_id, feat_1.feature_id, token_controller_1.text);
                        if (verified) {
                            Provider.of<Data>(context, listen: false).activateFeature_1(token_controller_1.text);

                        } else {
                          setState(() {
                            invalidToken_1 = true;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        prefixStyle: TextStyle(color: Colors.blue[900]),
                        //    errorText: (!tokenValidity && token_controller.text!="")? "Invalid token.": tokenValidity?"Feature added.":"",
                        hintText: 'Please enter the token here: ',
                        hintStyle: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                            fontSize: 15),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  IconButton(
                    iconSize: 25,
                    icon: Icon(Icons.send),
                    color: Colors.blue[900],
                    onPressed: () async {
                      bool verified =
                      premiumPayAPI.checkTokenValidFormat(token_controller_1.text) &&
                       premiumPayAPI.verifyToken(install_id, feat_1.feature_id, token_controller_1.text);
                      if (verified) {
                        Provider.of<Data>(context, listen: false).activateFeature_1(token_controller_1.text);
                      } else {
                        setState(() {
                          invalidToken_1 = true;
                        });
                      }
                    },
                  )
                ]),
            SizedBox(
              height: 10,
            ),
            Visibility(
                visible: feat_1.activated,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Feature added.",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Colors.green),
                      )
                    ])),
            Visibility(
                visible: invalidToken_1,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Invalid token.",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Colors.red),
                      )
                    ])),
            SizedBox(
              height: 10,
            ),
            Text(feat_2.feature_name,
                style:
                TextStyle(color: Colors.blue[900], fontSize: 18)),
            SizedBox(
              height: 10,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.75,
                    decoration: BoxDecoration(
                      border: new Border.all(color: Colors.blue[600]),
                      color: feat_2.activated
                          ? Colors.grey
                          : Colors.white,
                    ),
                    child: TextField(
                      controller: token_controller_2,
                      readOnly: feat_2.activated,
                      onEditingComplete: () async {
                        bool verified =
                        premiumPayAPI.checkTokenValidFormat(token_controller_2.text)
                            && premiumPayAPI.verifyToken(install_id, feat_2.feature_id, token_controller_2.text);
                        if (verified) {
                          Provider.of<Data>(context, listen: false).activateFeature_2(token_controller_2.text);
                        } else {
                          setState(() {
                            invalidToken_2 = true;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        prefixStyle: TextStyle(color: Colors.blue[900]),
                        //    errorText: (!tokenValidity && token_controller.text!="")? "Invalid token.": tokenValidity?"Feature added.":"",
                        hintText: 'Please enter the token here: ',
                        hintStyle: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                            fontSize: 15),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  IconButton(
                    iconSize: 25,
                    icon: Icon(Icons.send),
                    color: Colors.blue[900],
                    onPressed: () async {
                      bool verified =
                      premiumPayAPI.checkTokenValidFormat(token_controller_2.text)
                          && premiumPayAPI.verifyToken(install_id,
                          feat_2.feature_id,
                          token_controller_2.text);
                      if (verified) {
                        Provider.of<Data>(context, listen: false).activateFeature_2(token_controller_2.text);

                      } else {
                        setState(() {
                          invalidToken_2 = true;
                        });
                      }
                    },
                  )
                ]),
            SizedBox(
              height: 10,
            ),
            Visibility(
                visible: feat_2.activated,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Feature added.",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Colors.green),
                      )
                    ])),
            Visibility(
                visible: invalidToken_2,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Invalid token.",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Colors.red),
                      )
                    ])),
            SizedBox(height: 20,)

          ],
        ),
      ),
    );
  }
}
