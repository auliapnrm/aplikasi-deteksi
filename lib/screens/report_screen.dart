import 'dart:io';
import 'package:debenih_release/widgets/customcircular.dart';
import 'package:flutter/material.dart';
import 'package:debenih_release/services/api_service.dart';
import 'package:debenih_release/models/user_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../constant.dart'; // Pastikan import kGradient

class ReportScreen extends StatefulWidget {
  final UserModel user;

  const ReportScreen({super.key, required this.user});

  @override
  ReportScreenState createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _reports = [];
  int _currentPage = 1;
  final int _pageSize = 25;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final reports =
          await _apiService.getUserReports(widget.user.userId.toString());
      setState(() {
        _reports = reports;
      });
    } catch (e) {
      print('Failed to fetch reports: $e');
    }
  }

  List<Map<String, dynamic>> get _paginatedReports {
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = startIndex + _pageSize;
    return _reports.sublist(
      startIndex,
      endIndex > _reports.length ? _reports.length : endIndex,
    );
  }

  Future<void> _exportToPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            headers: ['No', 'Waktu', 'Class', 'Confidence'],
            data: _reports.map((report) {
              return [
                report['id'].toString(),
                report['detection_time'],
                report['detection_class'],
                report['detection_confidence'].toString(),
              ];
            }).toList(),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/report-debenih.pdf');
    await file.writeAsBytes(await pdf.save());

    _viewPDF(file.path);
  }

  void _viewPDF(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewScreen(filePath: filePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Hasil Deteksi',
            style: TextStyle(color: Colors.black, fontFamily: 'Poppins')),
        backgroundColor: Colors.white,
      ),
      body: _reports.isEmpty
          ? const Center(
              child: CustomCircularProgressIndicator(
                  imagePath: 'assets/logo/circularcustom.png'))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 10.0,
                        columns: const [
                          DataColumn(label: Text('No')),
                          DataColumn(label: Text('Waktu')),
                          DataColumn(label: Text('Class')),
                          DataColumn(label: Text('Confidence')),
                        ],
                        rows: _paginatedReports.map((report) {
                          return DataRow(
                            cells: [
                              DataCell(Text(report['id'].toString())),
                              DataCell(Text(report['detection_time'])),
                              DataCell(Text(report['detection_class'])),
                              DataCell(Text(report['detection_confidence']
                                  .toStringAsFixed(2))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _currentPage > 1
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          : null,
                    ),
                    Text('Halaman $_currentPage'),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _currentPage * _pageSize < _reports.length
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: kGradient,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      onPressed: _exportToPDF,
                      child: const Text('Lihat Laporan',
                          style: TextStyle(fontFamily: 'Poppins')),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class PDFViewScreen extends StatelessWidget {
  final String filePath;

  const PDFViewScreen({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Pendeteksian',
            style: TextStyle(color: Colors.black, fontFamily: 'Poppins')),
        backgroundColor: Colors.white,
      ),
      body: PDFView(
        filePath: filePath,
      ),
    );
  }
}
