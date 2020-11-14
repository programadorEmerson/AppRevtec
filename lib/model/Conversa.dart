import 'package:cloud_firestore/cloud_firestore.dart';
class Conversa {

  String _idRemetente;
  String _idDestinatario;
  String _nome;
  String _nomeFiltro;
  int _ordem;
  String _mensagem;
  String _caminhoFoto;
  String _tipoMensagem;//texto ou imagem


  Conversa();

  salvar() async {

    Firestore db = Firestore.instance;
    await db.collection("conversas")
            .document( this.idRemetente )
            .collection( "ultima_conversa" )
            .document( this.idDestinatario )
            .setData( this.toMap() );

  }

  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = {
      "idRemetente"     : this.idRemetente,
      "idDestinatario"  : this.idDestinatario,
      "nome"            : this.nome,
      "nomeFiltro"      : this.nomeFiltro,
      "ordem"            : this.ordem,
      "mensagem"        : this.mensagem,
      "caminhoFoto"     : this.caminhoFoto,
      "tipoMensagem"    : this.tipoMensagem,
    };

    return map;

  }


  String get nomeFiltro => _nomeFiltro;

  set nomeFiltro(String value) {
    _nomeFiltro = value;
  }

  String get idRemetente => _idRemetente;

  set idRemetente(String value) {
    _idRemetente = value;
  }


  int get ordem => _ordem;

  set ordem(int value) {
    _ordem = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get mensagem => _mensagem;

  String get caminhoFoto => _caminhoFoto;

  set caminhoFoto(String value) {
    _caminhoFoto = value;
  }

  set mensagem(String value) {
    _mensagem = value;
  }

  String get idDestinatario => _idDestinatario;

  set idDestinatario(String value) {
    _idDestinatario = value;
  }

  String get tipoMensagem => _tipoMensagem;

  set tipoMensagem(String value) {
    _tipoMensagem = value;
  }


}