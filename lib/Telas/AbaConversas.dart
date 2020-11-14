import 'dart:async';
import 'package:revtec/Informacoes/Textos.dart';
import 'package:revtec/model/Conversa.dart';
import 'package:revtec/util/Util.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AbaConversas extends StatefulWidget {
  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {
  List<Conversa> _listaConversas = List();
  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore db = Firestore.instance;
  String _idUsuarioLogado;
  String _notificacao = "";
  Color _cor;
  String _mensagem="";
  String _nomeProduto;
  FontWeight _font;
  Icon _icone;
  TextEditingController _controllerProduto = TextEditingController();

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
    Conversa conversa = Conversa();
    _listaConversas.add(conversa);
  }

  var mensagemNaoTemDados = Center(
    child: Text(
      "Nenhuma mensagem recebida",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  Stream<QuerySnapshot> _adicionarListenerConversas() {
    Firestore db = Firestore.instance;
    final stream = db
        .collection("conversas")
        .document(_idUsuarioLogado)
        .collection("ultima_conversa")
        .orderBy("ordem")
        .snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = Textos.idDaRevtec;
    //Util.mensagem = Util.listnerMensagens(_idUsuarioLogado, context);
    _adicionarListenerConversas();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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


                        return LayoutBuilder(builder: (context, constraint){
                          double fontSizeNome = Textos.size(constraint.maxWidth * 0.07, min: 8, max: 16,);
                          double fontSizeMensagem = Textos.size(constraint.maxWidth * 0.07, min: 8, max: 14,);
                          double fontSizeLida = Textos.size(constraint.maxWidth * 0.07, min: 8, max: 14,);
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

                                if(item["mensagem"].toString().length>30){
                                  _mensagem = item["mensagem"].toString().substring(0,30)+"...";
                                }else {
                                  _mensagem = item["mensagem"].toString();
                                }

                                if (item["ordem"] == 0) {
                                  _notificacao = "Você tem nova msgm";
                                  _font = FontWeight.bold;
                                  _cor = Color(0xff075E54);
                                  _icone = Icon(Icons.add_circle_outline, size: 20, color: _cor);
                                } else if (item["ordem"] == 1) {
                                  _notificacao = "Sua msgm foi enviada";
                                  _font = FontWeight.bold;
                                  _cor = Color(0xff075E54);
                                  _icone = Icon(Icons.eject, size: 20, color: _cor);
                                } else if (item["ordem"] == 2) {
                                  _notificacao = "Sua mensagem foi lida";
                                  _font = FontWeight.bold;
                                  _cor = Color(0xff075E54);
                                  _icone = Icon(Icons.check, size: 20, color: _cor);
                                }

                                return Stack(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(8, 4, 8, 2),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Color(0xff075E54)),
                                            borderRadius: BorderRadius.circular(15),
                                            color: Colors.white30),
                                        padding: EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                                        width: double.infinity,
                                        child: GestureDetector(

                                          onTap: () async {
                                            Util.idUsuarioClicado = item["idDestinatario"];
                                            Util.idUsuarioLogado = Textos.idDaRevtec;
                                            Util.ordem = item["ordem"];
                                            Navigator.pushNamed(context, "/mensagens", arguments: await Util.getDadosUsuarioPeloId(item["idDestinatario"]));
                                          },
                                          child: Container(
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    child: Column(
                                                      children: <Widget>[
                                                        CircleAvatar(
                                                            radius: fontSizeNome+12,
                                                            backgroundColor: Colors.grey,
                                                            backgroundImage: NetworkImage(item["caminhoFoto"])
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 8,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Padding(
                                                          padding: EdgeInsets.only(top: 6),
                                                          child: Text(item["nome"],
                                                              style: TextStyle(
                                                                fontSize: fontSizeNome,
                                                                fontWeight:
                                                                FontWeight.bold,
                                                              )),
                                                        ),
                                                      ),
                                                      Container(
                                                          padding:
                                                          EdgeInsets.only(
                                                              top: 4,
                                                              bottom: 4),
                                                          child: Padding(
                                                            padding:
                                                            EdgeInsets.only(
                                                                top: 0),
                                                            child: Text(
                                                                _mensagem,
                                                                style: TextStyle(
                                                                  fontSize: fontSizeMensagem,
                                                                )),
                                                          )),
                                                      Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            flex: 10,
                                                            child: Row(
                                                              children: <Widget>[
                                                                Expanded(
                                                                  flex: 9,
                                                                  child: Padding(
                                                                    padding: EdgeInsets.only(right: 4),
                                                                    child: Text(_notificacao,
                                                                        textAlign: TextAlign.end,
                                                                        style: TextStyle(
                                                                          fontWeight: _font,
                                                                          color: _cor,
                                                                          fontSize: fontSizeLida,
                                                                          //fontWeight: FontWeight.bold,
                                                                          //color: Color(0xff075E54)
                                                                        )),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child: _icone,
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                                return null;
                              });
                        });
                      }
                    }
                    break;
                }
                return null;
              }),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: FloatingActionButton(
            onPressed: () async {
              _pesquisarItem();
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
        )
      ],
    );
  }

  _pesquisarItem(){
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
                        "Selecione a opção desejada?",
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
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(Icons.search, size: 25, color: Colors.black,)
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
                                        width: MediaQuery.of(context).size.width,
                                        child: new RaisedButton(
                                          color: Color(0xff075E54),
                                          child: Text(
                                            "Pesquisar Conversa",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                            ),
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
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(Icons.list, size: 25, color: Colors.black,)
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
                                        width: MediaQuery.of(context).size.width,
                                        child: new RaisedButton(
                                          color: Color(0xff075E54),
                                          child: Text(
                                            "Exibir todos",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                            ),
                                          ),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            _adicionarListenerConversas();
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
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

  _pesquisarProduto(){
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
                        "1º nome do usuário",
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
                                                      //width: MediaQuery.of(context).size.width,
                                                      child: new TextField(
                                                        controller: _controllerProduto,
                                                        textCapitalization: TextCapitalization.words,
                                                        autofocus: true,
                                                        keyboardType: TextInputType.text,
                                                        style: TextStyle(fontSize: 20),
                                                        decoration: InputDecoration(
                                                          hintText: "Ex: Pedro",
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(16)),
                                                          prefixIcon: Icon(Icons.location_city),
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
                                      padding: EdgeInsets.only(right: 8, left: 8, bottom: 8, top: 16),
                                      child: Container(
                                          width: double.infinity,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            //border: Border.all()
                                          ),
                                          child: RaisedButton(
                                              child: Text("Pesquisar",style: TextStyle(color: Colors.white, fontSize: 20),
                                              ),
                                              color: Color(0xff075E54),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                _buscarProduto();

                                              })
                                      ),
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

  _buscarProduto(){
    String nomeDoProduto = _controllerProduto.text+" ";
    if (nomeDoProduto.isNotEmpty) {
      setState(() {
        _nomeProduto = nomeDoProduto.substring(0, nomeDoProduto.indexOf(" ")).toLowerCase();
      });
      _estaCorretoProduto(nomeDoProduto);
      _controllerProduto.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;
    }else {

      Util.flutterNotification(context,
          FlushbarPosition.BOTTOM, // posição
          "${Util.primeiroNomeUsuarioLogado}", // Titulo
          "Informe um contato", // Texto
          Icon(Icons.info_outline, size: 25, color: Colors.green.shade300), // Icone
          Colors.black, // Cor de Fundo
          Colors.black, // Cor da barra lateral
          Duration(seconds: 3) // duraçao em segundos
      );

    }
  }

  _estaCorretoProduto(String texto){
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
                        "O 1º nome esta correto?\n${texto}",textAlign: TextAlign.center,
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
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(Icons.check, size: 25, color: Colors.black,)
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
                                        width: MediaQuery.of(context).size.width,
                                        child: new RaisedButton(
                                          color: Color(0xff075E54),
                                          child: Text(
                                            "Esta correto",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                            ),
                                          ),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            _adicionarListenerProdutosNome(_nomeProduto);
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
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(Icons.warning, size: 25, color: Colors.black,)
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
                                        width: MediaQuery.of(context).size.width,
                                        child: new RaisedButton(
                                          color: Color(0xff075E54),
                                          child: Text(
                                            "Esta errado",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                            ),
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

  Stream<QuerySnapshot> _adicionarListenerProdutosNome(String nomeProduto) {
    Firestore db = Firestore.instance;
    final stream = db
        .collection("conversas")
        .document(_idUsuarioLogado)
        .collection("ultima_conversa")
        .where("nomeFiltro", isEqualTo: nomeProduto)
        .orderBy("ordem")
        .snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }

}
