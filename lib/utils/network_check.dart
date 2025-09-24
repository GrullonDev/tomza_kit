import 'dart:io';

/// Attempts to determine whether the device has an active internet
/// connection. It first tries DNS lookup for a reliable host (google.com)
/// and falls back to opening a socket to 8.8.8.8:53.
Future<bool> hasInternetConnection({Duration timeout = const Duration(seconds: 3)}) async {
  try {
    final result = await InternetAddress.lookup('example.com').timeout(timeout);
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } catch (_) {
    // ignore and try socket fallback
  }

  try {
    final socket = await Socket.connect('8.8.8.8', 53, timeout: timeout);
    socket.destroy();
    return true;
  } catch (_) {
    return false;
  }
}
