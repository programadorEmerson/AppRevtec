import 'dart:async';

import 'package:revtec/Informacoes/Textos.dart';
import 'package:revtec/Telas/CarrinhoCompras/Abas/ItensPedido.dart';
import 'package:revtec/model/PedidoId.dart';
import 'package:revtec/util/Util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:toast/toast.dart';

class PedidosFinalizadosRevtec extends StatefulWidget {

  @override
  _PedidosFinalizadosRevtecState createState() => _PedidosFinalizadosRevtecState();
}

class _PedidosFinalizadosRevtecState extends State<PedidosFinalizadosRevtec> {
  Firestore db = Firestore.instance;
  final _controllerEntregue = StreamController<QuerySnapshot>.broadcast();

  Stream<QuerySnapshot> _adicionarListenerPedidos() {
    Firestore db = Firestore.instance;
    final stream = db
        .collection("pedidosEnviados")
        .where("status", isEqualTo: "Encerrado")
        .snapshots();
    stream.listen((dados) {
      _controllerEntregue.add(dados);
    });

  }

  _verificarItens(String idPedido)async{
    Navigator.pushNamed(context, "/pedidoFinalizadoEmpresa", arguments: await "");
  }

  _showDialogCancelarPedido(String idLoja, String idPedido, String urlImagem, String dataPedido, String idComprador){
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
                        "Deseja cancelar este pedido?",
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
                                                  Icon(Icons.shopping_cart, size: 25, color: Colors.black,)
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
                                            "Sim quero cancelar",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                            ),
                                          ),
                                          onPressed: () async {

                                            Navigator.of(context).pop();
                                            PedidoId dadosDoPedido = PedidoId();
                                            dadosDoPedido.idPedido = idPedido;
                                            dadosDoPedido.dataPedido = dataPedido;
                                            dadosDoPedido.status = "Cancelado";
                                            dadosDoPedido.idLoja = idLoja;
                                            dadosDoPedido.idComprador = idComprador;
                                            dadosDoPedido.urlImagem = urlImagem;

                                            Util.flutterNotification(context,
                                                FlushbarPosition.BOTTOM, // posição
                                                "${Util.primeiroNomeUsuarioLogado}", // Titulo
                                                "Pedido cancelado com sucesso.", // Texto
                                                Icon(Icons.info_outline, size: 25, color: Colors.green.shade300), // Icone
                                                Colors.black, // Cor de Fundo
                                                Colors.black, // Cor da barra lateral
                                                Duration(seconds: 3) // duraçao em segundos
                                            );


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
                                                  Icon(Icons.business, size: 25, color: Colors.black,)
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
                                            "Não eu desisti",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                            ),
                                          ),
                                          onPressed: () async {
                                            Navigator.of(context).pop();

                                            Util.flutterNotification(context,
                                                FlushbarPosition.BOTTOM, // posição
                                                "${Util.primeiroNomeUsuarioLogado}", // Titulo
                                                "Nada foi alterado", // Texto
                                                Icon(Icons.info_outline, size: 25, color: Colors.green.shade300), // Icone
                                                Colors.black, // Cor de Fundo
                                                Colors.black, // Cor da barra lateral
                                                Duration(seconds: 3) // duraçao em segundos
                                            );

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

  _showDialogAdmin(String idLoja, String idPedido, String urlImagem, String dataPedido, String idComprador){
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
                        "Selecione a opção desejada",
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
                                                  Icon(Icons.shopping_cart, size: 25, color: Colors.black,)
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
                                            "Verificar itens",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                            ),
                                          ),
                                          onPressed: () async {
                                            _verificarItens(idPedido);
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
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(Icons.done, size: 25, color: Colors.black,)
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
                                            "Finalizar pedido",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                            ),
                                          ),
                                          onPressed: () async {
                                            Navigator.of(context).pop();

                                            String idPedidoCapturado = Util.idPedidoFinalizado;

                                            QuerySnapshot querySnapshot = await db
                                                .collection("pedidos")
                                                .document(Util.idComprador)
                                                .collection(Util.idLoja)
                                                .document(idPedidoCapturado)
                                                .collection("itens")
                                                .getDocuments();

                                            for (DocumentSnapshot item in querySnapshot.documents) {
                                              Firestore db = Firestore.instance;
                                              db.collection("pedidos")
                                                  .document(Util.idComprador)
                                                  .collection(Util.idLoja)
                                                  .document(idPedidoCapturado)
                                                  .collection("itens")
                                                  .document(item["idProduto"])
                                                  .updateData({"status" : "entregue"});
                                            }

                                            db.collection("pedidosEmpresa")
                                                .document(Util.idLoja)
                                                .collection("pedidos")
                                                .document(idPedidoCapturado)
                                                .updateData({"status" : "entregue"});

                                            setState(() {
                                              Util.idPedidoFinalizado = "0";
                                            });

                                            Util.flutterNotification(context,
                                                FlushbarPosition.BOTTOM, // posição
                                                "${Util.primeiroNomeUsuarioLogado}", // Titulo
                                                "Pedido finalizado com sucesso.", // Texto
                                                Icon(Icons.info_outline, size: 25, color: Colors.green.shade300), // Icone
                                                Colors.black, // Cor de Fundo
                                                Colors.black, // Cor da barra lateral
                                                Duration(seconds: 3) // duraçao em segundos
                                            );
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
                                                  Icon(Icons.cancel, size: 25, color: Colors.black,)
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
                                            "Cancelar pedido",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                            ),
                                          ),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            _showDialogCancelarPedido(idLoja, idPedido, urlImagem, dataPedido, idComprador);
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

  _recuperarDadosUsuario() async {   
    _adicionarListenerPedidos();
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
      "Sem pedidos em finalizdos.\n\nVocê ainda não tem nenhum pedido finalizado",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  _calcularCarrinho(String idComprador, String idLoja, String idPedido) async {
    double valor = 0;
    int quantidade = 0;
    double resultado = 0;

    QuerySnapshot querySnapshot = await db
        .collection("pedidos")
        .document(idComprador)
        .collection(idLoja)
        .document(idPedido)
        .collection("itens")
        .getDocuments();

    for (DocumentSnapshot item in querySnapshot.documents) {
      valor = double.parse(
          Util.prepararValoresParaCalculo(item["prodPreco"], context));
      quantidade = int.parse(item["prodQuantidade"]);
      resultado = (valor * quantidade) + resultado;
    }

    Util.valorDoCarrinho = resultado.toString();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("imagens/fundo.png"), fit: BoxFit.cover)),
        child: StreamBuilder<QuerySnapshot>(
            stream: _controllerEntregue.stream,
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    CircularProgressIndicator(),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 16),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "Carregando Pedidos",
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

                            AssetImage _imagem =
                            AssetImage("imagens/novofundotopoproduto.png");

                            return Container(
                              padding: EdgeInsets.only(
                                  left: 4, right: 4, top: 2, bottom: 2),
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: ()  async{
                                    Navigator.pushNamed(context, "/itens", arguments: item["idPedido"]);
                                },
                                child: Container(

                                  decoration: BoxDecoration(
                                      border: Border.all(color: Color(0xffB0C4DE)),
                                      borderRadius: BorderRadius.circular(15),
                                      image: DecorationImage(
                                          image: _imagem, fit: BoxFit.fill)
                                    //color: Colors.green,
                                    //image: DecorationImage(
                                    //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          padding: EdgeInsets.only(top: 4,bottom: 4,left: 4,right: 4),
                                          decoration: BoxDecoration(
                                            //border: Border.all(),
                                            //color: Colors.green,
                                            //image: DecorationImage(
                                            //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              CircleAvatar(
                                                  radius: 35,
                                                  backgroundColor: Colors.white,
                                                  backgroundImage:
                                                  NetworkImage(item["urlImagem"]))
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 8,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                //border: Border.all(),
                                                //color: Colors.green,
                                                //image: DecorationImage(
                                                //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                              ),
                                              child: Text("ID: "+item["idPedido"].substring(15),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    //color: Color(0xff075E54)
                                                  )),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(top: 4,bottom: 4),
                                              decoration: BoxDecoration(
                                                //border: Border.all(),
                                                //color: Colors.green,
                                                //image: DecorationImage(
                                                //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                              ),
                                              child: Text("Data: "+item["dataPedido"],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    //fontWeight: FontWeight.bold,
                                                    //color: Color(0xff075E54)
                                                  )),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                //border: Border.all(),
                                                //color: Colors.green,
                                                //image: DecorationImage(
                                                //  image: AssetImage("imagens/bgbg.jpg"), fit: BoxFit.cover)
                                              ),
                                              child: Text("Status do Pedido: ${item["status"]}",
                                                  style: TextStyle(
                                                    fontSize: 14,
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
  }
}
