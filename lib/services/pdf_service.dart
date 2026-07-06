import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

class PdfService {
  PdfService._();
  static final PdfService instance = PdfService._();

  Future<List<int>> _buildPdfBytes({
    required String title,
    required String description,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title,
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text(description, style: const pw.TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
    return doc.save();
  }

  String _safeName(String title) {
    return title.trim().isEmpty
        ? 'note_${DateTime.now().millisecondsSinceEpoch}'
        : title.trim().replaceAll(RegExp(r'[^\w\s-]'), '');
  }

  /// For sharing: writes to the app's own cache dir, always readable
  /// by this app's process — no permissions, no scoped-storage issues.
  Future<File> generateForShare({
    required String title,
    required String description,
  }) async {
    final bytes = await _buildPdfBytes(title: title, description: description);
    final cacheDir = await getTemporaryDirectory();
    final file = File('${cacheDir.path}/${_safeName(title)}.pdf');
    await file.writeAsBytes(bytes);
    print(file.path);
    print(await file.exists());
    return file;
  }

  Future<void> downloadToDownloads({
    required String title,
    required String description,
  }) async {
    final bytes = await _buildPdfBytes(title: title, description: description);
    final params = SaveFileDialogParams(
      data: Uint8List.fromList(bytes),
      fileName: '${_safeName(title)}.pdf',
    );
    await FlutterFileDialog.saveFile(params: params);
  }
}
