import 'dart:async';
import 'dart:convert'as convert;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
//AIzaSyAsT0z6mWQpegfOASVDtoz0tMwYRNVyvdY
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Enkaz Durum'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);



  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  //AIzaSyA2Jm6nCkSPY_sIt2vYlOkPIWQhoaii7m4

  BitmapDescriptor uyari,dusuk_uyari;

  Completer<GoogleMapController> haritaKontrol = Completer();

  var baslangicKonum = CameraPosition(target: LatLng(36.57645384304422,36.15370904971601),zoom: 6,);

  List<Marker> isaretler = <Marker>[];

  iconOlustur(context){
    ImageConfiguration configuration = createLocalImageConfiguration(context);
    BitmapDescriptor.fromAssetImage(configuration, "resimler/uyari.png").then((icon) {
      uyari = icon;
    },
    );
    ImageConfiguration configuration2 = createLocalImageConfiguration(context);
    BitmapDescriptor.fromAssetImage(configuration2, "resimler/dusuk_uyari.png").then((icon) {
      dusuk_uyari = icon;
    },
    );
  }
  var jsonResponse;
  Future<void> konumaGit() async {
    var url = 'https://deprem-database.herokuapp.com/mobil.php';
    var response = await http.get(url);
    if (response.statusCode == 200){
    jsonResponse = convert.jsonDecode(response.body);
    print(jsonResponse.length);
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
    GoogleMapController controller = await haritaKontrol.future;
      List<Marker> dizi = [];
      for (var i=0;i<jsonResponse.length;i++) {
        
      if (jsonResponse[i]["bina_durumu"]=="0"){
        dizi.add(
          Marker(
      markerId: MarkerId(jsonResponse[i]["idnew_table"]),
      position: LatLng(double.parse(jsonResponse[i]["enlem"]),double.parse(jsonResponse[i]["boylam"])),
      infoWindow: InfoWindow(title: "İste",snippet: "Kişi:"+jsonResponse[i]["kisi_sayisi"]),
      icon: uyari,
      ));}
      else if(jsonResponse[i]["bina_durumu"]=="1"){
        dizi.add(
      Marker(
      markerId: MarkerId(jsonResponse[i]["idnew_table"]),
      position: LatLng(double.parse(jsonResponse[i]["enlem"]),double.parse(jsonResponse[i]["boylam"])),
      infoWindow: InfoWindow(title: "İste",snippet: "Kişi:"+jsonResponse[i]["kisi_sayisi"]),
      icon: dusuk_uyari,
    ));

    }
    
      
      };
    //     Marker(
    //   markerId: MarkerId("Id0"),
    //   position: LatLng(double.parse(jsonResponse[0]["enlem"]),double.parse(jsonResponse[0]["boylam"])),
    //   infoWindow: InfoWindow(title: "İste",snippet: "Evim"),
    //   icon: uyari,
    // ),Marker(
    //   markerId: MarkerId("Id1"),
    //   position: LatLng(36.57986216196741, 36.15912603119237),
    //   infoWindow: InfoWindow(title: "Ben",snippet: "Evim"),
    //   icon: dusuk_uyari,
    // )];
   

    setState(() {
      isaretler.addAll(dizi);
    });

    var gidilecekKonum = CameraPosition(target: LatLng(36.57645384304422,36.15370904971601),zoom:12,);

    controller.animateCamera(CameraUpdate.newCameraPosition(gidilecekKonum));

  }

  @override
  Widget build(BuildContext context) {
    iconOlustur(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 400,
              height: 530
              ,
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: baslangicKonum,
                markers: Set<Marker>.of(isaretler),
                onMapCreated: (GoogleMapController controller){
                  haritaKontrol.complete(controller);
                },
              ),
            ),
            RaisedButton(
              child: Text("Güncelle"),
              color:Colors.blue,
              elevation:4.0,
              splashColor:Colors.blueAccent,
              onPressed: (){
                konumaGit();
              },
            ),
          ],
        ),
      ),

    );
  }
}
