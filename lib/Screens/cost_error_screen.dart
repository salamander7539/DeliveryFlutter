import 'package:flutter/material.dart';
import 'package:faem_app/Internet/check_internet.dart';
import 'package:faem_app/PostData/service_data_pass.dart';
import 'package:faem_app/data/data.dart';
import 'package:faem_app/Models/TicketModel.dart';
import 'package:flutter_svg/svg.dart';
import 'home_screen.dart';

class CostErrorScreen extends StatefulWidget {
  final TicketModel ticketModel;

  CostErrorScreen({Key key, this.ticketModel}) : super(key: key);

  @override
  CostErrorScreenState createState() =>
      CostErrorScreenState(ticketModel: ticketModel);
}

class CostErrorScreenState extends State<CostErrorScreen> {
  final TicketModel ticketModel;

  CostErrorScreenState({this.ticketModel});

  TextEditingController descField = new TextEditingController();

  showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop(true);
        });
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          child: Container(
            height: 150,
            width: 300,
            child: Padding(
                padding: EdgeInsets.only(top: 0, left: 15, right: 15),
                child: Center(
                  child: Text(
                    'Ваше сообщение отправлено, его рассмотрят в ближайшее время',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                )
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    descField.text = ticketModel.description;
    // TODO: implement build
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 30, bottom: 0),
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: InkWell(
                        child: Padding(
                            padding: EdgeInsets.only(),
                            child: Container(
                                height: 50,
                                width: 60,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 15, bottom: 15, right: 15),
                                  child: Center(
                                    child: SvgPicture.asset(
                                        'assets/svg_images/arrow_left.svg'),
                                  ),
                                ))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          ticketModel.title,
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
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(top: 100),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: Column(
                          children: <Widget>[
                            Flexible(
                              flex: 1,
                              child: Text(
                                'Вы можете написать подробный комментарий\nо доставке или сообщить какую-либо\nинформацию о заказе',
                                style: TextStyle(color: Color(0xFF424242), fontSize: 14),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(right: 150, top: 10),
                                child: Stack(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 160, top: 0),
                                        child: Text(
                                          '*',
                                          style: TextStyle(color: Color(0xFFFC5B58), fontSize: 14),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 10, right: 40),
                                        child: Text(
                                          'Комментарий',
                                          style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 4,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 100),
                          child: Container(
                            height: 345,
                            width: 320,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7.0),
                                border: Border.all(width: 1.0, color: Colors.grey[200])),
                            child: TextField(
                              minLines: 1,
                              maxLines: 100,
                              controller: descField,
                              textCapitalization: TextCapitalization.sentences,
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 14),
                              keyboardType: TextInputType.text,
                              decoration: new InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                border: InputBorder.none,
                                counterText: '',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(left: 0, top: 20, bottom: 20),
                child: FlatButton(
                  child: Text(
                    "Отправить",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  color: Color(0xFF67C070),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                  EdgeInsets.only(left: 130, top: 20, right: 130, bottom: 20),
                  onPressed: () async {
                    if (await Internet.checkConnection()) {
                      ticketModel.description = descField.text;
                      showAlertDialog(context);
                      await loadServiceData(ticketModel);
                      Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                          builder: (context) => new HomeScreen(),
                        ),
                      );
                    } else {
                      noConnection(context);
                    }
                  },
                ),
              ),
            )
          ],
        ));
  }
}
