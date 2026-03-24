import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/sale_record.dart';
import '../services/storage_service.dart';
import '../widgets/add_sale_dialog.dart';
import '../widgets/export_dialog.dart';
import 'day_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  final String locale;
  final VoidCallback onToggleLocale;

  const CalendarScreen({
    super.key,
    required this.locale,
    required this.onToggleLocale,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool _selectingRange = false;
  Map<String, double> _dailyTotals = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadTotals();
  }

  @override
  void didUpdateWidget(CalendarScreen old) {
    super.didUpdateWidget(old);
    _loadTotals();
  }

  Future<void> _loadTotals() async {
    setState(() => _loading = true);
    final totals = await StorageService.instance.getDailyTotals(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    if (mounted) setState(() { _dailyTotals = totals; _loading = false; });
  }

  AppLocalizations get l10n => AppLocalizations(widget.locale);

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
    _loadTotals();
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
    _loadTotals();
  }

  Future<double> _getRangeTotalAllMonths() async {
    if (_rangeStart == null || _rangeEnd == null) return 0;
    final records = await StorageService.instance.getRecordsInRange(_rangeStart!, _rangeEnd!);
    double total = 0.0;
    for (final r in records) { total += r.amount; }
    return total;
  }

  void _onDayTap(DateTime day) async {
    if (_selectingRange) {
      if (_rangeStart == null) {
        setState(() => _rangeStart = day);
      } else if (_rangeEnd == null) {
        if (day.isBefore(_rangeStart!)) {
          setState(() { _rangeEnd = _rangeStart; _rangeStart = day; });
        } else {
          setState(() => _rangeEnd = day);
        }
        _selectingRange = false;
        final total = await _getRangeTotalAllMonths();
        if (mounted) {
          _showRangeTotalDialog(total);
        }
      }
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DayDetailScreen(
            date: day,
            locale: widget.locale,
          ),
        ),
      );
      if (result == true) _loadTotals();
    }
  }

  void _showRangeTotalDialog(double total) {
    final l = l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.calculate_outlined, color: Color(0xFF8B6F5E)),
          const SizedBox(width: 8),
          Text(l.periodTotal, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            '${AppLocalizations.formatDate(_rangeStart!, widget.locale)}  ${l.to}  ${AppLocalizations.formatDate(_rangeEnd!, widget.locale)}',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EFE8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '€${_fmtAmount(total)}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C4033),
              ),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () {
              setState(() { _rangeStart = null; _rangeEnd = null; });
              Navigator.pop(ctx);
            },
            child: Text(l.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B6F5E)),
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.confirm, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() async {
    final result = await showDialog<SaleRecord>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddSaleDialog(
        locale: widget.locale,
        initialDate: DateTime.now(),
      ),
    );
    if (result != null) {
      await StorageService.instance.saveRecord(result);
      _loadTotals();
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (_) => ExportDialog(locale: widget.locale),
    );
  }

  String _fmtAmount(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final l = l10n;
    final now = DateTime.now();
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F4),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Text(
                    l.appTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const Spacer(),
                  // Range select button
                  _buildIconBtn(
                    icon: _selectingRange ? Icons.close : Icons.date_range_outlined,
                    color: _selectingRange ? Colors.orange : const Color(0xFF8B6F5E),
                    onTap: () {
                      setState(() {
                        _selectingRange = !_selectingRange;
                        if (!_selectingRange) { _rangeStart = null; _rangeEnd = null; }
                      });
                    },
                    tooltip: l.selectPeriod,
                  ),
                  const SizedBox(width: 4),
                  // Export
                  _buildIconBtn(
                    icon: Icons.download_outlined,
                    color: const Color(0xFF8B6F5E),
                    onTap: _showExportDialog,
                    tooltip: l.exportReport,
                  ),
                  const SizedBox(width: 4),
                  // Language
                  GestureDetector(
                    onTap: widget.onToggleLocale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B6F5E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.language, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(l.langSwitch,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            // Range select hint
            if (_selectingRange)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF8F00).withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline, size: 16, color: Color(0xFFFF8F00)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _rangeStart == null
                          ? (widget.locale == 'zh' ? '請點選開始日期' : 'Tap start date')
                          : (widget.locale == 'zh' ? '請點選結束日期' : 'Tap end date'),
                      style: const TextStyle(fontSize: 13, color: Color(0xFFE65100)),
                    ),
                  ),
                  if (_rangeStart != null)
                    Text(
                      AppLocalizations.formatDate(_rangeStart!, widget.locale),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                    ),
                ]),
              ),

            // Range result bar
            if (_rangeStart != null && _rangeEnd != null && !_selectingRange)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B6F5E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppLocalizations.formatDate(_rangeStart!, widget.locale)} ${l.to} ${AppLocalizations.formatDate(_rangeEnd!, widget.locale)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                    GestureDetector(
                      onTap: () => setState(() { _rangeStart = null; _rangeEnd = null; }),
                      child: const Icon(Icons.close, size: 18, color: Color(0xFF8B6F5E)),
                    ),
                  ],
                ),
              ),

            // Month header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _prevMonth,
                    icon: const Icon(Icons.chevron_left, color: Color(0xFF5C4033)),
                  ),
                  Text(
                    l.monthYear(_focusedMonth.month, _focusedMonth.year),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.chevron_right, color: Color(0xFF5C4033)),
                  ),
                ],
              ),
            ),

            // Weekday headers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: l.weekdays
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(d,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: d == '日' || d == 'Sun' || d == '六' || d == 'Sat'
                                      ? const Color(0xFFBF8970)
                                      : const Color(0xFF8D6E63),
                                )),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 4),

            // Calendar grid
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B6F5E)))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: startWeekday + daysInMonth,
                        itemBuilder: (ctx, i) {
                          if (i < startWeekday) return const SizedBox();
                          final day = i - startWeekday + 1;
                          final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
                          final dateKey = AppLocalizations.formatDateShort(date);
                          final total = _dailyTotals[dateKey];
                          final isToday = date.year == now.year &&
                              date.month == now.month &&
                              date.day == now.day;
                          final isStart = _rangeStart != null &&
                              date.year == _rangeStart!.year &&
                              date.month == _rangeStart!.month &&
                              date.day == _rangeStart!.day;
                          final isEnd = _rangeEnd != null &&
                              date.year == _rangeEnd!.year &&
                              date.month == _rangeEnd!.month &&
                              date.day == _rangeEnd!.day;
                          final inRange = _rangeStart != null &&
                              _rangeEnd != null &&
                              !date.isBefore(_rangeStart!) &&
                              !date.isAfter(_rangeEnd!);

                          return GestureDetector(
                            onTap: () => _onDayTap(date),
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isStart || isEnd
                                    ? const Color(0xFF8B6F5E)
                                    : inRange
                                        ? const Color(0xFF8B6F5E).withValues(alpha: 0.12)
                                        : isToday
                                            ? const Color(0xFFF5EFE8)
                                            : null,
                                borderRadius: BorderRadius.circular(10),
                                border: isToday && !isStart && !isEnd
                                    ? Border.all(color: const Color(0xFF8B6F5E), width: 1.5)
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$day',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isToday || isStart || isEnd
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isStart || isEnd
                                          ? Colors.white
                                          : isToday
                                              ? const Color(0xFF5C4033)
                                              : const Color(0xFF3E2723),
                                    ),
                                  ),
                                  if (total != null && total > 0) ...[
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: isStart || isEnd
                                            ? Colors.white.withValues(alpha: 0.3)
                                            : const Color(0xFFD7A98C).withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '€${_fmtAmount(total)}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: isStart || isEnd
                                              ? Colors.white
                                              : const Color(0xFF5C4033),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),

            // Bottom total bar
            if (_dailyTotals.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B6F5E).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l.monthYear(_focusedMonth.month, _focusedMonth.year)} ${l.totalSales}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF5C4033)),
                    ),
                    Text(
                      '€${_fmtAmount(_dailyTotals.values.fold(0.0, (a, b) => a + b))}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF8B6F5E),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildIconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip ?? '',
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
