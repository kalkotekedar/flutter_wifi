import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_wifi/flutter_wifi.dart';
import 'dart:io' show Platform;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Wifi',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _wifiName = 'click button to get wifi ssid.';
  int level = 0;
  String _ip = 'click button to get ip.';
  String _currentWifiState = 'click here to get current wifi state';
  String _changeWifiState = "click here to change wifi state";
  List<WifiResult> ssidList = [];
  String ssid = '', password = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wifi'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.all(8.0),
          itemCount: ssidList.length + 1,
          itemBuilder: (BuildContext context, int index) {
            return itemSSID(index);
          },
        ),
      ),
    );
  }

  Widget itemSSID(index) {
    if (index == 0) {
      return Column(
        children: [
          Row(
            children: <Widget>[
              RaisedButton(
                child: Text('ssid'),
                onPressed: _getWifiName,
              ),
              Offstage(
                offstage: level == 0,
                child: Image.asset(
                    level == 0 ? 'images/wifi1.png' : 'images/wifi$level.png',
                    width: 28,
                    height: 21),
              ),
              Text(_wifiName),
            ],
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                child: Text('ip'),
                onPressed: _getIP,
              ),
              Text(_ip),
            ],
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                child: Text('currentWifiState'),
                onPressed: _getWifiStatus,
              ),
              Text(_currentWifiState),
            ],
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                child: Text('changeWifiState'),
                onPressed: _changeWifiStatus,
              ),
              Text(_changeWifiState),
            ],
          ),
          TextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              icon: Icon(Icons.wifi),
              hintText: 'Your wifi ssid',
              labelText: 'ssid',
            ),
            keyboardType: TextInputType.text,
            onChanged: (value) {
              ssid = value;
            },
          ),
          TextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              icon: Icon(Icons.lock_outline),
              hintText: 'Your wifi password',
              labelText: 'password',
            ),
            keyboardType: TextInputType.text,
            onChanged: (value) {
              password = value;
            },
          ),
          RaisedButton(
            child: Text('connection'),
            onPressed: connection,
          ),
        ],
      );
    } else {
      return Column(children: <Widget>[
        ListTile(
          leading: Image.asset('images/wifi${ssidList[index - 1].level}.png',
              width: 28, height: 21),
          title: Text(
            ssidList[index - 1].ssid,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16.0,
            ),
          ),
          dense: true,
        ),
        Divider(),
      ]);
    }
  }

  void loadData() async {
    if (Platform.isIOS) {
      // TODO: iOS list SSID is not done
      setState(() {
        ssidList = [];
      });
    } else {
      FlutterWifi.list(filter: '').then((list) {
        setState(() {
          ssidList = list;
        });
      });
    }
  }

  Future<Null> _getWifiName() async {
    int l = await FlutterWifi.level;
    String wifiName = await FlutterWifi.ssid;
    setState(() {
      level = l;
      _wifiName = wifiName;
    });
  }

  Future<Null> _getIP() async {
    String ip = await FlutterWifi.ip;
    setState(() {
      _ip = ip;
    });
  }

  Future<Null> connection() async {
    FlutterWifi.connection(ssid, password).then((v) {
      print(v);
    });
  }

  Future<Null> _getWifiStatus() async {
    bool result = await FlutterWifi.isWifiEnabled();
    setState(() {
      _currentWifiState = result ? "Enabled" : "Disabled";
    });
  }

  Future<Null> _changeWifiStatus() async {
    bool result = await FlutterWifi.turnWifiOnOff(enable: true);
    setState(() {
      _changeWifiState = result ? "Done" : "Not Done";
    });
  }
}
