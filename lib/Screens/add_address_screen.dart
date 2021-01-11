import 'package:flutter/material.dart';
import 'package:faem_app/Internet/check_internet.dart';
import 'package:faem_app/Screens/autocolplete_field_list.dart';
import 'package:faem_app/Screens/cart_screen.dart';
import 'package:faem_app/data/data.dart';
import 'package:faem_app/Models/my_addresses_model.dart';
import 'package:flutter_svg/svg.dart';
import 'package:faem_app/Screens/address_screen.dart';
import 'address_screen.dart';
import 'my_addresses_screen.dart';

// ignore: must_be_immutable
class AddAddressScreen extends StatefulWidget {
  MyFavouriteAddressesModel myAddressesModel;
  AddressScreenState parent;

  AddAddressScreen({Key key, this.myAddressesModel, this.parent}) : super(key: key);

  @override
  AddAddressScreenState createState() =>
      AddAddressScreenState(myAddressesModel, parent);
}

class AddAddressScreenState extends State<AddAddressScreen> {
  bool status1 = false;
  String name;
  MyFavouriteAddressesModel myAddressesModel;
  GlobalKey<AutoCompleteFieldState> autoCompleteFieldKey = new GlobalKey();
  AddressScreenState parent;
  TakeAwayState parent1;


  AddAddressScreenState(this.myAddressesModel, this.parent);

  TextEditingController nameField = new TextEditingController();
  TextEditingController commentField = new TextEditingController();
  GlobalKey<CartPageState>cartPageKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    nameField.text = myAddressesModel.name;
    commentField.text = myAddressesModel.description;
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                        padding: EdgeInsets.only(top: 30, bottom: 25),
                        child: Container(
                            height: 40,
                            width: 60,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 12, bottom: 12, right: 10),
                              child:SvgPicture.asset(
                                  'assets/svg_images/arrow_left.svg'),
                            )))),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 80, left: 20),
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Text('Адрес',
                            style: TextStyle(fontSize: 14, color: Color(0xFF9B9B9B))),
                      ),
                    ),
                    AutoCompleteField(autoCompleteFieldKey, onSelected: (){
                      myAddressesModel.address = FavouriteAddress.fromInitialAddressModelChild(autoCompleteFieldKey.currentState.selectedValue);
                      return;
                    }, initialValue: (myAddressesModel.address == null) ? '' : myAddressesModel.address.unrestrictedValue,)
                  ],
                ),
              )
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(bottom: 15, left: 15, right: 15, top: 5),
                child: FlatButton(
                  child: Text(
                      "Добавить адрес",
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white)
                  ),
                  color: Color(0xFF67C070),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                  EdgeInsets.only(left: 100, top: 20, right: 100, bottom: 20),
                  onPressed: () async {
                    if (await Internet.checkConnection()) {
                      if(myAddressesModel.address == null){
                        return;
                      }
                      myAddressesModel.name = nameField.text;
                      myAddressesModel.description = commentField.text;
                      // if(myAddressesModel.tag == null) {
                      //   myAddressesModel.tag = "";
                      //   parent.myAddressesModelList
                      //       .add(new MyFavouriteAddressesModel(tag: null));
                      // }
                      //await myAddressesModel.ifNoBrainsSave();

                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(context,
                        new MaterialPageRoute(builder: (context) => new AddressScreen(restaurant: parent.restaurant, myAddressesModelList: parent.myAddressesModelList,)),
                      );
//                      if(cartPageKey.currentState.cartScreenKey.currentState.){
//
//                      }else{
//                        Navigator.push(context,
//                          new MaterialPageRoute(builder: (context) => new TakeAway(restaurant: parent1.restaurant,)),
//                        );
//                      }
                    } else {
                      noConnection(context);
                    }
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}