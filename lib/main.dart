// Laroyê Exu
// Exú é Mojubá
// Salve suas forças Sr Exu das 7 Espadas
// Salve a Umbanda sagrada

import 'package:flutter/material.dart';
import 'GeradorDeRotas/RouteGenerator.dart';
import 'dart:io';

final ThemeData temaIOS = ThemeData(
    primaryColor: Color(0xff075E54),
    accentColor: Color(0xff25D366)
);

final ThemeData temaPadrao = ThemeData(
  primaryColor: Color(0xff075E54),
  accentColor: Color(0xff25D366),
);

void main(){
  runApp(
    MaterialApp(
      theme: Platform.isIOS ? temaIOS : temaPadrao,
      initialRoute: "/login",
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
    ),
  );
}