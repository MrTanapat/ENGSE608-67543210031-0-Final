import 'package:flutter/material.dart';
import '../models/borrow_record.dart';
import '../services/db_helper.dart';

class BorrowProvider extends ChangeNotifier {
  List<BorrowRecord> _list = [];

  String _search = "";
  String _statusFilter = "All";

  bool _isLoading = false;
  String _message = "";

  // =========================
  // 📦 GETTER
  // =========================

  List<BorrowRecord> get list {
    List<BorrowRecord> result = List.from(_list);

    if (_search.isNotEmpty) {
      result = result.where((e) {
        return e.itemName.toLowerCase().contains(_search.toLowerCase()) ||
            e.borrower.toLowerCase().contains(_search.toLowerCase());
      }).toList();
    }

    if (_statusFilter != "All") {
      result = result.where((e) {
        return e.status.trim().toLowerCase() ==
            _statusFilter.trim().toLowerCase();
      }).toList();
    }

    return result;
  }

  bool get isLoading => _isLoading;
  String get message => _message;

  // =========================
  // 🔧 CORE FUNCTION
  // =========================

  Future<void> loadData() async {
    _setLoading(true);

    final data = await DBHelper.instance.getAll();
    _list = data.map((e) => BorrowRecord.fromMap(e)).toList();

    // 🔥 sort ล่าสุดขึ้นก่อน
    _list.sort((a, b) => b.borrowDate.compareTo(a.borrowDate));

    _setLoading(false);
  }

  Future<void> add(BorrowRecord record) async {
    await DBHelper.instance.insert(record.toMap());
    _setMessage("✅ เพิ่มข้อมูลสำเร็จ");
    await loadData();
  }

  Future<void> update(BorrowRecord record) async {
    await DBHelper.instance.update(record.toMap());
    _setMessage("✏️ แก้ไขข้อมูลสำเร็จ");
    await loadData();
  }

  Future<void> delete(int id) async {
    await DBHelper.instance.delete(id);
    _setMessage("🗑 ลบข้อมูลแล้ว");
    await loadData();
  }

  // =========================
  // 🔍 FILTER
  // =========================

  void setSearch(String val) {
    _search = val;
    notifyListeners();
  }

  void setStatus(String val) {
    _statusFilter = val;
    notifyListeners();
  }

  // =========================
  // 📊 DASHBOARD
  // =========================

  int get borrowed => _list.where((e) => e.status == "Borrowed").length;

  int get returned => _list.where((e) => e.status == "Returned").length;

  int get overdue => _list.where((e) {
    if (e.status == "Returned") return false;

    try {
      return DateTime.parse(e.returnDate).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }).length;

  int get total => _list.length;

  // =========================
  // ⚙️ PRIVATE
  // =========================

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setMessage(String msg) {
    _message = msg;
    notifyListeners();
  }

  void clearMessage() {
    _message = "";
  }
}
