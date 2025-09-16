/// PushService: stub para notificaciones push.
library;

class PushService {
  Future<void> initialize() async {
    // TODO: Integrar con Firebase Messaging u otro proveedor.
  }

  Future<void> subscribeToTopic(String topic) async {}
  Future<void> unsubscribeFromTopic(String topic) async {}
}
