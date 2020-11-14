import 'dart:async';

import 'package:revtec/Informacoes/Textos.dart';
import 'package:revtec/model/PedidoId.dart';
import 'package:revtec/model/PedidosProdutos.dart';
import 'package:revtec/util/Util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:toast/toast.dart';

class UsuariosCadastrados extends StatefulWidget {
  @override
  _UsuariosCadastradosState createState() => _UsuariosCadastradosState();
}

class _UsuariosCadastradosState extends State<UsuariosCadastrados> {
  String _idUsuarioLogado;
  int quantidade = 0;
  TextEditingController _controllerProduto = TextEditingController();
  double _preco = 0;
  double _valorEntrega = 0;
  Firestore db = Firestore.instance;
  TextEditingController _textFieldQtdade = TextEditingController();

  final _controller = StreamController<QuerySnapshot>.broadcast();

  Stream<QuerySnapshot> _adicionarListenerDistribuidor() {
    Firestore db = Firestore.instance;
    final stream = db
        .collection("usuarios")
        .where("infoAdicional", isEqualTo: "Comprador")
        //.orderBy("nome")
        .snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  Stream<QuerySnapshot> _adicionarListenerUsuario() {
    Firestore db = Firestore.instance;
    final stream = db
        .collection("usuarios")
        .where("infoAdicional", isEqualTo: "Usuário")
        //.orderBy("nome")
        .snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }



  _deletarItemComprador(
      String pIdProduto, String pIdPedido, String idDestinatario) async {
    await db
        .collection("pedidos")
        .document(Util.idUsuarioLogadoApp)
        .collection(idDestinatario)
        .document(pIdPedido)
        .collection("itens")
        .document(pIdProduto)
        .delete();

    Util.flutterNotification(
        context,
        FlushbarPosition.BOTTOM, // posição
        "${Util.primeiroNomeUsuarioLogado}", // Titulo
        "Item removido com sucesso", // Texto
        Icon(Icons.info_outline,
            size: 25, color: Colors.green.shade300), // Icone
        Colors.black, // Cor de Fundo
        Colors.black, // Cor da barra lateral
        Duration(seconds: 3) // duraçao em segundos
        );
  }

  _deletarItemVendedor(
      String pIdProduto, String pIdPedido, String idDestinatario) async {
    await db
        .collection("pedidos")
        .document(idDestinatario)
        .collection(Util.idUsuarioLogadoApp)
        .document(pIdPedido)
        .collection("itens")
        .document(pIdProduto)
        .delete();

    _deletarItemComprador(pIdProduto, pIdPedido, idDestinatario);
  }

  _finalizarVendedor(String pIdPedido, String idDestinatario, PedidoId pedido,
      PedidoId pedido2) async {
    await db
        .collection("pedidosUsuario")
        .document(_idUsuarioLogado)
        .collection("pedidos")
        .document(Util.idPedido)
        .setData(pedido.toMap());

    await db
        .collection("pedidosEmpresa")
        .document(idDestinatario)
        .collection("pedidos")
        .document(Util.idPedido)
        .setData(pedido2.toMap());

    _finalizarComprador(pIdPedido, idDestinatario, pedido);
  }

  _finalizarComprador(
      String pIdPedido, String idDestinatario, PedidoId pedido) async {
    String idPedidoCapturado = Util.idPedido;
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();

    await db
        .collection("pedidos")
        .document(usuarioLogado.uid)
        .collection(idDestinatario)
        .document(pIdPedido)
        .setData(pedido.toMap());

    QuerySnapshot querySnapshot = await db
        .collection("pedidos")
        .document(_idUsuarioLogado)
        .collection(Util.idLoja)
        .document(idPedidoCapturado)
        .collection("itens")
        .getDocuments();

    for (DocumentSnapshot item in querySnapshot.documents) {
      Firestore db = Firestore.instance;
      db
          .collection("pedidos")
          .document(_idUsuarioLogado)
          .collection(Util.idLoja)
          .document(idPedidoCapturado)
          .collection("itens")
          .document(item["idProduto"])
          .updateData({"status": "Finalizado"});
    }

    setState(() {
      _preco = 0;
      Util.idPedido = Util.gerarIdUnico();
      Util.statusPedido = "Aberto";

      Util.flutterNotification(
          context,
          FlushbarPosition.BOTTOM, // posição
          "Pedido finalizado", // Titulo
          "${Util.primeiroNomeUsuarioLogado}, seu pedido foi enviado com sucesso!.", // Texto
          Icon(Icons.check, size: 25, color: Colors.green.shade300), // Icone
          Colors.black, // Cor de Fundo
          Colors.black, // Cor da barra lateral
          Duration(seconds: 3) // duraçao em segundos
          );
    });
  }

  _recuperarDadosUsuario() async {
    _adicionarListenerDistribuidor();
  }

  @override
  void initState() {
    super.initState();
    _adicionarListenerDistribuidor();
  }

  var mensagemCarregando = Center(
    child: Column(
      children: <Widget>[
        Text("Carregando requisições"),
        CircularProgressIndicator()
      ],
    ),
  );

  var mensagemNaoTemDados = Center(
    child: Text(
      Textos.nomeUsuarioLogado + "\n\nSem novos usuários.",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  _alterarQuantidade(String idUsuario, String idLoja, String idPedido,
      String idProduto, String quantidade) {
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
                        "Qual a nova quantidade",
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
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .words,
                                                        autofocus: true,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        style: TextStyle(
                                                            fontSize: 20),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              "Quantidade",
                                                          filled: true,
                                                          fillColor:
                                                              Colors.white,
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16)),
                                                          prefixIcon: Icon(Icons
                                                              .location_city),
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
                                                "Confirmar",
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
                                                if (_controllerProduto
                                                    .text.isNotEmpty) {
                                                  Navigator.of(context).pop();
                                                } else {
                                                  Navigator.of(context).pop();
                                                  _controllerProduto.value =
                                                      new TextEditingController
                                                                  .fromValue(
                                                              new TextEditingValue(
                                                                  text: ""))
                                                          .value;
                                                  Toast.show(
                                                      "Quantidade inválida",
                                                      context,
                                                      duration:
                                                          Toast.LENGTH_LONG,
                                                      gravity: Toast.CENTER);
                                                }
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        LayoutBuilder(builder: (context, constraint) {
          double fonteTitulo = Textos.size(
            constraint.maxWidth * 0.07,
            min: 8,
            max: 17,
          );
          double fonteDetalhe = Textos.size(
            constraint.maxWidth * 0.07,
            min: 8,
            max: 14,
          );
          return Scaffold(
            appBar: AppBar(
              title: Text("Usuários Cadastrados"),
            ),
            body: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("imagens/fundo.png"),
                      fit: BoxFit.cover)),
              child: StreamBuilder<QuerySnapshot>(
                  stream: _controller.stream,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Container(
                          padding: EdgeInsets.only(top: 8),
                          child: Column(
                            children: <Widget>[
                              Center(
                                //padding: EdgeInsets.only(top: 16),
                                child: Container(
                                  padding: EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          CircularProgressIndicator(),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(top: 16),
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              "Carregando Itens",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Color(0xff075E54),
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                        break;
                      case ConnectionState.active:
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return Text("Erro ao carregar os dados!");
                        } else {
                          QuerySnapshot querySnapshot = snapshot.data;
                          if (querySnapshot.documents.length == 0) {
                            return mensagemNaoTemDados;
                          } else {
                            return ListView.separated(
                                itemCount: querySnapshot.documents.length,
                                separatorBuilder: (context, indice) => Divider(
                                      height: 2,
                                      color: Colors.grey,
                                    ),
                                itemBuilder: (context, indice) {
                                  List<DocumentSnapshot> requisicoes =
                                      querySnapshot.documents.toList();
                                  DocumentSnapshot item = requisicoes[indice];

                                  AssetImage _imagem = AssetImage(
                                      "imagens/fundotopoproduto.png");

                                  return Container(
                                    padding: EdgeInsets.only(
                                        left: 8, right: 8, top: 4, bottom: 0),
                                    width: double.infinity,
                                    child: Container(
                                      padding: EdgeInsets.only(left: 8),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Color(0xffB0C4DE)),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          image: DecorationImage(
                                              image: _imagem, fit: BoxFit.fill)
                                          //color: Colors.green,
                                          //image: DecorationImage(
                                          //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                          ),
                                      child: GestureDetector(

                                        onLongPress: (){
                                          if (item["infoAdicional"] ==
                                              "Usuário") {
                                            mudarParaDistribuidor(
                                                item["idUsuario"]);
                                          } else {
                                            mudarParaUsuario(item["idUsuario"], context);
                                          }
                                        },

                                        onTap: () {
                                          mensagemParaUsuario(item["idUsuario"]);
                                        },
                                        
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    top: 10,
                                                    bottom: 10,
                                                    left: 2,
                                                    right: 4),
                                                decoration: BoxDecoration(
                                                    //border: Border.all(),
                                                    //color: Colors.green,
                                                    //image: DecorationImage(
                                                    //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                                    ),
                                                child: Column(
                                                  children: <Widget>[
                                                    CircleAvatar(
                                                        radius: 30,
                                                        backgroundColor:
                                                            Colors.white,
                                                        backgroundImage:
                                                            NetworkImage(item[
                                                                "urlImagem"]))
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 8,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    top: 4,
                                                    bottom: 4,
                                                    left: 4,
                                                    right: 4),
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      flex: 10,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            //border: Border.all(),
                                                            //color: Colors.green,
                                                            //image: DecorationImage(
                                                            //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                                            ),
                                                        child: Column(
                                                          children: <Widget>[
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  //border: Border.all(),
                                                                  //color: Colors.green,
                                                                  //image: DecorationImage(
                                                                  //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                                                  ),
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          3),
                                                              child: Column(
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                      item[
                                                                          "nome"],
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            fonteTitulo,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        //color: Color(0xff075E54)
                                                                      ))
                                                                ],
                                                              ),
                                                            ),
                                                            Column(
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                      //border: Border.all(),
                                                                      //color: Colors.green,
                                                                      //image: DecorationImage(
                                                                      //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                                                      ),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .only(
                                                                              top: 4),
                                                                  child: Row(
                                                                    children: <
                                                                        Widget>[
                                                                      Expanded(
                                                                        flex:
                                                                            10,
                                                                        child:
                                                                            Container(
                                                                          decoration: BoxDecoration(
                                                                              //border: Border.all(),
                                                                              //color: Colors.green,
                                                                              //image: DecorationImage(
                                                                              //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                                                              ),
                                                                          child:
                                                                              Column(
                                                                            children: <Widget>[
                                                                              Row(
                                                                                children: <Widget>[
                                                                                  Expanded(
                                                                                    flex: 10,
                                                                                    child: Text(
                                                                                      "Tipo de Usuário: " + item["infoAdicional"].toString()+
                                                                                      "\nTelefone: "+ item["telefone"].toString(),
                                                                                      textAlign: TextAlign.center,
                                                                                      style: TextStyle(fontSize: fonteDetalhe),
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .only(
                                                                              top: 0),
                                                                  child: Column(
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        "Cidade: " +
                                                                            item["cidade"],
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize: fonteTitulo),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          }
                        }
                        break;
                    }
                    return null;
                  }),
            ),
          );
        }),
        Positioned(
          bottom: 10,
          right: 10,
          child: FloatingActionButton(
            onPressed: () {
              _adicionarListenerUsuario();
            },
            backgroundColor: Color(0xff075E54),
            foregroundColor: Colors.red,
            mini: true,
            child: Icon(
              Icons.people,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          bottom: 55,
          right: 10,
          child: FloatingActionButton(
            onPressed: () {
              _adicionarListenerDistribuidor();
            },
            backgroundColor: Color(0xff075E54),
            foregroundColor: Colors.red,
            mini: true,
            child: Icon(
              Icons.shopping_cart,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void mensagemParaUsuario(String idUsuario) {
    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text("Enviar mensagem"),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Enviar mensagem para este usuário."),
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
            onPressed: () async {           
              Navigator.pop(context);
              Navigator.pushNamed(context, "/mensagens", arguments: await Util.getDadosUsuarioPeloId(idUsuario));
            },
          ),
        ],
      ),
    );
  }

  void mudarParaDistribuidor(String idUsuario) {
    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text("Habilitar visualizar preços?"),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Habilitar visualização"),
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
              _pesquisarProduto(idUsuario);
            },
          ),
        ],
      ),
    );
  }

  _pesquisarProduto(String idUsuario) {
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
                        "Qual porcentagem se aplica?",
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
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .words,
                                                        autofocus: true,
                                                        keyboardType:
                                                            TextInputType.number,
                                                        style: TextStyle(
                                                            fontSize: 20),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: "Ex: 10",
                                                          filled: true,
                                                          fillColor:
                                                              Colors.white,
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16)),
                                                          prefixIcon: Icon(Icons
                                                              .tune),
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
                                                "Confirmar",
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
                                                _buscarProduto(idUsuario);
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

  _buscarProduto(String idUsuario) {
    String nomeDoProduto = _controllerProduto.text;
    if (nomeDoProduto.isNotEmpty) {
      _estaCorretoProduto(nomeDoProduto, idUsuario);
      _controllerProduto.value =
          new TextEditingController.fromValue(new TextEditingValue(text: ""))
              .value;
    } else {
      Util.flutterNotification(
          context,
          FlushbarPosition.BOTTOM, // posição
          "${Util.primeiroNomeUsuarioLogado}", // Titulo
          "Informe uma porcentagem", // Texto
          Icon(Icons.info_outline,
              size: 25, color: Colors.green.shade300), // Icone
          Colors.black, // Cor de Fundo
          Colors.black, // Cor da barra lateral
          Duration(seconds: 3) // duraçao em segundos
          );
    }
  }

  _estaCorretoProduto(String texto, String idUsuario) {
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
                        "Esta correto a porcentagem?\n" +
                            texto +
                            "\% sobre a tabela base.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
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
              decoration: BoxDecoration(
                  //border: Border.all(color: Color(0xffB0C4DE)),
                  //color: Colors.green,
                  //image: DecorationImage(
                  //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                  ),
              child: Container(
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
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  //border: Border.all(),
                                                  //color: Color(
                                                  //    0xff075E54)
                                                  //image: DecorationImage(
                                                  //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.check,
                                                    size: 25,
                                                    color: Colors.black,
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      //border: Border.all(color: Color(0xffB0C4DE)),
                                      //color: Colors.green,
                                      //image: DecorationImage(
                                      //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                      ),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: new RaisedButton(
                                          color: Color(0xff075E54),
                                          child: Text(
                                            "Esta correto",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          onPressed: () async {
                                            db
                                                .collection("usuarios")
                                                .document(idUsuario)
                                                .updateData(
                                                    {"categoria": texto});

                                            db
                                                .collection("usuarios")
                                                .document(idUsuario)
                                                .updateData({
                                              "infoAdicional": "Comprador"
                                            });

                                            _adicionarListenerUsuario();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
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
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  //border: Border.all(),
                                                  //color: Color(
                                                  //    0xff075E54)
                                                  //image: DecorationImage(
                                                  //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.warning,
                                                    size: 25,
                                                    color: Colors.black,
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      //border: Border.all(color: Color(0xffB0C4DE)),
                                      //color: Colors.green,
                                      //image: DecorationImage(
                                      //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                      ),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: new RaisedButton(
                                          color: Color(0xff075E54),
                                          child: Text(
                                            "Esta errado",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            _pesquisarProduto(idUsuario);
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

void mudarParaUsuario(String idUsuario, BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => CupertinoAlertDialog(
      title: Text("Desabilitar visualizar preços?"),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Desabilitar visualização"),
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
            Firestore db = Firestore.instance;
            db
                .collection("usuarios")
                .document(idUsuario)
                .updateData({"categoria": "100.0"});

            db
                .collection("usuarios")
                .document(idUsuario)
                .updateData({"infoAdicional": "Usuário"});

            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

_Novaquantidade(TextEditingController _controllerProduto, BuildContext context) {
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
                      "Qual a quantidade",
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
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 10,
                                        child: Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Container(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    child: new TextField(
                                                      controller:
                                                          _controllerProduto,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                      autofocus: true,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: "Quantidade",
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16)),
                                                        prefixIcon: Icon(
                                                            Icons.unfold_more),
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
                                        right: 8, left: 8, bottom: 8, top: 16),
                                    child: Container(
                                        width: double.infinity,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            //border: Border.all()
                                            ),
                                        child: RaisedButton(
                                            child: Text(
                                              "Confirmar",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                            color: Color(0xff075E54),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(32)),
                                            onPressed: () async {
                                              if (_controllerProduto
                                                  .text.isNotEmpty) {
                                                Navigator.of(context).pop();
                                              } else {
                                                Navigator.of(context).pop();
                                                _controllerProduto.value =
                                                    new TextEditingController
                                                                .fromValue(
                                                            new TextEditingValue(
                                                                text: ""))
                                                        .value;

                                                Util.notification(
                                                    context, // posição
                                                    "Ops!!!", // Titulo
                                                    "Quantidade inválida.", // Texto
                                                    Icon(Icons.info_outline,
                                                        size: 25,
                                                        color: Colors.green
                                                            .shade300), // Icone
                                                    Colors
                                                        .black, // Cor de Fundo
                                                    Colors
                                                        .black, // Cor da barra lateral
                                                    Duration(
                                                        seconds:
                                                            3) // duraçao em segundos
                                                    );
                                              }
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
