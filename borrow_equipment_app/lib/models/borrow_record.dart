class BorrowRecord {
  int? id;
  String itemName;
  String borrower;
  String borrowDate;
  String returnDate;
  String status;
  String? note;

  BorrowRecord({
    this.id,
    required this.itemName,
    required this.borrower,
    required this.borrowDate,
    required this.returnDate,
    required this.status,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'borrower': borrower,
      'borrowDate': borrowDate,
      'returnDate': returnDate,
      'status': status,
      'note': note,
    };
  }

  factory BorrowRecord.fromMap(Map<String, dynamic> map) {
    return BorrowRecord(
      id: map['id'],
      itemName: map['itemName'],
      borrower: map['borrower'],
      borrowDate: map['borrowDate'],
      returnDate: map['returnDate'],
      status: map['status'],
      note: map['note'],
    );
  }
}
