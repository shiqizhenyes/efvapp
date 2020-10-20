import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freevideo/api/api_client.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemPage extends StatefulWidget {
  final String id;
  ItemPage({this.id});
  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  final formKey = GlobalKey<FormState>();
  final mainKey = GlobalKey<ScaffoldState>();
  final _itemtitlecontroller = TextEditingController();
  final _itempricecontroller = TextEditingController();
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
  Map item;
  @override
  initState() {
    super.initState();
    userBox = Hive.box('user');
    print(item);
    getItem();
  }

  Future getItem() async {
    ApiClient client = ApiClient();
    Map data = await client.getItem(widget.id);
    setState(() {
      item = data;
    });
    _itemtitlecontroller.text = item['item']['subject'];
    _itempricecontroller.text = item['item']['amount'];
  }

  Widget _buildItemTitleTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '商品名称',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            readOnly: true,
            controller: _itemtitlecontroller,
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

  Widget _buildItemPriceTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '价格',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            readOnly: true,
            controller: _itempricecontroller,
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

  Future codePay(int type) async {
    ApiClient client = ApiClient();
    Map data = await client.postCodePay(widget.id, type);
    if (data['success'] == 1) {
      launch(data['url']);
    } else {
      Fluttertoast.showToast(msg: data['message']);
    }
  }

  Widget _buildBuyBtn() {
    List<Widget> buyType = [Container()];
    Map pay = item['pay'];
    List paytype = pay['paytype'];
    List codepaytype = pay['codepaytype'];
    paytype.forEach((thepay) {
      if (thepay == 2) {
        for (var i = 0; i < codepaytype.length; i++) {
          var type = codepaytype[i];
          if (type == 1) {
            buyType.add(Container(
              padding: EdgeInsets.only(top: 25.0, bottom: 0.0),
              width: double.infinity,
              child: RaisedButton(
                elevation: 5.0,
                onPressed: () {
                  codePay(1);
                },
                padding: EdgeInsets.all(15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: Colors.white,
                child: Text(
                  '码支付(支付宝)',
                  style: TextStyle(
                    color: Color(0xFF527DAA),
                    letterSpacing: 1.5,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
            ));
          } else if (type == 2) {
            buyType.add(Container(
              padding: EdgeInsets.only(top: 25.0, bottom: 0.0),
              width: double.infinity,
              child: RaisedButton(
                elevation: 5.0,
                onPressed: () {
                  codePay(2);
                },
                padding: EdgeInsets.all(15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: Colors.white,
                child: Text(
                  '码支付(QQ支付)',
                  style: TextStyle(
                    color: Color(0xFF527DAA),
                    letterSpacing: 1.5,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
            ));
          } else if (type == 3) {
            buyType.add(Container(
              padding: EdgeInsets.only(top: 25.0, bottom: 0.0),
              width: double.infinity,
              child: RaisedButton(
                elevation: 5.0,
                onPressed: () {
                  codePay(3);
                },
                padding: EdgeInsets.all(15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: Colors.white,
                child: Text(
                  '码支付(微信支付)',
                  style: TextStyle(
                    color: Color(0xFF527DAA),
                    letterSpacing: 1.5,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
            ));
          }
        }
      }
    });
    return Column(children: buyType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('订单详情')),
      body: item == null
          ? Center(
              child: CircularProgressIndicator(backgroundColor: Colors.black26))
          : GestureDetector(
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
                            _buildItemTitleTF(),
                            SizedBox(height: 20.0),
                            _buildItemPriceTF(),
                            _buildBuyBtn()
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
