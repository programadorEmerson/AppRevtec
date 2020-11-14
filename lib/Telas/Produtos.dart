import 'package:revtec/Informacoes/Textos.dart';
import 'package:revtec/Telas/Institucional.dart';
import 'package:revtec/Telas/Automotiva.dart';
import 'package:revtec/Telas/Industrial.dart';
import 'package:revtec/Telas/Lavanderia.dart';
import 'package:flutter/material.dart';

class Produtos extends StatefulWidget {
  @override
  _ProdutosState createState() => _ProdutosState();
}

class _ProdutosState extends State<Produtos> {
  int _indiceAtual = 0;

  @override
  Widget build(BuildContext context) {

    List<Widget> telas = [Automotiva(), Industrial(), Institucional(), Lavanderia()];

    return Stack(
      children: <Widget>[
        LayoutBuilder(
            builder: (context, constraint) {
          double fontSize = Textos.size(
            constraint.maxWidth * 0.07,
            min: 8,
            max: 16,
          );
          GlobalKey _menuState = GlobalKey();
          return Scaffold(
            body: telas[_indiceAtual],
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: _indiceAtual,
                onTap: (indice) {
                  setState(() {
                    _indiceAtual = indice;
                  });
                },
                type: BottomNavigationBarType.fixed,
                fixedColor: Color(0xff075E54),
                items: [
                  BottomNavigationBarItem(
                      //backgroundColor: Colors.orange,
                      title: Text(
                        "Automotiva",
                        style: TextStyle(fontSize: fontSize),
                      ),
                      icon: Icon(Icons.directions_car)),
                  BottomNavigationBarItem(
                      //backgroundColor: Colors.red,
                      title: Text(
                        "Industrial",
                        style: TextStyle(fontSize: fontSize),
                      ),
                      icon: Icon(Icons.business)),
                  BottomNavigationBarItem(
                      //backgroundColor: Colors.blue,
                      title: Text(
                        "Institucional",
                        style: TextStyle(fontSize: fontSize),
                      ),
                      icon: Icon(Icons.home)),
                  BottomNavigationBarItem(
                      //backgroundColor: Colors.green,
                      title: Text(
                        "Lavanderia",
                        style: TextStyle(fontSize: fontSize),
                      ),
                      icon: Icon(Icons.local_laundry_service)),
                ]),
          );
        }),              
      ],
    );
  }
}
