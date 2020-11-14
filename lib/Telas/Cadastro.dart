import 'dart:convert';
import 'package:revtec/model/Usuario.dart';
import 'package:revtec/util/Util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
import 'dart:io';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Cadastro extends StatefulWidget {
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {

  String _cep = "";
  File _imagem;
  bool _subindoImagem = false;
  String _urlImagemRecuperada;
  String _cidade = "";
  String _estado = "";
  String _rua = "";
  String _bairro = "";
  String _meuToken = "";
  String _fotoPadrao = "";
  String _idUnico = "";

  List<String> _locations = new List(); // Option 2
  String _selectedLocation; // Option 2

  //Controladores
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerConfirmeEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  TextEditingController _controllerContraSenha = TextEditingController();
  TextEditingController _controllerCep = TextEditingController();
  TextEditingController _controllerCidade = TextEditingController();
  TextEditingController _controllerEstado = TextEditingController();
  TextEditingController _controllerRua = TextEditingController();
  TextEditingController _controllerBairro = TextEditingController();
  TextEditingController _controllerTelefone = TextEditingController();

  var maskFormatter = new MaskTextInputFormatter(mask: '#####-###', filter: { "#": RegExp(r'[0-9]') });
  var maskFormatterTelefone = new MaskTextInputFormatter(mask: '(##)#.####-####', filter: { "#": RegExp(r'[0-9]') });

  String _mensagemErro = "";

  _populateStringArray() async {
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot =
    await db.collection("categorias").getDocuments();

    List<String> list = new List();
    list.clear();
    list.add("Não sou vendedor");
    for (DocumentSnapshot item in querySnapshot.documents) {
      //list.add(item["valor"]);
      list.add(item.documentID);
    }
    setState(() {
      _locations = list ;
    });

    DocumentSnapshot snapshot = await db.collection("imagemPadrao").document( "fotoPadrao" ).get();
    Map<String, dynamic> dados = snapshot.data;

    setState(() {
      _fotoPadrao = dados["valor"];
      _controllerCep.value = new TextEditingController.fromValue(new TextEditingValue(text: Util.cepQueUsuarioEsta)).value;
      _controllerCidade.value = new TextEditingController.fromValue(new TextEditingValue(text: Util.cidadeQueOMotoristaEsta)).value;
      _controllerRua.value = new TextEditingController.fromValue(new TextEditingValue(text: Util.enderecoQueUsuarioEsta)).value;
    });

    _recuperarUF();

  }

  _telefoneInvalido(String mensagem){
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
                    children: <Widget>[
                      Expanded(
                        flex: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              mensagem,
                              style: TextStyle(
                                color: Color(0xff075E54),
                              ),
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
      },
    );
  }

  _recuperarUF() async {
    String cepDigitado = Util.cepQueUsuarioEsta;
    String url = "https://viacep.com.br/ws/${cepDigitado}/json/";
    http.Response response;

    response = await http.get(url);
    Map<String, dynamic> retorno = json.decode( response.body );

    String localidade = retorno["localidade"];
    String cep = retorno["cep"];
    String bairro = retorno["bairro"];
    String uf = retorno["uf"];
    String logradouro = retorno["logradouro"];

    if(retorno["localidade"] == null){

      Util.flutterNotification(context,
          FlushbarPosition.BOTTOM, // posição
          "${Util.primeiroNomeUsuarioLogado}", // Titulo
          "Cidade não localizada", // Texto
          Icon(Icons.info_outline, size: 25, color: Colors.green.shade300), // Icone
          Colors.black, // Cor de Fundo
          Colors.black, // Cor da barra lateral
          Duration(seconds: 3) // duraçao em segundos
      );

    }else {
      setState(() {
        _cidade = localidade;
        _cep = cep;
        _bairro = bairro;
        _estado = uf;
        _rua = logradouro;
        //_controllerCidade.value = new TextEditingController.fromValue(new TextEditingValue(text: retorno["localidade"])).value;
        _controllerEstado.value = new TextEditingController.fromValue(new TextEditingValue(text: retorno["uf"])).value;
        //_controllerRua.value = new TextEditingController.fromValue(new TextEditingValue(text: retorno["logradouro"])).value;
      });
    }
  }

  _recuperarCep() async {
    String cepDigitado = _controllerCep.text;
    String url = "https://viacep.com.br/ws/${cepDigitado}/json/";
    http.Response response;

    response = await http.get(url);
    Map<String, dynamic> retorno = json.decode( response.body );

    String localidade = retorno["localidade"];
    String cep = retorno["cep"];
    String bairro = retorno["bairro"];
    String uf = retorno["uf"];
    String logradouro = retorno["logradouro"];

    if(retorno["localidade"] == null){

      Util.flutterNotification(context,
          FlushbarPosition.BOTTOM, // posição
          "${Util.primeiroNomeUsuarioLogado}", // Titulo
          "Cidade não localizada", // Texto
          Icon(Icons.info_outline, size: 25, color: Colors.green.shade300), // Icone
          Colors.black, // Cor de Fundo
          Colors.black, // Cor da barra lateral
          Duration(seconds: 3) // duraçao em segundos
      );

    }else {
      setState(() {
        _cidade = localidade;
        _cep = cep;
        _bairro = bairro;
        _estado = uf;
        _rua = logradouro;
        _controllerCidade.value = new TextEditingController.fromValue(new TextEditingValue(text: retorno["localidade"])).value;
        _controllerEstado.value = new TextEditingController.fromValue(new TextEditingValue(text: retorno["uf"])).value;
        _controllerRua.value = new TextEditingController.fromValue(new TextEditingValue(text: retorno["logradouro"])).value;
      });
    }
  }

  _validarCampos()async{

    //Recupera dados dos campos
    String nome = _controllerNome.text+" ";
    String email = _controllerEmail.text;
    String confirmeEmail = _controllerConfirmeEmail.text;
    String senha = _controllerSenha.text;
    String contraSenha = _controllerContraSenha.text;
    String bairro = _controllerBairro.text;
    String cidade = _controllerCidade.text;
    String rua = _controllerRua.text;
    String estado = _controllerEstado.text;
    String telefone = _controllerTelefone.text;
    String categoria = _selectedLocation;
    String fotoSalvar= "";
    String tipoUsuario;
    String dataCadastro = Util.getDataAtual();
    String dataPagamento = Util.getDataAtual();
    String dataVencimento = Util.getDataAtual();

    if(_selectedLocation == "Não sou vendedor"){
      tipoUsuario = "Usuario";
    }else {
      tipoUsuario = "Empresa";
    }

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot = await db.collection("imagemPadrao").document( "fotoPadrao" ).get();
    Map<String, dynamic> dados = snapshot.data;

    if(dados["valor"] != _fotoPadrao){
      fotoSalvar = _fotoPadrao;
    }else {
      fotoSalvar = dados["valor"];
    }

    if(nome.isNotEmpty){
      if(email.isNotEmpty){
        if(email == confirmeEmail){
          if(senha.isNotEmpty){
            if(senha == contraSenha){
              if(cidade.isNotEmpty){
                if(telefone.isNotEmpty){
                  
                  Usuario usuario = Usuario();
                    usuario.nome = nome;
                    usuario.nomeFiltro = nome.substring(0, nome.indexOf(" ")).toLowerCase();
                    usuario.email = email;
                    usuario.senha = senha;
                    usuario.bairro = bairro;
                    usuario.categoria = "100.0";
                    usuario.cidade = cidade;
                    usuario.dataCadastro = Util.adicionarDiasNaData(0, "Us");
                    usuario.dataPagamento = Util.adicionarDiasNaData(180, "Us");
                    usuario.dataVencimento = Util.adicionarDiasNaData(180, "Us");
                    usuario.endereco = rua;
                    usuario.estado = estado;
                    usuario.infoAdicional = "Usuário";
                    usuario.status = "ativo";
                    usuario.telefone = telefone;
                    usuario.tipoPlano = "periodoTeste";
                    usuario.tipoUsuario = "aguardandoAtivacao";
                    usuario.token = "naoCapturado";
                    usuario.urlImagem = fotoSalvar;
                    _cadastrarUsuario( usuario );

                }else{
                  Util.flutterNotification(context,
                      FlushbarPosition.BOTTOM, // posição
                      "${Util.primeiroNomeUsuarioLogado}", // Titulo
                      "Informe seu telefone", // Texto
                      Icon(Icons.info_outline, size: 25, color: Colors.green.shade300), // Icone
                      Colors.black, // Cor de Fundo
                      Colors.black, // Cor da barra lateral
                      Duration(seconds: 3) // duraçao em segundos
                  );
                  setState(() {
                    _controllerTelefone.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;
                  });
                }
              }else{
                Util.flutterNotification(context,
                    FlushbarPosition.BOTTOM, // posição
                    "${Util.primeiroNomeUsuarioLogado}", // Titulo
                    "Cidade não localizada, informe o CEP e pesquise", // Texto
                    Icon(Icons.info_outline, size: 25, color: Colors.green.shade300), // Icone
                    Colors.black, // Cor de Fundo
                    Colors.black, // Cor da barra lateral
                    Duration(seconds: 3) // duraçao em segundos
                );
                setState(() {
                  _controllerCidade.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;
                });
              }
            }else{
              Util.flutterNotification(context,
                  FlushbarPosition.BOTTOM, // posição
                  "${Util.primeiroNomeUsuarioLogado}", // Titulo
                  "As senhas não conferem", // Texto
                  Icon(Icons.info_outline, size: 25, color: Colors.green.shade300), // Icone
                  Colors.black, // Cor de Fundo
                  Colors.black, // Cor da barra lateral
                  Duration(seconds: 3) // duraçao em segundos
              );
              setState(() {
                _controllerSenha.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;
                _controllerContraSenha.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;
              });
            }
          }else{
            Util.flutterNotification(context,
                FlushbarPosition.BOTTOM, // posição
                "${Util.primeiroNomeUsuarioLogado}", // Titulo
                "Informe sua senha", // Texto
                Icon(Icons.info_outline, size: 25, color: Colors.green.shade300), // Icone
                Colors.black, // Cor de Fundo
                Colors.black, // Cor da barra lateral
                Duration(seconds: 3) // duraçao em segundos
            );
            setState(() {
              _controllerSenha.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;
            });
          }
        }else {
          Util.flutterNotification(context,
              FlushbarPosition.BOTTOM, // posição
              "${Util.primeiroNomeUsuarioLogado}", // Titulo
              "Os e-mails não são iguais", // Texto
              Icon(Icons.info_outline, size: 25, color: Colors.green.shade300), // Icone
              Colors.black, // Cor de Fundo
              Colors.black, // Cor da barra lateral
              Duration(seconds: 3) // duraçao em segundos
          );
          setState(() {
            _controllerEmail.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;
            _controllerConfirmeEmail.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;
          });
        }
      }else{
        Util.flutterNotification(context,
            FlushbarPosition.BOTTOM, // posição
            "${Util.primeiroNomeUsuarioLogado}", // Titulo
            "Informe seu e-mail", // Texto
            Icon(Icons.info_outline, size: 25, color: Colors.green.shade300), // Icone
            Colors.black, // Cor de Fundo
            Colors.black, // Cor da barra lateral
            Duration(seconds: 3) // duraçao em segundos
        );
        setState(() {
          _controllerEmail.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;
        });
      }
    }else{
      Util.flutterNotification(context,
          FlushbarPosition.BOTTOM, // posição
          "${Util.primeiroNomeUsuarioLogado}", // Titulo
          "Informe seu nome ou empresa", // Texto
          Icon(Icons.info_outline, size: 25, color: Colors.green.shade300), // Icone
          Colors.black, // Cor de Fundo
          Colors.black, // Cor da barra lateral
          Duration(seconds: 3) // duraçao em segundos
      );
      setState(() {
        _controllerNome.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;
      });
    }


  }

  _dialogErro(String mensagem){
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
                        mensagem,
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
        );
      },
    );
  }

  _cadastrarUsuario( Usuario usuario )async{

    FirebaseAuth auth = FirebaseAuth.instance;

    auth.createUserWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha
    ).then((firebaseUser){

      //Salvar dados do usuário
      Firestore db = Firestore.instance;

      usuario.idUsuario = firebaseUser.uid;
      usuario.senha = usuario.senha;

      db.collection("usuarios")
      .document( firebaseUser.uid )
      .setData( usuario.toMap() );

      Navigator.pushNamedAndRemoveUntil(context, "/login", (_)=> false);

    }).catchError((error){
      print("erro app: " + error.toString() );
      setState(() {
        _mensagemErro = "Erro ao cadastrar usuário, verifique os campos e tente novamente!";
       // _mensagemErro = error.toString();
      });

    });
  }

  Future _recuperarImagem(String origemImagem) async {

    File imagemSelecionada;
    switch( origemImagem ){
      case "camera" :
        imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.camera);
        break;
      case "galeria" :
        imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.gallery);
        break;
    }

    setState(() {
      _imagem = imagemSelecionada;
      if( _imagem != null ){
        _subindoImagem = true;
        _uploadImagem();
      }
    });
  }

  Future _uploadImagem() async {
    Toast.show("Enviando Imagem", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
        .child("perfil")
        .child(_idUnico + ".jpg");

    //Upload da imagem
    StorageUploadTask task = arquivo.putFile(_imagem);

    //Controlar progresso do upload
    task.events.listen((StorageTaskEvent storageEvent){
      if( storageEvent.type == StorageTaskEventType.progress ){
        setState(() {
          _subindoImagem = true;
        });
      }else if( storageEvent.type == StorageTaskEventType.success ){
        setState(() {
          Toast.show("Upload Completo", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
          _subindoImagem = false;
        });
      }

    });

    //Recuperar url da imagem
    task.onComplete.then((StorageTaskSnapshot snapshot){
      _recuperarUrlImagem(snapshot);
    });

  }

  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot) async {

    String url = await snapshot.ref.getDownloadURL();

    setState(() {
      _fotoPadrao = url;
    });

  }

  @override
  void initState() {
    super.initState();
    _populateStringArray();

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Revtec Bioquímica - Cadastro"),
        ),
        body: Container(
          decoration: BoxDecoration(color: Color(0xff075E54)),
          padding: EdgeInsets.only(left: 16,right: 16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 8),
                        child: Container(
                          child: CircleAvatar(
                              radius: 100,
                              backgroundColor: Colors.white,
                              backgroundImage:
                              _fotoPadrao != null
                                  ? NetworkImage(_fotoPadrao)
                                  : null
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8, top: 4),
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 6,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(32)
                                    ),
                                    child: Text("Selecione uma imagem",style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                    ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Container(
                                      padding: EdgeInsets.only(left: 0),
                                      width: double.infinity,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(32)
                                      ),
                                      child: Center(
                                        child: RaisedButton(
                                            child: Icon(Icons.camera_alt, size: 25, color: Colors.black,),
                                            color: Colors.white,
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(32)
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _idUnico = Util.gerarIdUnico();
                                              });
                                              _recuperarImagem("camera");
                                            }),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Container(
                                      width: double.infinity,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(32)
                                      ),
                                      child: Center(
                                        child: RaisedButton(
                                            child: Icon(Icons.image, size: 25, color: Colors.black,),
                                            color: Colors.white,
                                            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(32)
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _idUnico = Util.gerarIdUnico();
                                              });
                                              _recuperarImagem("galeria");
                                            }),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: TextField(
                      textCapitalization: TextCapitalization.words,
                      controller: _controllerNome,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Nome",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32))),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: _controllerEmail,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "E-mail",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32))),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: _controllerConfirmeEmail,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Confirme o e-mail",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32))),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: _controllerSenha,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Senha",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32))),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: TextField(
                      controller: _controllerContraSenha,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Confirme a senha",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32))),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 8,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 10,
                                child: TextField(
                                  inputFormatters: [maskFormatter],
                                  controller: _controllerCep,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(fontSize: 20),
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                      hintText: "CEP",
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(32))),
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 10,
                                child: Container(
                                  padding: EdgeInsets.only(left: 4),
                                  child: RaisedButton(
                                      child: Icon(Icons.search, size: 25, color: Colors.black,),
                                      color: Colors.white,
                                      padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(32)
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _cep = _controllerCep.text;
                                        });
                                        _recuperarCep();
                                      }),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 10,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 8,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 4),
                                  child: TextField(
                                    enabled: false,
                                    controller: _controllerCidade,
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(fontSize: 20),
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                        hintText: "Cidade",
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(32))),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 10,
                                      child: Container(
                                        padding: EdgeInsets.only(left: 4),
                                        child: TextField(
                                          enabled: false,
                                          controller: _controllerEstado,
                                          style: TextStyle(fontSize: 20),
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                              hintText: "UF",
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(32))),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: TextField(
                      textCapitalization: TextCapitalization.words,
                      controller: _controllerRua,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Endereço ex: Rua Goias, 99",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32))),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: TextField(
                      inputFormatters: [maskFormatterTelefone],
                      controller: _controllerTelefone,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Telefone",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32))),
                    ),
                  ),              
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(32, 8, 32, 16),
                    child: RaisedButton(
                        child: Text(
                          "Cadastrar",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        color: Colors.green,
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                        onPressed: () {
                          _validarCampos();
                        }
                    ),
                  ),
                  Center(
                    child: Text(
                      _mensagemErro,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 20
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
