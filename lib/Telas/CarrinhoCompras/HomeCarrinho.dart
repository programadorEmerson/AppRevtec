import 'package:revtec/Informacoes/Textos.dart';
import 'package:revtec/model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:revtec/Telas/CarrinhoCompras/Abas/PedidosEmAberto.dart';
import 'package:revtec/Telas/CarrinhoCompras/Abas/PedidosFinalizados.dart';
import 'package:revtec/Telas/CarrinhoCompras/Abas/PedidosFinalizadosRevtec.dart';
import 'package:revtec/Telas/CarrinhoCompras/Abas/PedidosEmAbertoRevtec.dart';

class HomeCarrinho extends StatefulWidget {
  @override
  _HomeCarrinhoState createState() => _HomeCarrinhoState();
}

class _HomeCarrinhoState extends State<HomeCarrinho> {
  String _idUsuarioLogado;
  String _idUsuarioClicado;
  String _emailUsuarioLogado;
  Firestore db = Firestore.instance;
  int _indiceAtual = 0;

  List<Widget> telas = [Textos.souARevtec ? PedidosEmAbertoRevtec() : PedidosEmAberto(), Textos.souARevtec ? PedidosFinalizadosRevtec() : PedidosFinalizados()];

  _recuperarDadosUsuario() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      FirebaseUser usuarioLogado = await auth.currentUser();
      setState(() {
        _idUsuarioLogado = usuarioLogado.uid;
      });
      _emailUsuarioLogado = usuarioLogado.email;
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          padding: EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0),
          child: telas[_indiceAtual],
        ),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _indiceAtual,
            onTap: (indice) {
              setState(() {
                _indiceAtual = indice;
              });
            },
            type: BottomNavigationBarType.shifting,
            fixedColor: Colors.white,
            items: [
              BottomNavigationBarItem(
                  backgroundColor: Color(0xff075E54),
                  title: Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Textos.souARevtec ? Text("Pedidos em Aberto") : Text("Carrinho de Compras"),
                  ),
                  icon: Icon(Icons.shopping_cart)),
              BottomNavigationBarItem(
                  backgroundColor: Color(0xff075E54),
                  title: Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Textos.souARevtec ? Text("Pedidos Concluídos") : Text("Pedidos Finalizados"),
                  ),
                  icon: Icon(Icons.remove_shopping_cart)),
            ]));
  }
}
