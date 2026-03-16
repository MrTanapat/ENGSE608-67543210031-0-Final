import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/borrow_provider.dart';
import 'detail_screen.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<BorrowProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("รายการทั้งหมด"), centerTitle: true),
      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "ค้นหาอุปกรณ์ / ผู้ยืม",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => p.setSearch(v),
            ),
          ),

          // 🎯 FILTER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButtonFormField(
              value: "All",
              decoration: InputDecoration(
                labelText: "Filter Status",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                "All",
                "Borrowed",
                "Returned",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => p.setStatus(v!),
            ),
          ),

          const SizedBox(height: 10),

          // 📦 LIST
          Expanded(
            child: p.list.isEmpty
                ? const Center(
                    child: Text("ไม่มีข้อมูล", style: TextStyle(fontSize: 18)),
                  )
                : ListView.builder(
                    itemCount: p.list.length,
                    itemBuilder: (_, i) {
                      final item = p.list[i];

                      return Dismissible(
                        key: ValueKey(item.id),

                        // 🟥 Background
                        background: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),

                        // ❗ CONFIRM DELETE
                        confirmDismiss: (_) async {
                          return await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("ยืนยันการลบ"),
                              content: Text(
                                "ต้องการลบ '${item.itemName}' ใช่หรือไม่?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("ยกเลิก"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("ลบ"),
                                ),
                              ],
                            ),
                          );
                        },

                        onDismissed: (_) {
                          p.delete(item.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("ลบแล้ว")),
                          );
                        },

                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: ListTile(
                            title: Text(
                              item.itemName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(item.borrower),

                            // 🎯 STATUS BADGE
                            leading: CircleAvatar(
                              backgroundColor: item.status == "Returned"
                                  ? Colors.green
                                  : Colors.orange,
                              child: Icon(
                                item.status == "Returned"
                                    ? Icons.check
                                    : Icons.access_time,
                                color: Colors.white,
                              ),
                            ),

                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailScreen(record: item),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
