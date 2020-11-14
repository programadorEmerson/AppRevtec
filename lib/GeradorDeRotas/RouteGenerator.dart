import 'package:revtec/Telas/Cadastro.dart';
import 'package:revtec/Telas/CarrinhoCompras/Abas/ItensPedido.dart';
import 'package:revtec/Telas/CarrinhoCompras/Abas/ItensPedidoRevtec.dart';
import 'package:revtec/Telas/DetalhesDoProdutoNoButton.dart';
import 'package:revtec/Telas/UsuariosCadastrados.dart';
import 'package:revtec/Telas/DetalhesDoProdutoSemBotao.dart';
import 'package:revtec/Telas/Login.dart';
import 'package:revtec/Telas/Mensagens.dart';
import 'package:revtec/Telas/Principal.dart';
import 'package:revtec/Telas/ZoomPage.dart';
import 'package:circular_splash_transition/circular_splash_transition.dart';
import 'package:flutter/material.dart';
import 'package:revtec/Telas/bloqueado.dart';


class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => Principal());
      case "/login":
        return MaterialPageRoute(builder: (_) => Login());
      case "/bloqueado":
        return MaterialPageRoute(builder: (_) => Bloqueado());
      case "/principal":
        return MaterialPageRoute(builder: (_) => Principal());
      case "/cadastro":
        return MaterialPageRoute(builder: (_) => Cadastro());
      case "/mensagens":
        return CircularSplashRoute(
          builder: Mensagens(args, "sim"), //named route
          color: Color(0xffFFFFFF),
          duration: Duration(milliseconds: 0), //optional
        );
      case "/zoom":
        return CircularSplashRoute(
          builder: ZoomPage(args), //named route
          color: Color(0xffFFFFFF),
          duration: Duration(milliseconds: 0), //optional
        );
      case "/detalheSemBotao":
        return CircularSplashRoute(
          builder: DetalhesDoProdutoSemBotao(args), //named route
          color: Color(0xffFFFFFF),
          duration: Duration(milliseconds: 0), //optional
        );
      case "/itens":
        return CircularSplashRoute(
          builder: ItensPedido(args), //named route
          color: Color(0xffFFFFFF),
          duration: Duration(milliseconds: 0), //optional
        );
      case "/usuarios":
        return CircularSplashRoute(
          builder: UsuariosCadastrados(), //named route
          color: Color(0xffFFFFFF),
          duration: Duration(milliseconds: 0), //optional
        );  
      case "/itensRevtec":
        return CircularSplashRoute(
          builder: ItensPedidoRevtec(args), //named route
          color: Color(0xffFFFFFF),
          duration: Duration(milliseconds: 0), //optional
        );
      case "/detalhe":
        return CircularSplashRoute(
          builder: DetalhesDoProdutoNoButton(args), //named route
          color: Color(0xffFFFFFF),
          duration: Duration(milliseconds: 0), //optional
        );  
      default:
        _erroRota();
    }
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Tela não encontrada!"),
        ),
        body: Center(
          child: Text("Tela não encontrada!"),
        ),
      );
    });
  }
}
