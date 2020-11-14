import 'dart:async';
import 'dart:math';
import 'package:flushbar/flushbar.dart';
import 'package:revtec/Informacoes/Textos.dart';
import 'package:revtec/Telas/PDFScreen.dart';
import 'package:revtec/model/PedidoId.dart';
import 'package:revtec/model/PedidosProdutos.dart';
import 'package:revtec/util/Util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class DetalhesDoProdutoNoButton extends StatefulWidget {
  String idProduto;
  DetalhesDoProdutoNoButton(this.idProduto);

  @override
  _DetalhesDoProdutoNoButtonState createState() =>
      _DetalhesDoProdutoNoButtonState();
}

class _DetalhesDoProdutoNoButtonState extends State<DetalhesDoProdutoNoButton> {
  TextEditingController _controllerProduto = TextEditingController();
  String _selectedLocation = "Selecione a Litragem";
  List<String> _litragens = new List();
  List<String> _valores = new List();
  String _valorUnitario = "Selecione";
  String _apresentacao = "";
  String _indicacoes = "";
  String _modoDeUsar = "";
  String _nomeProduto = "";
  String _caracteristicaProduto = "";
  String _linhaProduto = "";
  double _litragem = 0;
  int _qtdadePorCaixa = 0;
  String _urlImagem = "";
  double _r = -100, _b = -100;
  String _urlImagemZoom = "";
  String urlPDFPath = "";
  String assetPDFPath = "";
  String pathPDF = "";
  String urlBoletim = "";
  String _quantidadeDeCaixasDoPedido;
  String _quantidadeDeItensDoPedido;

  List<DocumentSnapshot> _requisicoes;
  final _controller = StreamController<QuerySnapshot>.broadcast();

  @override
  void initState() {
    _listnerInstitucional();
    _populateStringArray(widget.idProduto, "Selecione a Litragem");
    setState(() {
      _selectedLocation = "Selecione a Litragem";
    });
    super.initState();
  }

  _criarPdf() {
    createFileOfPdfUrl().then((f) {
      setState(() {
        pathPDF = f.path;
      });
    });
  }

  Future<File> createFileOfPdfUrl() async {
    final url = urlBoletim;
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  _populateStringArray(String idProduto, String destaque) async {
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshotDadosDoProduto =
        await db.collection("produtos").document(widget.idProduto).get();
    Map<String, dynamic> dados = snapshotDadosDoProduto.data;
    setState(() {
      try {
      _apresentacao = dados["apresentacao"]; 
      _indicacoes = dados["indicacoes"];
      _modoDeUsar = dados["modoDeUsar"];
      _nomeProduto = dados["nome"];
      _caracteristicaProduto = dados["caracteristica"];
      _linhaProduto = dados["linha"];
      _urlImagem = dados["urlImagem"];
      _urlImagemZoom = dados["urlZoom"];
      Util.linkDoPdf = "http://revtec.com.br/boletim/"+dados["urlBoletim"]+".pdf";
      urlBoletim = "http://revtec.com.br/boletim/"+dados["urlBoletim"]+".pdf";
      _criarPdf();
      _r = 10;
      _b = 10;
      } catch (e) {
        Flushbar(
          title: "Ops!!!",
          message: "Produto não encontrado, vrifique o ID e tente novamente.",
          backgroundColor: Colors.black,
          flushbarPosition: FlushbarPosition.BOTTOM,
          icon: Icon(Icons.info, size: 28, color: Colors.blue.shade300),
          leftBarIndicatorColor: Colors.black,
          duration: Duration(seconds: 3),
        )..show(context);
      }      
      
    });
    QuerySnapshot querySnapshot = await db
        .collection("produtos")
        .document(idProduto)
        .collection("litragem")
        .getDocuments();
    List<String> list = new List();
    List<String> valores = new List();
    list.clear();
    list.add(destaque);
    for (DocumentSnapshot item in querySnapshot.documents) {
      list.add(item.documentID);
      valores.add(item["valor"]);
    }
    setState(() {
      _litragens = list;
      _valores = valores;
    });
  }

  Stream<QuerySnapshot> _listnerInstitucional() {
    Firestore db = Firestore.instance;
    final stream = db.collection("PaginaSobreEmpresa").snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes do produto"),
      ),
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

                              if(_modoDeUsar == ""){
                                  return Center(child: Text("Produto não encontrado", style: TextStyle(fontSize: textoTitulo, fontWeight:FontWeight.bold),));
                              }else {
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

                                  var text = Text(
                                                                        _nomeProduto,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Color(0xff075E54),
                                                                          fontSize:
                                                                              textoTitulo,
                                                                          fontStyle:
                                                                              FontStyle.italic,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      );

                                    var textCaracteristica = Text(
                                                                        _caracteristicaProduto,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Color(0xff075E54),
                                                                          fontSize:
                                                                              textoTitulo,
                                                                          fontStyle:
                                                                              FontStyle.italic,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      );

                                    var linha = Text(
                                                                        _linhaProduto,
                                                                        overflow: TextOverflow.ellipsis,                                                                        
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Color(0xff075E54),
                                                                          fontSize:
                                                                              textoTitulo,
                                                                          fontStyle:
                                                                              FontStyle.italic,
                                                                          fontWeight:
                                                                              FontWeight.bold,                                                                              
                                                                        ),
                                                                      );      

                                    var infoProduto = Text(
                                                                        "Informações do Produto",
                                                                        overflow: TextOverflow.ellipsis,                                                                        
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Color(0xff075E54),
                                                                          fontSize:
                                                                              textoTitulo,
                                                                          fontStyle:
                                                                              FontStyle.italic,
                                                                          fontWeight:
                                                                              FontWeight.bold,                                                                              
                                                                        ),
                                                                      );

                                    var valUnitario = Text(
                                                                        "Valor unitário: " +
                                                                                _valorUnitario,
                                                                        overflow: TextOverflow.ellipsis,                                                                        
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Color(0xff075E54),
                                                                          fontSize:
                                                                              textoTitulo,
                                                                          fontStyle:
                                                                              FontStyle.italic,
                                                                          fontWeight:
                                                                              FontWeight.bold,                                                                              
                                                                        ),
                                                                      );

                                    return Padding(
                                      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      "imagens/novofundotopoproduto.png"),
                                                  fit: BoxFit.cover),
                                              //border: Border.all(color: Color(0xff075E54)),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              //color: Colors.white70
                                              //color: Colors.green,
                                            ),
                                            padding: EdgeInsets.only(
                                                left: 6,
                                                right: 6,
                                                top: 0,
                                                bottom: 2),
                                            width: double.infinity,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  //border: Border.all(),
                                                  //color: Colors.green,
                                                  ),
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 3,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15)),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    6),
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              height: 140,
                                                              child: Image(
                                                                image: NetworkImage(
                                                                    _urlImagem),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 7,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 6),
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            height: 140,
                                                            decoration:
                                                                BoxDecoration(
                                                                    //color: Colors.white
                                                                    ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          6,
                                                                          0,
                                                                          0),
                                                                  child:
                                                                      Container(
                                                                    width: double
                                                                        .infinity,
                                                                    height: 30,
                                                                    decoration: BoxDecoration(
                                                                        //color: Color(0xff075E54),
                                                                        //border: Border.all(),
                                                                        borderRadius: BorderRadius.circular(10)),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          10,
                                                                          2,
                                                                          0,
                                                                          4),
                                                                  child: Container(
                                                                    child: infoProduto
                                                                  ),
                                                                ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          10,
                                                                          2,
                                                                          0,
                                                                          4),
                                                                  child: Container(
                                                                    child: text,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          10,
                                                                          0,
                                                                          0,
                                                                          4),
                                                                  child: Container(
                                                                    child: textCaracteristica,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          10,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  child: Container(
                                                                    child: linha,
                                                                  ),
                                                                ),                                                               
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 12, 0, 0),
                                            child: Container(
                                              width: double.infinity,
                                              child: Column(
                                                children: <Widget>[
                                                  Text(
                                                    "Apresentação",
                                                    style: TextStyle(
                                                        fontSize: textoTitulo,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 4, 0, 0),
                                                    child: Container(
                                                        width: double.infinity,
                                                        child: Text(
                                                            _apresentacao,
                                                            textAlign: TextAlign
                                                                .justify,
                                                            style: TextStyle(
                                                                fontSize:
                                                                    corpoMensagem,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal))),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 6, 0, 0),
                                                    child: Column(
                                                      children: <Widget>[
                                                        Text(
                                                          "Indicações",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  textoTitulo,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  0, 4, 0, 0),
                                                          child: Container(
                                                              width: double
                                                                  .infinity,
                                                              child: Text(
                                                                  _indicacoes,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .justify,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          corpoMensagem,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal))),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 6, 0, 60),
                                                    child: Column(
                                                      children: <Widget>[
                                                        Text(
                                                          "Modo de Usar",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  textoTitulo,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  0, 4, 0, 0),
                                                          child: Container(
                                                              width: double
                                                                  .infinity,
                                                              child: Text(
                                                                  _modoDeUsar,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .justify,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          corpoMensagem,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal))),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                              }
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
            bottom: _b,
            right: _r,
            child: FloatingActionButton(
              onPressed: () {
                Util.linkDoPdf = urlBoletim;
                Util.nomeDoProduto = _nomeProduto;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PDFScreen(pathPDF)));
              },
              backgroundColor: Color(0xff075E54),
              mini: false,
              child: Padding(
                padding: EdgeInsetsDirectional.only(top: 8),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.assignment_late,
                      size: 25,
                      color: Colors.white,
                    ),
                    Text(
                      "Boletim",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _quantidade() {
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

  _quantidadePorCaixa() {
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
        "Adicionando item ao carrinho.", // Texto
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
      if (Util.idDooPedidoEmAberto == "nao") {        
        idDoPedido = Util.gerarIdUnico();
      } else {
        idDoPedido = Util.idDooPedidoEmAberto;
      }
    } catch (e) {
      idDoPedido = Util.gerarIdUnico();
    }

    PedidoId pedido = new PedidoId();
    pedido.idPedido = idDoPedido;
    Util.idDooPedidoEmAberto = idDoPedido;
    pedido.dataPedido = Util.capturarDataAtual();
    pedido.status = "Aberto";
    pedido.idLoja = Util.idDaRevtec;
    pedido.idComprador = Textos.idUsuarioLogado;
    pedido.urlImagem = Textos.urlUsuario;
    pedido.nomeComprador = Textos.nomeUsuarioLogado;

    PedidosProdutos produto = new PedidosProdutos();
    produto.apresentacao = _apresentacao;
    produto.caracteristica = _caracteristicaProduto;
    produto.idProduto = widget.idProduto;
    produto.indicacoes = _indicacoes;
    produto.linha = _linhaProduto;
    produto.modoDeUsar = _modoDeUsar;
    produto.nome = _nomeProduto;
    produto.urlBoletim = Util.linkDoPdf;
    produto.urlImagem = _urlImagem;
    produto.urlZoom = _urlImagemZoom;
    produto.litragem = _litragem;
    produto.preco = _valorUnitario;
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
        .document(widget.idProduto)
        .setData(produto.toMap());

    Util.notification(
        context, // posição
        Textos.nomeUsuarioLogado, // Titulo
        _nomeProduto + " adicionado ao carrinho", // Texto
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

  void usuarioSemLogin() {
    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text("Você não esta logado"),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Efetuar Login?"),
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
              Navigator.pushNamedAndRemoveUntil(
                  context, "/login", (_) => false);
            },
          ),
        ],
      ),
    );
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

  void adicionarAoCarrinho() {
    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text("Adicionar ao carrinho"),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Adicionar este item ao carrinho?"),
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
              _comprar();
            },
          ),
        ],
      ),
    );
  }

  void _resgatarValor(String litragem) {
    for (var i = 0; i < _litragens.length; i++) {
      if (_litragens[i] == litragem) {
        if (Textos.usuarioEstaLogado) {
          setState(() {
            _valorUnitario =
                Util.formatarValoresParaExibicao(double.parse(_valores[i - 1]));
          });
        } else {
          Util.notification(
              context, // posição
              "Atenção!!!", // Titulo
              "Para visualizar os preços faça o login.", // Texto
              Icon(Icons.info_outline,
                  size: 25, color: Colors.green.shade300), // Icone
              Colors.black, // Cor de Fundo
              Colors.black, // Cor da barra lateral
              Duration(seconds: 3) // duraçao em segundos
              );
        }
        break;
      }
    }
  }
}
