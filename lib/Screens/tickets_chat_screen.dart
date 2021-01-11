import 'package:flutter/material.dart';
import 'package:faem_app/GetData/getTicketByUuid.dart';
import 'package:faem_app/data/data.dart';
import 'package:faem_app/PutData/sendTicketMessage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import '../Internet/check_internet.dart';
import '../Models/TicketModel.dart';
import 'home_screen.dart';

class TicketsChatScreen extends StatefulWidget {
  String order_uuid;
  String time;

  TicketsChatScreen({Key key, this.order_uuid, this.time}) : super(key: key);

  @override
  TicketsChatScreenState createState() {
    return new TicketsChatScreenState(order_uuid, time);
  }
}

class TicketsChatScreenState extends State<TicketsChatScreen>
    with WidgetsBindingObserver {
  List<TicketsChatMessageScreen> chatMessageList;
  String order_uuid;
  String time;

  TicketsChatScreenState(this.order_uuid, this.time);

  TextEditingController messageField = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  buildChat() {
    return Scaffold(
      backgroundColor: Colors.white,
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Align(
            alignment: Alignment.topCenter,
            child: Text(
              'Обращение ' + time,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
            ),
          ),
          leading: InkWell(
            child: Container(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 20, bottom: 20),
                  child: SvgPicture.asset(
                      'assets/svg_images/arrow_left.svg'),
                )),
            onTap: () {
              Navigator.pop(context);
            },
          )
        ),
        body: Stack(
          children: <Widget>[
            Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: MediaQuery.of(context).viewInsets.left,
              right: MediaQuery.of(context).viewInsets.right,
              child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Column(
                      children: [
                        Container(
                          color: Colors.white,
                          height: MediaQuery.of(context).size.height * 0.9,
                          child: Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: ListView.builder(
                              reverse: true,
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.vertical,
                              itemCount: chatMessageList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return chatMessageList[chatMessageList.length - 1 - index];
                              },
                              //chatMessageList
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 40, bottom: 10),
                          child: Container(
                            color: Colors.white,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                      height: 40,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 15, left: 15),
                                        child: TextField(
                                          controller: messageField,
                                          decoration: new InputDecoration(
                                            contentPadding: EdgeInsets.only(bottom: 5, left: 10, right: 15),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(
                                                  const Radius.circular(15.0),
                                                ),
                                                borderSide: BorderSide(
                                                    color: Color(0xFFC8C7CC)
                                                )
                                            ),
                                            border: new OutlineInputBorder(
                                              borderRadius: const BorderRadius.all(
                                                const Radius.circular(15.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 15),
                                  child: InkWell(
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      child: Padding(
                                        padding: EdgeInsets.all(6),
                                        child: SvgPicture.asset(
                                            'assets/svg_images/send_message.svg'),
                                      ),
                                    ),
                                    onTap: () async {
                                      if (await Internet.checkConnection()) {
                                        var message = await sendTicketMessage(
                                          order_uuid,
                                          messageField.text,
                                        );
                                        setState(() {
                                          GlobalKey<TicketsChatMessageScreenState>
                                          chatMessageScreenStateKey = new GlobalKey<
                                              TicketsChatMessageScreenState>();
                                          if(messageField.text.length != 0){
                                            chatMessageList.add(
                                                new TicketsChatMessageScreen(
                                                    key: chatMessageScreenStateKey,
                                                    comment: new Comment(
                                                        createdAtUnix: DateTime.now().microsecond,
                                                        message: messageField.text,
                                                        senderType: 'client')));
                                          }
                                          messageField.clear();
                                        });
                                      } else {
                                        noConnection(context);
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
              ),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (chatMessageList != null) {
      print(chatMessageList.length);
      return buildChat();
    }
    return Container(
      color: Colors.white,
      child: FutureBuilder<TicketsListRecord>(
        future: getTicketByUuid(order_uuid),
        builder:
            (BuildContext context, AsyncSnapshot<TicketsListRecord> snapshot) {
          print('tututuwapatututuwapa ' + order_uuid);
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            //ticketsChatMessagesStates.clear();
            chatMessageList = new List<TicketsChatMessageScreen>();
            chatMessageList.add(new TicketsChatMessageScreen(comment: new Comment(
                senderType: 'client',
                message: snapshot.data.description,
                createdAtUnix: snapshot.data.createdAtUnix
            ),));
            if(snapshot.data.comments != null)
              snapshot.data.comments.forEach((element) {
                GlobalKey<ChatMessageScreenState> chatMessageScreenStateKey =
                new GlobalKey<ChatMessageScreenState>();
                //ticketsChatMessagesStates[element.uuid] = chatMessageScreenStateKey;
                chatMessageList.add(new TicketsChatMessageScreen(
                    comment: element, key: chatMessageScreenStateKey));
              });
            return buildChat();
          } else {
            return Center(
              child: SpinKitFadingCircle(
                color: Colors.green,
                size: 50.0,
              ),
            );
          }
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class TicketsChatMessageScreen extends StatefulWidget {
  Comment comment;

  TicketsChatMessageScreen({Key key, this.comment}) : super(key: key);

  @override
  TicketsChatMessageScreenState createState() {
    return new TicketsChatMessageScreenState(comment);
  }
}

class TicketsChatMessageScreenState extends State<TicketsChatMessageScreen> {
  Comment chatMessage;

  TicketsChatMessageScreenState(this.chatMessage);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Column(
        children: <Widget>[
          (chatMessage.senderType != 'client')
              ? Padding(
            padding: EdgeInsets.only(right: 15),
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xFFE5E6EA),
                        borderRadius: BorderRadius.circular(17.0),
                        border: Border.all(
                            width: 1.0, color: Color(0xFFE5E6EA))),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        chatMessage.message,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            decoration: TextDecoration.none),
                      ),
                    )),
              ),
            ),
          )
              : Padding(
            padding: EdgeInsets.only(left: 15),
            child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xFF67C070),
                          borderRadius: BorderRadius.circular(17.0),
                          border: Border.all(
                              width: 1.0, color: Color(0xFF67C070))),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          chatMessage.message,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              decoration: TextDecoration.none),
                        ),
                      )),
                )),
          ),
        ],
      ),
    );
  }
}