import 'dart:convert';

import 'package:champshop/model/product_model.dart';
import 'package:champshop/screens/add_product_menu.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/edit_product_menu.dart';
import '../utility/my_constant.dart';
import '../utility/my_style.dart';

class ListProductMenuList extends StatefulWidget {
  const ListProductMenuList({Key? key}) : super(key: key);

  @override
  State<ListProductMenuList> createState() => _ListProductMenuListState();
}

class _ListProductMenuListState extends State<ListProductMenuList> {
  bool loadStatus = true; // Process Load JSON
  bool status = true; // Have Data
  List<ProductModel> productModels = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readProductMenu();
  }

  Future<Null> readProductMenu() async {
    if (productModels.length != 0) {
      loadStatus = true;
      status = true;
      productModels.clear();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? idShop = preferences.getString('id');
    print('idShop = $idShop');

    String url =
        '${MyConstant().domain}/champshop/getProductWhereIdShop.php?isAdd=true&idShop=$idShop';
    await Dio().get(url).then((value) {
      setState(() {
        loadStatus = false;
      });

      if (value.toString() != 'null') {
        var result = json.decode(value.data);

        for (var map in result) {
          ProductModel productModel = ProductModel.fromJson(map);
          setState(() {
            productModels.add(productModel);
          });
        }
      } else {
        print('Work');
        setState(() {
          status = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        loadStatus ? MyStyle().showProgress() : showContent(),
        addProductBotton(),
      ],
    );
  }

  Widget showContent() {
    return status
        ? showListProduct()
        : Center(
            child: Text('ยังไม่มีสินค้า'),
          );
  }

  Widget showListProduct() => ListView.builder(
      itemCount: productModels.length,
      itemBuilder: (context, index) => Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width * 0.3,
                height: MediaQuery.of(context).size.width * 0.3,
                child: Image.network(
                  '${MyConstant().domain}${productModels[index].pathImage}',
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.width * 0.3,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        productModels[index].nameProduct!,
                        style: MyStyle().headText16,
                      ),
                      Text(
                        'ราคา ${productModels[index].price} บาท',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(productModels[index].detail!),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 10),
                width: MediaQuery.of(context).size.width * 0.20,
                height: MediaQuery.of(context).size.width * 0.20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      height: 30,
                      child: RaisedButton(
                          color: Color.fromARGB(255, 133, 210, 134),
                          onPressed: () {
                            MaterialPageRoute route = MaterialPageRoute(
                              builder: (context) => EditProductMenu(productModel: productModels[index],),
                            );
                            Navigator.push(context, route)
                                .then((value) => readProductMenu());
                          },
                          child: Text('แก้ไข')),
                    ),
                    Container(
                      height: 30,
                      child: RaisedButton(
                        color: Color.fromARGB(255, 254, 147, 139),
                        onPressed: () => deleateProduct(productModels[index]),
                        child: Text('ลบ'),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ));

  Future<Null> deleateProduct(ProductModel productModel) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: MyStyle()
            .showerror1('คุณต้องการลบ ${productModel.nameProduct} หรือไม่'),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                onPressed: () async {
                  Navigator.pop(context);
                  String url =
                      '${MyConstant().domain}/champshop/deleteProductWhereId.php?isAdd=true&id=${productModel.id}';
                  await Dio().get(url).then((value) => readProductMenu());
                },
                child: Text('ยืนยัน'),
              ),
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ยกเลิก'),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget addProductBotton() => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                  padding: EdgeInsets.only(bottom: 20, right: 20),
                  child: FloatingActionButton(
                    onPressed: () {
                      MaterialPageRoute route = MaterialPageRoute(
                          builder: (context) => AddProductMenu());
                      Navigator.push(context, route)
                          .then((value) => readProductMenu());
                    },
                    child: Icon(Icons.add),
                  )),
            ],
          ),
        ],
      );
}