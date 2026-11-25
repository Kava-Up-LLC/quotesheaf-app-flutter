import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../utils/formatters.dart';
import '../utils/money.dart';

part 'pdf_service.g.dart';

/// Everything printed on the quote PDF (PRD §5.5.2), already resolved.
class PdfQuote {
  const PdfQuote({
    required this.businessName,
    required this.tradeLabel,
    required this.businessPhone,
    required this.businessEmail,
    required this.businessAddress,
    required this.licenseNo,
    required this.approvalNote,
    this.footerTitle,
    this.footerNote,
    this.paymentColumns = const [],
    required this.logo,
    required this.number,
    required this.issueDate,
    required this.validUntil,
    required this.validDays,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    required this.customerEmail,
    required this.lines,
    required this.subtotal,
    required this.taxLabel,
    required this.taxAmount,
    required this.total,
  });

  final String businessName;
  final String? tradeLabel;
  final String? businessPhone;
  final String? businessEmail;
  final String? businessAddress;
  final String? licenseNo;
  final String? approvalNote;

  /// "How to pay" block; when [paymentColumns] is empty the footer falls back to [approvalNote].
  final String? footerTitle;
  final String? footerNote;
  final List<({String label, String value})> paymentColumns;
  final Uint8List? logo;
  final String number;
  final DateTime issueDate;
  final DateTime validUntil;
  final int validDays;
  final String customerName;
  final String? customerAddress;
  final String? customerPhone;
  final String? customerEmail;
  final List<PdfLine> lines;
  final int subtotal;
  final String taxLabel;
  final int taxAmount;
  final int total;
}

class PdfLine {
  const PdfLine({
    required this.name,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.amount,
  });

  final String name;
  final String? description;
  final num quantity;
  final String? unit;
  final int unitPrice;
  final int amount;
}

/// Builds the quote PDF on device (PRD §5.5.1) — Letter, Poppins, zinc greys.
class PdfService {
  static const _ink = PdfColor.fromInt(0xFF18181B);
  static const _muted = PdfColor.fromInt(0xFF71717A);
  static const _rule = PdfColor.fromInt(0xFFE4E4E7);

  pw.ThemeData? _theme;
  late pw.Font _light, _regular, _medium, _bold;

  Future<void> _loadFonts() async {
    if (_theme != null) return;
    Future<pw.Font> load(String name) async =>
        pw.Font.ttf(await rootBundle.load('assets/fonts/Poppins-$name.ttf'));
    _light = await load('Light');
    _regular = await load('Regular');
    _medium = await load('Medium');
    _bold = await load('Bold');
    _theme = pw.ThemeData.withFont(base: _regular, bold: _bold);
  }

  static String fileName(String businessName, String number) {
    final safe = businessName.replaceAll(RegExp(r"[^A-Za-z0-9]+"), '_').replaceAll(RegExp(r'^_|_$'), '');
    return '${safe}_Quote_$number.pdf';
  }

  Future<Uint8List> build(PdfQuote q) async {
    await _loadFonts();
    final doc = pw.Document(title: 'Quote ${q.number}', author: q.businessName, theme: _theme);
    final logo = q.logo == null ? null : pw.MemoryImage(q.logo!);

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.fromLTRB(54, 48, 54, 40),
      header: (ctx) => ctx.pageNumber == 1 ? _header(q, logo) : pw.SizedBox(),
      footer: (ctx) => _footer(q, ctx),
      build: (ctx) => [
        _billTo(q),
        pw.SizedBox(height: 18),
        _items(q),
        pw.SizedBox(height: 14),
        _totals(q),
      ],
    ));
    return doc.save();
  }

  /// Writes the PDF to the app temp folder and returns the file.
  Future<File> saveToTemp(Uint8List bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  pw.TextStyle _t(pw.Font f, double size, {PdfColor color = _ink, double spacing = 0}) =>
      pw.TextStyle(font: f, fontSize: size, color: color, letterSpacing: spacing);

  pw.Widget _header(PdfQuote q, pw.ImageProvider? logo) {
    final contact = [q.businessPhone, q.businessEmail].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    return pw.Column(children: [
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        if (logo != null) ...[
          pw.SizedBox(width: 50, height: 50, child: pw.Image(logo, fit: pw.BoxFit.contain)),
          pw.SizedBox(width: 12),
        ],
        pw.Expanded(
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(q.businessName, style: _t(_bold, 13)),
            if ((q.tradeLabel ?? '').isNotEmpty) ...[
              pw.SizedBox(height: 2),
              pw.Text(q.tradeLabel!, style: _t(_regular, 8, color: _muted)),
            ],
            if (contact.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(contact, style: _t(_regular, 8, color: _muted)),
            ],
          ]),
        ),
        pw.SizedBox(width: 16),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Text('Quote', style: _t(_light, 28)),
          pw.Text('#${q.number}', style: _t(_medium, 11)),
          pw.SizedBox(height: 6),
          pw.Text('Issued ${Fmt.longDate(q.issueDate)}', style: _t(_regular, 7.8, color: _muted)),
          pw.Text('Valid for ${q.validDays} day${q.validDays == 1 ? '' : 's'} · until ${Fmt.longDate(q.validUntil)}',
              style: _t(_regular, 7.8)),
        ]),
      ]),
      pw.SizedBox(height: 14),
      pw.Divider(thickness: 1, color: _ink, height: 1),
      pw.SizedBox(height: 16),
    ]);
  }

  pw.Widget _billTo(PdfQuote q) {
    final contact = [q.customerPhone, q.customerEmail].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    return pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.SizedBox(width: 64, child: pw.Text('BILL TO', style: _t(_medium, 7, color: _muted, spacing: 1.2))),
      pw.Expanded(
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(q.customerName, style: _t(_medium, 9)),
          if ((q.customerAddress ?? '').isNotEmpty) pw.Text(q.customerAddress!, style: _t(_regular, 8, color: _muted)),
          if (contact.isNotEmpty) pw.Text(contact, style: _t(_regular, 8, color: _muted)),
        ]),
      ),
    ]);
  }

  pw.Widget _items(PdfQuote q) {
    pw.Widget head(String s, {bool right = false}) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Text(s, style: _t(_medium, 7, color: _muted, spacing: 1.2), textAlign: right ? pw.TextAlign.right : null),
        );
    pw.Widget cell(pw.Widget child) => pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 7), child: child);
    const border = pw.BorderSide(color: _rule, width: 0.75);

    return pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(5),
        1: pw.FlexColumnWidth(1.2),
        2: pw.FlexColumnWidth(1.4),
        3: pw.FlexColumnWidth(1.4),
      },
      children: [
        pw.TableRow(
          repeat: true,
          decoration: const pw.BoxDecoration(border: pw.Border(bottom: border)),
          children: [head('SERVICE'), head('QTY'), head('PRICE', right: true), head('AMOUNT', right: true)],
        ),
        for (final l in q.lines)
          pw.TableRow(
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: border)),
            children: [
              cell(pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text(l.name, style: _t(_medium, 8.5)),
                if ((l.description ?? '').isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 2),
                    child: pw.Text(l.description!, style: _t(_regular, 7.5, color: _muted)),
                  ),
              ])),
              cell(pw.Text('${Money.formatQty(l.quantity)} ${l.unit ?? ''}'.trim(), style: _t(_regular, 8.5))),
              cell(pw.Text(Money.format(l.unitPrice), style: _t(_regular, 8.5), textAlign: pw.TextAlign.right)),
              cell(pw.Text(Money.format(l.amount), style: _t(_regular, 8.5), textAlign: pw.TextAlign.right)),
            ],
          ),
      ],
    );
  }

  pw.Widget _totals(PdfQuote q) {
    pw.Widget row(String label, String value) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text(label, style: _t(_regular, 8.5, color: _muted)),
            pw.Text(value, style: _t(_regular, 8.5)),
          ]),
        );
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.SizedBox(
        width: 3 * PdfPageFormat.inch,
        child: pw.Column(children: [
          row('Subtotal', Money.format(q.subtotal)),
          row(q.taxLabel, Money.format(q.taxAmount)),
          pw.SizedBox(height: 6),
          pw.Container(
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: _ink, width: 1.2))),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('Estimated total', style: _t(_regular, 8.5)),
                pw.Text(Money.format(q.total), style: _t(_bold, 20)),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  pw.Widget _footer(PdfQuote q, pw.Context ctx) {
    final legal = [q.businessAddress, q.licenseNo].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    final isLast = ctx.pageNumber == ctx.pagesCount;
    final label = _t(_medium, 7, color: _muted, spacing: 1.2);
    final pay = q.paymentColumns.isNotEmpty || (q.footerTitle ?? '').isNotEmpty;

    pw.Widget column(String title, String body, {bool muted = false}) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title.toUpperCase(), style: label),
            pw.SizedBox(height: 5),
            pw.Text(body, style: _t(_regular, 8.5, color: muted ? _muted : _ink)),
          ],
        );

    final lastPageBlock = !isLast
        ? null
        : pay
            ? pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Expanded(flex: 5, child: column(q.footerTitle ?? '', q.footerNote ?? '', muted: true)),
                for (final m in q.paymentColumns) ...[
                  pw.SizedBox(width: 14),
                  pw.Expanded(flex: 5, child: column(m.label, m.value)),
                ],
              ])
            : (q.approvalNote ?? '').isNotEmpty
                ? pw.Row(children: [
                    pw.SizedBox(width: 84, child: pw.Text('HOW TO APPROVE', style: label)),
                    pw.Expanded(child: pw.Text(q.approvalNote!, style: _t(_medium, 8))),
                  ])
                : null;

    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      if (lastPageBlock != null) ...[
        pw.Divider(thickness: 1, color: _ink, height: 1),
        pw.SizedBox(height: 12),
        lastPageBlock,
        pw.SizedBox(height: 12),
      ],
      pw.Container(
        padding: const pw.EdgeInsets.only(top: 8),
        decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: _rule, width: 0.75))),
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Expanded(child: pw.Text(legal, style: _t(_regular, 7, color: _muted))),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}', style: _t(_regular, 7, color: _muted)),
        ]),
      ),
    ]);
  }
}

@Riverpod(keepAlive: true)
PdfService pdfService(Ref ref) => PdfService();
