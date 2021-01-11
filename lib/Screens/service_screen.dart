import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../Internet/check_internet.dart';
import '../GetData/getTicketByFilter.dart';
import '../data/data.dart';
import '../Models/TicketModel.dart';
import 'home_screen.dart';
import 'service_orders_story.dart';
import 'tickets_chat_screen.dart';

class ServiceScreen extends StatefulWidget {
  @override
  ServiceScreenState createState() => ServiceScreenState();
}

class ServiceScreenState extends State<ServiceScreen> {

  TicketModel ticketModel;
  TicketsListRecord ticketsListRecord;

  @override
  Widget build(BuildContext context) {
    var format1 = new DateFormat('dd.MM.yy, HH:mm');
    // TODO: implement build
    return Scaffold(
        body: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Padding(
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
                                  'assets/svg_images/arrow_left.svg'),
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
                            "Служба поддержки",
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
              ),
              Divider(height: 1.0, color: Color(0xFFB9B9B9)),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(top: 30, left: 16, bottom: 10),
                        child: Text('Ваши вопросы',
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFB9B9B9))),
                      ),
                    ),
                    ListTile(
                      leading: Padding(
                        padding: EdgeInsets.only(bottom: 15, top: 15),
                        child: Text(
                          'Ошибка в заказе',
                          style: TextStyle(fontSize: 17, color: Color(0xFF424242)),
                        ),
                      ),
                      trailing: Padding(
                        padding: EdgeInsets.only(bottom: 15, top: 15),
                        child:
                        SvgPicture.asset('assets/svg_images/arrow_right.svg'),
                      ),
                      onTap: () async {
                        if (await Internet.checkConnection()) {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                              builder: (context) => new ServiceOrdersStoryScreen(
                                ticketModel: new TicketModel(
                                    title: '[ЕДА] Ошибка в заказе', description: ''),
                              ),
                            ),
                          );
                        } else {
                          noConnection(context);
                        }
                      },
                    ),
                    Divider(height: 1.0, color: Color(0xFFB9B9B9)),
                    ListTile(
                      leading: Padding(
                        padding: EdgeInsets.only(bottom: 15, top: 15),
                        child: Text(
                          'Ошибка стоимости',
                          style: TextStyle(fontSize: 17, color: Color(0xFF424242)),
                        ),
                      ),
                      trailing: Padding(
                        padding: EdgeInsets.only(bottom: 15, top: 15),
                        child:
                        SvgPicture.asset('assets/svg_images/arrow_right.svg'),
                      ),
                      onTap: () async {
                        if (await Internet.checkConnection()) {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                              builder: (context) => new ServiceOrdersStoryScreen(
                                  ticketModel: new TicketModel(
                                      title: '[ЕДА] Ошибка стоимости', description: '')),
                            ),
                          );
                        } else {
                          noConnection(context);
                        }
                      },
                    ),
                    Divider(height: 1.0, color: Color(0xFFB9B9B9)),
                    ListTile(
                      leading: Padding(
                        padding: EdgeInsets.only(bottom: 15, top: 15),
                        child: Text(
                          'Ошибка программмы',
                          style: TextStyle(fontSize: 17, color: Color(0xFF424242)),
                        ),
                      ),
                      trailing: Padding(
                        padding: EdgeInsets.only(bottom: 15, top: 15),
                        child:
                        SvgPicture.asset('assets/svg_images/arrow_right.svg'),
                      ),
                      onTap: () async {
                        if (await Internet.checkConnection()) {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                              builder: (context) => new ServiceOrdersStoryScreen(
                                  ticketModel: new TicketModel(
                                      title: '[ЕДА] Ошибка программмы', description: '')),
                            ),
                          );
                        } else {
                          noConnection(context);
                        }
                      },
                    ),
                    Divider(height: 1.0, color: Color(0xFFB9B9B9)),
                    ListTile(
                      leading: Padding(
                        padding: EdgeInsets.only(bottom: 15, top: 15),
                        child: Text(
                          'Другая причина',
                          style: TextStyle(fontSize: 17, color: Color(0xFF424242)),
                        ),
                      ),
                      trailing: Padding(
                        padding: EdgeInsets.only(bottom: 15, top: 15),
                        child:
                        SvgPicture.asset('assets/svg_images/arrow_right.svg'),
                      ),
                      onTap: () async {
                        if (await Internet.checkConnection()) {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                              builder: (context) => new ServiceOrdersStoryScreen(
                                  ticketModel: new TicketModel(
                                      title: '[ЕДА] Другая причина', description: '')),
                            ),
                          );
                        } else {
                          noConnection(context);
                        }
                      },
                    ),
                    Divider(height: 1.0, color: Colors.grey),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(top: 30, left: 16, bottom: 10),
                        child: Text('Мои обращения',
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFB9B9B9))),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: FutureBuilder<TicketsList>(
                        future:
                        getTicketsByFilter(1, 0, necessaryDataForAuth.phone_number),
                        builder:
                            (BuildContext context, AsyncSnapshot<TicketsList> snapshot) {
                          if (snapshot.connectionState == ConnectionState.done &&
                              snapshot.data != null) {
                            if(snapshot.data.records == null && snapshot.data.recordsCount == 0){
                              return Container();
                            }
                            var format = new DateFormat(' HH:mm  dd.MM.yyyy');
                            snapshot.data.records.sort((var a, var b) {
                              if(a.status == b.status)
                                return 0;
                              if(a.status == "resolved")
                                return 1;
                              return -1;
                            });
                            return Container(
                              child: ListView(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                children: List.generate(snapshot.data.recordsCount, (index){
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 15.0, right: 15, top: 10, bottom: 10),
                                    child: GestureDetector(
                                      child: Container(
                                        height: 90,
                                        padding: EdgeInsets.only(right: 10, left: 15),
                                        decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 8.0, // soften the shadow
                                                spreadRadius: 3.0, //extend the shadow
                                              )
                                            ],
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10.0),
                                            border: Border.all(width: 1.0, color: Colors.grey[200])),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                                                  child: Text(snapshot.data.records[index].title,
                                                    style: TextStyle(
                                                      fontSize: 18
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(right: 0.0),
                                                          child: SvgPicture.asset('assets/svg_images/clock.svg'),
                                                        ),
                                                        Text(format.format(DateTime.fromMillisecondsSinceEpoch(snapshot.data.records[index].createdAtUnix * 1000)),
                                                          style: TextStyle(
                                                              color: Color(0xFF9B9B9B),
                                                              fontSize: 11
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Row(
                                                      children: [
                                                        Text((snapshot.data.records[index].status == "resolved") ? 'Обработанно' : 'В обработке',
                                                          style: TextStyle(
                                                              fontSize: 18
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 8.0),
                                                          child: (snapshot.data.records[index].status == "resolved") ? SvgPicture.asset('assets/svg_images/delivered.svg') : SvgPicture.asset('assets/svg_images/unresolved.svg'),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () async {
                                        if (await Internet.checkConnection()) {
                                          Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                  builder: (context) =>
                                                  new TicketsChatScreen(
                                                    order_uuid: snapshot.data.records[index].uuid,
                                                    time: format.format(DateTime.fromMillisecondsSinceEpoch(snapshot.data.records[index].createdAtUnix * 1000)),
                                                  ))
                                          );
                                        } else {
                                          noConnection(context);
                                        }
                                        print('OYAOYA');
                                      },
                                    ),
                                  );
                                }),
                              ),
                            );
                          }
                          return Padding(
                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.13),
                            child: Center(
                              child: SpinKitFadingCircle(
                                color: Colors.green,
                                size: 50.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}