import 'dart:async';
import 'dart:ffi';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:revtec/Informacoes/Textos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:revtec/util/Util.dart';
import 'package:toast/toast.dart';

class CalcularDiluicao extends StatefulWidget {
  @override
  _CalcularDiluicaoState createState() => _CalcularDiluicaoState();
}

class _CalcularDiluicaoState extends State<CalcularDiluicao> {
  List<DocumentSnapshot> _requisicoes;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  TextEditingController _litros = TextEditingController();
  TextEditingController _um = TextEditingController();
  TextEditingController _para = TextEditingController();
  String _textoBotao = "CLIQUE PARA CALCULAR";
  String _textoResultado = "Insira as informações para calcular";
  FocusNode myFocusNode;

  @override
  void initState() {
    _listnerInstitucional();
    Textos.recurerarToken(context);
    myFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _listnerInstitucional() {
    Firestore db = Firestore.instance;
    final stream = db.collection("PaginaSobreEmpresa").snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(Textos.urlFundo), fit: BoxFit.cover)),
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
                                            "Carregando Informações",
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
                        return Stack(
                          children: <Widget>[
                            LayoutBuilder(builder: (context, constraint) {
                              double textoTitulo = Textos.size(
                                constraint.maxWidth * 0.07,
                                min: 8,
                                max: 18,
                              );
                              double corpoMensagem = Textos.size(
                                constraint.maxWidth * 0.07,
                                min: 8,
                                max: 16,
                              );

                              return ListView.separated(
                                  itemCount: querySnapshot.documents.length,
                                  separatorBuilder: (context, indice) =>
                                      Divider(
                                        height: 2,
                                        color: Colors.grey,
                                      ),
                                  itemBuilder: (context, indice) {
                                    List<DocumentSnapshot> requisicoes =
                                        _requisicoes;

                                    DocumentSnapshot item = requisicoes[indice];

                                    return Padding(
                                      padding: EdgeInsets.fromLTRB(8, 4, 8, 2),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            // border: Border.all(color: Colors.white),
                                            // borderRadius:BorderRadius.circular(15),
                                            // color: Colors.white70
                                            //color: Colors.green,
                                            //image: DecorationImage(
                                            //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                            ),
                                        padding: EdgeInsets.only(
                                            left: 6,
                                            right: 6,
                                            top: 2,
                                            bottom: 2),
                                        width: double.infinity,
                                        child: GestureDetector(
                                          onLongPress: () async {},
                                          onTap: () async {},
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                top: 4, bottom: 4),
                                            decoration: BoxDecoration(
                                                //border: Border.all(),
                                                //color: Colors.green,
                                                //image: DecorationImage(
                                                //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                                ),
                                            child: Column(
                                              children: <Widget>[
                                                Text(Textos.tituloDiluicao,
                                                    textAlign:
                                                        TextAlign.justify,
                                                    style: TextStyle(
                                                      fontSize: textoTitulo,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      //color: Color(0xff075E54)
                                                    )),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 8),
                                                  child: Text(Textos.comodiluir,
                                                      textAlign:
                                                          TextAlign.justify,
                                                      style: TextStyle(
                                                        fontSize: corpoMensagem,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        //color: Color(0xff075E54)
                                                      )),
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 12),
                                                  child: Center(
                                                    child: Text(
                                                        "Quantos litros deseja fazer?",
                                                        textAlign:
                                                            TextAlign.justify,
                                                        style: TextStyle(
                                                          fontSize:
                                                              corpoMensagem,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          //color: Color(0xff075E54)
                                                        )),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 8),
                                                  child: Center(
                                                    child: Container(
                                                      width: 150,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        border: Border.all(),
                                                        color: Colors.white,
                                                        //image: DecorationImage(
                                                        //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                                      ),
                                                      child: TextField(
                                                        controller: _litros,
                                                        autofocus: true,
                                                        focusNode: myFocusNode,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color: Color(
                                                                0xff075E54)),
                                                        decoration: InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            hintText: "Ex 10",
                                                            fillColor: Color(
                                                                0xff075E54),
                                                            prefixIcon: Icon(
                                                                Icons
                                                                    .format_color_fill,
                                                                color: Color(
                                                                    0xff075E54))),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 12, bottom: 8),
                                                  child: Center(
                                                    child: Text(
                                                        "Qual diluição vai usar? Ex: 1/40",
                                                        textAlign:
                                                            TextAlign.justify,
                                                        style: TextStyle(
                                                          fontSize:
                                                              corpoMensagem,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          //color: Color(0xff075E54)
                                                        )),
                                                  ),
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      flex: 2,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 4,
                                                                left: 2),
                                                        child: Container(
                                                          height: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            border:
                                                                Border.all(),
                                                            color: Colors.white,
                                                            //image: DecorationImage(
                                                            //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                                          ),
                                                          child: Center(
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 16),
                                                              child: TextField(
                                                                controller: _um,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    color: Color(
                                                                        0xff075E54)),
                                                                decoration: InputDecoration(
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    hintText:
                                                                        "Ex 1",
                                                                    fillColor:
                                                                        Color(
                                                                            0xff075E54)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 4,
                                                                left: 2),
                                                        child: Container(
                                                          height: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            border:
                                                                Border.all(),
                                                            color: Colors.white,
                                                            //image: DecorationImage(
                                                            //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                                          ),
                                                          child: Center(
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 12),
                                                              child: TextField(
                                                                controller:
                                                                    _para,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    color: Color(
                                                                        0xff075E54)),
                                                                decoration: InputDecoration(
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    hintText:
                                                                        "Ex 40",
                                                                    fillColor:
                                                                        Color(
                                                                            0xff075E54)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 6,
                                                                left: 4),
                                                        child: Container(
                                                          width: 150,
                                                          height: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            //border: Border.all(),
                                                            color: Color(
                                                                0xff075E54),
                                                            //image: DecorationImage(
                                                            //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4),
                                                            child: Center(
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  _calcularResultadoDaDiluicao();
                                                                },
                                                                child: Text(
                                                                    _textoBotao,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            corpoMensagem-2,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 16),
                                                  child: Center(
                                                    child: Text(_textoResultado,
                                                        textAlign:
                                                            TextAlign.justify,
                                                        style: TextStyle(
                                                          fontSize: textoTitulo,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          //color: Color(0xff075E54)
                                                        )),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                    return null;
                                  });
                            }),
                          ],
                        );
                      }
                      break;
                  }
                  return null;
                }),
          ),
        ],
      ),
    );
  }

  _montarLista(List list, [int start = 0, int end]) {
    var random = new Random();
    if (end == null) end = list.length;
    int length = end - start;
    while (length > 1) {
      int pos = random.nextInt(length);
      length--;
      var tmp1 = list[start + pos];
      list[start + pos] = list[start + length];
      list[start + length] = tmp1;
    }
    return list;
  }

  _calcularResultadoDaDiluicao() {
    double produto;
    double agua;
    String litroL = "", litroM = "";
    String textoResultado = "";

    if (_litros.text.isNotEmpty) {
      if (_um.text.isNotEmpty) {
        if (_para.text.isNotEmpty) {
          if (_textoBotao == "NOVO CÁLCULO") {

            setState(() {
              _textoBotao = "CLIQUE PARA CALCULAR";
              _textoResultado = "Insira as informações para calcular";
            });

            _um.value =
                new TextEditingController.fromValue(new TextEditingValue(text: ""))
                    .value;
            _para.value =
                new TextEditingController.fromValue(new TextEditingValue(text: ""))
                    .value;
            _litros.value =
                new TextEditingController.fromValue(new TextEditingValue(text: ""))
                    .value;

            Textos.flushBar("Novo Cálculo", "Para calcular novamente insira as informações", context, FlushbarPosition.BOTTOM, Icons.info);

          } else {
            String diluicao = _um.text.toString() + "/" + _para.text.toString();
            double litros = double.parse(_litros.text.toString());

            produto = (double.parse(_litros.text.toString()) * double.parse(_um.text.toString()) / double.parse(_para.text.toString()));
            agua = double.parse(_litros.text.toString()) - produto;        

            if (litros <= 1) {
              litroL = "Litro";
            } else {
              litroL = "Litros";
            }

            if (produto < 1) {
              litroM = "Ml";
            } else if (produto == 1) {
              litroM = "Litro";
            } else if (produto > 1) {
              litroM = "Litros";
            }

            textoResultado = "Para realizar a diluição " + diluicao + " você deve utilizar " + agua.toString() +
                " " +
                litroL +
                " de água, com " +
                produto.toString() +
                " " +
                litroM +
                " do produto em sua composição concentrada, ao final desta diluição nesta proporção você vai ter " +
                litros.toStringAsPrecision(2) +
                " " +
                litroL +
                ".";

            setState(() {
              _textoBotao = "NOVO CÁLCULO";
              _textoResultado = textoResultado;
            });

            Textos.flushBar("Diluição efetuada", "Para calcular novamente clique em NOVO CALCULO", context, FlushbarPosition.BOTTOM, Icons.info);

          }
        } else {
          Textos.flushBar("Ops !!!", "Você não informou a diluição", context, FlushbarPosition.BOTTOM, Icons.info);
        }
      } else {
        Textos.flushBar("Ops !!!", "Você não informou a diluição", context, FlushbarPosition.BOTTOM, Icons.info);
      }
    } else {
      Textos.flushBar("Ops !!!", "Informe a litragem a fazer", context, FlushbarPosition.BOTTOM, Icons.info);
    }
  }
}
