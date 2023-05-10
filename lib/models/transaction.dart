import 'dart:convert';

class Transaction {
  final String id;
  final String title;
  final double value;
  final DateTime date;

  Transaction({
    required this.id,
    required this.title,
    required this.value,
    required this.date,
  });

  // Converte um objeto Transaction para um Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'value': value,
      'date': date.toIso8601String(),
    };
  }

  // Converte um objeto Transaction para uma string JSON
  String toJson() => jsonEncode(toMap());

  // Cria um objeto Transaction a partir de um Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      value: map['value'],
      date: DateTime.parse(map['date']),
    );
  }

  // Cria um objeto Transaction a partir de uma string JSON
  factory Transaction.fromJson(String jsonString) =>
      Transaction.fromMap(jsonDecode(jsonString));


}
