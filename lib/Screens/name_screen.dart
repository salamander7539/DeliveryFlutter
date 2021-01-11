import 'package:flutter/material.dart';
import 'package:faem_app/Config/config.dart';
import 'package:faem_app/Internet/check_internet.dart';
import 'package:faem_app/data/data.dart';
import 'package:faem_app/Models/amplitude.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';
import 'home_screen.dart';

class NameScreen extends StatefulWidget {
  NameScreen({Key key}) : super(key: key);

  @override
  NameScreenState createState() => NameScreenState();
}

class NameScreenState extends State<NameScreen> {
  GlobalKey<ButtonState> buttonStateKey = new GlobalKey<ButtonState>();
  TextEditingController nameFieldController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                      padding: EdgeInsets.only(left: 15, top: 40),
                      child: Container(
                          height: 40,
                          width: 60,
                          child: Padding(
                            padding:
                                EdgeInsets.only(top: 12, bottom: 12, right: 30),
                            child: SvgPicture.asset(
                                'assets/svg_images/arrow_left.svg'),
                          )))),
              onTap: () => Navigator.pop(context),
            ),
            Align(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 0, bottom: 15),
                        child: Text('Как вас зовут?',
                            style: TextStyle(
                                fontSize: 24,
                                )),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding:
                          EdgeInsets.only(right: 30, left: 30, bottom: 100),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            flex: 1,
                            child: Padding(
                                padding: EdgeInsets.only(left: 15, right: 15),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xF5F5F5F5),
                                      borderRadius: BorderRadius.circular(7.0),
                                      border: Border.all(
                                          width: 1.0,
                                          color: Color(0xF5F5F5F5))),
                                  child: TextField(
                                    controller: nameFieldController,
                                    textAlign: TextAlign.start,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    style: TextStyle(
                                        fontSize: 18,),
                                    keyboardType: TextInputType.text,
                                    decoration: new InputDecoration(
                                      hintText: 'Ваше имя',
                                      contentPadding: EdgeInsets.only(left: 15),
                                      hintStyle: TextStyle(
                                          color: Color(0xFFB5B5B5),
                                          fontSize: 18),
                                      border: InputBorder.none,
                                      counterText: '',
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 17),
                child: Container(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: 20),
                            child: Button(
                              key: buttonStateKey,
                              color: Color(0xFF67C070),
                              onTap: () async {
                                if (await Internet.checkConnection()) {
                                  necessaryDataForAuth.name = nameFieldController.text;
                                  currentUser.isLoggedIn = true;
                                  await NecessaryDataForAuth.saveData();
                                  print(necessaryDataForAuth.name);
                                  homeScreenKey =
                                      new GlobalKey<HomeScreenState>();
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen()),
                                      (Route<dynamic> route) => false);
                                } else {
                                  noConnection(context);
                                }
                              },
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            )
          ],
        ));
  }
}

class Button extends StatefulWidget {
  Color color;
  VoidCallback onTap;

  Button({Key key, this.color, this.onTap}) : super(key: key);

  @override
  ButtonState createState() {
    return new ButtonState(color, onTap: onTap);
  }
}

class ButtonState extends State<Button> {
  String error = '';
  Color color;
  final VoidCallback onTap;

  ButtonState(this.color, {this.onTap});


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FlatButton(
      child: Text('Далее',
          style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Colors.white)),
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.only(left: 130, top: 20, right: 130, bottom: 20),
      onPressed: () async {
        await onTap();
      },
    );
  }
}
