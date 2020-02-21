import 'dart:convert';
import 'package:bitcoin_ticker/coin_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:bitcoin_ticker/constants.dart';
import 'package:bitcoin_ticker/card_widget.dart';


class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String selectedCurrency = 'USD';
  String rateBtc = '?';
  String rateEth = '?';
  String rateLtc = '?';
  String dataFromApi;

  DropdownButton androidDropdownButton() {
    List<DropdownMenuItem> listCurrency = [];
    for (String item in currenciesList) {
      String currency = item;
      listCurrency.add(
        DropdownMenuItem(child: Text(currency), value: currency),
      );
    }
    return DropdownButton(
      value: selectedCurrency,
      items: listCurrency,
      onChanged: (value) {
        setState(() {
          selectedCurrency = value;
          getRate(selectedCurrency);
        });
      },
    );
  }

  CupertinoPicker iOSPicker() {
    List<Text> listText = [];
    for (String item in currenciesList) {
      listText.add(
        Text(
          item,
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return CupertinoPicker(
      backgroundColor: Colors.lightBlue,
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) {
        setState(() {
          selectedCurrency = currenciesList[selectedIndex];
          getRate(selectedCurrency);
        });
      },
      children: listText,
    );
  }

  Widget getPicker() {
//    if (Platform.isIOS)
//      return iOSPicker();
//    else
//      (Platform.isAndroid);
    return iOSPicker();
  }

  Future<String> getCoin(String crypto, String currency) async {
    String rate;
    dynamic response =
        await http.get(coinUrl + crypto + '/' + currency + '?apikey=' + key);
    if (response.statusCode == 200) {
      dynamic json = jsonDecode(response.body);
      if (json['asset_id_base'] == crypto) {
        rate = json['rate'].toStringAsFixed(2);
      }
    }
    return rate;
  }

  Future<void> getRate(String currency) async {
    rateBtc = await getCoin('BTC', currency);
    rateEth = await getCoin('ETH', currency);
    rateLtc = await getCoin('LTC', currency);
    setState(() {});
  }

  List<Widget> getAllCoints() {
    Map<String, String> map = {'BTC': rateBtc, 'ETH': rateEth, 'LTC': rateLtc};
    List<Widget> listCoints = [];
    for (String coin in cryptoList) {
      listCoints.add(CardWidget(
          coin: coin, rate: map[coin], selectedCurrency: selectedCurrency));
    }
    return listCoints;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    getCoin('BTC', 'USD');
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: getAllCoints(),
          ),
          Center(
            child: Container(
                height: 150.0,
                alignment: Alignment.center,
                padding: EdgeInsets.only(bottom: 30.0),
                color: Colors.lightBlue,
                child: Platform.isIOS ? iOSPicker() : androidDropdownButton()),
          ),
        ],
      ),
    );
  }
}


