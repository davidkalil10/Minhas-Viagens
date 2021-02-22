import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Mapa extends StatefulWidget {

  String idViagem;
  Mapa({this.idViagem}); //construtor com parametro opcional

  @override
  _MapaState createState() => _MapaState();
}

class _MapaState extends State<Mapa> {

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _marcadores = {};

  CameraPosition _posicaoCamera =
    CameraPosition(
        target: LatLng(-23.595421491349803, -46.682340038550606),
        zoom: 16
    );

  //Instancia do Cloud firestore
  FirebaseFirestore _db = FirebaseFirestore.instance;

  _onMapCreated( GoogleMapController controller ){
    _controller.complete( controller );
  }

  _adicionarMarcador(LatLng latLng) async{

    List<Placemark> listaEnderecos = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    if (listaEnderecos != null && listaEnderecos.length >0){

      Placemark endereco = listaEnderecos[0];
      String ruaNum = endereco.thoroughfare + ", " + endereco.subThoroughfare;

      Marker marcador = Marker(
          markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
          position: latLng,
          infoWindow: InfoWindow(title: ruaNum),
          onTap: (){
            print("Clicado");
          }
      );
      setState(() {
        _marcadores.add(marcador);

        //Salva no firebase
        Map<String, dynamic> viagem = Map();
        viagem["titulo"] = ruaNum;
        viagem["latitude"] = latLng.latitude;
        viagem["longitude"] = latLng.longitude;

        _db.collection("viagens")
        .add(viagem);

      });
    }

  }

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(_posicaoCamera));
  }

  _adicionarListenerLocalizacao(){

    Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.best, distanceFilter: 10)
        .listen((Position position) {
      print("localização atual: " + position.toString());

      setState(() {

        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 16);
        _movimentarCamera();
      });
    });

  }

  _recuperaViagemParaID(String idViagem) async{

    if(idViagem != null){
      //Exibir marcador para id viagem
      DocumentSnapshot documentSnapshot = await _db
          .collection("viagens")
          .doc(idViagem)
          .get();

      var dados = documentSnapshot.data();
      String titulo = dados["titulo"];
      LatLng latLng = LatLng(dados["latitude"], dados["longitude"]);

      setState(() {

        Marker marcador = Marker(
            markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
            position: latLng,
            infoWindow: InfoWindow(title: titulo),
        );
        _marcadores.add(marcador);
        _posicaoCamera = CameraPosition(
            target: latLng,
            zoom: 16
        );
        _movimentarCamera();
      });

    }else{
      _adicionarListenerLocalizacao();
    }
  }

  @override
  void initState() {
    super.initState();
   // _adicionarListenerLocalizacao();

    //Recuperar Viagem pelo ID
    _recuperaViagemParaID(widget.idViagem);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapa"),),
      body: Container(
        child: GoogleMap(
          markers: _marcadores,
          myLocationEnabled: true,
          mapType: MapType.normal,
          initialCameraPosition: _posicaoCamera,
          onMapCreated: _onMapCreated,
          onLongPress: _adicionarMarcador,
        ),
      ),
    );
  }
}
