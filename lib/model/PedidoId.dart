
class PedidoId {

  String _idPedido;
  String _dataPedido;
  String _status;
  String _urlImagem;
  String _idLoja;
  String _idComprador;
  String _nomeComprador;

  PedidoId();

  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = {
      "idPedido" : this.idPedido,
      "dataPedido" : this.dataPedido,
      "status" : this.status,
      "idLoja" : this.idLoja,
      "idComprador" : this.idComprador,
      "nomeComprador" : this.nomeComprador,
      "urlImagem" : this.urlImagem
    };
    return map;
  }


  String get idLoja => _idLoja;

  set idLoja(String value) {
    _idLoja = value;
  }
  
  String get nomeComprador => _nomeComprador;

  set nomeComprador(String value) {
    _nomeComprador = value;
  }

  String get dataPedido => _dataPedido;

  set dataPedido(String value) {
    _dataPedido = value;
  }

  String get idPedido => _idPedido;

  set idPedido(String value) {
    _idPedido = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get urlImagem => _urlImagem;

  set urlImagem(String value) {
    _urlImagem = value;
  }

  String get idComprador => _idComprador;

  set idComprador(String value) {
    _idComprador = value;
  }


}