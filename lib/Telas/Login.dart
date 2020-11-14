import 'package:revtec/Informacoes/Textos.dart';
import 'package:revtec/Telas/Cadastro.dart';
import 'package:revtec/model/Usuario.dart';
import 'package:revtec/util/Util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toast/toast.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String _mensagemErro = "";

  _validarCampos() {
    //Recupera dados dos campos
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (email.isNotEmpty && email.contains("@")) {
      if (senha.isNotEmpty) {
        setState(() {
          _mensagemErro = "";
        });

        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.senha = senha;

        _logarUsuario(usuario);
      } else {
        setState(() {
          _mensagemErro = "Preencha a senha!";
        });
      }
    } else {
      setState(() {
        _mensagemErro = "Preencha o E-mail utilizando @";
      });
    }
  }

  _logarUsuario(Usuario usuario) {

    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(email: usuario.email, password: usuario.senha).then((firebaseUser) async {

    Firestore db = Firestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();

    try {
      DocumentSnapshot snapshotAppBar = await db.collection("usuarios").document(usuarioLogado.uid).get();
      DocumentSnapshot snapshotPedidoEmAberto = await db.collection("pedidos").document(usuarioLogado.uid).get(); 

      Textos.urlUsuario = snapshotAppBar.data["urlImagem"];
      Util.tipoDoUsuarioLogado = snapshotAppBar.data["infoAdicional"];

      if (usuarioLogado.uid==Textos.idDaRevtec) {
        Textos.souARevtec = true;
        Textos.usuarioEstaLogado = true;        
        Util.idDooPedidoEmAberto = "nao";
        Navigator.pushNamedAndRemoveUntil(context, "/principal", (_) => false);        
        //checarPedido("nao");
      } else {

        Util.idDooPedidoEmAberto = snapshotPedidoEmAberto.data["idPedidoEmAberto"].toString();
        Textos.souARevtec = false;
        Textos.usuarioEstaLogado = true;        
        Navigator.pushNamedAndRemoveUntil(context, "/principal", (_) => false);
        //checarPedido(snapshotPedidoEmAberto.data["idPedidoEmAberto"]);
               
      }
        
    } catch (e) {
        Util.idDooPedidoEmAberto = "nao";
        Textos.souARevtec = false;
        Textos.usuarioEstaLogado = true;        
        Navigator.pushNamedAndRemoveUntil(context, "/principal", (_) => false);
    }
    }).catchError((error) {
      setState(() {
        _mensagemErro =
            "Erro ao autenticar usuário, verifique e-mail e senha e tente novamente!";
      });
    });
  }

  void checarPedido(String idPedido) {
  showDialog(
    context: context,
    builder: (_) => CupertinoAlertDialog(
      title: Text("Id do Pedido"),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(idPedido),
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text("Não"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoDialogAction(
          child: Text("Sim"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

  Future _verificarUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    if (usuarioLogado != null) {
      Firestore db = Firestore.instance;
      FirebaseAuth auth = FirebaseAuth.instance;
      FirebaseUser usuarioLogado = await auth.currentUser();
      DocumentSnapshot snapshotAppBar = await db.collection("usuarios").document(usuarioLogado.uid).get();

      DocumentSnapshot snapshotPedidoEmAberto = await db.collection("pedidos").document(usuarioLogado.uid).get();
      Util.tipoDoUsuarioLogado = snapshotAppBar.data["infoAdicional"];

      Map<String, dynamic> verifica = snapshotPedidoEmAberto.data;
      try {
        if (verifica["idPedidoEmAberto"] == "nao") {
        Util.idDooPedidoEmAberto = "nao";
      } else {
        Util.idDooPedidoEmAberto = verifica["idPedidoEmAberto"];
      }
      } catch (e) {
        Util.idDooPedidoEmAberto = "nao";
      }

      Textos.nomeUsuarioLogado = snapshotAppBar.data["nome"];
      Util.idUsuarioLogadoApp = usuarioLogado.uid;
      Util.tipoDoUsuarioLogado = snapshotAppBar.data["infoAdicional"];

      if (snapshotAppBar.data["idUsuario"] == Util.idDaRevtec) {
        Textos.souARevtec = true;
        Textos.usuarioEstaLogado = true;      
        Navigator.pushNamedAndRemoveUntil(context, "/principal", (_) => false);
      } else {
        Textos.souARevtec = false;
        Textos.usuarioEstaLogado = true;
        Navigator.pushNamedAndRemoveUntil(context, "/principal", (_) => false);
      }
    }
  }

  @override
  void initState() {
    _verificarUsuarioLogado();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(49, 120, 65, 1),
        ),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 16, top: 80),
                  child: Image.asset(
                    "imagens/logopng.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerEmail,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "E-mail",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32)),
                      prefixIcon: Icon(
                        Icons.email,
                        color: Color.fromRGBO(49, 120, 65, 1),
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: _controllerSenha,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "Senha",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)),
                    prefixIcon: Icon(
                      Icons.vpn_key,
                      color: Color.fromRGBO(49, 120, 65, 1),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 2),
                  child: RaisedButton(
                      child: Text(
                        "FAZER LOGIN",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      color: Color.fromRGBO(68, 45, 119, 1),
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      onPressed: () {
                        _validarCampos();
                      }),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 2, bottom: 10),
                  child: RaisedButton(
                      child: Text(
                        "ENTRAR SEM LOGIN",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      color: Color.fromRGBO(68, 45, 119, 1),
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/", (_) => false);
                      }),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.only(top: 2),
                  child: Center(
                    child: GestureDetector(
                      child: Text("Não tem conta? cadastre-se!",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      onTap: () {
                        Navigator.popAndPushNamed(context, "/cadastro");
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      _mensagemErro,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
