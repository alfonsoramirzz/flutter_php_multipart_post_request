import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearIncidente,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _crearIncidente() async {
    var imagen_bytes = await rootBundle.load('assets/imagen.png');

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    var archivo_imagen =
        await writeToFile(imagen_bytes, '${appDocDir.path}/imagen.png');

    var base64_image = base64Encode(archivo_imagen.readAsBytesSync());

    var formData = json.encode({
      "incidente_image": base64_image,
      "extension_imagen": "png",
      "ID_Vehiculo": 9,
      "ID_Usuario": 1,
      "ind_Descripcion": "ejemplo de descripcion",
      "ind_Fecha_Incidente": "2020-11-27 14:41:25",
      "ind_Tipo_incidente": "ejemplo de tipo",
    });

    try {
      // http
      //     .post(
      //   "http://smartcityhyo.tk/api/Incidente/Insertar_Incidente.php",
      //   body: formData,
      // )
      //     .then((res) {
      //   print(res);
      // }).catchError((err) {
      //   print(err);
      // });

      var uri = Uri.parse(
          "http://smartcityhyo.tk/api/Incidente/Insertar_Incidente.php");
      var request = new http.MultipartRequest("POST", uri);

      request.fields['ID_Vehiculo'] = "9";
      request.fields['ID_Usuario'] = "1";
      request.fields['ind_Descripcion'] = "ejemplo de descripcion";
      request.fields['ind_Fecha_Incidente'] = "2020-11-27 14:41:25";
      request.fields['ind_Tipo_incidente'] = "ejemplo de tipo";

      request.files.add(await http.MultipartFile.fromPath(
        'incidente_image',
        '${appDocDir.path}/imagen.png',
      ));

      request.send().then((response) {
        if (response.statusCode == 201) print("Uploaded!");
      });
    } catch (e) {
      print(e);
    }
  }

  Future<File> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}
