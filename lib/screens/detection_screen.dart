import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class DetectionScreen extends StatelessWidget {
  final String imagePath;

  const DetectionScreen({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  Future<void> _saveImage(BuildContext context) async {
    try {
      final directory = await getExternalStorageDirectory();
      final folderPath = '${directory?.path}/Mathtech';
      final folder = Directory(folderPath);
      if (!await folder.exists()) {
        await folder.create();
      }
      final imageName = imagePath.split('/').last;
      final imageUrl = 'http://192.168.20.136:5000/$imagePath';

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final imageFile = File('$folderPath/$imageName');
        await imageFile.writeAsBytes(response.bodyBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gambar berhasil disimpan di ${imageFile.path}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Gagal mengunduh gambar: Status ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan gambar: $e')),
      );
    }
  }

  void _goBack(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'http://192.168.20.136:5000/$imagePath',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _goBack(context),
                  child: const Text('Kembali'),
                ),
                ElevatedButton(
                  onPressed: () => _saveImage(context),
                  child: const Text('Simpan Gambar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
