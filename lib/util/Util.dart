import 'package:revtec/model/Conversa.dart';
import 'package:revtec/model/Produto.dart';
import 'package:revtec/model/Mensagem.dart';
import 'package:revtec/model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:intl/intl.dart';

class Util {
  static String idLoja = "";

  static String chaveFCM =
      "AAAAAn3VSsc:APA91bH26Gpy2F9wsN7VVZNC_Ph9bbVRW8uAuWYGhOYOGfLxgEC_WK3CwcR7ZQXWvMS2ajP20i6iSYz8pGwwz7OtMLNFLRwr4mhVsXqBsPWXfq1hvNoOsSa9ROE37807TR_moeLL7JaQ";
  static String urlImagemProduto = "";
  static String linhaInstitucional = "Linha Institucional";
  static String linhaAutomotiva = "Linha Automotiva";
  static String linhaIndustrial = "Linha Industrial";
  static String linhaLavanderia = "Linha Lavanderia";
  static String linha = "";
  static String precoAlcool500ml = "0";
  static String precoAlcool1litro = "0";
  static String precoAlcool5litros = "0";
  static String temAnuncioNaCidade = "";
  static String qualAnuncioTem = "";
  static String idDaRevtec = "vjYwR6bU5sV2rjKahWQqfFsItwx2";
  static bool veioDoCadastro = false;
  static String cep = "";
  static double fonteBotoes = 0;
  static String tipoDoUsuarioLogado = "";
  static String linkDoPdf = "";
  static String nomeDoProduto = "";
  static String nomeUsuarioLogado = "";
  static String primeiroNomeUsuarioLogado = "";
  static String tipoUsuario = "";
  static String valorDoCarrinho = "0";
  static bool temMotoristaTaxi = false;
  static bool temMotoristaMotoTaxi = false;
  static int precoCorridaMotoTaxi = 0;
  static double porcentagem = 100.0;
  static int ordem = 0;
  static String apiYouTube = "AIzaSyDLk9z7cwGkhoTMedho_f_4mc5_3LOZ8HA";
  static String fcm_key = "0";
  static String pesquisa_youTube = "";
  static String id_canal = "UCCE-wBcct9mjSsB7enw5vXw";
  static String url_base_you_tube = "0";
  static int precoCorridaTaxi = 0;
  static String dataDoPedido = "";
  static String nomeProduto = "";
  static String idDooPedidoEmAberto = "";
  static String produtoDescricao = "";
  static String produtoInformacoes = "";
  static String cepQueUsuarioEsta = "";
  static String enderecoQueUsuarioEsta = "";
  static String cidadeQueOMotoristaEsta = "";
  static String cidadeConsulta = "";
  static int contadorListner = 0;
  static String urlGost = "";
  static String urlImagemUsuario = "";
  static String urlImagemVendedor = "";
  static String ondeEstou = "";
  static String cidadeCadastro = "";
  static bool modoGost = false;
  static String idComprador = "";
  static String idProduto = "";
  static String idPedido;
  static String idPedidoFinalizado;
  static String idUsuarioLogadoApp;
  static String statusPedido;
  static String idUsuarioClicado = "";
  static String idUsuarioLogado = "";
  static Usuario usuario;
  static String tipoDeAcesso = "novoCadastro";
  static int valor = 0;
  static double minhaLongitude = 0;
  static double minhaLatitude = 0;
  static double longitudePassageiro = 0;
  static double latitudePassageiro = 0;
  static double valorDaEntrega = 0;

  String gerarIdentificadorUnico() {
    var now = new DateTime.now();
    return now
        .toString()
        .replaceAll(":", "")
        .replaceAll(".", "")
        .replaceAll("-", "")
        .replaceAll(" ", "")
        .trim();
  }

  static aCidadeTemAnuncio(BuildContext context) async {
    bool temAnuncio = false;
    Firestore db = Firestore.instance;
    QuerySnapshot pegarIdUsuario =
        await db.collection("produtos").getDocuments();
    for (DocumentSnapshot item in pegarIdUsuario.documents) {
      var usuario = item.data;
      DocumentSnapshot cidadeDoAnuncio =
          await db.collection("usuarios").document(usuario["idUsuario"]).get();
      Map<String, dynamic> cidade = cidadeDoAnuncio.data;
      if (cidade["cidade"] == cidadeConsulta) {
        temAnuncio = true;
        temAnuncioNaCidade = "sim";
        break;
      }
    }
    return temAnuncio;
  }

  static configuracaoInicialAppRetornandoIdUsuarioLogado(
      BuildContext context) async {
    FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        //Notificação com o app aberto
        Flushbar(
          title: Util.primeiroNomeUsuarioLogado,
          message: "Bem vindo.",
          backgroundColor: Colors.black,
          flushbarPosition: FlushbarPosition.TOP,
          icon: Icon(Icons.message, size: 28, color: Colors.blue.shade300),
          leftBarIndicatorColor: Colors.black,
          duration: Duration(seconds: 3),
        )..show(context);
        return null;
      },
      onResume: (Map<String, dynamic> message) {
        //Notificação com o app fechado
        return null;
      },
      onLaunch: (Map<String, dynamic> message) {
        // Ao abrir o App
        return null;
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  static cadastrarProduto() {

    Firestore db = Firestore.instance;
    Produto produto = new Produto();

    String idProdutoGravar;

    produto.nome = "REVCLEAN PEROLADO DAMASCO".toUpperCase();
    produto.nomeFiltro = "REVCLEAN PEROLADO DAMASCO".toLowerCase();
    produto.caracteristica = "Detergente Líquido Perolado";
    produto.linha = "Linha Institucional";
    idProdutoGravar = "p151";

    produto.apresentacao = "Detergente líquido especialmente desenvolvido para limpeza e remoção de sujidades diversas.  Possui um agradável perfume aliado a um efeito de brilho perolado.";
    produto.indicacoes = "Produto indicado para uso específico em ambientes industriais, comerciais, residenciais e institucionais.";
    produto.modoDeUsar = "Aplicar o produto em sua forma concentrada e pura sobre a superfície a ser limpa, previamente umedecida. Esfregar uniformemente com movimentos circulares e, posteriormente, enxaguar com água corrente. Se necessário, repetir o procedimento afim de se atingir a limpeza desejada.";
    
    produto.urlBoletim = "http://revtec.com.br/boletim/BoletimTecnico-REVCLEANPEROLADO.pdf";
    produto.urlImagem = "https://firebasestorage.googleapis.com/v0/b/revtecbioquimicaltda.appspot.com/o/imagens%2FimgPadrao.png?alt=media&token=42eed0de-09e3-434e-9c0f-51d2e52ca6b2";
    produto.urlZoom = "https://firebasestorage.googleapis.com/v0/b/revtecbioquimicaltda.appspot.com/o/imagens%2FimgPadrao.png?alt=media&token=42eed0de-09e3-434e-9c0f-51d2e52ca6b2";
    produto.idProduto = idProdutoGravar;

    db
      .collection("produtos")
      .document(idProdutoGravar)
      .setData(produto.toMap());    

    db
      .collection("produtos")
      .document(idProdutoGravar)
      .collection("litragem")
      .document("1 Litro")
      .setData({"valor": "5.20"});   

    db
      .collection("produtos")
      .document(idProdutoGravar)
      .collection("litragem")
      .document("2 Litros")
      .setData({"valor": "8.6"});    

    db
      .collection("produtos")
      .document(idProdutoGravar)
      .collection("litragem")
      .document("5 Litros")
      .setData({"valor": "18.2"});  

    db
      .collection("produtos")
      .document(idProdutoGravar)
      .collection("litragem")
      .document("20 Litros")
      .setData({"valor": "68"});                                                                                    

    db
      .collection("produtos")
      .document(idProdutoGravar)
      .collection("litragem")
      .document("50 Litros")
      .setData({"valor": "154"});             
     
  }

  static precoAlcoolConsumidor()async{
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshotPreco = await db.collection("produtos").document("alcoolConsumidor").get();
    Map<String, dynamic> preco = snapshotPreco.data;

    precoAlcool500ml = preco["500ml"];
    precoAlcool1litro = preco["1litro"];
    precoAlcool5litros = preco["5litros"];


  }

  static enviarMensagem(String idQueRecebe, String idQueEnvia, String msg,
    String tipoMensagem, urlImagemEnvio) async {
    Firestore db = Firestore.instance;
    Usuario contato = await getDadosUsuarioPeloId(idQueRecebe);

    DocumentSnapshot snapshotRecebe =
        await db.collection("usuarios").document(idQueRecebe).get();
    Map<String, dynamic> quemRecebe = snapshotRecebe.data;

    DocumentSnapshot snapshotEnvia =
        await db.collection("usuarios").document(idQueEnvia).get();
    Map<String, dynamic> quemEnvia = snapshotEnvia.data;

    if (tipoMensagem == "texto") {
      // Salva a mensagem de texto

      //Salvar notificação conversa quem envia
      Conversa cRemetente = Conversa();
      cRemetente.idRemetente = idQueEnvia;
      cRemetente.idDestinatario = idQueRecebe;
      cRemetente.mensagem = msg;
      cRemetente.nome = quemRecebe["nome"];
      cRemetente.nomeFiltro = quemRecebe["nome"].toLowerCase();
      cRemetente.ordem = 1;
      cRemetente.caminhoFoto = quemRecebe["urlImagem"];
      cRemetente.tipoMensagem = tipoMensagem;
      cRemetente.salvar();

      //Salvar notificação conversa para o destinatario
      Conversa cDestinatario = Conversa();
      cDestinatario.idRemetente = idQueRecebe;
      cDestinatario.idDestinatario = idQueEnvia;
      cDestinatario.mensagem = msg;
      cDestinatario.nome = quemEnvia["nome"];
      cDestinatario.nomeFiltro = quemEnvia["nome"].toLowerCase();
      cDestinatario.ordem = 0;
      cDestinatario.caminhoFoto = quemEnvia["urlImagem"];
      cDestinatario.tipoMensagem = tipoMensagem;
      cDestinatario.salvar();

      //Monta o objeto mensagem
      Mensagem mensagem = Mensagem(contato);
      mensagem.idUsuario = idQueEnvia;
      mensagem.mensagem = msg;
      mensagem.urlImagem = "";
      mensagem.tipo = tipoMensagem;

      //Salvar mensagem para remetente
      salvarMensagem(idQueEnvia, idQueRecebe, mensagem, db);

      //Salvar mensagem para o destinatário
      salvarMensagem(idQueRecebe, idQueEnvia, mensagem, db);
    } else {
      // salva a mensagem de imagem

      //Salvar notificação conversa quem envia
      Conversa cRemetente = Conversa();
      cRemetente.idRemetente = idQueEnvia;
      cRemetente.idDestinatario = idQueRecebe;
      cRemetente.mensagem = "Enviei uma imagem";
      cRemetente.nome = quemRecebe["nome"];
      cRemetente.nomeFiltro = quemRecebe["nome"].toLowerCase();
      cRemetente.ordem = 1;
      cRemetente.caminhoFoto = quemRecebe["urlImagem"];
      cRemetente.tipoMensagem = tipoMensagem;
      cRemetente.salvar();

      //Salvar notificação conversa para o destinatario
      Conversa cDestinatario = Conversa();
      cDestinatario.idRemetente = idQueRecebe;
      cDestinatario.idDestinatario = idQueEnvia;
      cDestinatario.mensagem = "Enviei uma imagem";
      cDestinatario.nome = quemEnvia["nome"];
      cDestinatario.nomeFiltro = quemEnvia["nome"].toLowerCase();
      cDestinatario.ordem = 0;
      cDestinatario.caminhoFoto = quemEnvia["urlImagem"];
      cDestinatario.tipoMensagem = tipoMensagem;
      cDestinatario.salvar();

      Mensagem mensagem = Mensagem(contato);
      mensagem.idUsuario = idQueEnvia;
      mensagem.mensagem = "";
      mensagem.urlImagem = urlImagemEnvio;
      mensagem.tipo = "imagem";

      await db
          .collection("mensagens")
          .document(idQueEnvia)
          .collection(idQueRecebe)
          .document(gerarIdUnico())
          .setData(mensagem.toMap());
    }
  }

  static salvarMensagem(String idRemetente, String idDestinatario, Mensagem msg,
      Firestore db) async {
    Util util = new Util();

    await db
        .collection("mensagens")
        .document(idRemetente)
        .collection(idDestinatario)
        .document(gerarIdUnico())
        .setData(msg.toMap());
  }

  static marcarComoLida(String idRemetente, String idDestinatario) {
    Firestore db = Firestore.instance;

    try {
      if (ordem == 0) {
        db
            .collection("conversas")
            .document(idRemetente)
            .collection("ultima_conversa")
            .document(idDestinatario)
            .updateData({"ordem": 2}).then((_) {
          db
              .collection("conversas")
              .document(idDestinatario)
              .collection("ultima_conversa")
              .document(idRemetente)
              .updateData({"ordem": 2});
        });
      }
    } catch (e) {}
  }

  static String prepararValoresParaCalculo(String valor, BuildContext context) {
    FlutterMoneyFormatter fmf = new FlutterMoneyFormatter(
        amount: double.parse(valor
            .replaceAll("R\$ ", "")
            .replaceAll(".", "")
            .replaceAll(",", ".")),
        settings: MoneyFormatterSettings(
            symbol: 'R\$',
            thousandSeparator: '',
            decimalSeparator: '.',
            symbolAndNumberSeparator: ' ',
            fractionDigits: 2));

    return fmf.output.nonSymbol;
  }

  static flutterNotification(
      BuildContext context,
      FlushbarPosition posicao,
      String titulo,
      String mensagem,
      Icon icone,
      Color corFundo,
      Color corBarraLateral,
      Duration duracao) {
    Flushbar(
      title: titulo,
      message: mensagem,
      backgroundColor: corFundo,
      flushbarPosition: posicao,
      icon: icone,
      leftBarIndicatorColor: corBarraLateral,
      duration: duracao,
    )..show(context);
  }

  static formatarValoresParaExibicao(double valorDouble) {
    var f = new NumberFormat("#,##0.00", "pt_BR");
    String valorViagemFormatado = f.format(valorDouble);
    return "R\$ " + valorViagemFormatado;
  }

  static notification(BuildContext context, String titulo, String mensagem,
      Icon icone, Color corFundo, Color corBarraLateral, Duration duracao) {
    Flushbar(
      title: titulo,
      message: mensagem,
      backgroundColor: corFundo,
      flushbarPosition: FlushbarPosition.BOTTOM,
      icon: icone,
      leftBarIndicatorColor: corBarraLateral,
      duration: duracao,
    )..show(context);
  }

  static formatarParaCalcular(String precoFloat) {
    String mexida = "";

    if (precoFloat.substring(0, 1) == " ") {
      mexida = precoFloat.substring(1);
    } else {
      mexida = precoFloat;
    }

    double valor2 = 0;
    String valor;
    if (mexida.length <= 6) {
      valor = mexida.replaceAll(",", ".");
      valor2 = double.parse(valor);
    } else {
      valor = mexida.replaceAll(".", "");
      valor2 = double.parse(valor.replaceAll(",", "."));
    }

    return valor2;
  }

  static consultarMotorista() async {
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot =
        await db.collection("usuarios").getDocuments();

    for (DocumentSnapshot item in querySnapshot.documents) {
      var dados = item.data;
      if (dados["tipoUsuario"] == "MotoristaTaxi" &&
          dados["cidade"] == cidadeQueOMotoristaEsta) {
        temMotoristaTaxi = true;
        break;
      }
    }

    for (DocumentSnapshot item in querySnapshot.documents) {
      var dados = item.data;
      if (dados["tipoUsuario"] == "MotoristaMotoTaxi" &&
          dados["cidade"] == cidadeQueOMotoristaEsta) {
        temMotoristaMotoTaxi = true;
        break;
      }
    }
  }

  static atualizarToken(
      FirebaseMessaging firebaseMessaging, Firestore db, String idUsuario) {
    firebaseMessaging.getToken().then((token) {
      db
          .collection("usuarios")
          .document(idUsuario)
          .updateData({"token": token});
    });
  }

  static verAnunciante(
      String idUsuario, String idUsuarioLogado, BuildContext context) async {
    (idUsuarioLogado == idUsuario)
        ? Navigator.pushNamed(context, "/homeMinhaEmpresa",
            arguments: await getDadosUsuarioPeloId(idUsuario))
        : Navigator.pushNamed(context, "/detalhesEmpresa",
            arguments: await getDadosUsuarioPeloId(idUsuario));
  }

  static String prepararValoresParaExibir(String valor) {
    FlutterMoneyFormatter fmf = new FlutterMoneyFormatter(
        amount: double.parse(valor),
        settings: MoneyFormatterSettings(
            symbol: 'R\$',
            thousandSeparator: '.',
            decimalSeparator: ',',
            symbolAndNumberSeparator: ' ',
            fractionDigits: 2));

    return fmf.output.symbolOnLeft;
  }

  static formatarValorParaDouble(String precoString) {
    String valor;
    if (precoString.length <= 6) {
      valor = precoString.replaceAll(",", ".");
    } else {
      valor = precoString.replaceAll(".", "").replaceAll(",", ".");
    }
    return valor;
  }

  static String gerarIdUnico() {
    var now = new DateTime.now();
    return now
        .toString()
        .replaceAll(":", "")
        .replaceAll(".", "")
        .replaceAll("-", "")
        .replaceAll(" ", "")
        .trim();
  }

  String dataAtual() {
    var now = new DateTime.now();

    return now.toString().substring(8, 10) +
        "/" +
        now.toString().substring(5, 7) +
        "/" +
        now.toString().substring(0, 4);
  }

  static String capturarDataAtual() {
    var now = new DateTime.now();

    return now.toString().substring(8, 10) +
        "/" +
        now.toString().substring(5, 7) +
        "/" +
        now.toString().substring(0, 4);
  }

  static String getDataAtual() {
    var now = new DateTime.now();

    return now.toString().substring(8, 10) +
        "/" +
        now.toString().substring(5, 7) +
        "/" +
        now.toString().substring(0, 4);
  }

  static Future<FirebaseUser> getUsuarioAtual() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    return await auth.currentUser();
  }

  static String adicionarDiasNaData(int dias, String formato_Br_ou_US) {
    String data = "";
    var hoje = new DateTime.now();
    var diasAMais = hoje.add(new Duration(days: dias));

    if (formato_Br_ou_US == "Br") {
      data = diasAMais.toString().substring(8, 10) +
          "/" +
          diasAMais.toString().substring(5, 7) +
          "/" +
          diasAMais.toString().substring(0, 4);
    } else {
      data = diasAMais.toString().substring(0, 4) +
          "-" +
          diasAMais.toString().substring(5, 7) +
          "-" +
          diasAMais.toString().substring(8, 10);
    }
    return data;
  }

  static Future<Usuario> getIdUsuarioPeloEmail(
      String email, BuildContext context) async {
    Firestore db = Firestore.instance;
    Usuario usuario = Usuario();
    QuerySnapshot querySnapshot =
        await db.collection("usuarios").getDocuments();

    for (DocumentSnapshot item in querySnapshot.documents) {
      if (email == item.data["email"]) {
        usuario.idUsuario = item.data["idUsuario"];
      }
    }
    return usuario;
  }

  static Future<Usuario> getDadosUsuarioPeloId(String pId) async {
    Firestore db = Firestore.instance;
    db.collection("usuarios").document(pId).updateData({"idLoja": pId});
    db.collection("usuarios").document(pId).updateData({"idUsuario": pId});
    db.collection("usuarios").document(pId).updateData({"bairro": "naoTem"});
    db.collection("usuarios").document(pId).updateData({"listner": "naoTem"});
    db
        .collection("usuarios")
        .document(pId)
        .updateData({"receberNotificacoes": false});
    DocumentSnapshot snapshot = await db.collection("usuarios").document(pId).get();

    Map<String, dynamic> dados = snapshot.data;

    Usuario usuario = Usuario();

    usuario.idUsuario = pId;
    usuario.idLoja = pId;
    usuario.nome = dados["nome"];
    usuario.nomeFiltro = dados["nomeFiltro"];
    usuario.email = dados["email"];
    usuario.urlImagem = dados["urlImagem"];
    usuario.senha = dados["senha"];
    usuario.bairro = dados["bairro"];
    usuario.cidade = dados["cidade"];
    usuario.endereco = dados["endereco"];
    usuario.estado = dados["estado"];
    usuario.status = dados["status"];
    usuario.telefone = dados["telefone"];
    usuario.tipoPlano = dados["tipoPlano"];
    usuario.tipoUsuario = dados["tipoUsuario"];
    usuario.token = dados["token"];
    usuario.dataCadastro = dados["dataCadastro"];
    usuario.dataPagamento = dados["dataPagamento"];
    usuario.dataVencimento = dados["dataVencimento"];
    usuario.categoria = dados["categoria"];
    usuario.infoAdicional = dados["infoAdicional"];
    usuario.receberNotificacoes = false;

    return usuario;
  }

  static dialogErroCor(
      String mensagem, Color cor, BuildContext context, Icon icone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Row(
            children: <Widget>[
              Expanded(
                flex: 10,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: icone,
                      ),
                      Text(
                        mensagem,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cor,
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

  static dialogErro(String mensagem, BuildContext contexto, Icon icone) {
    showDialog(
      context: contexto,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Row(
            children: <Widget>[
              Expanded(
                flex: 10,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: icone,
                      ),
                      Text(
                        mensagem,
                        textAlign: TextAlign.center,
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

  static _anuncioFinalizado(BuildContext context) {
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
                        "O que vai anunciar?",
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.local_grocery_store,
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
                                            "Um produto",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            Navigator.pushNamed(
                                                context, "/cadastarProduto");
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
                                                    Icons.build,
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
                                            "Um serviço",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          onPressed: () async {},
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
                                                    Icons.monetization_on,
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
                                            "Vou alugar",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          onPressed: () {},
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

  static criarAnuncio(BuildContext context) {
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
                        "O que vai anunciar?",
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.local_grocery_store,
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
                                            "Um produto",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            tipoDeAcesso = "novoCadastro";
                                            Navigator.pushNamed(
                                                context, "/cadastarProduto");
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
                                                    Icons.build,
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
                                            "Um serviço",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            tipoDeAcesso = "novoCadastro";
                                            Navigator.pushNamed(
                                                context, "/cadastarServico");
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
                                                    Icons.monetization_on,
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
                                            "Vou alugar",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            tipoDeAcesso = "novoCadastro";
                                            Navigator.pushNamed(
                                                context, "/cadastarAluguel");
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
