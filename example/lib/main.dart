import 'dart:html';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_premiumpay_package/flutter_premiumpay_package.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class Feature {
  final String feature_id;
  final String feature_name;
  bool activated;
  String token;

  Feature(this.feature_id, this.feature_name) {
    activated = false;
  }
}

class Data {
  String application_id;
  String install_id;
  Feature feature_1;
  Feature feature_2;
  List<String> features;
  String email;
  bool connected;
  String permanentLink;
  TextEditingController token_controller_1;
  TextEditingController token_controller_2;

  Data(){
    feature_1 = new Feature("jewish-time#1", "Jewish Time Premium");
    feature_2 = new Feature("jewish-time#2", "Custom background");
    features = [feature_1.feature_id, feature_2.feature_id];
    token_controller_1 = new TextEditingController();
    token_controller_2 = new TextEditingController();
  }
}

Future<String> _getPermanentLinkFromSharedPref() async {
  final prefs = await SharedPreferences.getInstance();
  final link = prefs.getString('permanent_link');
  if (link == null) {
    return "";
  }
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

Future<String> _getAppIdFromSharedPref() async {
  final prefs = await SharedPreferences.getInstance();
  final appId = prefs.getString('application_id');
  if (appId == null) {
    await _resetAppId("jewish-time");
    return "jewish-time";
  }
  return appId;
}

Future<String> _getInstallIdFromSharedPref() async {
  final prefs = await SharedPreferences.getInstance();
  String installId = prefs.getString('install_id');
  if (installId == null) {
    await _resetInstallId();
    installId = prefs.getString('install_id');
  }
  return installId;
}

Future<bool> _getFeatureActivationFromSharedPref(Feature value) async {
  final prefs = await SharedPreferences.getInstance();
  bool activated = prefs.getBool(value.feature_id + "_activated");
  if (activated == null) {
    activated = false;
    value.activated = false;
    await prefs.setBool(value.feature_id + "_activated", false);
  }
  return activated;
}

Future<String> _getTokenFromSharedPref(Feature value) async {
  final prefs = await SharedPreferences.getInstance();
  String token = prefs.getString(value.feature_id + "_token");
  return token;
}

Future<void> _resetInstallId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('install_id', premiumPayAPI.createInstallId());
}

Future<void> _resetAppId(String app) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('application_id', app);
}

Future<void> _resetFeatureActivation(Feature value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(value.feature_id + "_activated", true);
  value.activated = true;
}

Future<void> _resetToken(Feature value, String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(value.feature_id + "_token", token);
  value.token = token;
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DemoAccessPage(),
    );
  }
}

class DemoAccessPage extends StatefulWidget {
  @override
  _DemoAccessPageState createState() => _DemoAccessPageState();
}

class _DemoAccessPageState extends State<DemoAccessPage> {

  Data data;
  Future<bool> initialisation;

  @override
  void initState() {

    super.initState();
    data = Data();
    initialisation = init();
  }

  Future<bool> init() async {
    data.feature_1.activated = await _getFeatureActivationFromSharedPref(data.feature_1);
    data.feature_2.activated = await _getFeatureActivationFromSharedPref(data.feature_2);
    if (data.feature_1.activated) {
      data.feature_1.token = await _getTokenFromSharedPref(data.feature_1);
      data.token_controller_1.text = data.feature_1.token;
    }
    if (data.feature_2.activated) {
      data.feature_2.token = await _getTokenFromSharedPref(data.feature_2);
      data.token_controller_2.text = data.feature_2.token;
    }

    data.email = await _getEmailFromSharedPref();
    data.connected = await _getConnectedFromSharedPref();
    data.application_id = await _getAppIdFromSharedPref();
    data.install_id =await  _getInstallIdFromSharedPref();
    data.permanentLink = await _getPermanentLinkFromSharedPref();
    return true;
  }

 void refresh() {
    setState(() {});
  }

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
            future: initialisation,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
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
                                  data.feature_1.feature_name + " feature: ",
                                  softWrap: true,
                                  maxLines: 3,
                                  style: TextStyle(
                                      color: Colors.blue[900], fontSize: 18),
                                )),
                                data.feature_1.activated
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
                                  onPressed: () async {
                                    final dataBack = await Navigator.push<Object>(
                                      context,
                                      MaterialPageRoute<dynamic>(
                                          builder: (context) => DemoConnectPage(
                                              notifyParent: refresh,
                                              data:data
                                          )),
                                    ) as Data;

                                    data.application_id = dataBack.application_id;
                                    data.install_id = dataBack.install_id;
                                    data.feature_1 = dataBack.feature_1;
                                    data.feature_2 = dataBack.feature_2;
                                    data.features = dataBack.features;
                                    data.email = dataBack.email;
                                    data.connected = dataBack.connected;
                                    data.token_controller_1 = dataBack.token_controller_1;
                                    data.token_controller_2 = dataBack.token_controller_2;
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
                            data.feature_2.feature_name + " feature: ",
                            softWrap: true,
                            maxLines: 3,
                            style: TextStyle(
                                color: Colors.blue[900], fontSize: 18),
                          )),
                          data.feature_2.activated
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
                            onPressed: () async {
                              final dataBack = await Navigator.push<Object>(
                                context,
                                MaterialPageRoute<dynamic>(
                                    builder: (context) => DemoConnectPage(
                                        notifyParent: refresh,
                                        data : data
                                    )),
                              ) as Data;

                              data.application_id = dataBack.application_id;
                              data.install_id = dataBack.install_id;
                              data.feature_1 = dataBack.feature_1;
                              data.feature_2 = dataBack.feature_2;
                              data.features = dataBack.features;
                              data.email = dataBack.email;
                              data.connected = dataBack.connected;
                              data.token_controller_1 = dataBack.token_controller_1;
                              data.token_controller_2 = dataBack.token_controller_2;
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
                            onPressed: () async {
                              final dataBack = await Navigator.push<Object>(
                                context,
                                MaterialPageRoute<dynamic>(
                                    builder: (context) => DemoConnectPage(
                                        notifyParent: refresh,
                                        data : data
                                    )),
                              ) as Data;

                              data.application_id = dataBack.application_id;
                              data.install_id = dataBack.install_id;
                              data.feature_1 = dataBack.feature_1;
                              data.feature_2 = dataBack.feature_2;
                              data.features = dataBack.features;
                              data.email = dataBack.email;
                              data.connected = dataBack.connected;
                              data.token_controller_1 = dataBack.token_controller_1;
                              data.token_controller_2 = dataBack.token_controller_2;
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

  final Function() notifyParent;
  final Data data;


  DemoConnectPage(
      {Key key,
      @required this.notifyParent, this.data})
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
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.connected) email_controller.text = widget.data.email;
    return Scaffold(
      appBar: AppBar(
        leading:  IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: (){Navigator.pop(context,widget.data);}
        ),
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
                visible: !widget.data.connected,
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

            (widget.data.connected)?

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
                              "Your install ID: \n${widget.data.install_id}",
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
                                            _resetConnected(false);
                                            widget.data.connected = false;
                                            //  connectResult.status =
                                            //     ConnectStatus.NOT_CONNECTED;
                                            //  syncResult.status =
                                            //      SyncStatus.NOT_CONNECTED;
                                            msg = "";
                                       //     accountValidate = false;
                                            _resetPermanentLink("");
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

                                         syncResult = await premiumPayAPI.syncRequest(widget.data.install_id);
                                        widget.data.permanentLink =
                                            syncResult.permanentLink;
                                        _resetPermanentLink(syncResult.permanentLink);

                                        switch(syncResult.status){

                                          case SyncStatus.ACTIVATED_TOKEN :{

                                            (syncResult.tokens.length == 1) ?
                                            msg = syncResult.tokens.length.toString() + " token loaded."
                                                :
                                            msg = syncResult.tokens.length.toString() + " tokens loaded.";

                                            for (int i = 0; i < syncResult.tokens.length; i++) {

                                              if (widget.data.feature_1.feature_id == syncResult.tokens[i].featureId) {

                                                _resetFeatureActivation(widget.data.feature_1);
                                                _resetToken(widget.data.feature_1, syncResult.tokens[i].token);
                                                widget.data.token_controller_1.text = widget.data.feature_1.token;
                                              }
                                              if (widget.data.feature_2.feature_id == syncResult.tokens[i].featureId) {

                                                await _resetFeatureActivation(widget.data.feature_2);
                                                await _resetToken(widget.data.feature_2, syncResult.tokens[i].token);
                                                widget.data.token_controller_2.text = widget.data.feature_2.token;
                                              }
                                            }
                                            setState(() {
                                              showIcon = false;
                                            });
                                            widget.notifyParent();
                                            break;
                                          }
                                          case SyncStatus.INSTALLATION_LINKED : {
                                            setState(() {
                                              showIcon = false;
                                              msg =
                                              "The installation is linked but no feature has been added.";
                                            });
                                            break;
                                          }
                                          case SyncStatus.INSTALLATION_NOT_LINKED : {
                                            setState(() {
                                              showIcon = false;
                                              msg =
                                              "The installation need to be linked to an account.";
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
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: ((syncResult != null &&  syncResult.status ==
                                          SyncStatus.INSTALLATION_NOT_LINKED) || ( connectResult != null && connectResult.status == ConnectStatus.NEED_TO_VERIFY_EMAIL  ))
                                          ? Colors.red
                                          : Colors.green))),
                          Visibility(
                              visible: (widget.data.permanentLink != ""),
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
                                      String url = widget.data.permanentLink;
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
                                        "Your install ID: \n${widget.data.install_id}",
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
                                            widget.data.email =
                                                email_controller.text;
                                            _resetEmail(email_controller.text);
                                            Install install = premiumPayAPI.createInstall(
                                                await widget.data.install_id,
                                                await widget.data.application_id,
                                                widget.data.features);
                                             connectResult =
                                                await premiumPayAPI.connectRequest(install, widget.data.email,
                                                    resendEmail: resend_email,
                                                    acceptPromoOffers: accept_promo_offers);
                                            setState(() {
                                              showIcon = false;
                                            });
                                            switch(connectResult.status){
                                              case ConnectStatus.NEED_TO_VERIFY_EMAIL:{
                                                setState(() {
                                                  widget.data.connected = true;
                                                  _resetConnected(true);
                                                  msg =
                                                  "Check your email and click on the link provided to link your installation.";
                                                });
                                                break;
                                              }
                                              case ConnectStatus.SUCCESSFUL_CONNECT: {
                                                setState(() {
                                              //    accountValidate = true;
                                                  widget.data.connected = true;
                                                  _resetConnected(true);
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
            Text(widget.data.feature_1.feature_name,
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
                      color: widget.data.feature_1.activated
                          ? Colors.grey
                          : Colors.white,
                    ),
                    child: TextField(
                      controller: widget.data.token_controller_1,
                      readOnly: widget.data.feature_1.activated,
                      onEditingComplete: () async {
                        bool verified =
                        widget.data.token_controller_1.text.length == 96
                            ? premiumPayAPI.verifyToken(await widget.data.install_id, widget.data.feature_1.feature_id, widget.data.token_controller_1.text)
                            : false;
                        if (verified) {
                          setState(() {
                            widget.data.feature_1.activated = true;
                            _resetFeatureActivation(widget.data.feature_1);
                            widget.data.feature_1.token =
                                widget.data.token_controller_1.text;
                            _resetToken(widget.data.feature_1,
                                widget.data.token_controller_1.text);
                          });
                        } else {
                          setState(() {
                            invalidToken_1 = true;
                          });
                          widget.notifyParent();
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
                      widget.data.token_controller_1.text.length == 96
                          ? premiumPayAPI.verifyToken(await widget.data.install_id, widget.data.feature_1.feature_id, widget.data.token_controller_1.text)
                          : false;
                      if (verified) {
                        setState(() {
                          widget.data.feature_1.activated = true;
                          _resetFeatureActivation(widget.data.feature_1);
                          widget.data.feature_1.token =
                              widget.data.token_controller_1.text;
                          _resetToken(widget.data.feature_1,
                              widget.data.token_controller_1.text);
                        });
                      } else {
                        setState(() {
                          invalidToken_1 = true;
                        });
                        widget.notifyParent();
                      }
                    },
                  )
                ]),
            SizedBox(
              height: 10,
            ),
            Visibility(
                visible: widget.data.feature_1.activated,
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
            Text(widget.data.feature_2.feature_name,
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
                      color: widget.data.feature_2.activated
                          ? Colors.grey
                          : Colors.white,
                    ),
                    child: TextField(
                      controller: widget.data.token_controller_2,
                      readOnly: widget.data.feature_2.activated,
                      onEditingComplete: () async {
                        bool verified =
                        premiumPayAPI.checkTokenValidFormat(widget.data.token_controller_2.text)
                            ? premiumPayAPI.verifyToken(await widget.data.install_id, widget.data.feature_2.feature_id, widget.data.token_controller_2.text)
                            : false;
                        if (verified) {
                          setState(() {
                            widget.data.feature_2.activated = true;
                            _resetFeatureActivation(widget.data.feature_2);
                            widget.data.feature_2.token =
                                widget.data.token_controller_2.text;
                            _resetToken(widget.data.feature_2,
                                widget.data.token_controller_2.text);
                          });
                          widget.notifyParent();
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
                      premiumPayAPI.checkTokenValidFormat(widget.data.token_controller_2.text)
                          ? premiumPayAPI.verifyToken(await widget.data.install_id,
                          widget.data.feature_2.feature_id,
                          widget.data.token_controller_2.text)
                          : false;
                      if (verified) {
                        setState(() {
                          widget.data.feature_2.activated = true;
                          _resetFeatureActivation(widget.data.feature_2);
                          widget.data.feature_2.token =
                              widget.data.token_controller_2.text;
                          _resetToken(widget.data.feature_2,
                              widget.data.token_controller_2.text);
                        });
                        widget.notifyParent();
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
                visible: widget.data.feature_2.activated,
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
