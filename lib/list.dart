import 'package:device_id/device_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const NetworkSecurity STA_DEFAULT_SECURITY = NetworkSecurity.WPA;

class WifiList extends StatefulWidget {
  @override
  _WifiListState createState() => _WifiListState();
}

class _WifiListState extends State<WifiList> {
  List<ListTile> _wifiList = new List();
  TextEditingController _passwordCtrl = TextEditingController();

  @override
  initState() {
    super.initState();
    getWifiList();
  }

  Future<void> confirmDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Input password'),
            content: SingleChildScrollView(
              child: TextField(
                controller: _passwordCtrl,
                decoration: InputDecoration(hintText: 'Masukkan password'),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Submit'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  handleConnect(network) async {
    // await confirmDialog();
    var bssid = network.bssid;
    var deviceId = await DeviceId.getID;
    try {
      var response = await WiFiForIoTPlugin.connect(
          network.ssid
      );
      if (response == true) {
        print("connect");
        String url = DotEnv().env['BASE_URL'] + "login?deviceId=$deviceId&bssid=$bssid";
        print("===================");
        var response2 = await http.get(url);
        print(response2.statusCode);
        if (response2.statusCode == 200) {
          Scaffold
            .of(context)
            .showSnackBar(SnackBar(content: Text('Connected')));
        } else {
          throw("cannot access internet");
        }

      } else {
        Scaffold
            .of(context)
            .showSnackBar(SnackBar(content: Text('Connection failed')));
        throw("cannot connect to this network");
      }

      _passwordCtrl.text = '';
    } catch (e) {
      print(e);
    }
  }

  handleDisconnect(network) async {
    WiFiForIoTPlugin.disconnect();
  }

  Future<Null> getWifiList() async {
    List<WifiNetwork> networks;
    List<ListTile> wifiList = new List();
    String ssid = await WiFiForIoTPlugin.getSSID();
    bool connected;
    try {
      networks = await WiFiForIoTPlugin.loadWifiList();
    } on PlatformException {
      networks = new List<WifiNetwork>();
    }
    if (networks != null && networks.length > 0) {
      networks.forEach((network) {
        PopupCommand oCmdConnect = new PopupCommand("Connect", network.ssid);
        PopupCommand oCmdRemove = new PopupCommand("Remove", network.ssid);
        List<PopupMenuItem<PopupCommand>> popupMenuItems = new List();
        popupMenuItems.add(
          new PopupMenuItem<PopupCommand>(
            value: oCmdConnect,
            child: const Text('Connect'),
          ),
        );

        popupMenuItems.add(
          new PopupMenuItem<PopupCommand>(
            value: oCmdRemove,
            child: const Text('Disconnect'),
          ),
        );
        connected = ssid == network.ssid;
        wifiList.add(ListTile(
          title: Text(network.ssid),
          trailing: FlatButton(
            onPressed: () async {
              if (connected) {
                setState(() {
                  connected = false;
                });
                return handleDisconnect(network);
              }
              setState(() {
                  connected = true;
              });
              return handleConnect(network);
            },
            child: connected ? Text("disconnect") : Text("connect", style: TextStyle(fontSize: 12, color: Colors.red)),
          ),
        ));
      });
    }

    setState(() {
      _wifiList = wifiList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: getWifiList,
      child: ListView(
        children: _wifiList,
      ),
    );
  }
}

class PopupCommand {
  String command;
  String argument;

  PopupCommand(this.command, this.argument) {
    ///
  }
}
