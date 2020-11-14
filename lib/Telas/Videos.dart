import 'package:revtec/Telas/Api.dart';
import 'package:revtec/model/Video.dart';
import 'package:revtec/util/Util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_youtube/flutter_youtube.dart';

class Videos extends StatefulWidget {

  String pesquisa;

  Videos(  );

  @override
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> {

  _listarVideos(String pesquisa){
    Api api = Api();
    return api.pesquisar( pesquisa );
  }

  @override
  void initState() {
    super.initState();
    //Util.mensagem = Util.listnerMensagens(Util.idUsuarioLogadoApp, context);
    print("chamado 1 - initState");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("chamado 2 - didChangeDependencies");
  }

  @override
  void didUpdateWidget(Videos oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("chamado 2 - didUpdateWidget");
  }

  @override
  void dispose() {
    super.dispose();
    print("chamado 4 - dispose");
  }

  @override
  Widget build(BuildContext context) {

    print("chamado 3 - build");

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 3, bottom: 3 , left: 8, right: 8),
        child: FutureBuilder<List<Video>>(
          future: _listarVideos( Util.pesquisa_youTube ),
          builder: (contex, snapshot){
            switch( snapshot.connectionState ){
              case ConnectionState.none :
              case ConnectionState.waiting :
                return Center(
                  child: CircularProgressIndicator(),
                );
                break;
              case ConnectionState.active :
              case ConnectionState.done :
                if( snapshot.hasData ){

                  return ListView.separated(
                      itemBuilder: (context, index){

                        List<Video> videos = snapshot.data;
                        Video video = videos[ index ];

                        return GestureDetector(
                          onTap: (){
                            FlutterYoutube.playYoutubeVideoById(
                                apiKey: Util.apiYouTube,
                                videoId: video.id,
                                autoPlay: true,
                                fullScreen: true
                            );
                          },
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage( video.imagem ),
                                    )
                                ),
                              ),
                              ListTile(
                                title: Text( video.titulo ),
                                subtitle: Text( video.canal ),
                              )
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => Divider(
                        height: 2,
                        color: Colors.grey,
                      ),
                      itemCount: snapshot.data.length
                  );
                }else{
                  return Center(
                    child: Text("Nenhum dado a ser exibido!"),
                  );
                }
                break;
            }
            return null;
          },
        ),
      ),
    );
  }
}
