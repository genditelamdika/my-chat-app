import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mychat/firebase_options.dart';

class AnalyticsEngine {
  static final _instance = FirebaseAnalytics.instance;

  static Future<void> init() {
    return Firebase.initializeApp(
      options:DefaultFirebaseOptions.currentPlatform,
    );
  }
  static void userLogsIn(String loginMethod)
  async {
    return _instance.logLogin(loginMethod:loginMethod);
  }

  static void addsItemToCart(String ItemId, int cost) async {
    return _instance.logAddToCart(items: [AnalyticsEventItem(itemId: ItemId, price: cost)]);
  }
  static void counterPressed(String username) async {
    return _instance.logEvent(name: username);
  }
}