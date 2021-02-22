import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:minhasviagens/Home.dart';
import 'package:minhasviagens/Mapa.dart';
import 'package:minhasviagens/SplashScreen.dart';

/*
void main() {
  runApp(MaterialApp(
    title: "Minhas Viagens",
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    title: "Minhas Viagens",
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}
