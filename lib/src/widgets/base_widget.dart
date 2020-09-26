import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/models/checkout_response.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  bool isProcessing = false;
  String confirmationMessage = 'Do you want to cancel payment?';
  bool alwaysPop = false;

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: buildChild(context),
    );
  }

  Widget buildChild(BuildContext context);

  Future<bool> _onWillPop() async {
    if (isProcessing) {
      return false;
    }

    var returnValue = getPopReturnValue();
    if (alwaysPop ||
        (returnValue != null && (returnValue is CheckoutResponse && returnValue.status == true))) {
      Navigator.of(context).pop(returnValue);
      return false;
    }

    var text = new Text(confirmationMessage);

    var dialog = Platform.isIOS
        ? new CupertinoAlertDialog(
            content: text,
            actions: <Widget>[
              new CupertinoDialogAction(
                child: Text(
                  'Yes',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor,
                  ),
                ),
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context, true); // Returning true to
                  // _onWillPop will pop again.
                },
              ),
              new CupertinoDialogAction(
                child: Text(
                  'No',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor,
                  ),
                ),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context, false); // Pops the confirmation dialog but not the page.
                },
              ),
            ],
          )
        : new AlertDialog(
            content: text,
            actions: <Widget>[
              new FlatButton(
                  child: Text(
                    'NO',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // Pops the confirmation dialog but not the page.
                  }),
              new FlatButton(
                  child: Text(
                    'YES',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true); // Returning true to _onWillPop will pop again.
                  })
            ],
          );

    bool exit = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => dialog,
        ) ??
        false;

    if (exit) {
      Navigator.of(context).pop(returnValue);
    }
    return false;
  }

  void onCancelPress() async {
    bool close = await _onWillPop();
    if (close) {
      Navigator.of(context).pop(getPopReturnValue());
    }
  }

  getPopReturnValue() {
    return null;
  }
}
