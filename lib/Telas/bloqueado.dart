import 'package:flutter/material.dart';

class Bloqueado extends StatefulWidget {
  Bloqueado({Key key}) : super(key: key);

  @override
  _BloqueadoState createState() => _BloqueadoState();
}

class _BloqueadoState extends State<Bloqueado> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Revtec Bioquímica LTDA"),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "Aplicativo descontinuado\n\ncontato@programandosolucoes.com\n\n\n\nwww.programandosolucoes.com",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,            
          ),
          ),
      ),
    );
  }
}
