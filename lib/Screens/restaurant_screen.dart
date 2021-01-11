import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:faem_app/GetData/getImage.dart';
import 'package:faem_app/Internet/check_internet.dart';
import 'package:faem_app/PostData/restaurant_items_data_pass.dart';
import 'package:faem_app/data/data.dart';
import 'package:faem_app/Models/ResponseData.dart';
import 'package:faem_app/Models/RestaurantDataItems.dart';
import 'package:faem_app/Models/amplitude.dart';
import 'package:faem_app/Models/food.dart';
import 'package:faem_app/Models/order.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import '../data/data.dart';
import 'cart_screen.dart';
import 'home_screen.dart';

class RestaurantScreen extends StatefulWidget {
  final Records restaurant;

  RestaurantScreen({Key key, this.restaurant}) : super(key: key);

  @override
  RestaurantScreenState createState() =>
      RestaurantScreenState(restaurant, '');
}

class RestaurantScreenState extends State<RestaurantScreen> {
  final Records restaurant;
  // Добавленные глобалки
  RestaurantDataItems restaurantDataItems; // Модель текущего меню
  CategoryList categoryList; // Виджет с категориями еды
  // (для подгрузки ВПЕРЕД по клику по категории)
  ScrollController foodScrollController = new ScrollController(); // Скролл контроллер для хавки
  List<MenuItem> foodMenuItems = new List<MenuItem>(); // Виджеты с хавкой
  List<MenuItemTitle> foodMenuTitles = new List<MenuItemTitle>(); // Тайтлы категорий
  List<Widget> menuWithTitles = new List<Widget>();
  int load_category_index = 0; // Индекс подгружаемой категории (няряду с page)
  // Конец добавленных мной глобалок
  int page = 1;
  int limit = 12;
  String category;

  GlobalKey<FormState> foodItemFormKey = GlobalKey();
  GlobalKey<CounterState> counterKey = new GlobalKey();
  GlobalKey<BasketButtonState> basketButtonStateKey =
  new GlobalKey<BasketButtonState>();
  bool isLoading = true;

  GlobalKey<FormState> _foodItemFormKey = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldStateKey = GlobalKey();


  RestaurantScreenState(this.restaurant, this.category);


  _dayOff(FoodRecords restaurantDataItems,
      GlobalKey<MenuItemCounterState> menuItemCounterKey) {
    GlobalKey<VariantsSelectorState> variantsSelectorStateKey =
    GlobalKey<VariantsSelectorState>();
    GlobalKey<ToppingsSelectorState> toppingsSelectorStateKey =
    new GlobalKey<ToppingsSelectorState>();

    DateTime now = DateTime.now();
    int dayNumber  = now.weekday-1;

    int work_beginning = restaurant.work_schedule[dayNumber].work_beginning;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
          )),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: Align(
                alignment: Alignment.topCenter,
                child: Text('К сожалению, доставка не доступна.\nБлижайшее время в ${( work_beginning/ 60).toStringAsFixed(0)} часов',
                  style: TextStyle(
                      fontSize: 16
                  ),
                  textAlign: TextAlign.center,
                )
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10,left: 15, right: 15, bottom: 25),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: FlatButton(
                  child: Text(
                    "Далее",
                    style:
                    TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  color: Color(0xFF67C070),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.only(
                      left: 110, top: 20, right: 110, bottom: 20),
                  onPressed: () async {
                    homeScreenKey = new GlobalKey<HomeScreenState>();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => HomeScreen()),
                            (Route<dynamic> route) => false);
                  },
                )
            ),
          )
        ],
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        elevation: 20,
        content: Center(
          child: Text("Товар добавлен в коризну"),
        ));
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop(true);
        });
        return Padding(
          padding: EdgeInsets.only(bottom: 500),
          child: Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            child: Container(
              height: 50,
              width: 100,
              child: Center(
                child: Text("Товар добавлен в коризну"),
              ),
            ),
          ),
        );
      },
    );
  }

  showCartClearDialog(BuildContext context, Order order,
      GlobalKey<MenuItemCounterState> menuItemCounterKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            child: Container(
                height: 242,
                width: 300,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 15, top: 20, bottom: 20, right: 15),
                      child: Text(
                        'Все ранее добавленные блюда из ресторна ${currentUser.cartDataModel.cart[0].restaurant.name} будут удалены из корзины',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey,
                    ),
                    InkWell(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 20),
                          child: Center(
                            child: Text(
                              'Ок',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      onTap: () async {
                        if (await Internet.checkConnection()) {
                          if (currentUser.cartDataModel.cart.length > 0 &&
                              currentUser
                                  .cartDataModel.cart[0].restaurant.uuid !=
                                  restaurant.uuid) {
                            currentUser.cartDataModel.cart.clear();
                            currentUser.cartDataModel.addItem(order);
                            currentUser.cartDataModel.saveData();
                            basketButtonStateKey.currentState.refresh();
                            menuItemCounterKey.currentState.refresh();
                            counterKey.currentState.refresh();
                          }
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Padding(
                            padding: EdgeInsets.only(bottom: 0),
                            child: showAlertDialog(context),
                          );
                        } else {
                          noConnection(context);
                        }
                      },
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey,
                    ),
                    InkWell(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 20),
                          child: Center(
                            child: Text(
                              'Отмена',
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )),
          ),
        );
      },
    );
  }



  Widget foodList(String s) {
    return Text(s, style: TextStyle(fontSize: 15.0, color: Color(0x99999999)));
  }

  @override
  void initState() {
    super.initState();


    // Инициализируем список категорий
    categoryList = new CategoryList(key: new GlobalKey<CategoryListState>(), restaurant: restaurant, parent: this);

    // Навешиваем лисенер на скролл контроллер
    foodScrollController.addListener(() {
      try{
        if(!isLoading){
          // Используя силу математики, находим индекс хавки, на которую сейчас
          // смотрим
          var currentCategoryWidget = foodMenuTitles.firstWhere((element) => element.key.currentState!=null);
          String currentCategory = (currentCategoryWidget != null) ? currentCategoryWidget.title : categoryList.key.currentState.currentCategory;
          categoryList.key.currentState.SelectCategory(currentCategory);
          categoryList.key.currentState.ScrollToSelectedCategory();
        }
      }catch(e){

      }
    });
  }

  _buildFoodCategoryList() {
    if(restaurant.product_category.length>0)
      return categoryList;
    else
      return Container(height: 0);
  }




  Widget _buildScreen() {
    isLoading = false;
    // Если хавки нет
    if (restaurantDataItems.records_count == 0) {
      return Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 50, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(left: 0),
                    child: InkWell(
                        onTap: () async {
                          homeScreenKey =
                          new GlobalKey<HomeScreenState>();
                          if(await Internet.checkConnection()){
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
                          }else{
                            noConnection(context);
                          }
                        },
                        child: Container(
                            height: 40,
                            width: 60,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 12, bottom: 12, right: 10, left: 16),
                              child: SvgPicture.asset(
                                  'assets/svg_images/arrow_left.svg'),
                            ))),
                  ),
                ),
                Flexible(
                  flex: 7,
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(right: 30),
                      child: Text(
                        this.restaurant.name,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10),
            child: Divider(color: Color(0xFFEEEEEE), height: 1,),
          ),
          _buildFoodCategoryList(),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10),
            child: Divider(color: Color(0xFFEEEEEE), height: 1,),
          ),
          Align(
            alignment: Alignment.center,
            child: Center(
              child: Text('Нет товаров данной категории'),
            ),
          ),
          SizedBox(height: 10.0),
        ],
      );
    }


    foodMenuItems.addAll(MenuItem.fromFoodRecordsList(restaurantDataItems.records, this));
    foodMenuTitles.addAll(MenuItemTitle.fromCategoryList(restaurant.product_category));
    menuWithTitles = generateMenu();
    GlobalKey<SliverTextState>sliverTextKey = new GlobalKey();
    GlobalKey<SliverImageState>sliverImageKey = new GlobalKey();
    ScrollController sliverScrollController = new ScrollController();
    sliverScrollController.addListener(() {
      if(sliverTextKey.currentState != null && sliverScrollController.offset > 107){
        sliverTextKey.currentState.setState(() {
          sliverTextKey.currentState.title =  new Text(this.restaurant.name, style: TextStyle(color: Colors.black),);
        });
      }else{
        if(sliverTextKey.currentState != null){
          sliverTextKey.currentState.setState(() {
            sliverTextKey.currentState.title =  new Text('');
          });
        }
      }
      if(sliverImageKey.currentState != null && sliverScrollController.offset > 107){
        sliverImageKey.currentState.setState(() {
          sliverImageKey.currentState.image =
          new SvgPicture.asset('assets/svg_images/arrow_left.svg');
          });
      }else{
        if(sliverImageKey.currentState != null){
          sliverImageKey.currentState.setState(() {
            sliverImageKey.currentState.image =  null;
          });
        }
      }
    });
    return CustomScrollView(
      controller: sliverScrollController,
      slivers: [
        SliverAppBar(
          expandedHeight: 175.0,
          floating: true,
          pinned: true,
          snap: true,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.all(20),
            child: InkWell(child: SliverImage(key: sliverImageKey, image: null,),
              onTap: () async {
                homeScreenKey =
                new GlobalKey<HomeScreenState>();
                if(await Internet.checkConnection()){
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
                }else{
                  noConnection(context);
                }
              },
            )
          ),
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
              title: SliverText(title: Text('', style: TextStyle(fontSize: 18),),key: sliverTextKey,),
              background: ClipRRect(
                  child: Stack(
                    children: <Widget>[
                      Hero(
                          tag: restaurant.name,
                          child: Image.network(
                            getImage(restaurant.image),
                            fit: BoxFit.cover,
                            height: 200.0,
                            width: MediaQuery.of(context).size.width,
                          )),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.only(top: 40, left: 15),
                            child: GestureDetector(
                              child: SvgPicture.asset(
                                  'assets/svg_images/rest_arrow_left.svg'),
                              onTap: () async {
                                if(await Internet.checkConnection()){
//                              Navigator.of(context).pushAndRemoveUntil(
//                                  MaterialPageRoute(
//                                      builder: (context) => HomeScreen()),
//                                      (Route<dynamic> route) => false);
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
                                }else{
                                  noConnection(context);
                                }
                              },
                            ),
                          ))
                    ],
                  )),
          ),
        ),
        SliverList(
            delegate: SliverChildBuilderDelegate(
                (context, index){
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),),
                    ),
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 15),
                                child: Text(
                                  this.restaurant.name,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF3F3F3F)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: SvgPicture.asset(
                                    'assets/svg_images/rest_info.svg'),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Container(
                                height: 26,
                                width: 51,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xFFEFEFEF)
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset('assets/svg_images/star.svg',
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: Text('5.0',
                                            style: TextStyle(
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Container(
                                height: 26,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xFFEFEFEF)
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(left:8, right: 8, top: 5, bottom: 5),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 5),
                                          child: SvgPicture.asset('assets/svg_images/rest_car.svg',
                                          ),
                                        ),
                                        Text(
                                          (restaurant.order_preparation_time_second != null)? '~' +  '${restaurant.order_preparation_time_second ~/ 60} мин' : '',
                                          style: TextStyle(
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10, right: 15),
                              child: Container(
                                height: 26,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xFFEFEFEF)
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(left:8, right: 13, top: 5, bottom: 5),
                                    child: Text('Доставка 80-150 ₽',
                                      style: TextStyle(
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        _buildFoodCategoryList(),
                        Expanded(
                          child: ListView.builder(
                            itemBuilder:(BuildContext context, int index) => menuWithTitles[index],
                            controller: foodScrollController,
                            padding: EdgeInsets.only(left: 10.0, right: 10, bottom: 0),
                            itemCount: menuWithTitles.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                          ),
                        ),
                        BasketButton(
                            key: basketButtonStateKey, restaurant: restaurant),
                      ],
                    ),
                  );
                },
              childCount: 1,
            ),
        )
      ],
    );
  }

  List<Widget> generateMenu() {
    List<Widget> menu = new List<Widget>();
    String lastCategoryName = "";
    int lastCategoryIndex = -1;
    foodMenuItems.forEach((foodMenuItem) {
      if(foodMenuItem.restaurantDataItems.category != lastCategoryName){
        lastCategoryIndex++;
        lastCategoryName = foodMenuItem.restaurantDataItems.category;
        menu.add(foodMenuTitles[lastCategoryIndex]);
      }
      menu.add(foodMenuItem);
    });
    return menu;
  }

  @override
  Widget build(BuildContext context) {
    if(restaurantDataItems != null){
      return _buildScreen();
    }
    return Scaffold(
      key: _scaffoldStateKey,
      body: FutureBuilder<RestaurantDataItems>(
          future: loadAllRestaurantItems(restaurant),
          initialData: null,
          builder: (BuildContext context,
              AsyncSnapshot<RestaurantDataItems> snapshot) {
            print(snapshot.connectionState);
            if (snapshot.connectionState == ConnectionState.done) {
              restaurantDataItems = snapshot.data;
              return _buildScreen();
            } else {
              return Center(
                child: SpinKitFadingCircle(
                  color: Colors.green,
                  size: 50.0,
                ),
              );
            }
          }),
    );
  }
  // Подгрузка итемов с категорией
  // ignore: non_constant_identifier_names
  Future<bool> GoToCategory(int categoryIndex) async {
    if(isLoading)
      return false;
    isLoading = true;
    // находим итем с данной категорией
    MenuItem targetCategory = menuWithTitles.firstWhere((element) => element is MenuItem && element.restaurantDataItems.category == restaurant.product_category[categoryIndex]);
    if(targetCategory != null){
      while(targetCategory.key.currentContext == null) {
        await foodScrollController.animateTo(foodScrollController.offset+200, duration: new Duration(milliseconds: 15),
            curve: Curves.ease);
      }
      // джампаем к нему

      await Scrollable.ensureVisible(targetCategory.key.currentContext, duration: new Duration(milliseconds: 100),
          curve: Curves.ease);
      foodScrollController.position.jumpTo(foodScrollController.position.pixels-40);
    }
    isLoading = false;
    return true;
  }
}


class MenuItemTitle extends StatefulWidget {
  MenuItemTitle({
    this.key,
    this.title,
  }) : super(key: key);
  final String  title;
  final GlobalKey<MenuItemTitleState> key;

  @override
  MenuItemTitleState createState() {
    return new MenuItemTitleState(title);
  }

  static List<MenuItemTitle> fromCategoryList(List<String> categories){
    List<MenuItemTitle> result = new List<MenuItemTitle>();
    categories.forEach((element) {
      result.add(new MenuItemTitle(key: new GlobalKey<MenuItemTitleState>(), title: element,));
    });
    return result;
  }
}

class MenuItemTitleState extends State<MenuItemTitle>{
  final String  title;

  MenuItemTitleState(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 10),
      child: Text(title[0].toUpperCase() + title.substring(1),
        style: TextStyle(
          color: Color(0xFF424242),
          fontSize: 21,
        ),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}

class CartItemsQuantity extends StatefulWidget {
  CartItemsQuantity({
    Key key,
    this.restaurantDataItems,
  }) : super(key: key);
  final FoodRecords restaurantDataItems;

  @override
  CartItemsQuantityState createState() {
    return new CartItemsQuantityState(restaurantDataItems);
  }
}

class CartItemsQuantityState extends State<CartItemsQuantity> {
  final FoodRecords restaurantDataItems;

  CartItemsQuantityState(this.restaurantDataItems);

  @override
  Widget build(BuildContext context) {
    int amount = 0;
    currentUser.cartDataModel.cart.forEach((element) {
      if (element.food.uuid == restaurantDataItems.uuid) {
        amount = element.quantity;
      }
    });
    return Padding(
      padding: EdgeInsets.only(top: 0),
      child: (amount != 0)
          ? Container(
        decoration: BoxDecoration(
            color: Color(0xFF67C070), shape: BoxShape.circle),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Text('$amount',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
              )),
        ),
      )
          : (restaurantDataItems.weight != null && restaurantDataItems.weight_measure!= null)
          ? Text(
        restaurantDataItems.weight + ' ' + restaurantDataItems.weight_measure,
        style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 12),
      )
          : Container(),
    );
  }

  void refresh() {
    setState(() {});
  }
}

class Counter extends StatefulWidget {
  GlobalKey<PriceFieldState> priceFieldKey;
  Counter({Key key, this.priceFieldKey}) : super(key: key);

  @override
  CounterState createState() {
    return new CounterState(priceFieldKey);
  }
}

class CounterState extends State<Counter> {
  GlobalKey<PriceFieldState> priceFieldKey;
  CounterState(this.priceFieldKey);

  int counter = 1;

  // ignore: non_constant_identifier_names
  void _incrementCounter_plus() {
    setState(() {
      counter++;
      if(priceFieldKey.currentState != null){
        priceFieldKey.currentState.setCount(counter);
      }
    });
  }

  // ignore: non_constant_identifier_names
  void _incrementCounter_minus() {
    setState(() {
      counter--;
      if(priceFieldKey.currentState != null){
        priceFieldKey.currentState.setCount(counter);
      }
    });
  }


  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 0),
      child: Container(
        width: 122,
        height: 58,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.black)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
            child: InkWell(
              onTap: () {
                if (counter != 1) {
                  _incrementCounter_minus();
                  // counter = restaurantDataItems.records_count;
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8)),
                ),
                height: 40,
                width: 28,
                child: Padding(
                  padding: EdgeInsets.all(7),
                  child: (counter <= 1) ? SvgPicture.asset('assets/svg_images/minus.svg') : SvgPicture.asset('assets/svg_images/black_minus.svg'),
                ),
              ),
            ),
          ),
          SizedBox(width: 19.0),
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Text(
              '$counter',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 0, top: 0, bottom: 0),
            child: InkWell(
              onTap: () async {
                if (await Internet.checkConnection()) {
                  setState(() {
                    _incrementCounter_plus();
                    // counter = restaurantDataItems.records_count;
                  });
                } else {
                  noConnection(context);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                ),
                height: 40,
                width: 28,
                child: Padding(
                  padding: EdgeInsets.all(7),
                  child: SvgPicture.asset('assets/svg_images/plus_counter.svg'),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}


class PriceField extends StatefulWidget {
  FoodRecords restaurantDataItems;
  PriceField({Key key, this.restaurantDataItems}) : super(key: key);

  @override
  PriceFieldState createState() {
    return new PriceFieldState(restaurantDataItems);
  }
}

class PriceFieldState extends State<PriceField> {
  int count = 1;
  FoodRecords restaurantDataItems;
  PriceFieldState(this.restaurantDataItems);
  Widget build(BuildContext context) {
    return Text(

      '${restaurantDataItems.price * count}\₽',

      style: TextStyle(
          fontSize: 15.0,
          color: Color(0xFF000000)),
      overflow: TextOverflow.ellipsis,
    );
  }
  void setCount(int newCount){
    setState(() {
      count = newCount;
    });
  }
}

class ButtonCounter extends StatefulWidget {
  ButtonCounter({Key key}) : super(key: key);

  @override
  ButtonCounterState createState() {
    return new ButtonCounterState();
  }
}

class ButtonCounterState extends State<ButtonCounter> {
  @override
  Widget build(BuildContext context) {
    double totalPrice = 0;
    currentUser.cartDataModel.cart.forEach(
            (Order order) => totalPrice += order.quantity * order.food.price);

    return Text('${totalPrice.toStringAsFixed(0)} \₽',
        style: TextStyle(
            fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.white));
  }

  void refresh() {
    setState(() {});
  }
}

class BasketButton extends StatefulWidget {
  final Records restaurant;

  BasketButton({Key key, this.restaurant}) : super(key: key);

  @override
  BasketButtonState createState() {
    return new BasketButtonState(restaurant);
  }
}

class BasketButtonState extends State<BasketButton> {
  GlobalKey<ButtonCounterState> buttonCounterKey = new GlobalKey();
  final Records restaurant;

  BasketButtonState(this.restaurant);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (currentUser.cartDataModel.cart != null &&
        (currentUser.cartDataModel.cart.length == 0 ||
            currentUser.cartDataModel.cart[0].restaurant.uuid !=
                restaurant.uuid)) {
      return Container();
    }
    return Padding(
      padding: EdgeInsets.only(top: 15, right: 15, left: 15, bottom: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Center(
              child: Text('До бесплатной доставки 250\₽',
                style: TextStyle(
                  fontSize: 12
                ),
              ),
            ),
          ),
          FlatButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF67C070),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          (restaurant.order_preparation_time_second != null)? '${restaurant.order_preparation_time_second ~/ 60} мин' : '',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )),
                Flexible(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: 15,
                      ),
                      child: Text('Корзина',
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    )),
                Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF67C070),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: new ButtonCounter(
                        key: buttonCounterKey,
                      ),
                    ))
              ],
            ),
            color: Color(0xFF67C070),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
            onPressed: () async {
              if (await Internet.checkConnection()) {
                if (currentUser.cartDataModel.cart.length == 0) {
                  Navigator.of(context).push(
                      PageRouteBuilder(
                          pageBuilder: (context, animation, anotherAnimation) {
                            return EmptyCartScreen(restaurant: restaurant);
                          },
                          transitionDuration: Duration(milliseconds: 300),
                          transitionsBuilder:
                              (context, animation, anotherAnimation, child) {
                            return SlideTransition(
                              position: Tween(
                                  begin: Offset(-1.0, 0.0),
                                  end: Offset(0.0, 0.0))
                                  .animate(animation),
                              child: child,
                            );
                          }
                      ));
                } else {
                  Navigator.of(context).push(
                      PageRouteBuilder(
                          pageBuilder: (context, animation, anotherAnimation) {
                            return CartPageScreen(restaurant: restaurant);
                          },
                          transitionDuration: Duration(milliseconds: 300),
                          transitionsBuilder:
                              (context, animation, anotherAnimation, child) {
                            return SlideTransition(
                              position: Tween(
                                  begin: Offset(-1.0, 0.0),
                                  end: Offset(0.0, 0.0))
                                  .animate(animation),
                              child: child,
                            );
                          }
                      ));
                }
              } else {
                noConnection(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}

class VariantsSelector extends StatefulWidget {
  List<Variants> variantsList;

  VariantsSelector({Key key, this.variantsList}) : super(key: key);

  @override
  VariantsSelectorState createState() => VariantsSelectorState(variantsList);
}

class VariantsSelectorState extends State<VariantsSelector> {
  Variants selectedVariant;
  List<Variants> variantsList;

  @override
  void initState() {
    if(variantsList.length > 0){
      selectedVariant = variantsList[0];
    }
    super.initState();
  }

  VariantsSelectorState(this.variantsList);

  Widget build(BuildContext context) {
    List<Widget> widgetsList = new List<Widget>();
    variantsList.forEach((element) {
      widgetsList.add(
        ListTile(
          title: GestureDetector(
            child: Text(
              element.name,
              style: TextStyle(color: Color(0xFF424242)),
            ),onTap: (){
            setState(() {
              selectedVariant = element;
            });
          },
          ),
          leading: Radio(
            value: element,
            groupValue: selectedVariant,
            onChanged: (Variants value) {
              setState(() {
                selectedVariant = value;
              });
            },
          ),
        ),
      );
    });
    return Container(
      color: Colors.white,
      child: ScrollConfiguration(
        behavior: new ScrollBehavior(),
        child: SingleChildScrollView(
          child: Column(
            children: widgetsList,
          ),
        ),
      ),
    );
  }
}

class ToppingsSelector extends StatefulWidget {
  List<Toppings> toppingsList;

  ToppingsSelector({Key key, this.toppingsList}) : super(key: key);

  @override
  ToppingsSelectorState createState() => ToppingsSelectorState(toppingsList);
}

class ToppingsSelectorState extends State<ToppingsSelector> {
  List<Toppings> toppingsList;
  List<MyCheckBox> widgetsList = new List<MyCheckBox>();

  ToppingsSelectorState(this.toppingsList);

  Widget build(BuildContext context) {
    toppingsList.forEach((element) {
      widgetsList.add(MyCheckBox(
          key: new GlobalKey<MyCheckBoxState>(),
        title: element.name,
        topping: element,));
    });
    return Container(
      color: Colors.white,
      child: ScrollConfiguration(
        behavior: new ScrollBehavior(),
        child: SingleChildScrollView(
          child: Column(
            children: widgetsList,
          ),
        ),
      ),
    );
  }

  List<Toppings> getSelectedToppings() {
    List<Toppings> result = new List<Toppings>();
    widgetsList.forEach((element) {
      if (element.key.currentState != null &&
          element.key.currentState.isSelected) {
        result.add(element.topping);
      }
    });
    return result;
  }
}

class MyCheckBox extends StatefulWidget {
  Toppings topping;
  String title;
  GlobalKey<MyCheckBoxState> key;

  MyCheckBox({this.key, this.topping, this.title}) : super(key: key);

  @override
  MyCheckBoxState createState() => MyCheckBoxState(topping, title);
}

class MyCheckBoxState extends State<MyCheckBox> {
  Toppings topping;
  String title;
  bool isSelected = false;

  MyCheckBoxState(this.topping, this.title);

  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: isSelected,
      title: Text(
        title,
        style: TextStyle(color: Color(0xff424242)),
      ),
      onChanged: (bool f) {
        setState(() {
          isSelected = f;
        });
      },
    );
  }
}


// Список категорий
class CategoryList extends StatefulWidget {
  CategoryList({this.key, this.restaurant, this.parent}) : super(key: key);
  final GlobalKey<CategoryListState> key;
  final RestaurantScreenState parent;
  final Records restaurant;

  @override
  CategoryListState createState() {
    return new CategoryListState(restaurant, parent);
  }
}

class CategoryListState extends State<CategoryList> {
  final Records restaurant;
  final RestaurantScreenState parent;
  String currentCategory;
  List<CategoryListItem> categoryItems;

  CategoryListState(this.restaurant, this.parent);

  _category() {
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
            height: 340,
            child: _buildCategoryBottomNavigationMenu(),
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                )),
          );
        });
  }

  _buildCategoryBottomNavigationMenu() {
    return Container(
      child: ListView(
          scrollDirection: Axis.vertical,
          children: List.generate(categoryItems.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10, right: 15),
              child: GestureDetector(
                child: Row(
                  children: [
                    Text(categoryItems[index].value[0].toUpperCase() + categoryItems[index].value.substring(1),
                      style: (categoryItems[index].value != currentCategory) ? TextStyle(fontSize: 18) : TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.start,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 2),
                      child: Text(categoryItems[index].value.length.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    )
                  ],
                ),
                onTap: () async {
                  String value = categoryItems[index].value;
                  Navigator.pop(context);
                  if(await parent.GoToCategory(restaurant.product_category.indexOf(value)))
                    SelectCategory(value);
                  ScrollToSelectedCategory();
                },
              ),
            );
          })
      ),
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    categoryItems = new List<CategoryListItem>();
    currentCategory = (restaurant.product_category.length > 0) ? restaurant.product_category[0] : '';
  }
  @override
  Widget build(BuildContext context) {
    // Если категории в списке отличаются от категорий ресторана
    if(categoryItems.length != restaurant.product_category.length){
      // Очищаем лист, если он не очищен
      if(categoryItems.length != 0)
        categoryItems.clear();
      // Заполянем список категорий категориями продуктов
      restaurant.product_category.forEach((element) {
        categoryItems.add(new CategoryListItem(key: new GlobalKey<CategoryListItemState>(),
            categoryList: this,value: element));
      });
    }
    // Скроллинг к выбранной категории после билда скрина
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ScrollToSelectedCategory();
    });

    return  Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        height: 70,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 5),
              child: InkWell(
                  child: SvgPicture.asset('assets/svg_images/menu.svg'),
                onTap: (){
                    _category();
                },
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.87,
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: categoryItems
              ),
            ),
          ],
        )
      ),
    );

  }

  void SelectCategory(String category) {
    String oldCategory = this.currentCategory;
    this.currentCategory = category;
    CategoryListItem categoryItem =
    categoryItems.firstWhere((element) => element.value == oldCategory);
    categoryItem.key.currentState.setState(() { });
    categoryItem =
        categoryItems.firstWhere((element) => element.value == category);
    categoryItem.key.currentState.setState(() { });
  }

  void ScrollToSelectedCategory() async{
    print(currentCategory);
    CategoryListItem selected_category =
    categoryItems.firstWhere((element) => element.value == currentCategory);
    if(selected_category!=null && selected_category.key.currentContext != null)
      await Scrollable.ensureVisible(selected_category.key.currentContext, duration: new Duration(seconds: 1), curve: Curves.ease);
  }

  void refresh(){
    setState(() {

    });
  }
}

// Итем списка категорий
class CategoryListItem extends StatefulWidget {
  CategoryListItem({this.key, this.value, this.categoryList}) : super(key: key);
  final GlobalKey<CategoryListItemState> key;
  final String value;
  final CategoryListState categoryList;

  @override
  CategoryListItemState createState() {
    return new CategoryListItemState(value,categoryList);
  }
}


class CategoryListItemState extends State<CategoryListItem> with AutomaticKeepAliveClientMixin {
  final CategoryListState categoryList;
  final String value;

  CategoryListItemState(this.value, this.categoryList);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
          padding:
          EdgeInsets.only(left: 11, top: 5, bottom: 5),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: (value != categoryList.currentCategory)
                    ? Colors.white
                    : Color(0xFF67C070)),
            child: Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Center(
                  child: Text(
                    value[0].toUpperCase() + value.substring(1),
                    style: TextStyle(
                        color: (value != categoryList.currentCategory)
                            ? Color(0xFF424242)
                            : Colors.white,
                        fontSize: 15),
                  ),
                )),
          )),
      onTap: () async {
        if (await Internet.checkConnection()) {
          //Если категория загрузась без ошибок
          if(await categoryList.parent.GoToCategory(categoryList.restaurant.product_category.indexOf(value)))
            categoryList.SelectCategory(value); // выделяем ее
        } else {
          noConnection(context);
        }
      },
    );
  }
}

class MenuItemCounter extends StatefulWidget {
  GlobalKey<PriceFieldState> priceFieldKey;
  FoodRecords foodRecords;
  MenuItemCounter({Key key, this.priceFieldKey, this.foodRecords}) : super(key: key);

  @override
  MenuItemCounterState createState() {
    return new MenuItemCounterState(priceFieldKey, this.foodRecords);
  }
}

class MenuItemCounterState extends State<MenuItemCounter> {
  GlobalKey<PriceFieldState> priceFieldKey;
  Order order;
  FoodRecords foodRecords;
  MenuItemCounterState(this.priceFieldKey, this.foodRecords);

  int counter = 1;

  // ignore: non_constant_identifier_names
  void _incrementCounter_plus() {
    setState(() {
      counter++;
      updateCartItemQuantity();
    });
  }

  // ignore: non_constant_identifier_names
  void _incrementCounter_minus() {
    setState(() {
      counter--;
      updateCartItemQuantity();
    });
  }


  void updateCartItemQuantity(){
    order.quantity = counter;
  }

  Widget build(BuildContext context) {
    try{
      order = currentUser.cartDataModel.cart.firstWhere((element) => element.food.uuid == foodRecords.uuid);
    }catch(e){
      order = null;
    }
    if(order == null){
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 5),
          child: Row(
            children: [
              SvgPicture.asset('assets/svg_images/rest_plus.svg'),
              Container(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 5, top: 5, right: 5),
                    child: Text(
                      '${foodRecords.price} \₽',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
              ),
            ],
          ),
        ),
      );
    }
    counter = order.quantity;
    return Padding(
        padding: EdgeInsets.only(left: 15, right: 0),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          InkWell(
            onTap: () {
              if (counter != 1) {
                _incrementCounter_minus();
                // counter = restaurantDataItems.records_count;
              }
            },
            child: SvgPicture.asset('assets/svg_images/rest_minus.svg'),
          ),
          Container(
            height: 30,
            width: 30,
            child: Padding(
              padding: EdgeInsets.only(right: 10, left: 10),
              child: Center(
                child: Text(
                  '$counter',
                  style: TextStyle(
                      fontSize: 18.0,
                    fontWeight: FontWeight.w400
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              if (await Internet.checkConnection()) {
                setState(() {
                  _incrementCounter_plus();
                  // counter = restaurantDataItems.records_count;
                });
              } else {
                noConnection(context);
              }
            },
            child: SvgPicture.asset('assets/svg_images/rest_plus.svg'),
          ),
        ])
    );
  }

  void refresh() {
    setState(() {});
  }
}



// Итем хавки
class MenuItem extends StatefulWidget {
  MenuItem({this.key, this.restaurantDataItems, this.parent}) : super(key: key);
  final GlobalKey<MenuItemState> key;
  final RestaurantScreenState parent;
  final FoodRecords restaurantDataItems;

  @override
  MenuItemState createState() {
    return new MenuItemState(restaurantDataItems, parent);
  }
  static List<MenuItem> fromFoodRecordsList(List<FoodRecords> foodRecordsList, RestaurantScreenState parent) {
    List<MenuItem> result = new List<MenuItem>();
    foodRecordsList.forEach((element) {
      result.add(new MenuItem(parent: parent, restaurantDataItems: element, key: new GlobalKey<MenuItemState>()));
    });
    return result;
  }
}

class MenuItemState extends State<MenuItem> with AutomaticKeepAliveClientMixin{
  final FoodRecords restaurantDataItems;
  final RestaurantScreenState parent;


  MenuItemState(this.restaurantDataItems, this.parent);


  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    GlobalKey<CartItemsQuantityState> cartItemsQuantityKey = new GlobalKey();
    GlobalKey<MenuItemCounterState> menuItemCounterKey = new GlobalKey();
    CartItemsQuantity cartItemsQuantity = new CartItemsQuantity(
      key: cartItemsQuantityKey,
      restaurantDataItems: restaurantDataItems,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Center(
          child: GestureDetector(
              onTap: () async {
                if (await Internet.checkConnection()) {
                  _onPressedButton(restaurantDataItems, menuItemCounterKey);
                } else {
                  noConnection(context);
                }
              },
              child: Container(
                height: 150,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15)),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    height: 100,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10.0, left: 15),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              restaurantDataItems.name,
                                              style: TextStyle(
                                                  fontSize: 16.0, color: Color(0xFF3F3F3F), fontWeight: FontWeight.w700),
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 15.0, bottom: 0, top: 5),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              restaurantDataItems.weight + '' + restaurantDataItems.weight_measure,
                                              style: TextStyle(
                                                  fontSize: 10.0,
                                                  color: Colors.grey),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  MenuItemCounter(foodRecords: restaurantDataItems, key: menuItemCounterKey,)
                                  // Align(
                                  //   child: cartItemsQuantity,
                                  // )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15),
                              bottomRight: Radius.circular(15)),
                          child: Hero(
                            tag: restaurantDataItems.name,
                            child: Image.network(
                              getImage(restaurantDataItems.image),
                              fit: BoxFit.cover,
                              height: 150,
                              width: 168,
                            ),)),
                    )
                  ],
                ),
              ))),
    );
  }
  void _onPressedButton(FoodRecords food, GlobalKey<MenuItemCounterState> menuItemCounterKey) {

    DateTime now = DateTime.now();
    int currentTime = now.hour*60+now.minute;
    print((currentTime/60).toString() + 'KANTENT');
    print((now.hour).toString() + 'KANTENT');
    print((now.minute).toString() + 'KANTENT');
    int dayNumber  = now.weekday-1;

    int work_beginning = parent.restaurant.work_schedule[dayNumber].work_beginning;
    int work_ending = parent.restaurant.work_schedule[dayNumber].work_ending;
    bool day_off = parent.restaurant.work_schedule[dayNumber].day_off;
    bool available = parent.restaurant.available != null ? parent.restaurant.available : true;
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
            )),
        context: context,
        builder: (context) {
          if(day_off ||
              !available ||
              !(currentTime >= work_beginning && currentTime < work_ending)){
            return Container(
              height: 260,
              child: parent._dayOff(food, menuItemCounterKey),
              decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                  )),
            );
          }else{
            if(food.variants != null && food.toppings == null|| food.variants == null&& food.toppings != null){
              return Container(
                height: 470,
                child: _buildBottomNavigationMenu(food, menuItemCounterKey),
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                    )),
              );
            }
            if(food.comment != "" && food.comment != null){
              return Container(
                height: 335,
                child: _buildBottomNavigationMenu(food, menuItemCounterKey),
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                    )),
              );
            }if(food.variants == null || food.toppings == null){
              return Container(
                height: 290,
                child: _buildBottomNavigationMenu(food, menuItemCounterKey),
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                    )),
              );
            }
            else{
              return Container(
                height: 570,
                child: _buildBottomNavigationMenu(food, menuItemCounterKey),
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                    )),
              );
            }
          }
        });
  }
  Container _buildBottomNavigationMenu(FoodRecords restaurantDataItems, GlobalKey<MenuItemCounterState> menuItemCounterKey) {
    GlobalKey<VariantsSelectorState> variantsSelectorStateKey =
    GlobalKey<VariantsSelectorState>();
    GlobalKey<ToppingsSelectorState> toppingsSelectorStateKey =
    new GlobalKey<ToppingsSelectorState>();
    GlobalKey<PriceFieldState> priceFieldKey =
    new GlobalKey<PriceFieldState>();


    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
          )),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(children: <Widget>[
                    ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0)),
                        child: Stack(
                          children: <Widget>[
                            Hero(
                                tag: restaurantDataItems.name,
                                child: Image.network(
                                  getImage(restaurantDataItems.image),
                                  fit: BoxFit.cover,
                                  height: 160.0,
                                  width: MediaQuery.of(context).size.width,
                                )),
                            Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10, right: 15),
                                  child: GestureDetector(
                                    child: SvgPicture.asset(
                                        'assets/svg_images/bottom_close.svg'),
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ))
                          ],
                        )),
                    (restaurantDataItems.comment != "" &&
                        restaurantDataItems.comment != null)
                        ? Padding(
                      padding:
                      EdgeInsets.only(left: 15, top: 20, bottom: 10),
                      child: Text(
                        restaurantDataItems.comment,
                        style: TextStyle(
                            color: Color(0xFFB0B0B0), fontSize: 13),
                      ),
                    )
                        : Container(
                      height: 0,
                    ),
                    Divider(height: 0, color: Color(0xFFE6E6E6),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        (restaurantDataItems.variants != null)
                            ? Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 15, top: 10),
                            child: Text(
                              restaurantDataItems.name,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                            : Container(
                          height: 0,
                        ),
                        (restaurantDataItems.variants != null) ? Padding(
                          padding: EdgeInsets.only(right: 15, top: 10),
                          child: Text('Обязательно'),
                        ) : Container()
                      ],
                    ),
                    (restaurantDataItems.variants != null)
                        ? VariantsSelector(
                        key: variantsSelectorStateKey,
                        variantsList: restaurantDataItems.variants)
                        : Container(height: 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        (restaurantDataItems.toppings != null)
                            ? Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 15, top: 10),
                            child: Text(
                              'Добавки',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                            : Container(
                          height: 0,
                        ),
                        (restaurantDataItems.toppings != null) ? Padding(
                          padding: EdgeInsets.only(right: 15, top: 10),
                          child: Text('Опционально'),
                        ) : Container()
                      ],
                    ),
                    (restaurantDataItems.toppings != null)
                        ? ToppingsSelector(
                        key: toppingsSelectorStateKey,
                        toppingsList: restaurantDataItems.toppings)
                        : Container(height: 0),
                  ]),
                ),
              )),
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            decoration: (restaurantDataItems.toppings != null && restaurantDataItems.variants != null) ? BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.0, // soften the shadow
                  spreadRadius: 3.0, //extend the shadow
                )
              ],
            ) : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 10),
                      child: Container(
                        child: RichText(text:
                        TextSpan(
                            children: <TextSpan>[
                              TextSpan(text: restaurantDataItems.name,
                                style: TextStyle(
                                    fontSize: 15.0,
                                    color: Color(0xFF000000)),),
                            ]
                        )
                        ),
                      ),
                    )),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: PriceField(key: priceFieldKey, restaurantDataItems: restaurantDataItems),
                    )
                  ],
                ),
                SizedBox(
                  height: 4.0,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: Counter(
                              key: parent.counterKey,
                              priceFieldKey: priceFieldKey
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.only(left: 15, right: 5, bottom: 0),
                          child: FlatButton(
                            child: Text(
                              "Добавить",
                              style:
                              TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            color: Color(0xFF67C070),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.only(
                                left: 70, top: 20, right: 70, bottom: 20),
                            onPressed: () async {
                              if (await Internet.checkConnection()) {
                                FoodRecords foodOrder =
                                FoodRecords.fromFoodRecords(
                                    restaurantDataItems);
                                if (variantsSelectorStateKey.currentState !=
                                    null) {
                                  if (variantsSelectorStateKey
                                      .currentState.selectedVariant !=
                                      null) {
                                    foodOrder.variants = [
                                      variantsSelectorStateKey
                                          .currentState.selectedVariant
                                    ];
                                  } else {
                                    foodOrder.variants = null;
                                  }
                                  print(foodOrder.variants);
                                }
                                if (toppingsSelectorStateKey.currentState !=
                                    null) {
                                  List<Toppings> toppingsList =
                                  toppingsSelectorStateKey.currentState
                                      .getSelectedToppings();
                                  if (toppingsList.length != null) {
                                    foodOrder.toppings = toppingsList;
                                  } else {
                                    foodOrder.toppings = null;
                                  }
                                  foodOrder.toppings.forEach((element) {
                                    print(element.name);
                                  });
                                }
                                if (currentUser.cartDataModel.cart.length > 0 &&
                                    parent.restaurant.uuid !=
                                        currentUser.cartDataModel.cart[0]
                                            .restaurant.uuid) {
                                  parent.showCartClearDialog(
                                      context,
                                      new Order(
                                          food: foodOrder,
                                          quantity:
                                          parent.counterKey.currentState.counter,
                                          restaurant: parent.restaurant,
                                          date: DateTime.now().toString()),
                                      menuItemCounterKey);
                                } else {
                                  currentUser.cartDataModel.addItem(new Order(
                                      food: foodOrder,
                                      quantity: parent.counterKey.currentState.counter,
                                      restaurant: parent.restaurant,
                                      date: DateTime.now().toString()));
                                  currentUser.cartDataModel.saveData();
                                  Navigator.pop(context);
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 0),
                                    child: parent.showAlertDialog(context),
                                  );
                                  parent.basketButtonStateKey.currentState.refresh();
                                  menuItemCounterKey.currentState.refresh();
                                  parent.counterKey.currentState.refresh();
                                }
                              } else {
                                noConnection(context);
                              }
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SliverText extends StatefulWidget {
  SliverText({
    this.key,
    this.title
  }) : super(key: key);
  final GlobalKey<SliverTextState> key;
  Text title;

  @override
  SliverTextState createState() {
    return new SliverTextState(title);
  }
}

class SliverTextState extends State<SliverText>{

  Text title;
  SliverTextState(title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 0),
      child: title
    );
  }
}

class SliverImage extends StatefulWidget {
  SliverImage({
    this.key,
    this.image
  }) : super(key: key);
  final GlobalKey<SliverImageState> key;
  SvgPicture image;

  @override
  SliverImageState createState() {
    return new SliverImageState(image);
  }
}

class SliverImageState extends State<SliverImage>{


  SvgPicture image;

  SliverImageState(image);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 0),
        child: image
    );
  }
}