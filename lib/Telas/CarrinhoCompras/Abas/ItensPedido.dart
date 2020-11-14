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

class ItensPedido extends StatefulWidget {
  String idPedido;
  ItensPedido(this.idPedido);

  @override
  _ItensPedidoState createState() => _ItensPedidoState();
}

class _ItensPedidoState extends State<ItensPedido> {
  String _idUsuarioLogado;
  String _precoRecuperado;
  int _qtdadePorCaixa = 0;
  double _litragem = 0;
  String _apresentacao = "";
  String _volume = "";
  String _litragemExibir = "0";
  String _urlImagem = "";
  String _urlPdfBoletim = "";
  String _idProduto = "";
  String _urlImagemZoom = "";
  String _valorUnitario = "";
  String _indicacoes = "";
  String _modoDeUsar = "";
  String _nomeProduto = "";
  String _caracteristicaProduto = "";
  String _linhaProduto = "";
  String _selectedLocation;
  String _quantidadeDeItensDoPedido;
  String _quantidadeDeCaixasDoPedido;
  String _idUsuarioClicado;
  String _emailUsuarioLogado;
  String _quantidade = "0";
  String _precoDaEntrega = "0";
  int _quantidadeDeVolume = 0;
  int quantidade = 0;
  TextEditingController _controllerProduto = TextEditingController();
  double _preco = 0;
  double _valorEntrega = 0;
  Firestore db = Firestore.instance;
  TextEditingController _textFieldQtdade = TextEditingController();

  final _controller = StreamController<QuerySnapshot>.broadcast();

  Stream<QuerySnapshot> _adicionarListenerProdutos() {
    Firestore db = Firestore.instance;
    final stream = db
        .collection("pedidos")
        .document(widget.idPedido)
        .collection("itens")
        .snapshots();
    stream.listen((dados) {
      _controller.add(dados);
      _calcularVolume();
      _calcularCarrinho();
    });
  }

  _calcularCarrinho() async {
    double valor = 0;
    int quantidade = 0;
    double resultado = 0;

    QuerySnapshot querySnapshot = await db
        .collection("pedidos")
        .document(widget.idPedido)
        .collection("itens")
        .getDocuments();

    for (DocumentSnapshot item in querySnapshot.documents) {
      valor =
          double.parse(Util.prepararValoresParaCalculo(item["preco"], context));
      quantidade = int.parse(item["quantidade"].toString());
      resultado = (valor * quantidade) + resultado;
    }

    setState(() {
      _preco = resultado;
    });
  }

  _calcularVolume() async {
    int valor = 0;
    int quantidade = 0;
    int resultado = 0;

    QuerySnapshot querySnapshot = await db
        .collection("pedidos")
        .document(widget.idPedido)
        .collection("itens")
        .getDocuments();

    for (DocumentSnapshot item in querySnapshot.documents) {
      quantidade = int.parse(item["quantidadeCaixas"]);
      resultado = (valor + quantidade) + resultado;
    }

    setState(() {
      _quantidadeDeVolume = resultado;
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
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();

    setState(() {
      _precoDaEntrega =
          Util.prepararValoresParaExibir(Util.valorDaEntrega.toString());
      _valorEntrega = Util.valorDaEntrega;
      _idUsuarioLogado = usuarioLogado.uid;
      //til.mensagem = Util.listnerMensagens(_idUsuarioLogado, context);
      // _idUsuarioClicado = widget.usuario.idUsuario;
    });
    _emailUsuarioLogado = usuarioLogado.email;
    _adicionarListenerProdutos();
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
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
      Textos.nomeUsuarioLogado + "\n\nSeu carrinho está vazio.",
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
                                                  _novaQuantidade(
                                                      idUsuario,
                                                      idLoja,
                                                      idPedido,
                                                      idProduto,
                                                      _controllerProduto.text);
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
                title: Text("Detalhes do pedido"),
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
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                  separatorBuilder: (context, indice) =>
                                      Divider(
                                        height: 2,
                                        color: Colors.grey,
                                      ),
                                  itemBuilder: (context, indice) {
                                    List<DocumentSnapshot> requisicoes =
                                        querySnapshot.documents.toList();
                                    DocumentSnapshot item = requisicoes[indice];

                                    AssetImage _imagem = AssetImage(
                                        "imagens/novofundotopoproduto.png");

                                        if(item["litragem"].toString() == "0.5"){
                                            _litragemExibir = "500 Ml";
                                        } else if(item["litragem"].toString() == "1.0"){
                                            _litragemExibir = "1 Litro";
                                        } else if(item["litragem"].toString() == "2.0"){
                                            _litragemExibir = "2 Litros";
                                        } else if(item["litragem"].toString() == "5.0"){
                                            _litragemExibir = "5 Litros";
                                        } else if(item["litragem"].toString() == "20.0"){
                                            _litragemExibir = "20 Litros";
                                        } else if(item["litragem"].toString() == "50.0"){
                                            _litragemExibir = "50 Litros";
                                        } else if(item["litragem"].toString() == "200.0"){
                                            _litragemExibir = "200 Litros";
                                        } else if(item["litragem"].toString() == "1000.0"){
                                            _litragemExibir = "1000 Litros";
                                        }

                                        if(int.parse(item["quantidadeCaixas"]) > 1){
                                          if (int.parse(item["quantidadeCaixas"]) > 1 && item["litragem"] > 0 && item["litragem"] <= 5 ) {
                                          _volume = "caixas";
                                        } else if (int.parse(item["quantidadeCaixas"]) > 1 && item["litragem"] >= 20 && item["litragem"] <= 50 ) {
                                          _volume = "bombonas";
                                        } else {
                                            _volume = "containners";
                                          }
                                        }else {
                                          if(item["litragem"] > 0 && item["litragem"] <= 5){
                                            _volume = "caixa";
                                          } else if(item["litragem"] >= 20 && item["litragem"] <= 50){
                                            _volume = "bombona";
                                          } else {
                                            _volume = "containner";
                                          }
                                        }


                                    return Container(
                                      padding: EdgeInsets.only(
                                          left: 4, right: 4, top: 2, bottom: 2),
                                      width: double.infinity,
                                      child: Container(
                                        padding: EdgeInsets.only(left: 8),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Color(0xffB0C4DE)),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            image: DecorationImage(
                                                image: _imagem,
                                                fit: BoxFit.fill)
                                            //color: Colors.green,
                                            //image: DecorationImage(
                                            //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                            ),
                                        child: GestureDetector(
                                          onTap: (){
                                            Navigator.pushNamed(context, "/detalhe", arguments: item["idProduto"]);
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
                                                                          "nome"].toString().toUpperCase()+"\n"+_litragemExibir+" - Volume: "+item["quantidadeCaixas"]+" "+_volume,
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
                                                                        flex: 2,
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
                                                                                      "Qtd: " + item["quantidade"].toString(),
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
                                                                      Expanded(
                                                                        flex: 4,
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
                                                                                      "Un: " + item["preco"].toString(),
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
                                                                      Expanded(
                                                                        flex: 4,
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
                                                                                      "Total: " + Util.formatarValoresParaExibicao(double.parse((Util.formatarParaCalcular(item["preco"].toString().replaceAll("R\$ ", "")) * int.parse(item["quantidade"].toString())).toString())),
                                                                                      textAlign: TextAlign.center,
                                                                                      style: TextStyle(fontSize: fonteDetalhe),
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
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
              bottomNavigationBar: Row(
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 6, 4),
                      child: Text(
                        "Valor do pedido: " +
                            Util.prepararValoresParaExibir(_preco.toString()) +
                            "\nQuantidade total de caixas: " +
                            _quantidadeDeVolume.toString(),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  )
                ],
              ));
        })
      ],
    );
  }

  _Novaquantidade() {
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
                                                              .unfold_more),
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
                                                  _calcularQuantidade(int.parse(
                                                      _controllerProduto.text));
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

  _calcularQuantidade(int quantidade) {
    String item;
    String caixas;

    int restoDivisao = int.parse(_controllerProduto.text) % _qtdadePorCaixa;

    String qtdadeDeCaixa =
        ((int.parse(_controllerProduto.text) / _qtdadePorCaixa))
            .toString()
            .substring(
                0,
                ((int.parse(_controllerProduto.text) / _qtdadePorCaixa))
                    .toString()
                    .indexOf("."));

    if (restoDivisao != 0) {
      setState(() {
        _quantidadeDeCaixasDoPedido = "1";
        qtdadeDeCaixa = (int.parse(qtdadeDeCaixa.toString()) + 1).toString();
      });

      int quantidadeQueFalta =
          _qtdadePorCaixa - (_qtdadePorCaixa - restoDivisao);

      if ((_qtdadePorCaixa - quantidadeQueFalta) > 1) {
        item = "itens";
      } else {
        item = "item";
      }

      if (int.parse(qtdadeDeCaixa) > 1) {
        caixas = "caixas";
      } else {
        caixas = "caixa";
      }

      setState(() {
        _quantidadeDeItensDoPedido =
            (int.parse((_qtdadePorCaixa - quantidadeQueFalta).toString()) +
                    int.parse(_controllerProduto.text))
                .toString();
      });

      completarCarrinho(
          item,
          caixas,
          quantidade.toString(),
          _qtdadePorCaixa.toString(),
          (_qtdadePorCaixa - quantidadeQueFalta).toString(),
          qtdadeDeCaixa);
    } else {
      setState(() {
        _quantidadeDeItensDoPedido = _controllerProduto.text;
        _quantidadeDeCaixasDoPedido = qtdadeDeCaixa;
      });
      _comprar();
    }
  }

  _transformarLitragem(String litragem) {
    if (litragem == "0.5") {
      setState(() {
        _selectedLocation = "500 Ml";
        _qtdadePorCaixa = 12;
      });
    } else if (litragem == "1.0") {
      setState(() {
        _selectedLocation = "1 Litro";
        _qtdadePorCaixa = 12;
      });
    } else if (litragem == "2.0") {
      setState(() {
        _selectedLocation = "2 Litros";
        _qtdadePorCaixa = 6;
      });
    } else if (litragem == "5.0") {
      setState(() {
        _selectedLocation = "5 Litros";
        _qtdadePorCaixa = 4;
      });
    } else if (litragem == "20.0") {
      setState(() {
        _selectedLocation = "20 Litros";
        _qtdadePorCaixa = 1;
      });
    } else if (litragem == "50.0") {
      setState(() {
        _selectedLocation = "50 Litros";
        _qtdadePorCaixa = 1;
      });
    } else if (litragem == "200.0") {
      setState(() {
        _selectedLocation = "200 Litros";
        _qtdadePorCaixa = 1;
      });
    } else if (litragem == "1000.0") {
      setState(() {
        _selectedLocation = "1000 Litros";
        _qtdadePorCaixa = 1;
      });
    }
  }

  _comprar() async {
    if (_selectedLocation == "0,500 Ml") {
      setState(() {
        _litragem = 0.500;
        _qtdadePorCaixa = 12;
      });
    } else {
      if (_selectedLocation == "1 Litro") {
        setState(() {
          _litragem = 1;
          _qtdadePorCaixa = 12;
        });
      } else {
        if (_selectedLocation == "2 Litros") {
          setState(() {
            _litragem = 2;
            _qtdadePorCaixa = 6;
          });
        } else {
          if (_selectedLocation == "5 Litros") {
            setState(() {
              _litragem = 5;
              _qtdadePorCaixa = 4;
            });
          } else {
            if (_selectedLocation == "20 Litros") {
              setState(() {
                _litragem = 20;
                _qtdadePorCaixa = 1;
              });
            } else {
              if (_selectedLocation == "50 Litros") {
                setState(() {
                  _litragem = 50;
                  _qtdadePorCaixa = 1;
                });
              } else {
                if (_selectedLocation == "200 Litros") {
                  setState(() {
                    _litragem = 200;
                    _qtdadePorCaixa = 1;
                  });
                } else {
                  if (_selectedLocation == "1000 Litros") {
                    setState(() {
                      _litragem = 1000;
                      _qtdadePorCaixa = 1;
                    });
                  } else {
                    Util.notification(
                        context, // posição
                        "Ops!!!", // Titulo
                        "Litragem inválida.", // Texto
                        Icon(Icons.info_outline,
                            size: 25, color: Colors.green.shade300), // Icone
                        Colors.black, // Cor de Fundo
                        Colors.black, // Cor da barra lateral
                        Duration(seconds: 3) // duraçao em segundos
                        );
                  }
                }
              }
            }
          }
        }
      }
    }

    Util.notification(
        context, // posição
        "Por favor aguarde.", // Titulo
        "Estamos alterando a quantidade.", // Texto
        Icon(Icons.info_outline,
            size: 25, color: Colors.green.shade300), // Icone
        Colors.black, // Cor de Fundo
        Colors.black, // Cor da barra lateral
        Duration(seconds: 3) // duraçao em segundos
        );

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshotPedidoEmAberto =
        await db.collection("pedidos").document(Textos.idUsuarioLogado).get();
    Map<String, dynamic> verifica = snapshotPedidoEmAberto.data;

    String idDoPedido;

    try {
      if (verifica["idPedidoEmAberto"] == "nao") {
        idDoPedido = Util.gerarIdUnico();
      } else {
        idDoPedido = verifica["idPedidoEmAberto"];
      }
    } catch (e) {
      idDoPedido = Util.gerarIdUnico();
    }

    PedidoId pedido = new PedidoId();
    pedido.idPedido = idDoPedido;
    pedido.dataPedido = Util.capturarDataAtual();
    pedido.status = "Aberto";
    pedido.idLoja = Util.idDaRevtec;
    pedido.idComprador = Textos.idUsuarioLogado;
    pedido.urlImagem = Textos.urlUsuario;
    pedido.nomeComprador = Textos.nomeUsuarioLogado;

    PedidosProdutos produto = new PedidosProdutos();
    produto.apresentacao = _apresentacao;
    produto.caracteristica = _caracteristicaProduto;
    produto.idProduto = _idProduto;
    produto.indicacoes = _indicacoes;
    produto.linha = _linhaProduto;
    produto.modoDeUsar = _modoDeUsar;
    produto.nome = _nomeProduto;
    produto.urlBoletim = Util.linkDoPdf;
    produto.urlImagem = _urlImagem;
    produto.urlZoom = _urlImagemZoom;
    produto.litragem = _litragem;
    produto.preco = _precoRecuperado;
    produto.quantidadeCaixas = _quantidadeDeCaixasDoPedido;
    produto.quantidade = int.parse(_quantidadeDeItensDoPedido);

    await db // Grava o número do pedido em aberto
        .collection("pedidos")
        .document(pedido.idComprador)
        .setData({"idPedidoEmAberto": pedido.idPedido});

    await db // Grava o pedido para a empresa
        .collection("pedidos")
        .document(pedido.idPedido)
        .setData(pedido.toMap());

    await db // Grava os itens do pedido
        .collection("pedidos")
        .document(pedido.idPedido)
        .collection("itens")
        .document(_idProduto)
        .setData(produto.toMap());

    Util.notification(
        context, // posição
        Textos.nomeUsuarioLogado, // Titulo
        "Alteramos o item " + _nomeProduto + ".", // Texto
        Icon(Icons.info_outline,
            size: 25, color: Colors.green.shade300), // Icone
        Colors.black, // Cor de Fundo
        Colors.black, // Cor da barra lateral
        Duration(seconds: 3) // duraçao em segundos
        );

    _controllerProduto.value =
        new TextEditingController.fromValue(new TextEditingValue(text: ""))
            .value;
  }

  void completarCarrinho(String item, String caixas, String qtdadePedida,
      String qtdPorCaixa, String quantidadeParaCompletar, String numCaixas) {
    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text("Você pediu " + qtdadePedida.toString() + " itens."),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("A caixa vem com " +
              qtdPorCaixa +
              " unidades, \npodemos incluir mais " +
              quantidadeParaCompletar +
              " " +
              item +
              " e \ncompletar um total de " +
              numCaixas +
              " " +
              caixas +
              "?"),
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
              setState(() {
                _quantidadeDeCaixasDoPedido = numCaixas;
              });
              Navigator.pop(context);
              _comprar();
            },
          ),
        ],
      ),
    );
  }

  _novaQuantidade(String idUsuario, String idLoja, String idPedido,
      String idProduto, String quantidade) {
    db
        .collection("pedidos")
        .document(idUsuario)
        .collection(idLoja)
        .document(idPedido)
        .collection("itens")
        .document(idProduto)
        .updateData({"prodQuantidade": quantidade}).then((_) {
      db
          .collection("pedidos")
          .document(idLoja)
          .collection(idUsuario)
          .document(idPedido)
          .collection("itens")
          .document(idProduto)
          .updateData({"prodQuantidade": quantidade});
    });
    _controllerProduto.value =
        new TextEditingController.fromValue(new TextEditingValue(text: ""))
            .value;
    Toast.show("Quantidade alterada", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
  }
}
