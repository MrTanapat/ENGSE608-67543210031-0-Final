import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/borrow_record.dart';
import '../providers/borrow_provider.dart';
import 'add_edit_screen.dart';

class DetailScreen extends StatelessWidget {
  final BorrowRecord record;
  const DetailScreen({super.key, required this.record});

  Widget row(String t, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text("$t: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<BorrowProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Detail")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                row("Item", record.itemName),
                row("Borrower", record.borrower),
                row("Status", record.status),
                row("Note", record.note ?? "-"),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditScreen(record: record),
                          ),
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text("Delete"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        p.delete(record.id!);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
