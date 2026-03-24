import 'package:uuid/uuid.dart';

class SaleRecord {
  final String id;
  final DateTime date;
  final double amount;
  final String? note;
  final DateTime createdAt;

  SaleRecord({
    String? id,
    required this.date,
    required this.amount,
    this.note,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SaleRecord.fromJson(Map<String, dynamic> json) => SaleRecord(
        id: json['id'],
        date: DateTime.parse(json['date']),
        amount: (json['amount'] as num).toDouble(),
        note: json['note'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  SaleRecord copyWith({
    double? amount,
    String? note,
    DateTime? date,
  }) =>
      SaleRecord(
        id: id,
        date: date ?? this.date,
        amount: amount ?? this.amount,
        note: note ?? this.note,
        createdAt: createdAt,
      );
}
