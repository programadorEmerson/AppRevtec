
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Usuario {

  double _latitude;
  String _listner;
  double _longitude;
  String _idUsuario;
  String _idLoja;
  String _nome;
  String _nomeFiltro;
  String _email;
  String _urlImagem;
  String _senha;
  String _bairro;
  String _cidade;
  String _endereco;
  String _estado;
  String _status;
  String _telefone;
  String _tipoPlano;
  String _tipoUsuario;
  String _token;
  String _dataCadastro;
  String _dataPagamento;
  String _dataVencimento;
  String _categoria;
  String _infoAdicional;
  bool _receberNotificacoes;
  var maskFormatterTelefone = new MaskTextInputFormatter(mask: '(##)#.####-####', filter: { "#": RegExp(r'[0-9]') });
  TextEditingController _telefoneE = TextEditingController();

  Usuario();

  String verificaTipoUsuario(bool tipoUsuario){
    return tipoUsuario ? "motorista" : "passageiro";
  }

  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = {
      "idUsuario" : this.idUsuario,
      "nome" : this.nome,
      "nomeFiltro" : this.nomeFiltro,
      "idLoja" : this.idLoja,
      "email" : this.email,
      "urlImagem" : this.urlImagem,
      "senha" : this.senha,
      "listner" : this.listner,
      "bairro" : this.bairro,
      "latitude"    : this.latitude,
      "longitude"   : this.longitude,
      "cidade" : this.cidade,
      "endereco" : this.endereco,
      "estado" : this.estado,
      "status" : this.status,
      "telefone" : this.telefone,
      "tipoPlano" : this.tipoPlano,
      "tipoUsuario" : this.tipoUsuario,
      "dataCadastro" : this.dataCadastro,
      "dataPagamento" : this.dataPagamento,
      "dataVencimento" : this.dataVencimento,
      "categoria" : this.categoria,
      "token" : this.token,
      "infoAdicional" : this.infoAdicional,
      "receberNotificacoes" : this.receberNotificacoes
    };

    return map;

  }


  String get nomeFiltro => _nomeFiltro;

  set nomeFiltro(String value) {
    _nomeFiltro = value;
  }

  String get listner => _listner;

  set listner(String value) {
    _listner = value;
  }

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }

  String get idLoja => _idLoja;

  set idLoja(String value) {
    _idLoja = value;
  }

  bool get receberNotificacoes => _receberNotificacoes;

  set receberNotificacoes(bool value) {
    _receberNotificacoes = value;
  }

  String get infoAdicional => _infoAdicional;

  set infoAdicional(String value) {
    _infoAdicional = value;
  }

  String get categoria => _categoria;

  set categoria(String value) {
    _categoria = value;
  }

  String get dataCadastro => _dataCadastro;

  set dataCadastro(String value) {
    _dataCadastro = value;
  }

  String get bairro => _bairro;

  set bairro(String value) {
    _bairro = value;
  }

  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;
  }

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get urlImagem => _urlImagem;

  set urlImagem(String value) {
    _urlImagem = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get cidade => _cidade;

  set cidade(String value) {
    _cidade = value;
  }

  String get endereco => _endereco;

  set endereco(String value) {
    _endereco = value;
  }

  String get estado => _estado;

  set estado(String value) {
    _estado = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get telefone => _telefone;

  set telefone(String value) {
    _telefone = value;
  }

  String get tipoPlano => _tipoPlano;

  set tipoPlano(String value) {
    _tipoPlano = value;
  }

  String get tipoUsuario => _tipoUsuario;

  set tipoUsuario(String value) {
    _tipoUsuario = value;
  }

  String get token => _token;

  set token(String value) {
    _token = value;
  }

  String get dataPagamento => _dataPagamento;

  set dataPagamento(String value) {
    _dataPagamento = value;
  }

  String get dataVencimento => _dataVencimento;

  set dataVencimento(String value) {
    _dataVencimento = value;
  }

  static Future<List<Usuario>> recuperarContatos(String idUsuario) async {
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot = await db.collection("notificacoes").document(idUsuario).collection("contato").getDocuments();
    List<Usuario> listaUsuarios = List();
    for (DocumentSnapshot item in querySnapshot.documents) {
      Usuario usuario = Usuario();
      usuario.idUsuario = item.data["idLoja"];
      usuario.email = item.data["email"];
      usuario.nome = item.data["nome"];
      usuario.estado = item.data["estado"];
      usuario.cidade = item.data["cidade"];
      usuario.urlImagem = item.data["urlImagem"];
      usuario.token = item.data["token"];
      usuario.receberNotificacoes = item.data["receberNotificacoes"];
      usuario.categoria = item.data["categoria"];
      if(item.data["idLoja"] != idUsuario){
        listaUsuarios.add(usuario);
      }
    }
    return listaUsuarios;
  }

  double get longitude => _longitude;

  set longitude(double value) {
    _longitude = value;
  }

}