import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freevideo/api/api_client.dart';
import 'package:freevideo/item.dart';
import 'package:hive/hive.dart';

class BuyvipScreen extends StatefulWidget {
  @override
  _BuyvipScreenState createState() => _BuyvipScreenState();
}

class _BuyvipScreenState extends State<BuyvipScreen> {
  final formKey = GlobalKey<FormState>();
  final mainKey = GlobalKey<ScaffoldState>();
  final _pricecontroller = TextEditingController();
  final _directpricecontroller = TextEditingController();
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
  int _selectedGender;
  int _selectedDay = 30;
  List<DropdownMenuItem<int>> genderList = [];
  List<DropdownMenuItem<int>> dayList = [];
  List vipgroups = [];
  String token = '';
  @override
  initState() {
    super.initState();
    userBox = Hive.box('user');
    setState(() {
      token = userBox.get('token');
    });
    getVipgroups();
    loadDayList();
  }
  Future getVipgroups() async {
    ApiClient client = ApiClient();
    Map data = await client.getVipgroups();
    vipgroups = data['vipgroups'];
    setState(() {
      _selectedGender = 0;
    });
    vipgroups.asMap().forEach((index, vipgroup) {
      genderList.add(DropdownMenuItem(child: Text(vipgroup['title']), value: index));
    });
  }

  void loadDayList() {
    dayList = [];
    dayList.add(new DropdownMenuItem(
      child: new Text('30天'),
      value: 30,
    ));
    dayList.add(new DropdownMenuItem(
      child: new Text('90天'),
      value: 90,
    ));
    dayList.add(new DropdownMenuItem(
      child: new Text('180天'),
      value: 180,
    ));
    dayList.add(new DropdownMenuItem(
      child: new Text('360天'),
      value: 360,
    ));
  }
  

  Widget _buildDayTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '选择开通天数',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: DropdownButtonFormField(
            iconEnabledColor: Colors.white,
            hint: new Text('选择开通天数', style: TextStyle(color: Colors.white)),
            items: dayList,
            value: _selectedDay,
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
              hintText: '选择开通天数',
              hintStyle: kHintTextStyle,
            ),
            onChanged: (value) {
              setState(() {
                _selectedDay = value;
              });
              getPrice();
            },
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '选择需要购买的用户组',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: DropdownButtonFormField(
            iconEnabledColor: Colors.white,
            items: genderList,
            value: _selectedGender,
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
              hintText: '选择您购买的VIP用户组',
              hintStyle: kHintTextStyle,
            ),
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
              getPrice();
            },
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildScorePriceTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '积分价格',
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
  Widget _buildDirectPriceTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '直接购买价格',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            readOnly: true,
            controller: _directpricecontroller,
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

  // Future postlogin() async {
  //   ApiClient client = new ApiClient();
  //   Map data = await client.postLogin(
  //       _emailcontroller.text.trim(), _passwordcontroller.text.trim());
  //   if (data['success'] == 0) {
  //     Fluttertoast.showToast(msg: data['message']);
  //   } else {
  //     userBox.put('token', data['token']);
  //     userBox.put('user', data['user']);
  //     Navigator.of(context).pop();
  //   }
  // }
  Future directBuy() async {
    ApiClient client = ApiClient();
    Map data = await client.directBuyVip(vipgroups[_selectedGender]['_id'], _selectedDay.toString(), token);
    if(data['success'] == 0) {
      Fluttertoast.showToast(msg: data['message'], toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.CENTER);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ItemPage(id: data['id']))
      );
    }
  }
  Future scoreBuyVip() async {
    ApiClient client = ApiClient();
    Map data = await client.scoreBuyVip(vipgroups[_selectedGender]['_id'], _selectedDay.toString(), token);
    if(data['success'] == 0) {
      Fluttertoast.showToast(msg: data['message'], toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.CENTER);
    } else {
      Fluttertoast.showToast(msg: data['message'], toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.CENTER);
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
          '直接购买',
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
  Widget _buildScoreBuyBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () {
          scoreBuyVip();
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          '积分购买',
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
  Future getPrice() async {
    ApiClient client = ApiClient();
    print(_selectedGender);
    Map data = await client.getJiage(vipgroups[_selectedGender]['_id'], _selectedDay.toString());
    _pricecontroller.text = data['score'].toString();
    _directpricecontroller.text = data['price'].toString();
  }
  // Widget _buildGetpriceBtn() {
  //   return Container(
  //     padding: EdgeInsets.only(top:25.0, bottom:0.0),
  //     width: double.infinity,
  //     child: RaisedButton(
  //       elevation: 5.0,
  //       onPressed: () {
  //         getPrice();
  //       },
  //       padding: EdgeInsets.all(15.0),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(30.0),
  //       ),
  //       color: Color(0xFF6CA8F1),
  //       child: Text(
  //         '获取价格',
  //         style: TextStyle(
  //           color: Colors.white,
  //           letterSpacing: 1.5,
  //           fontSize: 18.0,
  //           fontWeight: FontWeight.bold,
  //           fontFamily: 'OpenSans',
  //         ),
  //       ),
  //     ),
  //   );
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('购买VIP用户组')),
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
                        _buildGroupTF(),
                        SizedBox(
                          height: 20.0,
                        ),
                        _buildDayTF(),
                        SizedBox(
                          height: 20.0,
                        ),
                        _buildScorePriceTF(),
                        SizedBox(
                          height: 20.0,
                        ),
                        _buildDirectPriceTF(),
                        _buildBuyBtn(),
                        _buildScoreBuyBtn()
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
