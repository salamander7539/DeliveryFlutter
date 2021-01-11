import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:faem_app/Config/config.dart';
import 'package:faem_app/GetData/centrifugo.dart';
import 'package:faem_app/GetData/getImage.dart';
import 'package:faem_app/GetData/getOrder.dart';
import 'package:faem_app/GetData/getTicketByFilter.dart';
import 'package:faem_app/Internet/check_internet.dart';
import 'package:faem_app/PostData/RestarurantCategories.dart';
import 'package:faem_app/PostData/chat.dart';
import 'package:faem_app/GetData/orders_story_data.dart';
import 'package:faem_app/PostData/restaurant_data_pass.dart';
import 'package:faem_app/Screens/orders_details.dart';
import 'package:faem_app/Screens/profile_screen.dart';
import 'package:faem_app/Screens/restaurant_screen.dart';
import 'package:faem_app/Screens/service_screen.dart';
import 'package:faem_app/data/data.dart';
import 'package:faem_app/Models/ChatHistoryModel.dart';
import 'package:faem_app/Models/OrderStoryModel.dart';
import 'package:faem_app/Models/QuickMessagesModel.dart';
import 'package:faem_app/Models/RestaurantCategoriesModel.dart';
import 'package:faem_app/Models/centrifugo.dart';
import 'package:faem_app/Models/last_addresses_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:faem_app/Models/ResponseData.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth_screen.dart';
import 'device_id_screen.dart';
import 'infromation_screen.dart';
import 'my_addresses_screen.dart';
import 'orders_story_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen() : super(key: homeScreenKey);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver{
  List<OrderChecking> orderList;
  int page = 1;
  int limit = 12;
  bool isLoading = true;
  List<Records> records_items = new List<Records>();
  String category_uuid = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<BasketButtonState> basketButtonStateKey = new GlobalKey<BasketButtonState>();
  int records_count = -1;
  Amplitude analytics;
  final String apiKey = 'e0a9f43456e45fc41f68e3d8a149d18d';
  RestaurantCategories restaurantCategories;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('darova' + state.toString());
    if(state == AppLifecycleState.resumed){
      setState(() {

      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  _filter() {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
            )),
        context: context,
        builder: (context) {
          return Container(
            height: 420,
            child: _buildFilterNavigationMenu(),
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                )),
          );
        });
  }

  bool firstSelected = false;

  _buildFilterNavigationMenu() {
    return Container(
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 15, left: 20, bottom: 15),
              child: Text(
                'Отобразить сначала',
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          FilterListScreen(),
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 10),
            child: FlatButton(
              child: Text('Готово',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white)),
              color: Color(0xFF67C070),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.only(left: 140, top: 20, right: 140, bottom: 20),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
    );
  }


  _kitchensFilter(GlobalKey<KitchenListScreenState> kitchenListKey) {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
            )),
        context: context,
        builder: (context) {
          return Container(
            height: 600,
            child: _buildKitchensFilterNavigationMenu(kitchenListKey),
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                )),
          );
        });
  }

  bool filterSelect = false;


  _buildKitchensFilterNavigationMenu(GlobalKey<KitchenListScreenState> kitchenListKey) {
    return Container(
      height: 610,
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0, left: 15),
                child: Text(
                  'Кухни',
                  style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ),
          KitchenListScreen(key: kitchenListKey),

        ],
      ),
    );
  }


  _distanceFilter() {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
            )),
        context: context,
        builder: (context) {
          return Container(
            height: 400,
            child: _buildDistanceFilterNavigationMenu(),
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                )),
          );
        });
  }

  _buildDistanceFilterNavigationMenu() {
    return Container(
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 20),
              child: Text(
                'Показывать с отдаленностью',
                style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.only(left: 20, right: 15),
            title: Text('Доверюсь вам'),
            trailing: SvgPicture.asset('assets/svg_images/circle.svg'),
          ),
          ListTile(
            contentPadding: EdgeInsets.only(left: 20, right: 15),
            title: Text('С высоким рейтингом'),
            trailing: SvgPicture.asset('assets/svg_images/circle.svg'),
          ),
          ListTile(
            contentPadding: EdgeInsets.only(left: 20, right: 15),
            title: Text('Быстрые'),
            trailing: SvgPicture.asset('assets/svg_images/circle.svg'),
          ),
          ListTile(
            contentPadding: EdgeInsets.only(left: 20, right: 15),
            title: Text('Недорогие'),
            trailing: SvgPicture.asset('assets/svg_images/circle.svg'),
          ),
          ListTile(
            contentPadding: EdgeInsets.only(left: 20, right: 15),
            title: Text('Дорогие'),
            trailing: SvgPicture.asset('assets/svg_images/circle.svg'),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: FlatButton(
              child: Text('Готово',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white)),
              color: Color(0xFF67C070),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.only(left: 140, top: 20, right: 140, bottom: 20),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
    );
  }

  bool isExpanded = false;

  List<Widget> _buildRestaurantFoodCategoriesList(Records restaurant){
    List<Widget> result = new List<Widget>();

    restaurant.product_category.forEach((element) {
      result.add(Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: Container(
          padding: EdgeInsets.only(left: 8, right: 8, top: 0),
          height: 25,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xFFE6E6E6)
          ),
          child: Center(child: Text('#' + element[0].toUpperCase() + element.substring(1))),
        ),
      ));
    });
    return result;
  }



  _buildRestaurantsList() {
    DateTime now = DateTime.now();
    int currentTime = now.hour*60+now.minute;
    print((currentTime/60).toString() + 'KANTENT');
    print((now.hour).toString() + 'KANTENT');
    print((now.minute).toString() + 'KANTENT');
    int dayNumber  = now.weekday-1;
    List<Widget> restaurantList = [];
    records_items.forEach((Records restaurant) {
      int work_beginning = restaurant.work_schedule[dayNumber].work_beginning;
      int work_ending = restaurant.work_schedule[dayNumber].work_ending;
      bool day_off = restaurant.work_schedule[dayNumber].day_off;
      bool available = restaurant.available != null ? restaurant.available : true;
      restaurantList.add(InkWell(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8.0, // soften the shadow
                    spreadRadius: 3.0, //extend the shadow
                  )
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(width: 1.0, color: Colors.grey[200])),
            child: Column(
              children: <Widget>[
                ( day_off ||
                    !available ||
                    !(currentTime >= work_beginning && currentTime < work_ending)) ? Stack(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0)),
                        child: Hero(
                            tag: restaurant.uuid,
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.grey,
                                  BlendMode.saturation
                              ),
                              child: Image.network(
                                getImage(restaurant.image),
                                height: 200.0,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                              ),
                            ))),
                    Padding(
                      padding: const EdgeInsets.only(top: 150.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          height: 32,
                          width: 250,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20)
                              ),
                              color: Colors.black.withOpacity(0.5)
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8),
                              child: Text(
                                "Заведение откроется в ${(work_beginning / 60).toStringAsFixed(0)} часов",
                                style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ) : Stack(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0)),
                        child:  Hero(
                            tag: restaurant.uuid,
                            child: Image.network(
                              getImage(restaurant.image),
                              height: 200.0,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ))),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 15.0, top: 12, bottom: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          restaurant.name,
                          style: TextStyle(
                              fontSize: 21.0,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3F3F3F),),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      SizedBox(
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                padding: EdgeInsets.only(left: 8, right: 8, top: 0),
                                height: 25,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xFF67C070)
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset('assets/svg_images/rest_star.svg',
                                      color: Colors.white,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 3.0),
                                      child: Text('5.0',
                                        style: TextStyle(
                                            color: Colors.white
                                        ),
                                      ),
                                    )
                                  ],
                                )
                            ),
                            Container(
                              height: 25,
                              padding: EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xFFEFEFEF)
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5.0, left: 0),
                                    child: SvgPicture.asset(
                                        'assets/svg_images/rest_car.svg'),
                                  ),
                                  Text(
                                    (restaurant.order_preparation_time_second != null)? '~' + '${restaurant.order_preparation_time_second ~/ 60} мин' : '',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: Container(
                                height: 25,
                                padding: EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xFFEFEFEF)
                                ),
                                child: Center(
                                  child: Text(
                                    'от 100 руб',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          onTap: () async {
            if (await Internet.checkConnection()) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) {
                  return RestaurantScreen(restaurant: restaurant);
                }),
              );
            } else {
              noConnection(context);
            }
            print(await Internet.checkConnection());
          }));
    });
    List<Widget> childrenColumn = new List<Widget>();
    childrenColumn.addAll(restaurantList);
    if(restaurantList.length < records_count){
      childrenColumn.add(
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Center(
              child: SpinKitFadingCircle(
                color: Colors.green,
                size: 50.0,
              ),
            ),
          )
      );
    }
    return Column(children: childrenColumn);
  }

  List<Widget> getSideBarItems(bool isLogged) {
    List<Widget> allSideBarItems = [
      Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: ListTile(
          leading: SvgPicture.asset('assets/svg_images/info.svg'),
          title: Text(
            'Информация',
            style: TextStyle(
                fontSize: 17, color: Color(0xFF424242), letterSpacing: 0.45),
          ),
          onTap: () async {
            if (await Internet.checkConnection()) {
              Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (context) => new InformationScreen(),
                ),
              );
            } else {
              noConnection(context);
            }
          },
        ),
      ),
    ];

    if (isLogged) {
      allSideBarItems.insertAll(0, [
        Padding(
          padding: EdgeInsets.only(top: 0),
          child: InkWell(
            child: Container(
              color: Color(0xFF67C070),
              child: ListTile(
                title: Text(
                  necessaryDataForAuth.name ?? ' ',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
                subtitle: Text(
                  necessaryDataForAuth.phone_number ?? ' ',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                trailing: GestureDetector(
                  child: SvgPicture.asset(
                      'assets/svg_images/pencil.svg'),
                ),
              ),
            ),
            onTap: () async {
              if (await Internet.checkConnection()) {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => new ProfileScreen(),
                  ),
                );
              } else {
                noConnection(context);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: SvgPicture.asset('assets/svg_images/order_story.svg'),
            ),
            title: Text(
              'История заказов',
              style: TextStyle(
                  fontSize: 17, color: Color(0xFF424242), letterSpacing: 0.45),
            ),
            onTap: () async {
              if (await Internet.checkConnection()) {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => new OrdersStoryScreen(),
                  ),
                );
              } else {
                noConnection(context);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: ListTile(
            leading: SvgPicture.asset('assets/svg_images/my_addresses.svg'),
            title: Text(
              'Мои адреса',
              style: TextStyle(
                  fontSize: 17, color: Color(0xFF424242), letterSpacing: 0.45),
            ),
            onTap: () async {
              if (await Internet.checkConnection()) {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => new MyAddressesScreen(),
                  ),
                );
              } else {
                noConnection(context);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: ListTile(
            leading: SvgPicture.asset('assets/svg_images/service.svg'),
            title: Text(
              'Служба поддержки',
              style: TextStyle(
                  fontSize: 17, color: Color(0xFF424242), letterSpacing: 0.45),
            ),
            onTap: () async {
              if (await Internet.checkConnection()) {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => new ServiceScreen(),
                  ),
                );
              } else {
                noConnection(context);
              }
            },
          ),
        ),
      ]);
      allSideBarItems.add(
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: ListTile(
            leading: SvgPicture.asset('assets/svg_images/exit.svg'),
            title: Text(
              'Выход',
              style: TextStyle(
                  fontSize: 17, color: Color(0xFF424242), letterSpacing: 0.45),
            ),
            onTap: () async {
              if (await Internet.checkConnection()) {
                necessaryDataForAuth.refresh_token = null;
                authCodeData.refresh_token = null;
                await NecessaryDataForAuth.saveData();
                await LastAddressesModel.clear();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => DeviceIdScreen()),
                        (Route<dynamic> route) => false);
              } else {
                noConnection(context);
              }
            },
          ),
        ),
      );
    } else {
      allSideBarItems.insert(
          0,
          Padding(
            padding: EdgeInsets.only(top: 0),
            child: ListTile(
                title: InkWell(
                  child: Padding(
                    padding: EdgeInsets.only(top: 0, bottom: 20),
                    child: Text(
                      'Авторизоваться',
                      style: TextStyle(
                          fontSize: 17,
                          color: Color(0xFF424242),
                          letterSpacing: 0.45),
                    ),
                  ),
                  onTap: () async {
                    if (await Internet.checkConnection()) {
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                          builder: (context) => new AuthScreen(),
                        ),
                      );
                    } else {
                      noConnection(context);
                    }
                  },
                )),
          ));
    }
    return allSideBarItems;
  }

  GlobalKey<KitchenListScreenState> kitchenListKey = new GlobalKey();

  List<Widget> _buildRestaurantCategoriesList(List<Record> categories){
    List<Widget> result = new List<Widget>();
    result.add(Row(
      children: [
        GestureDetector(
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                  color: Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: SvgPicture.asset('assets/svg_images/union.svg'),
              ),
            ),
          ),
          onTap: () async {
            if (await Internet.checkConnection()) {
              _filter();
            } else {
              noConnection(context);
            }
          },
        ),
        GestureDetector(
          child: Padding(
              padding:
              EdgeInsets.only(left: 10, right: 5,),
              child: Stack(
                children: [
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Color(0xFFF6F6F6)),
                    child: Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Кухни",
                                style: TextStyle(
                                    color: Color(0xFF424242),
                                    fontSize: 15),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: SvgPicture.asset('assets/svg_images/arrow_down'),
                              )
                            ],
                          ),
                        )
                    ),
                  ),
//                  (kitchenListKey.currentState.selectedKitchens.length != 0) ? Padding(
//                    padding: const EdgeInsets.only(left: 70, bottom: 20),
//                    child: Container(
//                      width: 23,
//                        height: 23,
//                        padding: EdgeInsets.all(5),
//                        decoration: BoxDecoration(
//                            borderRadius: BorderRadius.circular(20),
//                            color: Colors.white
//                        ),
//                        child: Center(
//                          child: Text('${kitchenListKey.currentState.selectedKitchens.length}',
//                            style: TextStyle(
//                              fontSize: 14
//                            ),
//                          ),
//                        )
//                    ),
//                  ): Container()
                ],
              )),
          onTap: () async {
            if (await Internet.checkConnection()) {
              _kitchensFilter(kitchenListKey);
            } else {
              noConnection(context);
            }
          },
        ),
        GestureDetector(
          child: Padding(
              padding:
              EdgeInsets.only(left: 10, right: 5),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xFFF6F6F6)),
                child: Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Center(
                      child: Row(
                        children: [
                          Text(
                            "По расстоянию",
                            style: TextStyle(
                                color: Color(0xFF424242),
                                fontSize: 15),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SvgPicture.asset('assets/svg_images/arrow_down'),
                          )
                        ],
                      ),
                    )),
              )),
          onTap: () async {
            if (await Internet.checkConnection()) {
              _distanceFilter();
            } else {
              noConnection(context);
            }
          },
        )
      ],
    ));
    categories.forEach((element) {
      result.add(GestureDetector(
        child: Padding(
            padding:
            EdgeInsets.only(left: 5, right: 5),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: (element.uuid != category_uuid)
                      ? Color(0xFFF6F6F6)
                      : Color(0xFF67C070)),
              child: Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Center(
                    child: Text(
                      element.name[0].toUpperCase() + element.name.substring(1),
                      style: TextStyle(
                          color: (element.uuid !=
                              category_uuid)
                              ? Color(0xFF424242)
                              : Colors.white,
                          fontSize: 15),
                    ),
                  )),
            )),
        onTap: () async {
          if (await Internet.checkConnection()) {
            setState(() {
              isLoading = true;
              page = 1;
              category_uuid = (element.uuid == category_uuid) ? '' : element.uuid;
            });
          } else {
            noConnection(context);
          }
        },
      ));
    });
    return result;
  }


  _buildRestaurantCategories(){
    if(restaurantCategories != null){
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Container(
          height: 45,
          child: ListView(
              scrollDirection: Axis.horizontal,
              children: _buildRestaurantCategoriesList(restaurantCategories.records)
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10),
      child: Container(
        height: 45,
        child: FutureBuilder<RestaurantCategories>(
          future: loadRestaurantCategories(1, 12),
          initialData: null,
          builder: (BuildContext context, AsyncSnapshot<RestaurantCategories> snapshot){
            if(snapshot.hasData){
              if(snapshot.connectionState == ConnectionState.done){
                restaurantCategories = snapshot.data;
                return ListView(
                    scrollDirection: Axis.horizontal,
                    children: _buildRestaurantCategoriesList(restaurantCategories.records)
                );
              }
            }
            return Container(height: 0);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: ClipRRect(
          borderRadius: BorderRadius.only(topRight: Radius.circular(15)),
          child: Drawer(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Center(
                    child: Image(
                      height: 97,
                      width: 142,
                      image: AssetImage('assets/images/faem.png'),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: getSideBarItems(currentUser.isLoggedIn),
                  ),
                ),
              ],
            )
          ),
        ),
        body: FutureBuilder<DeliveryResponseData>(
            future: loadRestaurant(page, limit, category_uuid),
            initialData: null,
            builder: (BuildContext context,
                AsyncSnapshot<DeliveryResponseData> snapshot) {
              print(snapshot.connectionState);
              if (snapshot.hasData) {
                if (page == 1) {
                  records_count = snapshot.data.records_count;
                  this.records_items.clear();
                }
//                if (snapshot.data.records_count == 0) {
//                  return Center(
//                    child: Text('Нет товаров данной категории'),
//                  );
//                }
                if (snapshot.connectionState == ConnectionState.done) {
                  if(snapshot.data.records != null){
                    records_items.addAll(snapshot.data.records);
                  }
                  isLoading = false;
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!isLoading &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      if (snapshot.data.records_count - (page + 1) * limit >
                          (-1) * limit) {
                        // snapshot = null;
                        setState(() {
                          isLoading = true;
                          page++;
                        });
                      }
                    }
                  },
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 50, left: 20, right: 15, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 0, top: 0),
                              child: InkWell(
                                child: SvgPicture.asset(
                                    'assets/svg_images/home_menu.svg',
                                  color: Colors.black,
                                ),
                                onTap: () {
                                  _scaffoldKey.currentState.openDrawer();
                                },
                              ),
                            ),
                            Container(
                              width: 250,
                              height: 38,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Color(0xFF09B44D)
                              ),
                              child: Center(
                                child: Text('Хаджи Мамсурова,42',
                                  style: TextStyle(
                                     color: Colors.white,
                                    fontSize: 13
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 0, top: 0),
                              child: InkWell(
                                child: SvgPicture.asset(
                                    'assets/svg_images/search.svg',
                                  color: Colors.black,),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: <Widget>[
                            FutureBuilder<List<OrderChecking>>(
                              future: OrderChecking.getActiveOrder(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<OrderChecking>> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                    snapshot.data != null &&
                                    snapshot.data.length > 0) {
                                  orderList = snapshot.data;
                                  return (currentUser.isLoggedIn)
                                      ? Padding(
                                        padding: const EdgeInsets.only(top: 15),
                                        child: Container(
                                    height: 230,
                                    child: ListView(
                                        children: snapshot.data,
                                        scrollDirection: Axis.horizontal,
                                    ),
                                  ),
                                      ) : Container(
                                    height: 0,
                                  );
                                } else {
                                  orderList = null;
                                  return Center(
                                    child: Container(
                                      height: 0,
                                    ),
                                  );
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20, top: 15, right: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Акции и новинки',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 0, right: 10),
                                        child: Text('Все',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      SvgPicture.asset('assets/svg_images/arrow_right.svg',
                                        color: Colors.grey,
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            ContainerReSize(),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                              EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text('Рестораны',
                                  style: TextStyle(
                                    fontSize: 28,
                                    color: Color(0xFF3F3F3F),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  )),
                            ),
                            Container(
                              child: _buildRestaurantCategories(),
                            ),
                            (records_items.isEmpty && !isLoading) ?  Center(
                              child: Container(),
                            ) : _buildRestaurantsList()
                          ],
                        ),
                      ),
                      (currentUser.cartDataModel.cart != null &&
                          currentUser.cartDataModel.cart.length != 0)
                          ? BasketButton(
                        key: basketButtonStateKey,
                        restaurant:
                        currentUser.cartDataModel.cart[0].restaurant,
                      )
                          : Visibility(
                        child: Container(height: 80),
                        visible: false,
                      )
                    ],
                  ),
                );
              } else {
                return Center(
                  child: SpinKitFadingCircle(
                    color: Colors.green,
                    size: 50.0,
                  ),
                );
              }
            }),
      ),
    );
  }
}

class OrderChecking extends StatefulWidget {
  OrdersStoryModelItem ordersStoryModelItem;

  OrderChecking({Key key, this.ordersStoryModelItem}) : super(key: key);
  static var state_array = [
    'waiting_for_confirmation',
    'cooking',
    'offer_offered',
    'smart_distribution',
    'finding_driver',
    'offer_rejected',
    'order_start',
    'on_place',
    'on_the_way',
    'transferred_to_store',
    'order_payment'
  ];

  @override
  OrderCheckingState createState() {
    return new OrderCheckingState(ordersStoryModelItem);
  }

  static Future<List<OrderChecking>> getActiveOrder() async {
    List<OrderChecking> activeOrderList = new List<OrderChecking>();
    OrdersStoryModel ordersStoryModel = await loadOrdersStoryModel();
    orderCheckingStates.clear();
    ordersStoryModel.ordersStoryModelItems
        .forEach((OrdersStoryModelItem element) {
      if (state_array.contains(element.state)) {
        print(element.uuid);
        GlobalKey<OrderCheckingState> key = new GlobalKey<OrderCheckingState>();
        orderCheckingStates[element.uuid] = key;
        activeOrderList.add(new OrderChecking(
          ordersStoryModelItem: element,
          key: key,
        ));
      }
    });
    return activeOrderList;
  }
}

class OrderCheckingState extends State<OrderChecking> with AutomaticKeepAliveClientMixin {
  OrdersStoryModelItem ordersStoryModelItem;
  @override
  bool get wantKeepAlive => true;

  OrderCheckingState(this.ordersStoryModelItem);



  @override
  Widget build(BuildContext context) {
    var processing = ['waiting_for_confirmation'
    ];
    var cooking_state = [
      'cooking',
      'offer_offered',
      'smart_distribution',
      'finding_driver',
      'offer_rejected',
      'order_start',
      'on_place',
      'transferred_to_store',
      'order_accepted'
    ];
    var in_the_way = ['on_the_way'];
    var take = ['order_payment'];

    if (!OrderChecking.state_array.contains(ordersStoryModelItem.state)) {
      return Container();
    }
    print("ownDelivery " + ordersStoryModelItem.own_delivery.toString());
    print(ordersStoryModelItem.state);
    return InkWell(
      child: Container(
          width: 320,
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.0,
                  spreadRadius: 3.0,
                )
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(17.0),
              border: Border.all(width: 1.0, color: Colors.grey[200])),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Align(
                          child: Text(
                            'Ваш заказ из ' +
                                (ordersStoryModelItem.store != null
                                    ? ordersStoryModelItem.store.name
                                    : 'Пусто'),
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 10, left: 20, top: 0),
                        child: InkWell(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                                color: Color(0xF6F6F6F6)),
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, top: 7, bottom: 0),
                                child: Text(
                                  'Заказ',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 13),
                                )),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) {
                                return OrdersDetailsScreen(
                                    ordersStoryModelItem: ordersStoryModelItem);
                              }),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: (in_the_way
                    .contains(ordersStoryModelItem.state)) ? Padding(
                  padding: EdgeInsets.only(right: 170, bottom: 8),
                  child: Text(ordersStoryModelItem.driver.color + ' ' + ordersStoryModelItem.driver.car + ' ' + ordersStoryModelItem.driver.reg_number,
                    style: TextStyle(color: Color(0xFF000000), fontSize: 16),),
                ) : Container(height: 0),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 5, right: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color: (processing
                                  .contains(ordersStoryModelItem.state))
                                  ? Color(0xFF4DC3E9)
                                  : Color(0xF6F6F6F6)),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: (processing
                                    .contains(ordersStoryModelItem.state))
                                    ? SvgPicture.asset(
                                    'assets/svg_images/white_clock.svg')
                                    : SvgPicture.asset(
                                    'assets/svg_images/clock.svg'),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Text('Обработка',
                                    style: (processing
                                        .contains(ordersStoryModelItem.state))
                                        ? TextStyle(
                                        color: Colors.white, fontSize: 10)
                                        : TextStyle(
                                        color: Color(0x42424242),
                                        fontSize: 10)),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: (ordersStoryModelItem.without_delivery) ? EdgeInsets.only(left: 20) : EdgeInsets.only(right: 5),
                        child: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color: (cooking_state
                                  .contains(ordersStoryModelItem.state))
                                  ? Color(0xFF51ca64)
                                  : Color(0xF6F6F6F6)),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: (cooking_state
                                    .contains(ordersStoryModelItem.state))
                                    ? SvgPicture.asset(
                                    'assets/svg_images/white_bell.svg')
                                    : SvgPicture.asset(
                                    'assets/svg_images/bell.svg'),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Text('Готовится',
                                    style: (cooking_state
                                        .contains(ordersStoryModelItem.state))
                                        ? TextStyle(
                                        color: Colors.white, fontSize: 10)
                                        : TextStyle(
                                        color: Color(0x42424242),
                                        fontSize: 10)),
                              )
                            ],
                          ),
                        ),
                      ),
                      (ordersStoryModelItem.without_delivery) ? Container() : Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color: Color(0xF6F6F6F6)),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 15),
                                child: (in_the_way
                                    .contains(ordersStoryModelItem.state))
                                    ? SvgPicture.asset(
                                    'assets/svg_images/light_car.svg')
                                    : SvgPicture.asset(
                                    'assets/svg_images/car.svg'),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Text('В пути',
                                    style: (in_the_way
                                        .contains(ordersStoryModelItem.state))
                                        ? TextStyle(
                                        color: Colors.black, fontSize: 10)
                                        : TextStyle(
                                        color: Color(0x42424242),
                                        fontSize: 10)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color: (take.contains(ordersStoryModelItem.state))
                                  ? Color(0xFFFE534F)
                                  : Color(0xF6F6F6F6)),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: (take.contains(ordersStoryModelItem.state))
                                    ? SvgPicture.asset(
                                    'assets/svg_images/white_ready.svg')
                                    : SvgPicture.asset(
                                    'assets/svg_images/ready.svg'),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Text('Заберите',
                                    style: (take
                                        .contains(ordersStoryModelItem.state))
                                        ? TextStyle(
                                        color: Colors.white, fontSize: 10)
                                        : TextStyle(
                                        color: Color(0x42424242),
                                        fontSize: 10)),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              (in_the_way.contains(ordersStoryModelItem.state) && ordersStoryModelItem.own_delivery != null && ordersStoryModelItem.own_delivery) ? Padding(
                  padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  child: Text('Доставку осуществляет курьер от заведения',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14
                    ),
                  )
              ) :Container()
            ],
          )),
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) {
            return OrdersDetailsScreen(
                ordersStoryModelItem: ordersStoryModelItem);
          }),
        );
      },
    );
  }
}

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  String order_uuid;

  ChatScreen({Key key, this.order_uuid}) : super(key: key);

  @override
  ChatScreenState createState() {
    return new ChatScreenState(order_uuid);
  }
}

class ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  List<ChatMessageScreen> chatMessageList;
  String order_uuid;

  ChatScreenState(this.order_uuid);

  TextEditingController messageField = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed){
      setState(() {

      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  buildChat() {
    List<String> messagedUuid = new List<String>();
    chatMessageList.forEach((element) {
      if (element.chatMessage.to == 'client' &&
          element.chatMessage.ack == false) {
        element.chatMessage.ack = true;
        messagedUuid.add(element.chatMessage.uuid);
      }
    });
    if (messagedUuid.length > 0) {
      Chat.readMessage(messagedUuid);
    }
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Чат с водителем',
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
                ),
              )),
          leading: InkWell(
            child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                    padding: EdgeInsets.only(left: 15, top: 0),
                    child: Container(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 20, bottom: 20, right: 0),
                          child: Image(image: AssetImage('assets/images/arrow_left.png'),),
                        )))),
            onTap: () {
              Navigator.pushReplacement(
                context,
                new MaterialPageRoute(
                  builder: (context) => new HomeScreen(),
                ),
              );
            },
          ),
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
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: ListView.builder(
                            reverse: true,
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.vertical,
                            itemCount: chatMessageList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return chatMessageList[index];
                            },
                            //chatMessageList
                          ),
                        ),
                      ),
                      Stack(
                        children: <Widget>[
                          Container(
                            height: 60,
                            child: QuickMessageScreen(
                              messageField: messageField,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 65, bottom: 20, right: 15, left: 15),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(right: 10, top: 0),
                                        child: Container(
                                          height: 34,
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
                                    )
                                ),
                                InkWell(
                                  child: Container(
                                      height: 40,
                                      width: 40,
                                      child: Padding(
                                        padding: EdgeInsets.all(6),
                                        child: SvgPicture.asset(
                                            'assets/svg_images/send_message.svg'),
                                      )
                                  ),
                                  onTap: () async {
                                    if (await Internet.checkConnection()) {
                                      var message = await Chat.sendMessage(
                                          order_uuid, messageField.text, 'driver');
                                      chatMessagesStates.forEach((key, value) {
                                        print(
                                            key + ' ' + value.currentState.toString());
                                      });
                                      print("Отправка сообщения");
                                      messageField.clear();
                                      setState(() {
                                        GlobalKey<ChatMessageScreenState>
                                        chatMessageScreenStateKey =
                                        new GlobalKey<ChatMessageScreenState>();
                                        chatMessagesStates[message.uuid] =
                                            chatMessageScreenStateKey;
                                        chatMessageList.insert(
                                            0,
                                            new ChatMessageScreen(
                                                key: chatMessageScreenStateKey,
                                                chatMessage: message));
                                      });
                                    } else {
                                      noConnection(context);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
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
    return FutureBuilder<ChatHistoryModel>(
      future: Chat.loadChatHistory(order_uuid, 'driver'),
      builder:
          (BuildContext context, AsyncSnapshot<ChatHistoryModel> snapshot) {
        print('tututuwapatututuwapa ' + order_uuid);
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          chatMessagesStates.clear();
          chatMessageList = new List<ChatMessageScreen>();
          snapshot.data.chatMessageList.forEach((element) {
            GlobalKey<ChatMessageScreenState> chatMessageScreenStateKey =
            new GlobalKey<ChatMessageScreenState>();
            chatMessagesStates[element.uuid] = chatMessageScreenStateKey;
            chatMessageList.add(new ChatMessageScreen(
                chatMessage: element, key: chatMessageScreenStateKey));
          });
          return buildChat();
        } else {
          return Center(
              child: SpinKitFadingCircle(
              color: Colors.green,
              size: 50.0,
              )
          );
        }
      },
    );
  }
}

// ignore: must_be_immutable
class ChatMessageScreen extends StatefulWidget {
  ChatMessage chatMessage;

  ChatMessageScreen({Key key, this.chatMessage}) : super(key: key);

  @override
  ChatMessageScreenState createState() {
    return new ChatMessageScreenState(chatMessage);
  }
}

class ChatMessageScreenState extends State<ChatMessageScreen> with WidgetsBindingObserver {
  ChatMessage chatMessage;

  ChatMessageScreenState(this.chatMessage);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed){
      setState(() {

      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Column(
        children: <Widget>[
          (chatMessage.to == 'client')
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
                        border:
                        Border.all(width: 1.0, color: Color(0xFFE5E6EA))),
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
          (chatMessage.to != 'client') ?
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: (chatMessage.ack ) ? Align(
              alignment: Alignment.centerRight,
              child: Text('Прочитано',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ): Align(
              alignment: Alignment.centerRight,
              child: Text('Доставлено',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ) :
          Container(height: 0,)
        ],
      ),
    );
  }
}

class QuickMessageScreen extends StatefulWidget {
  TextEditingController messageField;

  QuickMessageScreen({Key key, this.messageField}) : super(key: key);

  @override
  QuickMessageScreenState createState() {
    return new QuickMessageScreenState(messageField: messageField);
  }
}

class QuickMessageScreenState extends State<QuickMessageScreen> with WidgetsBindingObserver{
  TextEditingController messageField;

  QuickMessageScreenState({this.messageField});

  QuickMessageItem quickMessage;
  String quickTextMessage;

  buildQuickMessages() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: List.generate(quickMessage.messages.length, (index) {
        return GestureDetector(
          child: Padding(
              padding: EdgeInsets.only(left: 15, right: 5, top: 10, bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5.0, // soften the shadow
                        spreadRadius: 2.0, //extend the shadow
                      )
                    ],
                    color: (quickMessage.messages[index] != quickTextMessage)
                        ? Colors.white
                        : Color(0xFF67C070)),
                child: Padding(
                    padding: EdgeInsets.only(
                      left: 15,
                      right: 15,
                      top: 10,
                    ),
                    child: Text(
                      quickMessage.messages[index],
                      style: TextStyle(
                          color:
                          (quickMessage.messages[index] != quickTextMessage)
                              ? Color(0x99999999)
                              : Colors.white,
                          fontSize: 15),
                    )),
              )),
          onTap: () {
            setState(() {
              quickTextMessage = quickMessage.messages[index];
              messageField.text = quickTextMessage;
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (quickMessage != null) {
      return buildQuickMessages();
    }
    return FutureBuilder<QuickMessages>(
      future: Chat.getMessages(),
      builder: (BuildContext context, AsyncSnapshot<QuickMessages> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          quickMessage = snapshot.data.chatMessageList[0];
          return buildQuickMessages();
        } else {
          return Container();
        }
      },
    );
  }
}



class ContainerReSize extends StatefulWidget {

  ContainerReSize({Key key}) : super(key: key);

  @override
  ContainerReSizeState createState() {
    return new ContainerReSizeState();
  }
}

class ContainerReSizeState extends State<ContainerReSize>{

  ContainerReSizeState();
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        height: 110,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
//            Padding(
//              padding:  (isExpanded) ? EdgeInsets.only(left: 15, right: 8, top: 8, bottom: 8) : EdgeInsets.only(left: 15, right: 8, top: 12, bottom: 12),
//              child: GestureDetector(
//                child: AnimatedContainer(
//                  width: isExpanded ? 130 : 120,
//                  duration: const Duration(seconds: 1),
//                  child: Image(
//                    image: AssetImage('assets/images/share_image.png'),
//                  ),
//                ),
//                onTapUp: (value){
//                  setState(() {
//                    isExpanded = !isExpanded;
//                  });
//                },
//                onTapDown: (value){
//                  setState(() {
//                    isExpanded = !isExpanded;
//                  });
//                },
//              ),
//            ),
            Padding(
              padding:  EdgeInsets.only(left: 15, right: 8, top: 8, bottom: 8),
              child: Image(
                image: AssetImage('assets/images/share_image.png'),
              )
            ),
            Padding(
                padding:  EdgeInsets.only(right: 8, top: 8, bottom: 8),
                child: Image(
                  image: AssetImage('assets/images/share_image.png'),
                )
            ),
            Padding(
                padding:  EdgeInsets.only(right: 8, top: 8, bottom: 8),
                child: Image(
                  image: AssetImage('assets/images/share_image.png'),
                )
            ),
          ],
        ),
      ),
    );
  }
}


class KitchenListScreen extends StatefulWidget {

  KitchenListScreen({Key key}) : super(key: key);

  @override
  KitchenListScreenState createState() {
    return new KitchenListScreenState();
  }
}

class KitchenListScreenState extends State<KitchenListScreen>{

  KitchenListScreenState();

  List<bool> selectedKitchens = List.generate(12, (index) => false);
  List<String> images = [
    'assets/svg_images/sushi.svg',
    'assets/svg_images/pizza.svg',
    'assets/svg_images/burger.svg',
    'assets/svg_images/shashlik.svg',
    'assets/svg_images/fish_meat.svg',
    'assets/svg_images/cake.svg',
    'assets/svg_images/breakfast.svg',
    'assets/svg_images/dinner.svg',
    'assets/svg_images/bread.svg',
    'assets/svg_images/asian.svg',
    'assets/svg_images/russian.svg',
    'assets/svg_images/georgian.svg',
  ];
  List<String> images_white = [
    'assets/svg_images/sushi_white.svg',
    'assets/svg_images/pizza_white.svg',
    'assets/svg_images/burger_white.svg',
    'assets/svg_images/shashl_white.svg',
    'assets/svg_images/fish_meat_white.svg',
    'assets/svg_images/cake_white.svg',
    'assets/svg_images/breakfast_white.svg',
    'assets/svg_images/dinner_white.svg',
    'assets/svg_images/bread_white.svg',
    'assets/svg_images/asian_white.svg',
    'assets/svg_images/russian_white.svg',
    'assets/svg_images/georgian_white.svg',
  ];
  List<String> titles = [
    'Суши',
    'Пицца',
    'Бургеры',
    'Шашлык',
    'Мясо и рыба',
    'Пироги',
    'Завтраки',
    'Обеды',
    'Перекус',
    'Азиатская',
    'Русская',
    'Грузинская',
  ];

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 0, left: 8, right: 8, top: 0),
          height: 490,
          child: ListView(
            padding: EdgeInsets.zero,
            children: List.generate(12,(index){
              return InkWell(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 5, right: 5, bottom: 10),
                  child: (!selectedKitchens[index]) ? Container(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 9.0, right: 10),
                          child: SvgPicture.asset('assets/svg_images/kitchen_unselected.svg'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(titles[index],
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18
                            ),
                          ),
                        )
                      ],
                    ),
                  ) : Container(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 9.0, right: 10),
                          child: SvgPicture.asset('assets/svg_images/kitchen_selected.svg'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(titles[index],
                            style: TextStyle(
                                fontSize: 18
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                onTap: (){
                  setState(() {
                    selectedKitchens[index] = !selectedKitchens[index];
                  });
                },
              );
            }),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: FlatButton(
              child: Text('Применить',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white)),
              color: (haveSelectedItems()) ? Color(0xFF67C070) : Color(0xF3F3F3F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.only(left: 120, top: 20, right: 120, bottom: 20),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
          ),
        )
      ],
    );
  }

  bool haveSelectedItems(){
    try{
      var selectedItem = selectedKitchens.firstWhere((element) => element);
      return true;
    }catch(e){
      return false;
    }
  }
}


class FilterListScreen extends StatefulWidget {

  FilterListScreen({Key key}) : super(key: key);

  @override
  FilterListScreenState createState() {
    return new FilterListScreenState();
  }
}

class FilterListScreenState extends State<FilterListScreen>{

  FilterListScreenState();

  List<bool> selectedKitchens = List.generate(5, (index) => false);

  List<String> titles = [
    'Доверюсь вам',
    'С высоким рейтингом',
    'Быстрые',
    'Недорогие',
    'Дорогие',
  ];


  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.only(),
      height: 280,
      child: ListView(
        padding: EdgeInsets.zero,
        children: List.generate(5,(index){
          return InkWell(
            child: Padding(
              padding: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 15),
              child: (!selectedKitchens[index]) ? Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(titles[index],
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18
                      ),
                    ),
                    SvgPicture.asset('assets/svg_images/circle.svg'),
                  ],
                ),
              ) : Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(titles[index],
                      style: TextStyle(
                          fontSize: 18
                      ),
                    ),
                    SvgPicture.asset('assets/svg_images/address_screen_selector.svg'),
                  ],
                ),
              ),
            ),
            onTap: (){
              setState(() {
                selectedKitchens[index] = !selectedKitchens[index];
              });
            },
          );
        }),
      )
    );
  }
}