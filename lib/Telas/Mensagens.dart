import 'dart:async';
import 'package:revtec/Informacoes/Textos.dart';
import 'package:revtec/util/Util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:revtec/model/Conversa.dart';
import 'dart:io';
import 'package:revtec/model/Mensagem.dart';
import 'package:revtec/model/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

class Mensagens extends StatefulWidget {

  Usuario contato;
  String temTitulo;
  Mensagens(this.contato, this.temTitulo);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {

  bool _subindoImagem = false;
  String _idUsuarioLogado;
  String _idUsuarioDestinatario;
  Firestore db = Firestore.instance;
  TextEditingController _controllerMensagem = TextEditingController();

  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

  _enviarImagem (String pTipo) async {
    File imagemSelecionada;
    switch( pTipo ){
      case "camera" :
        imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.camera);
        break;
      case "galeria" :
        imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.gallery);
        break;
    }

    _subindoImagem = true;
    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
        .child("mensagens")
        .child( _idUsuarioLogado )
        .child( nomeImagem + ".jpg");

    //Upload da imagem
    StorageUploadTask task = arquivo.putFile( imagemSelecionada );

    //Controlar progresso do upload
    task.events.listen((StorageTaskEvent storageEvent){

      if( storageEvent.type == StorageTaskEventType.progress ){
        setState(() {
          _subindoImagem = true;
        });
      }else if( storageEvent.type == StorageTaskEventType.success ){
        task.onComplete.then((StorageTaskSnapshot snapshot)async{
          Util.enviarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, "", "imagem", await snapshot.ref.getDownloadURL());
        });
        setState(() {
          _subindoImagem = false;
        });
      }
    });
  }

  _showDialog(){
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
                                                  Icon(Icons.camera_enhance, size: 25, color: Colors.black,)
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
                                        child: new FlatButton(
                                          color: Color(0xff075E54),
                                          child: Text(
                                            "Tirar uma foto",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                            ),
                                          ),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            _enviarImagem("camera");
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
                                                  Icon(Icons.image, size: 25, color: Colors.black,)
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
                                            "Selecionar na galeria",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                            ),
                                          ),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            _enviarImagem("galeria");
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

  _enviarMensagem() {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
    Util.enviarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, textoMensagem, "texto", "");
      _controllerMensagem.clear();
    }
  }

  _enviarFoto() async {
    _showDialog();
  }

  _recuperarDadosUsuario() {

    if (Textos.souARevtec) {
      _idUsuarioLogado = Textos.idDaRevtec;
      _idUsuarioDestinatario = Util.idUsuarioClicado;      
    } else {
      _idUsuarioLogado = Textos.idUsuarioLogado;
      _idUsuarioDestinatario = Textos.idDaRevtec;
    }

    Util.marcarComoLida(Textos.usuario.idUsuario, Textos.idDaRevtec);
    _adicionarListenerMensagens();

  }

  Stream<QuerySnapshot> _adicionarListenerMensagens(){

    final stream = db.collection("mensagens")
        .document(_idUsuarioLogado)
        .collection(_idUsuarioDestinatario)
        .snapshots();

    stream.listen((dados){
      _controller.add( dados );
      Timer(Duration(seconds: 1), (){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } );
    });

  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {

    var caixaMensagem = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 10,
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerMensagem,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Digite a Mensagem...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)),
                    prefixIcon:
                      _subindoImagem
                        ? CircularProgressIndicator()
                        : IconButton(icon: Icon(Icons.camera_alt),onPressed:
                      _enviarFoto
                      )
                ),
              ),
            ),
          ),
          Platform.isIOS
              ? CupertinoButton(
                  child: Text("Enviar"),
                  onPressed: _enviarMensagem,
                )
              : FloatingActionButton(
                  backgroundColor: Color(0xff075E54),
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  mini: true,
                  onPressed: _enviarMensagem,
                )
        ],
      ),
    );

    var stream = StreamBuilder(
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
                                "Carregando Mensagens",
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

            QuerySnapshot querySnapshot = snapshot.data;

            if (snapshot.hasError) {
              return Text("Erro ao carregar os dados!");
            } else {
              return Expanded(
                child: ListView.builder(
                    controller: _scrollController,
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, indice) {

                      //recupera mensagem
                      List<DocumentSnapshot> mensagens = querySnapshot.documents.toList();
                      DocumentSnapshot item = mensagens[indice];

                      double larguraContainer =
                          MediaQuery.of(context).size.width * 0.8;

                      //Define cores e alinhamentos
                      Alignment alinhamento = Alignment.centerRight;
                      Color cor = Color(0xff6A5ACD);
                      Color corTexto = Colors.white;
                      FontWeight negrito = FontWeight.bold;
                      if ( _idUsuarioLogado != item["idUsuario"] ) {
                        alinhamento = Alignment.centerLeft;
                        cor = Color(0xff075E54);
                        corTexto = corTexto = Colors.white;
                      }

                      return Align(
                        alignment: alinhamento,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Container(
                            width: larguraContainer,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: cor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child:
                            item["tipo"] == "texto"
                                ? Text(item["mensagem"],style: TextStyle(fontSize: 18, color: corTexto, fontWeight: negrito,),)
                                : Image.network(item["urlImagem"]),
                          ),
                        ),
                      );
                    }),
              );
            }
            break;
        }
        return null;
      },
    );

    if(widget.temTitulo == "nao"){
      return Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("imagens/fundo.png"), fit: BoxFit.cover)),
          child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: <Widget>[
                    stream,
                    caixaMensagem,
                  ],
                ),
              )),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              CircleAvatar(
                  maxRadius: 20,
                  backgroundColor: Colors.grey,
                  backgroundImage: widget.contato.urlImagem != null
                      ? NetworkImage(widget.contato.urlImagem)
                      : null),
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(widget.contato.nome),
              )
            ],
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("imagens/fundo.png"), fit: BoxFit.cover)),
          child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: <Widget>[
                    stream,
                    caixaMensagem,
                  ],
                ),
              )),
        ),
      );
    }

  }
}
