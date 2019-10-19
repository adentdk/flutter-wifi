import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;
import 'package:device_id/device_id.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ListWifiItem extends StatefulWidget {
  ListWifiItem({Key key, this.network}) : super(key: key);
  WifiNetwork network;
  _ListWifiItemState createState() => _ListWifiItemState(); 
}

class _ListWifiItemState extends State<ListWifiItem> {
  bool connected;

  initConnected() {
    setState(() async {
      connected = widget.network.ssid == await WiFiForIoTPlugin.getSSID();
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
    } catch (e) {
      print(e);
    }
  }

  handleDisconnect(network) async {
    WiFiForIoTPlugin.disconnect();
  }

  Widget build(BuildContext context) {
    return ListTile(
          title: Text(widget.network.ssid),
          trailing: FlatButton(
            onPressed: () async {
              if (connected) {
                setState(() {
                  connected = false;
                });
                return handleDisconnect(widget.network);
              }
              setState(() {
                  connected = true;
              });
              return handleConnect(widget.network);
            },
            child: connected ? Text("disconnect") : Text("connect", style: TextStyle(fontSize: 12, color: Colors.red)),
          ),
        );
  }
}
