import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:revtec/Informacoes/Textos.dart';
import 'package:revtec/Telas/CalcularDiluicao.dart';
import 'package:revtec/Telas/CarrinhoCompras/HomeCarrinho.dart';
import 'package:revtec/Telas/Empresa.dart';
import 'package:revtec/Telas/Produtos.dart';
import 'package:revtec/util/Util.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class Principal extends StatefulWidget {
  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal>
    with SingleTickerProviderStateMixin {
  GlobalKey _menuState = GlobalKey();
  static String result = "Hey there !";
  Textos textos = new Textos();
  TabController _tabController;
  TextEditingController _controllerProduto = TextEditingController();
  List<String> itensMenu = ["Configurações", "Deslogar"];

  @override
  void initState() {
    super.initState();
    Textos.recuperarDadosDoUsuario(context);
    Util.configuracaoInicialAppRetornandoIdUsuarioLogado(context);
    Textos.recurerarToken(context);
    _tabController = TabController(length: 4, vsync: this);
  }

  void onClickOptionMenu(context, String value) async {
    print("_onClickOptionMenu $value");
    if ("qr" == value) {
      _scanQR(context);
    } else if ("Logout" == value) {
      FirebaseAuth.instance.signOut();
      Textos.usuarioEstaLogado = false;
      Textos.urlUsuario =
          "https://firebasestorage.googleapis.com/v0/b/revtecbioquimicaltda.appspot.com/o/imagens%2Fuser-no-photo.png?alt=media&token=f8f14dd8-5f89-40a0-a3d6-bebeb47eea49";
      Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
      Util.notification(
          context, // posição
          "Logout Realizado", // Titulo
          "Você foi desconectado", // Texto
          Icon(Icons.info_outline,
              size: 25, color: Colors.green.shade300), // Icone
          Colors.black, // Cor de Fundo
          Colors.black, // Cor da barra lateral
          Duration(seconds: 3) // duraçao em segundos
          );
    } else if ("id" == value) {
      _pesquisarProduto(context);
    } else if ("fechar" == value) {
      SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
    } else if ("Login" == value) {
      Textos.usuarioEstaLogado = false;
      Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
      Util.notification(
          context, // posição
          "Insira seus dados", // Titulo
          "Entre com suas credenciais ou cadastre-se", // Texto
          Icon(Icons.info_outline,
              size: 25, color: Colors.green.shade300), // Icone
          Colors.black, // Cor de Fundo
          Colors.black, // Cor da barra lateral
          Duration(seconds: 3) // duraçao em segundos
          );
    }
  }

  Scaffold bloqueado(){
    return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Expanded(
                    flex: 8,
                    child: Container(
                      padding: EdgeInsets.only(left: 8),
                      child: Text("Revtec Bioquímica Ltda",
                          overflow: TextOverflow.ellipsis,
                          //style: TextStyle(fontSize: fontSize)
                          ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 10,
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  InkWell(
                                    child: Column(
                                      children: <Widget>[
                                        CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.grey,
                                          backgroundImage:
                                              NetworkImage(Textos.urlUsuario),
                                        )
                                      ],
                                    ),
                                    onTap: () {
                                      // abre o popup menu
                                      dynamic state = _menuState.currentState;
                                      state.showButtonMenu();
                                    },
                                  ),
                                  PopupMenuButton<String>(
                                    key: _menuState,
                                    padding: EdgeInsets.zero,
                                    onSelected: (value) {
                                      onClickOptionMenu(context, value);
                                    },
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                      size: 28,
                                      color: Colors.white,
                                    ),
                                    itemBuilder: (BuildContext context) =>
                                        _getActions(),
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              bottom: TabBar(
                indicatorWeight: 1,
                labelStyle:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: <Widget>[
                  Tab(text: "Empresa"),
                  Tab(text: "Produtos"),
                  Tab(text: "Diluidor"),
                  Tab(text: "Pedidos")
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: <Widget>[
                Empresda(),
                Produtos(),
                CalcularDiluicao(),
                HomeCarrinho()
              ],
            ),
          );
  }

  _pesquisarProduto(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          title: new Row(
            children: <Widget>[
              Expanded(
                flex: 10,
                child: Container(
                  decoration: BoxDecoration(
                      //border: Border.all(),
                      //color: Color(
                      //    0xff075E54)
                      //image: DecorationImage(
                      //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                      ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "ID do produto",
                        style: TextStyle(
                          color: Color(0xff075E54),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          actions: <Widget>[
            // define os botões na base do dialogo
            new Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 10,
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                    //border: Border.all(color: Color(0xffB0C4DE)),
                                    //color: Colors.green,
                                    //image: DecorationImage(
                                    //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                    ),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 10,
                                          child: Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  //border: Border.all(),
                                                  //color: Color(
                                                  //    0xff075E54)
                                                  //image: DecorationImage(
                                                  //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                                  ),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                    //border: Border.all(color: Color(0xffB0C4DE)),
                                                    //color: Colors.green,
                                                    //image: DecorationImage(
                                                    //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                                    ),
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                      //width: MediaQuery.of(context).size.width,
                                                      child: new TextField(
                                                        controller:
                                                            _controllerProduto,
                                                        autofocus: true,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        style: TextStyle(
                                                            fontSize: 20),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: "Ex: 146",
                                                          filled: true,
                                                          fillColor:
                                                              Colors.white,
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16)),
                                                          prefixIcon: Icon(
                                                              Icons.search),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: 8,
                                          left: 8,
                                          bottom: 8,
                                          top: 16),
                                      child: Container(
                                          width: double.infinity,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              //border: Border.all()
                                              ),
                                          child: RaisedButton(
                                              child: Text(
                                                "Pesquisar",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20),
                                              ),
                                              color: Color(0xff075E54),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          32)),
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                _acessarProduto(
                                                    "p" +
                                                        _controllerProduto.text,
                                                    context);
                                              })),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        );
      },
    );
    return true;
  }

  _acessarProduto(String idProduto, BuildContext context) async {
    _controllerProduto.value =
        new TextEditingController.fromValue(new TextEditingValue(text: ""))
            .value;
    Textos.souARevtec
        ? Navigator.pushNamed(context, "/detalhe", arguments: idProduto)
        : Navigator.pushNamed(context, "/detalheSemBotao",
            arguments: idProduto);
  }

  Future _scanQR(BuildContext context) async {
    try {
      String qrResult = await BarcodeScanner.scan();
      result = qrResult;
      _pesquisaQr(result, context);
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        result = "Camera permission was denied";
      } else {
        result = "Unknown Error $ex";
      }
    } on FormatException {
      result = "You pressed the back button before scanning anything";
    } catch (ex) {
      result = "Unknown Error $ex";
    }
  }

  _pesquisaQr(String resultado, BuildContext context) {
    if (int.parse(resultado.length.toString()) > 3) {
      _launchURL(resultado);
    } else {
      if (resultado == "145") {
        Textos.souARevtec
            ? Navigator.pushNamed(context, "/detalhe", arguments: "p146")
            : Navigator.pushNamed(context, "/detalheSemBotao",
                arguments: "p146");
      } else {
        Textos.souARevtec
            ? Navigator.pushNamed(context, "/detalhe",
                arguments: "p" + resultado)
            : Navigator.pushNamed(context, "/detalheSemBotao",
                arguments: "p" + resultado);
      }
    }
  }

  _launchURL(String urlCapturada) async {
    if (await canLaunch(urlCapturada)) {
      await launch(urlCapturada);
    } else {
      throw 'Could not launch $urlCapturada';
    }
  }

  _getActions() {
    //_pesquisarProduto
    if (Textos.usuarioEstaLogado) {
      return <PopupMenuItem<String>>[
        PopupMenuItem<String>(
          value: "qr",
          child: Text("Ler Qrcode"),
        ),
        PopupMenuItem<String>(
          value: "id",
          child: Text("Pesquisar ID"),
        ),
        PopupMenuItem<String>(
          value: "Logout",
          child: Text("Fazer Logout"),
        ),
        PopupMenuItem<String>(
          value: "fechar",
          child: Text("Fechar App"),
        ),
      ];
    } else {
      return <PopupMenuItem<String>>[
        PopupMenuItem<String>(
          value: "qr",
          child: Text("Ler Qrcode"),
        ),
        PopupMenuItem<String>(
          value: "id",
          child: Text("Pesquisar ID"),
        ),
        PopupMenuItem<String>(
          value: "Login",
          child: Text("Fazer Login"),
        ),
        PopupMenuItem<String>(
          value: "fechar",
          child: Text("Fechar App"),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        LayoutBuilder(builder: (context, constraint) {
          double fontSize = Textos.size(
            constraint.maxWidth * 0.07,
            min: 8,
            max: 17,
          );
          return Scaffold(
            appBar: AppBar(
              title: Text("Revtec Bioquímica Ltda",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: fontSize)),
              centerTitle: true,
              bottom: TabBar(
                indicatorWeight: 1,
                labelStyle:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: <Widget>[
                  Tab(text: "Empresa"),
                  Tab(text: "Produtos"),
                  Tab(text: "Diluidor"),
                  Tab(text: "Pedidos")
                ],
              ),
            ),
            body: Center(
        child: Text(
          "Error 400\nBad Request to server, contact support\n\nwww.programandosolucoes.com",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,            
          ),
          ),
      ),
          );          
        }),
      ],
    );
  }
}
