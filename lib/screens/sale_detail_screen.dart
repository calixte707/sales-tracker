import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/sale_record.dart';
import '../services/storage_service.dart';

class SaleDetailScreen extends StatefulWidget {
  final SaleRecord record;
  final String locale;
  final int groupNumber;

  const SaleDetailScreen({
    super.key,
    required this.record,
    required this.locale,
    required this.groupNumber,
  });

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  late SaleRecord _record;
  bool _editMode = false;
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  bool _showNote = false;

  @override
  void initState() {
    super.initState();
    _record = widget.record;
    _amountCtrl = TextEditingController(
        text: _record.amount == _record.amount.truncateToDouble()
            ? _record.amount.toInt().toString()
            : _record.amount.toStringAsFixed(2));
    _noteCtrl = TextEditingController(text: _record.note ?? '');
    _showNote = (_record.note != null && _record.note!.isNotEmpty);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  AppLocalizations get l10n => AppLocalizations(widget.locale);

  Future<void> _save() async {
    final l = l10n;
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.amountRequired), backgroundColor: Colors.red[400]),
      );
      return;
    }
    final updated = _record.copyWith(
      amount: amount,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    await StorageService.instance.updateRecord(updated);
    setState(() { _record = updated; _editMode = false; });
    if (mounted) {
      Navigator.pop(context, 'updated');
    }
  }

  Future<void> _delete() async {
    final l = l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l.deleteConfirm),
        content: Text(l.deleteConfirmMsg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await StorageService.instance.deleteRecord(_record.id);
      if (mounted) Navigator.pop(context, 'deleted');
    }
  }

  String _fmtAmount(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final l = l10n;
    final dateStr = AppLocalizations.formatDate(_record.date, widget.locale);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5C4033)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l.groupLabel(widget.groupNumber),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
        actions: [
          if (!_editMode)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF8B6F5E)),
              onPressed: () => setState(() => _editMode = true),
            ),
          if (!_editMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _delete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B6F5E).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: Color(0xFF8B6F5E)),
                  const SizedBox(width: 8),
                  Text(dateStr,
                      style: const TextStyle(color: Color(0xFF5C4033), fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Amount section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _editMode
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.amount,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF8B6F5E), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          autofocus: true,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                          decoration: InputDecoration(
                            prefixText: '€ ',
                            prefixStyle: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8B6F5E)),
                            hintText: '0.00',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF8B6F5E), width: 2),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Text(l.amount,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF8B6F5E))),
                        const SizedBox(height: 12),
                        Text(
                          '€${_fmtAmount(_record.amount)}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            // Note section
            if (_editMode) ...[
              if (!_showNote)
                TextButton.icon(
                  onPressed: () => setState(() => _showNote = true),
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF8B6F5E), size: 18),
                  label: Text(l.addNote,
                      style: const TextStyle(color: Color(0xFF8B6F5E), fontSize: 14)),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(l.note,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8B6F5E),
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() { _showNote = false; _noteCtrl.clear(); });
                            },
                            child: const Icon(Icons.close, size: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteCtrl,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: l.noteHint,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF8B6F5E), width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ] else if (_record.note != null && _record.note!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.notes_outlined, size: 16, color: Color(0xFF8B6F5E)),
                      const SizedBox(width: 8),
                      Text(l.note,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF8B6F5E), fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 10),
                    Text(
                      _record.note!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3E2723),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Action buttons (edit mode)
            if (_editMode)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF8B6F5E)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => setState(() => _editMode = false),
                      child: Text(l.cancel,
                          style: const TextStyle(color: Color(0xFF8B6F5E), fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B6F5E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _save,
                      child: Text(l.save,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),

            // Recorded at
            if (!_editMode) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${l.recordAt}: ${_record.createdAt.hour.toString().padLeft(2, '0')}:${_record.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
