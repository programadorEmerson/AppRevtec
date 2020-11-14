import 'package:revtec/Informacoes/Textos.dart';
import 'package:revtec/Telas/AbaConversas.dart';
import 'package:revtec/Telas/AntesDepois.dart';
import 'package:revtec/Telas/Mensagens.dart';
import 'package:revtec/Telas/SobreEmpresa.dart';
import 'package:revtec/Telas/Videos.dart';
import 'package:revtec/Telas/teste.dart';
import 'package:revtec/model/Mensagem.dart';
import 'package:flutter/material.dart';

class Empresda extends StatefulWidget {
  @override
  _EmpresdaState createState() => _EmpresdaState();
}

class _EmpresdaState extends State<Empresda> {

  bool revtec = false;

  int _indiceAtual = 0;
  List<Widget> telas = Textos.souARevtec ? [SobreEmpresa(), AbaConversas(), Videos(), AntesDepois()]
                              :            [SobreEmpresa(), Mensagens(Textos.usuario, "nao"), Videos(), AntesDepois()];

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          LayoutBuilder(builder: (context, constraint) {
            double fontSize = Textos.size(constraint.maxWidth * 0.07, min: 8, max: 16,);
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
                            "Sobre",
                            style: TextStyle(fontSize: fontSize),
                          ),
                          icon: Icon(Icons.info_outline)),
                      BottomNavigationBarItem(
                        //backgroundColor: Colors.red,
                          title: Text(
                            "Mensagem",
                            style: TextStyle(fontSize: fontSize),
                          ),
                          icon: Icon(Icons.message)),
                      BottomNavigationBarItem(
                        //backgroundColor: Colors.blue,
                          title: Text(
                            "Vídeos",
                            style: TextStyle(fontSize: fontSize),
                          ),
                          icon: Icon(Icons.live_tv)),
                      BottomNavigationBarItem(
                        //backgroundColor: Colors.green,
                          title: Text(
                            "Imagens",
                            style: TextStyle(fontSize: fontSize),
                          ),
                          icon: Icon(Icons.image)),
                    ])
            );
          })
        ],
      ),
    );
  }
}
