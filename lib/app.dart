import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:faem_app/Screens/device_id_screen.dart';

class MyApp extends StatelessWidget {
  FirebaseAnalytics analytics = FirebaseAnalytics();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Faem Eda",
      theme: ThemeData(
        primaryColor: Color(0xFF67C070),
        cursorColor: Color(0xFF67C070),
        unselectedWidgetColor: Color(0xFF67C070),
        selectedRowColor: Color(0xFF67C070),
        toggleableActiveColor: Color(0xFF67C070),
      ),
      home: DeviceIdScreen(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}
