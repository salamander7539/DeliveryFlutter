import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/identify.dart';
import 'package:faem_app/data/data.dart';

class AmplitudeAnalytics{

  static Amplitude analytics;
  static String apiKey = 'e0a9f43456e45fc41f68e3d8a149d18d';

  static  Future<Amplitude> initialize(String user_id) async {


    analytics = Amplitude.getInstance(instanceName: "Faem Eda");
    analytics.setServerUrl("https://api2.amplitude.com");
    analytics.init(apiKey);
    analytics.enableCoppaControl();
    await analytics.setUserId(user_id);
    analytics.trackingSessionEvents(true);

    return analytics;
  }
}