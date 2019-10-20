import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity/connectivity.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:adawifi/list.dart';

const NetworkSecurity STA_DEFAULT_SECURITY = NetworkSecurity.WPA;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Connectivity _connectivity = new Connectivity();
  bool isWifiEnable = false;
  var listener;

  void initState() {
    super.initState();
    isWifiEnabled();
    listener = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.wifi && await WiFiForIoTPlugin.isEnabled() == true) {
        setState(() {
          isWifiEnable = true;
        });
      } else {
        setState(() {
          isWifiEnable = false;
        });
      }
    });
  }

  void dispose() {
    super.dispose();
    listener.cancel();
  }

  void handleChangeWifi(bool value) async {
    await WiFiForIoTPlugin.setEnabled(value);
    setState(() {
      isWifiEnable = value;
    });
  }

  Future<bool> isWifiEnabled() async {
    bool isEnable;
    isEnable = await WiFiForIoTPlugin.isEnabled();
    if (isEnable) {
      setState(() {
        isWifiEnable = true;
      });
    }
    return isEnable;
  }

  Future<bool> checkLocationPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.location);

    return permission == PermissionStatus.granted;
  }

  Future<bool> requestLocationPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler()
            .requestPermissions([PermissionGroup.location]);

    return permissions[PermissionGroup.location] == PermissionStatus.granted;
  }

  Future<bool> isConnected() async {
    bool isEnabledAndGranted;

    try {
      bool isEnabled = await WiFiForIoTPlugin.isEnabled();
      bool isGranted = await checkLocationPermission();
      if (isGranted == false) {
        await requestLocationPermission();
        isGranted = await checkLocationPermission();
      }

      if (isEnabled == true && isGranted) {
        isEnabledAndGranted = true;
      }
    } on PlatformException {
      isEnabledAndGranted = false;
    }

    if (!mounted) return true;

    return isEnabledAndGranted;
  }

  handleNavigate() {
    Navigator.pushNamed(context, '/detail');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Switch(
            value: isWifiEnable,
            onChanged: (value) {
             handleChangeWifi(!isWifiEnable);
            },
            activeTrackColor: Colors.lightGreenAccent, 
            activeColor: Colors.green,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Show Snackbar',
            onPressed: handleNavigate,
          ),
        ],
      ),
      body: isWifiEnable ? Container(
        child: FutureBuilder(
          future: isConnected(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data == true) {
                return WifiList();
              }
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ) : Center(
        child: GestureDetector(
          onTap: () => handleChangeWifi(true),
          child: Text("Turn on Wifi")
          )
        ),
    );
  }
}
