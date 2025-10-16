import 'dart:async';
import 'dart:io';

class NetworkUtils {
  static Future<bool> hasInternet({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    const dnsIp = '1.1.1.1';
    const dnsPort = 53;

    try {
      final socket = await Socket.connect(
        InternetAddress(dnsIp),
        dnsPort,
        timeout: timeout,
      );
      socket.destroy();
      return true;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
