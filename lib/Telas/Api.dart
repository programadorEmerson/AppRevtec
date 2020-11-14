import 'package:revtec/model/Video.dart';
import 'package:revtec/util/Util.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const CHAVE_YOUTUBE_API = "AIzaSyDLk9z7cwGkhoTMedho_f_4mc5_3LOZ8HA";
const ID_CANAL = "UCCE-wBcct9mjSsB7enw5vXw";
const URL_BASE = "https://www.googleapis.com/youtube/v3/";

class Api {

  Future<List<Video>> pesquisar(String pesquisa) async {
    http.Response response = await http.get(
        URL_BASE + "search"
            "?part=snippet"
            "&type=video"
            "&maxResults=50"
            "&order=date"
            "&key=$CHAVE_YOUTUBE_API"
            //"&channelId=$ID_CANAL" // se comentar aparece todos os vídeos do youtube
            "&q=${"Revtec Bioquímica"}"
    );

    if( response.statusCode == 200 ){
      Map<String, dynamic> dadosJson = json.decode( response.body );
      List<Video> videos = dadosJson["items"].map<Video>(
              (map){
            return Video.fromJson(map);
          }
      ).toList();
      return videos;
    }
  }
}