import 'dart:async';
import 'dart:math';

import 'package:revtec/Informacoes/Textos.dart';
import 'package:revtec/util/Util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:toast/toast.dart';

class Institucional extends StatefulWidget {
  @override
  _InstitucionalState createState() => _InstitucionalState();
}

class _InstitucionalState extends State<Institucional> {
  Firestore db = Firestore.instance;
  TextEditingController _controllerProduto = TextEditingController();
  List<DocumentSnapshot> _requisicoes;
  String _nomeProduto;
  static double _fonteMais=0;
  static double _fonteMenos;
  String code;

  final _controller = StreamController<QuerySnapshot>.broadcast();

  Stream<QuerySnapshot> _listnerInstitucional() {
    Firestore db = Firestore.instance;
    final stream = db
        .collection("produtos")
        .where("linha", isEqualTo: "Linha Institucional")
        //.orderBy("nome")
        .snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }



  Stream<QuerySnapshot> _listnerPesquisa(String pesquisa) {
    Firestore db = Firestore.instance;
    final stream = db
        .collection("produtos")
        .where("linha", isEqualTo: "Linha Institucional")
        .where("nomeFiltro", isEqualTo: pesquisa)
        //.orderBy("nome")
        .snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  _montarLista(List list, [int start = 0, int end]) {
    if (end == null) end = list.length;
    return list;
  }

  @override
  void initState() {
    _listnerInstitucional();
    super.initState();
  }

  var mensagemNaoTemDados = Center(
    child: Text(
      "Nenhum produto encontrado.\n\nRealize a pesquisa novamente\nou pesquise em branco para todos.",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("imagens/fundo.png"), fit: BoxFit.cover)),
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
                                            "Carregando Produtos",
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
                        _requisicoes =
                            _montarLista(querySnapshot.documents.toList());
                        AssetImage _imagem =
                            AssetImage("imagens/fundotopoproduto.png");
                        if (querySnapshot.documents.length == 0) {
                          return mensagemNaoTemDados;
                        } else {
                          return Stack(
                            children: <Widget>[
                              LayoutBuilder(builder: (context, constraint) {
                                double fontSizeMaior = Textos.size(
                                  constraint.maxWidth * 0.07,
                                  min: 8,
                                  max: 16,
                                );
                                double fontSizeMenor = Textos.size(
                                  constraint.maxWidth * 0.07,
                                  min: 8,
                                  max: 14,
                                );

                                _fonteMais = fontSizeMaior;
                                _fonteMenos = fontSizeMenor;

                                return Padding(
                                  padding: EdgeInsets.only(top: 8, bottom: 8),
                                  child: ListView.separated(
                                      itemCount: querySnapshot.documents.length,
                                      separatorBuilder: (context, indice) =>
                                          Divider(
                                            height: 2,
                                            //color: Colors.grey,
                                          ),
                                      itemBuilder: (context, indice) {
                                        List<DocumentSnapshot> requisicoes =
                                            _requisicoes;
                                        DocumentSnapshot item =
                                            requisicoes[indice];
                                        return Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(8, 4, 8, 2),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                image: DecorationImage(
                                                    image: _imagem,
                                                    fit: BoxFit.fill),
                                                color: Colors.white30),
                                            padding: EdgeInsets.only(
                                                left: 6,
                                                right: 6,
                                                top: 2,
                                                bottom: 2),
                                            width: double.infinity,
                                            child: GestureDetector(
                                              onTap: () {
                                              Textos.souARevtec ?
                                              Navigator.pushNamed(context, "/detalhe", arguments: item["idProduto"]) :
                                              Navigator.pushNamed(context, "/detalheSemBotao", arguments: item["idProduto"]);
                                            },
                                              child: Container(
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      flex: 2,
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 4,
                                                                bottom: 4,
                                                                left: 4,
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
                                                                radius: 27,
                                                                backgroundColor:
                                                                    Colors.grey,
                                                                backgroundImage:
                                                                    NetworkImage(
                                                                        item[
                                                                            "urlImagem"]))
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 8,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Row(children: [
                                                            Expanded(
                                                              flex: 8,
                                                              child: Container(
                                                            decoration: BoxDecoration(
                                                                //border: Border.all(),
                                                                //color: Colors.green,
                                                                //image: DecorationImage(
                                                                //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                                                ),
                                                            child: Text(
                                                                item["nome"],
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      fontSizeMaior,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  //color: Color(0xff075E54)
                                                                )),
                                                          ),
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                item["idProduto"].toString().replaceAll("p", "ID: "),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      fontSizeMaior,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  //color: Color(0xff075E54)
                                                                )),
                                                            )
                                                          ],),
                                                          Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 4,
                                                                    bottom: 4),
                                                            decoration: BoxDecoration(
                                                                //border: Border.all(),
                                                                //color: Colors.green,
                                                                //image: DecorationImage(
                                                                //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                                                ),
                                                            child: Text(
                                                                item[
                                                                    "caracteristica"],
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      fontSizeMenor,
                                                                  //fontWeight: FontWeight.bold,
                                                                  //color: Color(0xff075E54)
                                                                )),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                );
                              }),
                            ],
                          );
                        }
                      }
                      break;
                  }
                  return null;
                }),
          ),
          Positioned(
            bottom: 5,
            right: 10,
            child: FloatingActionButton(
              onPressed: () async {
                _pesquisarProduto();
              },
              backgroundColor: Color(0xff075E54),
              foregroundColor: Colors.red,
              mini: true,
              child: Icon(
                Icons.search,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _pesquisarProduto() {
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
                        "Nome do produto",
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
                                                            TextInputType.text,
                                                        style: TextStyle(
                                                            fontSize: 20),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              "Ex: Matrix Free",
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

                                                if (_controllerProduto
                                                    .text.isNotEmpty) {
                                                  _buscarProduto();
                                                } else {
                                                  _listnerInstitucional();
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

  _buscarProduto() {
    String nomeDoProduto = _controllerProduto.text;
    if (nomeDoProduto.isNotEmpty) {
      setState(() {
        _nomeProduto = nomeDoProduto.toLowerCase();
      });
      _estaCorretoProduto(nomeDoProduto);
      _controllerProduto.value =
          new TextEditingController.fromValue(new TextEditingValue(text: ""))
              .value;
    } else {
      Util.flutterNotification(
          context,
          FlushbarPosition.BOTTOM, // posição
          "${Util.primeiroNomeUsuarioLogado}", // Titulo
          "Informe um produto", // Texto
          Icon(Icons.info_outline,
              size: 25, color: Colors.green.shade300), // Icone
          Colors.black, // Cor de Fundo
          Colors.black, // Cor da barra lateral
          Duration(seconds: 3) // duraçao em segundos
          );
    }
  }

  _estaCorretoProduto(String texto) {
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
                        "Esta correto o produto?\n${texto}",
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
                                            Navigator.of(context).pop();
                                            _listnerPesquisa(_nomeProduto                                                
                                                .toLowerCase());
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
                                            _pesquisarProduto();
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
