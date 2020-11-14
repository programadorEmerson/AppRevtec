import 'package:revtec/Informacoes/alert.dart';
import 'package:revtec/model/Usuario.dart';
import 'package:revtec/util/Util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

class Textos {
  static Usuario usuario;
  static String idDaRevtec = "vjYwR6bU5sV2rjKahWQqfFsItwx2";
  static String apresentacaoTeste =
      "FLOAT é um poderoso limpador multiúso que possui alta performance de remoção e desincrustação de diversos tipos de sujeiras impregnadas. Sua formulação promove a limpeza profunda de superfícies e objetos pelo processo de flotação de partículas, que remove com extrema facilidade matéria orgânica, gorduras, óleos, graxas, cremes e manchas de diversas naturezas. Possui fácil aplicação e uma agradável fragrância, tudo isso sem causar nenhum dano à superfície.";
  static String indicacoesTeste =
      "Produto indicado para a utilização em hotéis, moteis, pousadas, restaurantes, refeitórios, lanchonetes, bares, padarias, cozinhas industriais e residenciais que necessitem de alta eficiência na limpeza e higienização de superfícies, utensílios, equipamentos, pisos de mármore, granito e cerâmicas, azulejos, porcelana, vidros, aço inoxidável, cromados, plásticos, fogões, coifas, geladeiras, etc.";
  static String modoDeUsarTeste =
      "Utilizar o produto puro ou em solução, na proporção de 1 parte de FLOAT para até 20 partes de Água, conforme o nível de sujidade. Com o auxílio de um frasco pulverizador, mop ou fibra, aplicar o produto sobre a superfície previamente umedecida, espalhando-o uniformemente. Esfregar a superfície e deixar agir por um período entre 30 segundos e 1 minuto. Decorrido o tempo de ação, enxaguar a superfície com água corrente e limpa ou, para superfícies menores, utilizar mop úmido ou um pano umedecido para remoção do produto.";
  static bool souARevtec = false;
  static String textoAppBar = "";
  static String nomeComprador = "";
  static String tituloDiluicao = "Saiba como diluir nossos produtos";
  static String tokemLogado = "";
  static String idUsuarioSemLogin = "";
  static String idUsuarioLogado = "";
  static String result = "Hey there !";
  static String urlImagemUsuarioLogado = "";
  static bool usuarioEstaLogado = false;
  static String comodiluir =
      "Além da opção de produtos pronto uso, temos a opção de produtos concentrado, portanto você pode fazer a quantidade desejada de acordo com as diluições fornecidas no rótudo, use nossa calculadora abaixo para que seja feita corretamente a diluição para a litragem desejada.";
  static String urlFundo =
      "https://firebasestorage.googleapis.com/v0/b/revtecbioquimicaltda.appspot.com/o/imagens%2Ffundo.png?alt=media&token=fa44c2a3-5da2-4cfe-b37e-67921ec89415";
  static String nomeUsuarioLogado = "Usuario desconectado";
  static String idUsuarioLogadoNoApp = "";
  static String urlUsuario =
      "https://firebasestorage.googleapis.com/v0/b/revtecbioquimicaltda.appspot.com/o/imagens%2Fuser-no-photo.png?alt=media&token=f8f14dd8-5f89-40a0-a3d6-bebeb47eea49";
  static String sobreempresaTitulo = "Revtec Bioquímica Ltda";
  static String texto1 =
      "A Revtec Bioquímica Ltda é uma indústria química de produtos para limpeza profissional, que visa customizar o uso dessas aplicações, tendo como diretriz no desenvolvimento de soluções, a preocupação com meio ambiente, eficiência nos resultados e baixo custo. Todos os produtos possuem formulação de alta eficiência, biodegradáveis, utilizando-se da tecnologia de flotação, que promove a suspensão de partículas, separando a sujeira da superfície com mínima ação mecânica (esfregação) e enxague.";
  static String texto2 = "Os produtos dividem-se em 4 grupos:";
  static String institucional =
      "- Institucional: largamente aprovados para limpeza em hospitais, clínicas, ambulatórios, centros cirúrgicos, cozinhas industriais, refeitórios, restaurantes, hotéis, motéis, pousadas, estabelecimentos de ensino, e demais estabelecimentos que necessitem de 100% de limpeza com economia e rapidez.";
  static String automotiva =
      "- Linha Automotiva: para limpeza interior e exterior para veículos geral, inclusive aeronaves, com excelente eficiência sem o risco de agressão à camada de tinta.";
  static String industrial =
      "- Linha Industrial: que proporciona economia e qualidade exclusiva na limpeza de oficinas, metalúrgicas, siderúrgicas, usinas, centro automotivos, postos, mecânicos e indústrias em geral.";
  static String lavanderia =
      "- Linha Lavanderia: atua nos processos de lavagem de artigos têxteis proporcionando uma alta performance na higienização e limpeza das roupas, deixando-as sempre limpas e confortáveis.";
  static String fundada =
      "Fundada em março de 1999, apresenta um crescimento significativo, resultado de uma administração eficiente, de um trabalho sério e produtos de excelente qualidade desde seu colaborador no inicio da cadeia de produção até seus distribuidores e revendas. Composta em seu quadro acionário por empresários e químicos com larga experiência administrativa e profissional, caracterizados por empenho na solução de todos os desafios a nós apresentado. Dispondo de colaboradores profissionais afinados num plano diretor de competência, honestidade, seriedade e qualidade total na gestão dos negócios. Sediada na cidade de Vargem Grande do Sul/SP, em amplo prédio próprio, organiza-se nos departamentos de recepção, telemarketing, vendas regionais, faturamento, financeiro, laboratório, estoque e produção. Dispondo de laboratório completo, gerenciado por químico com ampla experiência em pesquisas e desenvolvimento de produtos para limpeza em todos os níveis. Totalmente informatizada, com modernos computadores em rede, com registro das informações comerciais e financeiras, visando o bom, rápido e eficiente atendimento ao nosso cliente. A Revtec Bioquímica Ltda é uma inovadora empresa do setor, com amplos projetos de pesquisa e desenvolvimento resultando em produtos com qualidade, eficiência, tecnologia e posicionamento mercadológico inéditos.";
  TextEditingController _controllerProduto = TextEditingController();
  static flushBar(String title, String mensagem, BuildContext context,
      FlushbarPosition posicao, IconData icone) {
    Flushbar(
      title: title,
      message: mensagem,
      backgroundColor: Colors.black,
      flushbarPosition: posicao,
      icon: Icon(icone, size: 28, color: Color(0xff075E54)),
      leftBarIndicatorColor: Colors.black,
      duration: Duration(seconds: 3),
    )..show(context);
  }

  static criarUsuarioSemLogin(String id, String token) {
    Usuario usuario = Usuario();

    Firestore db = Firestore.instance;
    usuario.latitude = 0;
    usuario.listner = "null";
    usuario.longitude = 0;
    usuario.idUsuario = id;
    usuario.idLoja = id;
    usuario.nome = id;
    usuario.nomeFiltro = id;
    usuario.email = "visitante@visitante.com.br";
    usuario.urlImagem = urlUsuario;
    usuario.senha = "123456";
    usuario.bairro = "Bairro Visitante";
    usuario.cidade = "Cidade Visitante";
    usuario.endereco = "Endereço Visitante";
    usuario.estado = "VT";
    usuario.status = "Ativo";
    usuario.telefone = "(00)0.0000-0000";
    usuario.tipoPlano = "semPlano";
    usuario.tipoUsuario = "Visitante";
    usuario.token = tokemLogado;
    usuario.dataCadastro = "0000-00-00";
    usuario.dataPagamento = "null";
    usuario.dataVencimento = "null";
    usuario.categoria = "100.0";
    usuario.infoAdicional = "Visitante";
    usuario.receberNotificacoes = false;
    db.collection("usuarios").document(id).setData(usuario.toMap());
  }

  static recurerarToken(BuildContext context) async {
    Firestore db = Firestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();

    FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
    firebaseMessaging.getToken().then((token) async {
      tokemLogado = token;
      idUsuarioLogado = "visitante-" + token.substring(0, 10);
      criarUsuarioSemLogin("visitante-" + token.substring(0, 10), token);
      usuario = await Util.getDadosUsuarioPeloId(
          "visitante-" + token.substring(0, 10));
    });

    try {
      if (usuarioLogado.uid != null) {
        FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
        firebaseMessaging.getToken().then((token) async {
          db
              .collection("usuarios")
              .document(usuarioLogado.uid)
              .updateData({"token": token});
          tokemLogado = token;
          idUsuarioLogado = usuarioLogado.uid;
          usuario = await Util.getDadosUsuarioPeloId(usuarioLogado.uid);
        });
      }
    } catch (e) {}
  }

  static retornaMensagemDoBanco(
      BuildContext context, String child, String children) async {
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshotAppBar =
        await db.collection(child).document(children).get();
    return snapshotAppBar.data["valor"];
  }

  static recuperarDadosDoUsuario(BuildContext context) async {
    Firestore db = Firestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    try {
      DocumentSnapshot snapshotAppBar = await db.collection("usuarios").document(usuarioLogado.uid).get();
        Util.porcentagem = double.parse(snapshotAppBar.data["categoria"]);
        nomeUsuarioLogado = snapshotAppBar.data["nome"];
        urlUsuario = snapshotAppBar.data["urlImagem"];
    } catch (e) {
      Util.porcentagem = 100.0;
    }

  }

  static size(double size, {double min = 10, double max = 18}) {
    if (size < min) {
      return min;
    }
    if (size > max) {
      return max;
    }
    return size;
  }

  Row appBarLinha(BuildContext context, double fontSize, String texto) {
    GlobalKey _menuState = GlobalKey();
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: Container(
            padding: EdgeInsets.only(left: 8),
            child: Text(texto,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: fontSize)),
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
                                backgroundImage: NetworkImage(urlUsuario),
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
                          itemBuilder: (BuildContext context) => _getActions(),
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
    );
  }

  AppBar appBar(BuildContext context, double fontSize, String texto) {
    GlobalKey _menuState = GlobalKey();
    return AppBar(
      title: Row(
        children: [
          Expanded(
            flex: 8,
            child: Container(
              padding: EdgeInsets.only(left: 8),
              child: Text(texto,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: fontSize)),
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
                                  backgroundImage: NetworkImage(urlUsuario),
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
    );
  }

  void onClickOptionMenu(context, String value) async { 
    print("_onClickOptionMenu $value");
    if ("qr" == value) {
      _scanQR(context);
    } else if ("Logout" == value) {
      FirebaseAuth.instance.signOut();
      Textos.usuarioEstaLogado = false;
      urlUsuario = "https://firebasestorage.googleapis.com/v0/b/revtecbioquimicaltda.appspot.com/o/imagens%2Fuser-no-photo.png?alt=media&token=f8f14dd8-5f89-40a0-a3d6-bebeb47eea49";
      Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
      Util.notification(
          context, // posição
          "Logout Realizado", // Titulo
          "Você foi desconectado", // Texto
          Icon(Icons.info_outline, size: 25, color: Colors.green.shade300), // Icone
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

  _pesquisaQr(String resultado, BuildContext context){

      if(int.parse(resultado.length.toString())>3){
          _launchURL(resultado);
      } else {
        if(resultado == "145"){      
      Textos.souARevtec ? Navigator.pushNamed(context, "/detalhe", arguments: "p146") :
      Navigator.pushNamed(context, "/detalheSemBotao", arguments: "p146");
    } else {
      Textos.souARevtec ? Navigator.pushNamed(context, "/detalhe", arguments: "p"+resultado) :
      Navigator.pushNamed(context, "/detalheSemBotao", arguments: "p"+resultado);
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

_acessarProduto(String idProduto, BuildContext context)async{

bool validar = false;
String teste;

_controllerProduto.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;

    Firestore db = Firestore.instance;    
    QuerySnapshot querySnapshot = await db.collection("produtos").getDocuments();

      DocumentSnapshot snapshotAppBar = await db.collection("usuarios").document("jiOdUyeaoiRSGfxQRvS8A2b2PPx1").get();
      teste = snapshotAppBar.data["idUsuario"];


    Toast.show(teste, context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
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
                                                            TextInputType.number,
                                                        style: TextStyle(
                                                            fontSize: 20),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              "Ex: 146",
                                                          filled: true,
                                                          fillColor:
                                                              Colors.white,
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16)),
                                                          prefixIcon: Icon(Icons.search),
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
                                                _acessarProduto("p"+_controllerProduto.text, context);

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

  _getActions() { //_pesquisarProduto
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
}
