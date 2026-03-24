import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/sale_record.dart';

class AddSaleDialog extends StatefulWidget {
  final String locale;
  final DateTime initialDate;

  const AddSaleDialog({super.key, required this.locale, required this.initialDate});

  @override
  State<AddSaleDialog> createState() => _AddSaleDialogState();
}

class _AddSaleDialogState extends State<AddSaleDialog> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _showNote = false;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  AppLocalizations get l10n => AppLocalizations(widget.locale);

  void _submit() {
    final l = l10n;
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.amountRequired), backgroundColor: Colors.red[400]),
      );
      return;
    }
    final record = SaleRecord(
      date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day,
          DateTime.now().hour, DateTime.now().minute),
      amount: amount,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    Navigator.pop(context, record);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = l10n;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B6F5E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_shopping_cart,
                        color: Color(0xFF8B6F5E), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(l.addSale,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date picker
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EFE8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD7BEA8)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 16, color: Color(0xFF8B6F5E)),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.formatDate(_selectedDate, widget.locale),
                        style: const TextStyle(color: Color(0xFF5C4033), fontSize: 14),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit_outlined, size: 14, color: Color(0xFFBCAAA4)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Amount input
              Text(l.amount,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF8B6F5E), fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                decoration: InputDecoration(
                  prefixText: '€ ',
                  prefixStyle: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B6F5E)),
                  hintText: '0.00',
                  hintStyle: TextStyle(color: Colors.grey[300], fontSize: 24),
                  filled: true,
                  fillColor: const Color(0xFFFAF7F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF8B6F5E), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Add note toggle
              if (!_showNote)
                TextButton.icon(
                  onPressed: () => setState(() => _showNote = true),
                  icon: const Icon(Icons.add_circle_outline,
                      color: Color(0xFF8B6F5E), size: 18),
                  label: Text(l.addNote,
                      style: const TextStyle(color: Color(0xFF8B6F5E), fontSize: 14)),
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.zero,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(l.note,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF8B6F5E), fontWeight: FontWeight.w600)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() { _showNote = false; _noteCtrl.clear(); });
                        },
                        child: const Icon(Icons.close, size: 18, color: Colors.grey),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: l.noteHint,
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFFAF7F4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF8B6F5E), width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B6F5E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                onPressed: _submit,
                child: Text(
                  l.save,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
