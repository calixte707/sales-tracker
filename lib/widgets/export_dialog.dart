import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import '../l10n/app_localizations.dart';
import '../services/storage_service.dart';

class ExportDialog extends StatefulWidget {
  final String locale;
  const ExportDialog({super.key, required this.locale});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _loading = false;
  String? _error;

  AppLocalizations get l10n => AppLocalizations(widget.locale);

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF8B6F5E),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        _error = null;
      });
    }
  }

  Future<void> _export() async {
    final l = l10n;
    if (_endDate.isBefore(_startDate)) {
      setState(() => _error = l.rangeError);
      return;
    }

    setState(() { _loading = true; _error = null; });

    final records = await StorageService.instance.getRecordsInRange(_startDate, _endDate);

    if (records.isEmpty) {
      setState(() { _loading = false; _error = l.noDataExport; });
      return;
    }

    double total = 0.0;
    for (final r in records) { total += r.amount; }

    // Build CSV
    final buffer = StringBuffer();
    buffer.writeln('${l.salesDate},${l.salesAmount} (\u20ac),${l.salesNote}');

    for (final r in records) {
      final date = AppLocalizations.formatDateShort(r.date);
      final amount = r.amount == r.amount.truncateToDouble()
          ? r.amount.toInt().toString()
          : r.amount.toStringAsFixed(2);
      final note = (r.note ?? '').replaceAll('"', '""');
      buffer.writeln('$date,$amount,"$note"');
    }

    buffer.writeln('');
    buffer.writeln('${l.period},${AppLocalizations.formatDateShort(_startDate)} ~ ${AppLocalizations.formatDateShort(_endDate)}');
    final totalFmt = total == total.truncateToDouble() ? total.toInt().toString() : total.toStringAsFixed(2);
    buffer.writeln('${l.totalSales},\u20ac$totalFmt');

    // Download via web package
    final csvContent = buffer.toString();
    final bytes = utf8.encode(csvContent);
    final base64Str = base64Encode(bytes);
    final dataUrl = 'data:text/csv;charset=utf-8;base64,$base64Str';
    final fileName = 'sales_${AppLocalizations.formatDateShort(_startDate)}_${AppLocalizations.formatDateShort(_endDate)}.csv';

    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = dataUrl;
    anchor.download = fileName;
    web.document.body!.appendChild(anchor);
    anchor.click();
    web.document.body!.removeChild(anchor);

    setState(() => _loading = false);
    if (mounted) Navigator.pop(context);
  }

  String _fmtDate(DateTime d) => AppLocalizations.formatDate(d, widget.locale);

  @override
  Widget build(BuildContext context) {
    final l = l10n;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B6F5E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.download_outlined, color: Color(0xFF8B6F5E), size: 20),
              ),
              const SizedBox(width: 12),
              Text(l.exportReport,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.grey),
              ),
            ]),
            const SizedBox(height: 24),

            Text(l.startDate,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF8B6F5E), fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _DatePickerBtn(
              label: _fmtDate(_startDate),
              onTap: () => _pickDate(true),
            ),
            const SizedBox(height: 16),

            Text(l.endDate,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF8B6F5E), fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _DatePickerBtn(
              label: _fmtDate(_endDate),
              onTap: () => _pickDate(false),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_error!,
                    style: TextStyle(color: Colors.red[700], fontSize: 13)),
              ),
            ],

            const SizedBox(height: 24),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B6F5E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              onPressed: _loading ? null : _export,
              icon: _loading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.download, color: Colors.white),
              label: Text(l.export,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DatePickerBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5EFE8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD7BEA8)),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF8B6F5E)),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Color(0xFF5C4033), fontSize: 14)),
          const Spacer(),
          const Icon(Icons.edit_outlined, size: 14, color: Color(0xFFBCAAA4)),
        ]),
      ),
    );
  }
}
