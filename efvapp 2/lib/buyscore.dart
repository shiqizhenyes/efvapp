import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freevideo/api/api_client.dart';
import 'package:freevideo/item.dart';
import 'package:hive/hive.dart';

class BuyscoreScreen extends StatefulWidget {
  @override
  _BuyscoreScreenState createState() => _BuyscoreScreenState();
}

class _BuyscoreScreenState extends State<BuyscoreScreen> {
  final formKey = GlobalKey<FormState>();
  final mainKey = GlobalKey<ScaffoldState>();
  final _pricecontroller = TextEditingController();
  final _scorecontroller = TextEditingController();

  final kHintTextStyle = TextStyle(
    color: Colors.white54,
    fontFamily: 'OpenSans',
  );

  final kLabelStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontFamily: 'OpenSans',
  );

  final kBoxDecorationStyle = BoxDecoration(
    color: Color(0xFF6CA8F1),
    borderRadius: BorderRadius.circular(10.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6.0,
        offset: Offset(0, 2),
      ),
    ],
  );
  Box userBox;
  @override
  initState() {
    super.initState();
    userBox = Hive.box('user');
    Map portal = userBox.get('portal');
    _scorecontroller.addListener(() {
      String score = _scorecontroller.text;
      if(score.length == 0) {
        score = '0';
      }
      int amount = portal['amount'];
      int minamount = portal['minamount'] * amount;
      double price = int.parse(score) * 1 / amount*1;
      String pricetext = price.toStringAsFixed(2);
      if(minamount > int.parse(score)) {
        _pricecontroller.text = '至少购买' + minamount.toString() + '积分';
      } else {
        _pricecontroller.text = pricetext + '元';
      }
    });
  }


  Widget _buildScoreInputTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '输入购买积分数',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: _scorecontroller,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: '输入购买积分数',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildPriceTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '购买价格',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            readOnly: true,
            controller: _pricecontroller,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: '等待获取',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }
  Future directBuy() async {
    ApiClient client = ApiClient();
    String score = _scorecontroller.text;
    if(score.length == 0) {
      score = '0';
    }
    Map portal = userBox.get('portal');
    int amount = portal['amount'];
    int minamount = portal['minamount'] * amount;
    if(minamount > int.parse(score)) {
      Fluttertoast.showToast(msg: '至少购买' + minamount.toString() + '积分', gravity: ToastGravity.CENTER, toastLength: Toast.LENGTH_LONG);
    } else {
      print('buy score');
      Map data = await client.buyScore(userBox.get('token'), score);
      if(data['success'] == 1) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ItemPage(id: data['id']))
        );
      } else {
        Fluttertoast.showToast(msg: data['message'], gravity: ToastGravity.CENTER);
      }
    }
  }
  
  Widget _buildBuyBtn() {
    return Container(
      padding: EdgeInsets.only(top:25.0, bottom:0.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () {
          directBuy();
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          '点击购买',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('购买积分')),
      body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: formKey,
            child: Stack(
              children: <Widget>[
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF73AEF5),
                        Color(0xFF61A4F1),
                        Color(0xFF478DE0),
                        Color(0xFF398AE5),
                      ],
                      stops: [0.1, 0.4, 0.7, 0.9],
                    ),
                  ),
                ),
                Container(
                  height: double.infinity,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _buildScoreInputTF(),
                        SizedBox(
                          height: 20.0,
                        ),
                        _buildPriceTF(),
                        SizedBox(
                          height: 20.0,
                        ),
                        _buildBuyBtn(),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
