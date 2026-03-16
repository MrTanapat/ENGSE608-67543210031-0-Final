import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/borrow_record.dart';
import '../providers/borrow_provider.dart';

class AddEditScreen extends StatefulWidget {
  final BorrowRecord? record;

  const AddEditScreen({super.key, this.record});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final formKey = GlobalKey<FormState>();

  final itemCtrl = TextEditingController();
  final borrowerCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  DateTime? borrowDate;
  DateTime? returnDate;

  String status = "Borrowed";

  String formatDate(DateTime? date) {
    if (date == null) return "เลือกวันที่";
    return DateFormat("dd MMM yyyy").format(date);
  }

  Future pickDate(bool isBorrow) async {
    DateTime initial = isBorrow
        ? (borrowDate ?? DateTime.now())
        : (returnDate ?? DateTime.now());

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isBorrow) {
          borrowDate = picked;
        } else {
          returnDate = picked;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.record != null) {
      itemCtrl.text = widget.record!.itemName;
      borrowerCtrl.text = widget.record!.borrower;
      noteCtrl.text = widget.record!.note ?? "";

      borrowDate = DateTime.tryParse(widget.record!.borrowDate);
      returnDate = DateTime.tryParse(widget.record!.returnDate);

      status = widget.record!.status;
    }
  }

  @override
  void dispose() {
    itemCtrl.dispose();
    borrowerCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BorrowProvider>(); // ✅ FIX

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.record == null ? "📦 ยืมอุปกรณ์" : "✏️ แก้ไขข้อมูล"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: itemCtrl,
                        decoration: InputDecoration(
                          labelText: "ชื่ออุปกรณ์",
                          prefixIcon: const Icon(Icons.inventory_2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? "กรุณากรอกชื่ออุปกรณ์" : null,
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller: borrowerCtrl,
                        decoration: InputDecoration(
                          labelText: "ผู้ยืม",
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? "กรุณากรอกชื่อผู้ยืม" : null,
                      ),

                      const SizedBox(height: 20),

                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor: Colors.grey.shade100,
                        leading: const Icon(Icons.date_range),
                        title: const Text("วันที่ยืม"),
                        subtitle: Text(formatDate(borrowDate)),
                        trailing: const Icon(Icons.edit_calendar),
                        onTap: () => pickDate(true),
                      ),

                      const SizedBox(height: 10),

                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor: Colors.grey.shade100,
                        leading: const Icon(Icons.event),
                        title: const Text("วันที่คืน"),
                        subtitle: Text(formatDate(returnDate)),
                        trailing: const Icon(Icons.edit_calendar),
                        onTap: () => pickDate(false),
                      ),

                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        value: status,
                        decoration: InputDecoration(
                          labelText: "สถานะ",
                          prefixIcon: const Icon(Icons.info),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: ["Borrowed", "Returned"]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => status = v!),
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller: noteCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "หมายเหตุ",
                          prefixIcon: const Icon(Icons.note),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(
                  widget.record == null ? "บันทึกการยืม" : "อัปเดตข้อมูล",
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  if (borrowDate == null || returnDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("กรุณาเลือกวันที่")),
                    );
                    return;
                  }

                  final newRecord = BorrowRecord(
                    id: widget.record?.id,
                    itemName: itemCtrl.text,
                    borrower: borrowerCtrl.text,
                    borrowDate: borrowDate!.toIso8601String(),
                    returnDate: returnDate!.toIso8601String(),
                    status: status,
                    note: noteCtrl.text,
                  );

                  if (widget.record == null) {
                    await provider.add(newRecord);
                  } else {
                    await provider.update(newRecord);
                  }

                  if (!mounted) return; // ✅ กัน crash

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("บันทึกสำเร็จ ✅")),
                  );

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
