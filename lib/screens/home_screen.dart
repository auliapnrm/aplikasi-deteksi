import 'package:beras_app/models/user_model.dart';
import 'package:beras_app/services/api_service.dart';
import 'package:beras_app/widgets/camera_screen.dart';
import 'package:beras_app/widgets/detect_card.dart';
import 'package:beras_app/widgets/dynamic_island.dart';
import 'package:beras_app/widgets/icon_card.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:lottie/lottie.dart';
import '../constant.dart';
import 'detection_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _keyLangkahPengecekan = GlobalKey();
  bool _isLangkahPengecekanVisible = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    RenderBox? renderBox = _keyLangkahPengecekan.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      double position = renderBox.localToGlobal(Offset.zero).dy;
      if (_scrollController.offset > position - 200) {
        setState(() {
          _isLangkahPengecekanVisible = true;
        });
      } else {
        setState(() {
          _isLangkahPengecekanVisible = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final recognitions = await _apiService.detectImage(bytes);
      if (recognitions != null) {
        final image = await decodeImageFromList(bytes);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetectionScreen(
              recognitions: recognitions,
              imageBytes: bytes,
              user: widget.user,
              imageSize: Size(image.width.toDouble(), image.height.toDouble()),
            ),
          ),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final recognitions = await _apiService.detectImage(bytes);
      if (recognitions != null) {
        final image = await decodeImageFromList(bytes);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetectionScreen(
              recognitions: recognitions,
              imageBytes: bytes,
              user: widget.user,
              imageSize: Size(image.width.toDouble(), image.height.toDouble()),
            ),
          ),
        );
      }
    }
  }

  String getGreeting() {
    DateTime now = DateTime.now();
    DateTime jakartaTime = now.toUtc().add(const Duration(hours: 7)); // Waktu Jakarta GMT+7

    int hour = jakartaTime.hour;

    if (hour >= 00 && hour < 11) {
      return 'Halo. Selamat Pagi,';
    } else if (hour >= 11 && hour < 15) {
      return 'Halo. Selamat Siang,';
    } else if (hour >= 15 && hour < 18) {
      return 'Halo. Selamat Sore,';
    } else {
      return 'Halo. Selamat Malam,';
    }
  }

  Future<void> _startRealTimeDetection() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          controller: CameraController(
            firstCamera,
            ResolutionPreset.high,
          ),
          user: widget.user,
          apiService: _apiService,
        ),
      ),
    );
  }

  void _navigateToReportScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReportScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  const Color(0xFF5B86E5).withOpacity(0.3), // Biru dengan opacity rendah
                  const Color(0xFF36D1DC).withOpacity(0.3) // Ungu dengan opacity rendah
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.7, 1.3, 0.2], // Mengatur posisi transisi warna
              ),
            ),
          ),
          // Bagian atas warna biru dengan gradient
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.35, // 35% dari tinggi layar
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue[900]!,
                  Colors.purple[300]!,
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.9, 1.0], // Mengatur posisi transisi warna
              ),
            ),
            child: Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10), // Menambahkan jarak ke bawah
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            getGreeting(),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            widget.user.namaLengkap,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5), // Menambahkan jarak ke bawah
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  top: 30, // Sesuaikan posisi atas sesuai kebutuhan
                  left: 0,
                  right: 0,
                  child: Center(
                    child: DynamicIsland(
                      message: '',
                      isExpanded: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Konten dengan Card di atas dan ListView di bawah
          Positioned(
            top: MediaQuery.of(context).size.height * 0.26, // Sesuaikan dengan tinggi container biru
            left: 25,
            right: 25,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey, // Warna border
                  width: 0.5, // Ketebalan border
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Container(
                  color: Colors.white, // Latar belakang putih
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        const Text(
                          'Kamu sudah melakukan...',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: const [
                              GradientCard(number: '1', label: 'Total Deteksi'),
                              GradientCard(number: '2', label: 'Output Bagus'),
                              GradientCard(number: '3', label: 'Output Kurang Bagus'),
                              GradientCard(number: '4', label: 'Output Tidak Bagus'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _isLangkahPengecekanVisible ? 'Langkah Pengecekan' : 'Fitur kami',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Expanded(
                          child: CustomScrollView(
                            controller: _scrollController,
                            slivers: [
                              SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: const [
                                            IconCard(iconPath: 'assets/icons/photo-camera.png'),
                                            SizedBox(height: 8),
                                            Text(
                                              'Melalui\n Galeri',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Poppins',
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: const [
                                            IconCard(iconPath: 'assets/icons/picture.png'),
                                            SizedBox(height: 8),
                                            Text(
                                              'Realtime\n Deteksi',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Poppins',
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: const [
                                            IconCard(iconPath: 'assets/icons/orientation.png'),
                                            SizedBox(height: 8),
                                            Text(
                                              'Export\n Hasil',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Poppins',
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Langkah Pengecekan',
                                      key: _keyLangkahPengecekan,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                              SliverList(
                                delegate: SliverChildListDelegate(
                                  const [
                                    PreventCard(
                                      text: "◉ Unggah gambar gabah \natau melalui video\n◉ Sistem memproses foto \nataupun video \n ◉ Hasil deteksi keluar \n➤ Export ke PDF, deh :)",
                                      lottieAnimation: "assets/animations/animation7.json",
                                      title: "Langkah proses",
                                    ),
                                    PreventCard(
                                      text: "◉ Unggah gambar gabah \n◉ Pilih gambar gabah yang\n ingin dideteksi \n◉ Hasil deteksi keluar",
                                      lottieAnimation: "assets/animations/animation6.json",
                                      title: "Melalui Foto",
                                    ),
                                    PreventCard(
                                      text: "◉ Buka kamera kamu \n◉ Pilih menggunakan video \n◉ Hasil deteksi keluar\n secara real-time",
                                      lottieAnimation: "assets/animations/animation9.json",
                                      title: "Secara Realtime",
                                    ),
                                    PreventCard(
                                      text: "◉ Setelah melakukan \npendeteksian\n◉ Pilih menu laporan \n◉ Riwayat deteksi keluar\nsecara langsung\n ◉ Pilih Export data",
                                      lottieAnimation: "assets/animations/animation8.json",
                                      title: "Export Hasil",
                                    ),
                                  ],
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Mulai Pendeteksian',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                DetectCard(
                                                  iconPath: 'assets/icons/upload.png',
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.amber.withOpacity(0.4),
                                                      Colors.lightBlue.withOpacity(0.4)
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  onTap: () {
                                                    _pickImage();
                                                  },
                                                ),
                                                const SizedBox(height: 8),
                                                const Text(
                                                  'Melalui\n Galeri',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins',
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                DetectCard(
                                                  iconPath: 'assets/icons/transfer.png',
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.green.withOpacity(0.4),
                                                      Colors.lightGreen.withOpacity(0.4)
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  onTap: () {
                                                    _startRealTimeDetection();
                                                  },
                                                ),
                                                const SizedBox(height: 8),
                                                const Text(
                                                  'Realtime\n Deteksi',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins',
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                DetectCard(
                                                  iconPath: 'assets/icons/export.png',
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.cyanAccent.withOpacity(0.4),
                                                      Colors.lightGreen.withOpacity(0.4)
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  onTap: () {
                                                    _navigateToReportScreen();
                                                  },
                                                ),
                                                const SizedBox(height: 8),
                                                const Text(
                                                  'Export\n Hasil',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins',
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PreventCard extends StatelessWidget {
  final String lottieAnimation;
  final String title;
  final String text;
  const PreventCard({
    Key? key,
    required this.lottieAnimation,
    required this.title,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 156,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            Container(
              height: 136,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -5,
              left: -10,
              child: SizedBox(
                width: 150,
                child: Lottie.asset(
                  lottieAnimation,
                  fit: BoxFit.fill,
                  frameRate: FrameRate.max,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              left: 125,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                height: 136,
                width: MediaQuery.of(context).size.width - 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: Text(
                        text,
                        maxLines: 7,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GradientCard extends StatelessWidget {
  final String number;
  final String label;

  const GradientCard({Key? key, required this.number, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 7),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            gradient: kGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
