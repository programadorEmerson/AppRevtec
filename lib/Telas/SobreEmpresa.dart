import 'dart:async';
import 'dart:math';

import 'package:revtec/Informacoes/Textos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:revtec/util/Util.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class SobreEmpresa extends StatefulWidget {
  @override
  _SobreEmpresaState createState() => _SobreEmpresaState();
}

class _SobreEmpresaState extends State<SobreEmpresa> {

  List<DocumentSnapshot> _requisicoes;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  String result = "Hey there !";

  double _b = -100;
  double _r = -100;

  @override
  void initState() {
    _listnerInstitucional();
    super.initState();
    Util.precoAlcoolConsumidor();
    if (Textos.souARevtec) {
        _b = 10;
        _r = 10;
    } else {
      setState(() {
          _b = -100;
          _r = -100;
      });
    }
  }

  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan();
      setState(() {
        result = qrResult;
        _pesquisaQr(result);
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
    }
  }

  Stream<QuerySnapshot> _listnerInstitucional() {
    Firestore db = Firestore.instance;
    final stream = db
        .collection("PaginaSobreEmpresa")
        .snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  _pesquisaQr(String resultado){

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

  _montarLista(List list, [int start = 0, int end])  {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("imagens/fundo.png"), fit: BoxFit.cover)
            ),
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
                        _requisicoes = _montarLista(querySnapshot.documents.toList());
                        return Stack(
                          children: <Widget>[
                            LayoutBuilder(builder: (context, constraint) {
                              double textoTitulo = Textos.size(constraint.maxWidth * 0.07, min: 8, max: 18,);
                              double corpoMensagem = Textos.size(constraint.maxWidth * 0.07, min: 8, max: 16,);

                              return ListView.separated(
                                  itemCount: querySnapshot.documents.length,
                                  separatorBuilder: (context, indice) => Divider(
                                    height: 2,
                                    color: Colors.grey,
                                  ),
                                  itemBuilder: (context, indice) {

                                    List<DocumentSnapshot> requisicoes = _requisicoes;

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
                                            left: 6, right: 6, top: 2, bottom: 2),
                                        width: double.infinity,
                                        child: GestureDetector(

                                          onLongPress: ()async{
                                          },

                                          onTap: () async {
                                          },

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
                                                Text(
                                                    Textos.sobreempresaTitulo,
                                                    textAlign: TextAlign.justify,
                                                    style: TextStyle(
                                                      fontSize: textoTitulo,
                                                      fontWeight: FontWeight.bold,
                                                      //color: Color(0xff075E54)
                                                    )),
                                                Padding(
                                                  padding: EdgeInsets.only(top: 8),
                                                  child: Text(
                                                      Textos.texto1,
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(
                                                        fontSize: corpoMensagem,
                                                        fontWeight: FontWeight.normal,
                                                        //color: Color(0xff075E54)
                                                      )),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(top: 8),
                                                  child: Text(
                                                      Textos.texto2,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: corpoMensagem,
                                                        fontWeight: FontWeight.bold,
                                                        //color: Color(0xff075E54)
                                                      )),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(top: 8),
                                                  child: Text(
                                                      Textos.institucional,
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(
                                                        fontSize: corpoMensagem,
                                                        fontWeight: FontWeight.normal,
                                                        //color: Color(0xff075E54)
                                                      )),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(top: 8),
                                                  child: Text(
                                                      Textos.automotiva,
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(
                                                        fontSize: corpoMensagem,
                                                        fontWeight: FontWeight.normal,
                                                        //color: Color(0xff075E54)
                                                      )),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(top: 8),
                                                  child: Text(
                                                      Textos.industrial,
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(
                                                        fontSize: corpoMensagem,
                                                        fontWeight: FontWeight.normal,
                                                        //color: Color(0xff075E54)
                                                      )),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(top: 8),
                                                  child: Text(
                                                      Textos.lavanderia,
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(
                                                        fontSize: corpoMensagem,
                                                        fontWeight: FontWeight.normal,
                                                        //color: Color(0xff075E54)
                                                      )),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 58),
                                                  child: Text(
                                                      Textos.fundada,
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(
                                                        fontSize: corpoMensagem,
                                                        fontWeight: FontWeight.normal,
                                                        //color: Color(0xff075E54)
                                                      )),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
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
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton(
              onPressed: () {
                Textos.souARevtec ? Navigator.pushNamed(context, "/usuarios") : _scanQR();
                //Util.cadastrarProduto(); //Cadastrar item
              },
              backgroundColor: Color(0xff075E54),
              foregroundColor: Colors.red,
              mini: true,
              child: Textos.souARevtec ? Icon(
                Icons.account_circle,
                size: 30,
                color: Colors.white,
              ):Icon(
                Icons.center_focus_weak,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

