import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfViewerScreen extends StatelessWidget {
  final Map<String, dynamic> invoiceData;

  const PdfViewerScreen({super.key, required this.invoiceData});

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            cross: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("MOTOLAB WORKSHOP NETWORK", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Invoice Number: ${invoiceData['invoice_metadata']['invoice_number']}"),
              pw.Text("Date: ${invoiceData['invoice_metadata']['issue_date']}"),
              pw.Divider(),
              pw.Text("Customer Name: ${invoiceData['customer_details']['name']}"),
              pw.Text("Vehicle Plate: ${invoiceData['vehicle_details']['plate_number']}"),
              pw.SizedBox(height: 20),
              pw.Text("Total Amount Paid: ${invoiceData['financial_summary']['currency']} ${invoiceData['financial_summary']['grand_total']}", 
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Frozen Invoice Print Preview')),
      body: PdfPreview(
        build: (format) => _generatePdf(format),
        allowSharing: true,
        allowPrinting: true,
      ),
    );
  }
}
