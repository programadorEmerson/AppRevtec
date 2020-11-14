class Video {

  String id;
  String titulo;
  String descricao;
  String imagem;
  String canal;
  String url;

  Video({this.id,this.url, this.titulo, this.descricao, this.imagem, this.canal});

  factory Video.fromJson(Map<String, dynamic> json){
    return Video(
      id: json["id"]["videoId"],
      url: json["id"]["url"],
      titulo: json["snippet"]["title"],
      descricao: json["snippet"]["description"],
      imagem: json["snippet"]["thumbnails"]["high"]["url"],
      canal: json["snippet"]["channelTitle"],
    );
  }


}