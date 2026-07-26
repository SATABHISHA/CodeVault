import '../../../features/printers/domain/wireless_printing.dart';

enum AndroidRuntimePermission {
  bluetoothScan,
  bluetoothConnect,
  nearbyWifiDevices,
  locationWhenInUse,
  usb,
}

class PrinterPermissionPolicy {
  const PrinterPermissionPolicy();
  Set<AndroidRuntimePermission> requiredFor(
    AndroidPrinterTransport transport, {
    required int sdkInt,
  }) => switch (transport) {
    AndroidPrinterTransport.bluetoothClassic || AndroidPrinterTransport.ble =>
      sdkInt >= 31
          ? {
              AndroidRuntimePermission.bluetoothScan,
              AndroidRuntimePermission.bluetoothConnect,
            }
          : {AndroidRuntimePermission.locationWhenInUse},
    AndroidPrinterTransport.wifi when sdkInt >= 33 => {
      AndroidRuntimePermission.nearbyWifiDevices,
    },
    AndroidPrinterTransport.usbOtg => {AndroidRuntimePermission.usb},
    _ => const {},
  };
}
