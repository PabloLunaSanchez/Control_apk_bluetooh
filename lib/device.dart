import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothDeviceListEntry extends StatelessWidget {
  final Function onTap;
  final BluetoothDevice device;

  const BluetoothDeviceListEntry({required this.onTap, required this.device});

  @override
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      leading: Icon(Icons.devices),
      title: Text(device.name ?? "Dispositivo desconcido"),
      subtitle: Text(device.address.toString()),
      trailing: ElevatedButton(
        child: Text('Conectar'),
        onPressed: () {
          if (onTap != null) {
            onTap();
          }
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue),
        ),
      ),
    );
  }
}
