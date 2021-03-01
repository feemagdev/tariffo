import 'package:flutter/material.dart';
import 'auth.dart';

class Provider extends InheritedWidget {
  final Authentication auth;
  final db;

  Provider({Key key, Widget child, this.auth, this.db})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static Provider of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(Provider) as Provider);
}
