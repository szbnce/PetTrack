import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

// Globális változó a kameráknak
late List<CameraDescription> _cameras;

Future<void> main() async {
  // Ez kötelező, ha a runApp előtt hardveres dolgokat (pl. kamera) inicializálsz!
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lekérjük az elérhető kamerákat a telefonon
  _cameras = await availableCameras();
  
  runApp(const PetTrackApp());
}

class PetTrackApp extends StatelessWidget {
  const PetTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetTrack Monitor',
      theme: ThemeData.dark(), // Szigorúan sötét mód, kíméljük az akksit!
      home: const CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    // Kiválasztjuk a legelső (általában a hátsó) kamerát
    _controller = CameraController(
      _cameras[0], 
      ResolutionPreset.medium, // Nem kell 4K, elég a közepes felbontás!
      enableAudio: false,      // A nyúl úgyse beszél, felesleges a mikrofon
    );

    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        print("Kamera hiba: ${e.description}");
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Ez a függvény lövi a képet az API-nak
  Future<void> sendFrameToApi() async {
    if (!_controller.value.isInitialized) return;

    try {
      // 1. Lő egy képet
      final XFile image = await _controller.takePicture();
      final File file = File(image.path);

      // 2. Ide jön majd a Backend IP címed!
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.100:8080/upload-frame'),
      );

      // 3. Hozzácsapjuk a fájlt a kéréshez
      request.files.add(
        await http.MultipartFile.fromPath('frame', file.path),
      );

      // 4. Elküldjük és várjuk a csodát
      print("Küldés folyamatban...");
      var response = await request.send();

      if (response.statusCode == 200) {
        print("Sikeres küldés a backendnek! 🐰🚀");
      } else {
        print("A szerver elhajtott: ${response.statusCode}");
      }
    } catch (e) {
      print("Hálózati hiba (valószínűleg nem fut a backend): $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('PetTrack Monitor MVP'),
        backgroundColor: Colors.red[900],
      ),
      body: Center(
        child: _isCameraInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: CameraPreview(_controller),
              )
            : const CircularProgressIndicator(color: Colors.red),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: sendFrameToApi,
        label: const Text('Kép küldése az API-ra!'),
        icon: const Icon(Icons.send),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}