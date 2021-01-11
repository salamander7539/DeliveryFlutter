import 'package:flutter/material.dart';
import 'package:faem_app/Config/config.dart';
import 'package:faem_app/Screens/home_screen.dart';
import 'package:faem_app/data/data.dart';
import 'package:faem_app/Models/CartDataModel.dart';
import 'package:faem_app/Models/amplitude.dart';
import 'package:transparent_image/transparent_image.dart';

class DeviceIdScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: FutureBuilder<NecessaryDataForAuth>(
        future: NecessaryDataForAuth.getData(),
        builder:
            (BuildContext context, AsyncSnapshot<NecessaryDataForAuth> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            CartDataModel.getCart().then((value) {
              currentUser.cartDataModel = value;
              print('Cnjbn');
            });
            necessaryDataForAuth = snapshot.data;
            if (necessaryDataForAuth.refresh_token == null ||
                necessaryDataForAuth.phone_number == null ||
                necessaryDataForAuth.name == null) {
              currentUser.isLoggedIn = false;
              AmplitudeAnalytics.initialize(necessaryDataForAuth.device_id).then((value){
                AmplitudeAnalytics.analytics.logEvent('open_app');
              });
              return HomeScreen();
            }
            print(necessaryDataForAuth.refresh_token);
            AmplitudeAnalytics.initialize(necessaryDataForAuth.phone_number).then((value){
              AmplitudeAnalytics.analytics.logEvent('open_app');
            });
            return HomeScreen();
          } else {
            return Center(
                child: Image(
                  image: AssetImage('assets/images/faem.png'),
                )
            );
          }
        },
      ),
    );
  }
}