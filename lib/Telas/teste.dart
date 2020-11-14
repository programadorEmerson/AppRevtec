import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class teste extends StatefulWidget {
  @override
  _testeState createState() => _testeState();
}

class _testeState extends State<teste> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: (){
            Navigator.pushNamed(context, "/teste");
          },
          child: Text("oi"),
        ),
      ),
    );
  }
}
