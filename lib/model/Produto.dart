class Produto {

  String _apresentacao;
  String _caracteristica;
  String _idProduto;
  String _indicacoes;
  String _linha;
  String _modoDeUsar;
  String _nome;
  String _nomeFiltro;
  String _urlBoletim;
  String _urlImagem;
  String _urlZoom;

  Produto();

  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = {
      "apresentacao" : this.apresentacao,
      "caracteristica" : this.caracteristica,
      "idProduto" : this.idProduto,
      "indicacoes" : this.indicacoes,
      "linha" : this.linha,
      "modoDeUsar" : this.modoDeUsar,
      "nome" : this.nome,
      "nomeFiltro" : this.nomeFiltro,
      "urlBoletim" : this.urlBoletim,
      "urlImagem" : this.urlImagem,
      "urlZoom" : this.urlZoom
    };
    return map;
  }


  String get urlZoom => _urlZoom;

  set urlZoom(String value) {
    _urlZoom = value;
  }

  String get nomeFiltro => _nomeFiltro;

  set nomeFiltro(String value) {
    _nomeFiltro = value;
  }

  String get urlImagem => _urlImagem;

  set urlImagem(String value) {
    _urlImagem = value;
  }

  String get urlBoletim => _urlBoletim;

  set urlBoletim(String value) {
    _urlBoletim = value;
  }

  String get modoDeUsar => _modoDeUsar;

  set modoDeUsar(String value) {
    _modoDeUsar = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get linha => _linha;

  set linha(String value) {
    _linha = value;
  }

  String get indicacoes => _indicacoes;

  set indicacoes(String value) {
    _indicacoes = value;
  }

  String get idProduto => _idProduto;

  set idProduto(String value) {
    _idProduto = value;
  }

  String get caracteristica => _caracteristica;

  set caracteristica(String value) {
    _caracteristica = value;
  }

  String get apresentacao => _apresentacao;

  set apresentacao(String value) {
    _apresentacao = value;
  }
}