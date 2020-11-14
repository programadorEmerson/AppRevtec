import 'package:revtec/util/Util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:share/share.dart';

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  PDFScreen(this.pathPDF);

  String text = 't';
  String subject = 's';


  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
        appBar: AppBar(
          title: Text("Boletim Técnico"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () async {          
                final RenderBox box = context.findRenderObject();
                Share.share("Visualizar o pdf do boletim técnico do produto "+Util.nomeDoProduto+" no link abaixo:"+"\n\n"+Util.linkDoPdf+"\n\nCompartilhado pelo App Revtec Bioquímica",
                    subject: subject,
                    sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
              },
            ),
          ],
        ),
        path: pathPDF);
  }

}
