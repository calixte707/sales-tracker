import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/sale_record.dart';
import '../services/storage_service.dart';
import '../widgets/add_sale_dialog.dart';
import 'sale_detail_screen.dart';

class DayDetailScreen extends StatefulWidget {
  final DateTime date;
  final String locale;

  const DayDetailScreen({super.key, required this.date, required this.locale});

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  List<SaleRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final records = await StorageService.instance.getRecordsForDate(widget.date);
    if (mounted) setState(() { _records = records; _loading = false; });
  }

  AppLocalizations get l10n => AppLocalizations(widget.locale);

  double get _dayTotal => _records.fold(0.0, (s, r) => s + r.amount);

  String _fmtAmount(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  void _showAddDialog() async {
    final result = await showDialog<SaleRecord>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddSaleDialog(
        locale: widget.locale,
        initialDate: widget.date,
      ),
    );
    if (result != null) {
      await StorageService.instance.saveRecord(result);
      _load();
    }
  }



  @override
  Widget build(BuildContext context) {
    final l = l10n;
    final dateStr = AppLocalizations.formatDate(widget.date, widget.locale);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5C4033)),
          onPressed: () => Navigator.pop(context, _records.isNotEmpty),
        ),
        title: Text(
          dateStr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF8B6F5E)),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B6F5E)))
          : Column(
              children: [
                // Day total card
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B6F5E), Color(0xFFA0836E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B6F5E).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.totalSales,
                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            '€${_fmtAmount(_dayTotal)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(l.dailySales,
                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            '${_records.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Records list
                Expanded(
                  child: _records.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(l.noRecordsForDay,
                                  style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B6F5E),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                onPressed: _showAddDialog,
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: Text(l.addSale,
                                    style: const TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _records.length,
                          itemBuilder: (ctx, i) {
                            final record = _records[i];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SaleDetailScreen(
                                      record: record,
                                      locale: widget.locale,
                                      groupNumber: i + 1,
                                    ),
                                  ),
                                ).then((result) { if (result != null) _load(); });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5EFE8),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${i + 1}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF5C4033),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l.groupLabel(i + 1),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: Color(0xFF3E2723),
                                            ),
                                          ),
                                          if (record.note != null && record.note!.isNotEmpty)
                                            const SizedBox(height: 2),
                                          if (record.note != null && record.note!.isNotEmpty)
                                            Text(
                                              '•••',
                                              style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '€${_fmtAmount(record.amount)}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF5C4033),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right,
                                        color: Color(0xFFBCAAA4), size: 20),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: _records.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddDialog,
              backgroundColor: const Color(0xFF8B6F5E),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
