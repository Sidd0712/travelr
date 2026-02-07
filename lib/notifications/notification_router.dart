import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationRouter {
  static void handleForegroundNotification(RemoteMessage message) {
    switch (message.data['type']) {
      case 'CHAT':
        // show banner
        break;

      case 'ETA_UPDATE':
        // update ETA state
        break;
    }
  }

  static void handleNotificationTap(RemoteMessage message) {
    switch (message.data['type']) {
      case 'CHAT':
        // navigate to chat
        break;

      case 'MATCH_FOUND':
        // open match screen
        break;
    }
  }
}
