import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:faem_app/Config/config.dart';
import 'package:faem_app/Internet/check_internet.dart';
import 'package:faem_app/Screens/home_screen.dart';
import 'package:faem_app/Screens/tickets_chat_screen.dart';
import 'package:faem_app/Models/Auth.dart';
import 'package:faem_app/Models/AuthCode.dart';
import 'package:faem_app/Models/RestaurantDataItems.dart';
import 'package:faem_app/Models/user.dart';
import 'package:flutter_svg/svg.dart';

Map<String,GlobalKey<OrderCheckingState>> orderCheckingStates = new Map<String,GlobalKey<OrderCheckingState>>();
Map<String,GlobalKey<ChatMessageScreenState>> chatMessagesStates = new Map<String,GlobalKey<ChatMessageScreenState>>();
Map<String,GlobalKey<TicketsChatMessageScreenState>> ticketsChatMessagesStates = new Map<String,GlobalKey<TicketsChatMessageScreenState>>();
GlobalKey<HomeScreenState>homeScreenKey = new GlobalKey<HomeScreenState>(debugLabel: 'homeScreenKey');
var home  = new MaterialPageRoute(
  builder: (context) => new HomeScreen(),
);
RestaurantDataItems restaurantDataItems = null;
GlobalKey<ChatScreenState>chatKey = new GlobalKey<ChatScreenState>();
AuthCodeData authCodeData = null;
AuthData authData = null;
String FCMToken = '';
int code = 0;
NecessaryDataForAuth necessaryDataForAuth = new NecessaryDataForAuth(phone_number: null, refresh_token: null, device_id: null, name: null);

var DeliveryStates = [
  'cooking',
  'offer_offered',
  'smart_distribution',
  'finding_driver',
  'offer_rejected',
  'order_start',
  'on_place',
  'waiting_for_confirmation',
  'on_the_way',
  'order_payment'
];


// User
final currentUser = User(
  cartDataModel: null,
  name: '',
  orders: [
  ],
);
//checking on internet connection
noConnection(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pop(true);
      });
      return Center(
        child: Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          child: Container(
            height: 50,
            width: 100,
            child: Center(
              child: Text("Нет подключения к интернету"),
            ),
          ),
        ),
      );
    },
  );
}

// ignore: must_be_immutable
// for screen's title with navigator.pop
class ScreenTitlePop extends StatefulWidget {
  String title = '';
  String img = '';

  ScreenTitlePop({Key key, this.title, this.img}) : super(key: key);

  @override
  ScreenTitlePopState createState() {
    return new ScreenTitlePopState(title, img);
  }
}

class ScreenTitlePopState extends State<ScreenTitlePop> {
  String title = '';
  String img = '';

  ScreenTitlePopState(this.title, this.img);

  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(top: 30),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: InkWell(
                  child: Container(
                      height: 50,
                      width: 55,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 17, bottom: 17, right: 10),
                        child: SvgPicture.asset(
                            img),
                      )),
                  onTap: (){
                    Navigator.of(context).push(
                        PageRouteBuilder(
                            pageBuilder: (context, animation, anotherAnimation) {
                              return HomeScreen();
                            },
                            transitionDuration: Duration(milliseconds: 300),
                            transitionsBuilder:
                                (context, animation, anotherAnimation, child) {
//                                      animation = CurvedAnimation(
//                                          curve: Curves.bounceIn, parent: animation);
                              return SlideTransition(
                                position: Tween(
                                    begin: Offset(1.0, 0.0),
                                    end: Offset(0.0, 0.0))
                                    .animate(animation),
                                child: child,
                              );
                            }
                        ));
                  }
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 15),
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF424242)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

//for screen's title with pushAndRemoveUntil
class ScreenTitlePushAndRemoveUntil extends StatefulWidget {
  String title = '';
  String img = '';

  ScreenTitlePushAndRemoveUntil({Key key, this.title, this.img}) : super(key: key);

  @override
  ScreenTitlePushAndRemoveUntilState createState() {
    return new ScreenTitlePushAndRemoveUntilState(title, img);
  }
}

class ScreenTitlePushAndRemoveUntilState extends State<ScreenTitlePushAndRemoveUntil> {
  String title = '';
  String img = '';

  ScreenTitlePushAndRemoveUntilState(this.title, this.img);

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: InkWell(
              child: Container(
                  height: 50,
                  width: 60,
                  child: Padding(
                    padding:
                    EdgeInsets.only(top: 17, bottom: 17, right: 10),
                    child: SvgPicture.asset(
                        img),
                  )),
              onTap: () async {
                if (await Internet.checkConnection()) {
                  homeScreenKey = new GlobalKey<HomeScreenState>();
                  Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                          pageBuilder: (context, animation, anotherAnimation) {
                            return HomeScreen();
                          },
                          transitionDuration: Duration(milliseconds: 300),
                          transitionsBuilder:
                              (context, animation, anotherAnimation, child) {
//                                      animation = CurvedAnimation(
//                                          curve: Curves.bounceIn, parent: animation);
                            return SlideTransition(
                              position: Tween(
                                  begin: Offset(1.0, 0.0),
                                  end: Offset(0.0, 0.0))
                                  .animate(animation),
                              child: child,
                            );
                          }
                      ), (Route<dynamic> route) => false);
                } else {
                  noConnection(context);
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: 15),
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF424242)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

