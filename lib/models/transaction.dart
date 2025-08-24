class Transaction {
  final int id;
  final double amount;
  final String transactionType;
  final String remark;
  final int categoryId;
  final int accountId;
  final int userId;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.amount,
    required this.transactionType,
    required this.remark,
    required this.categoryId,
    required this.accountId,
    required this.userId,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      transactionType: json['transaction_type'],
      remark: json['remark'] ?? '',
      categoryId: json['category_id'],
      accountId: json['account_id'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'transaction_type': transactionType,
      'remark': remark,
      'category_id': categoryId,
      'account_id': accountId,
      'user_id': userId,
    };
  }
}
