class AppLocalizations {
  final String locale;
  AppLocalizations(this.locale);

  bool get isZh => locale == 'zh';

  String get appTitle => isZh ? '銷售記錄小助手' : 'Sales Tracker';
  String get calendar => isZh ? '日曆' : 'Calendar';
  String get addSale => isZh ? '添加銷售' : 'Add Sale';
  String get exportReport => isZh ? '匯出報告' : 'Export Report';
  String get amount => isZh ? '銷售金額 (€)' : 'Amount (€)';
  String get amountHint => isZh ? '請輸入金額' : 'Enter amount';
  String get addNote => isZh ? '＋ 添加備註' : '＋ Add Note';
  String get note => isZh ? '備註' : 'Note';
  String get noteHint => isZh ? '輸入備註內容...' : 'Enter notes...';
  String get save => isZh ? '儲存' : 'Save';
  String get cancel => isZh ? '取消' : 'Cancel';
  String get delete => isZh ? '刪除' : 'Delete';
  String get edit => isZh ? '修改' : 'Edit';
  String get confirm => isZh ? '確認' : 'Confirm';
  String get salesDetail => isZh ? '銷售詳情' : 'Sale Detail';
  String get dailySales => isZh ? '當日銷售記錄' : 'Daily Sales';
  String get noRecords => isZh ? '暫無記錄' : 'No records yet';
  String get noRecordsForDay => isZh ? '當天沒有銷售記錄' : 'No sales for this day';
  String get totalSales => isZh ? '總銷售額' : 'Total Sales';
  String get selectDateRange => isZh ? '選擇日期範圍' : 'Select Date Range';
  String get startDate => isZh ? '開始日期' : 'Start Date';
  String get endDate => isZh ? '結束日期' : 'End Date';
  String get export => isZh ? '匯出 CSV' : 'Export CSV';
  String get deleteConfirm => isZh ? '確定刪除這筆記錄？' : 'Delete this record?';
  String get deleteConfirmMsg => isZh ? '此操作無法復原。' : 'This action cannot be undone.';
  String get saleRecord => isZh ? '銷售記錄' : 'Sale Record';
  String get group => isZh ? '第' : 'Group';
  String get groupSuffix => isZh ? '團' : '';
  String get amountRequired => isZh ? '請輸入有效金額' : 'Please enter a valid amount';
  String get today => isZh ? '今天' : 'Today';
  String get periodTotal => isZh ? '時間段總計' : 'Period Total';
  String get selectPeriod => isZh ? '選擇時間段' : 'Select Period';
  String get exportSuccess => isZh ? '匯出成功' : 'Export Success';
  String get exportFailed => isZh ? '匯出失敗' : 'Export Failed';
  String get rangeError => isZh ? '結束日期不能早於開始日期' : 'End date cannot be before start date';
  String get noDataExport => isZh ? '所選時間段沒有數據' : 'No data in selected period';
  String get salesDate => isZh ? '日期' : 'Date';
  String get salesAmount => isZh ? '銷售金額' : 'Amount';
  String get salesNote => isZh ? '備註' : 'Note';
  String get period => isZh ? '時間段' : 'Period';
  String get langSwitch => isZh ? 'EN' : '中';
  String get to => isZh ? '至' : 'to';
  String get recordAt => isZh ? '記錄於' : 'Recorded at';
  String get editSale => isZh ? '修改銷售記錄' : 'Edit Sale Record';
  String get back => isZh ? '返回' : 'Back';

  String dayTotal(double amount) => isZh
      ? '€${_fmt(amount)}'
      : '€${_fmt(amount)}';

  String groupLabel(int n) => isZh ? '第 $n 團' : 'Group $n';

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  static String formatDate(DateTime d, String locale) {
    final isZh = locale == 'zh';
    if (isZh) {
      return '${d.year}年${d.month.toString().padLeft(2, '0')}月${d.day.toString().padLeft(2, '0')}日';
    }
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  static String formatDateShort(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static const List<String> weekdaysZh = ['日', '一', '二', '三', '四', '五', '六'];
  static const List<String> weekdaysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  List<String> get weekdays => isZh ? weekdaysZh : weekdaysEn;

  static const List<String> monthsZh = ['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月'];
  static const List<String> monthsEn = ['January','February','March','April','May','June','July','August','September','October','November','December'];
  List<String> get months => isZh ? monthsZh : monthsEn;

  String monthYear(int month, int year) => isZh ? '$year年 ${monthsZh[month - 1]}' : '${monthsEn[month - 1]} $year';
}
