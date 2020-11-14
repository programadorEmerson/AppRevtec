import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ZoomPage extends StatefulWidget {
  String url;
  ZoomPage(this.url);
  @override
  _ZoomPageState createState() => _ZoomPageState();
}

class _ZoomPageState extends State<ZoomPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          child: PhotoView(
            imageProvider: NetworkImage(widget.url),
          )
      )
    );
  }
}
