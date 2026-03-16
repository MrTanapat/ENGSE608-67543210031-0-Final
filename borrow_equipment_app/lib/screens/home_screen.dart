import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/borrow_provider.dart';
import 'list_screen.dart';
import 'add_edit_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<BorrowProvider>(context, listen: false).loadData();
    });
  }

  // 📊 Card สถิติ
  Widget buildStatCard(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 14)),
              Text(
                "$value",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<BorrowProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("📊 Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: "รายการทั้งหมด",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListScreen()),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 📊 STATS
            Row(
              children: [
                buildStatCard(
                  "Borrowed",
                  p.borrowed,
                  Icons.inventory,
                  Colors.orange,
                ),
                buildStatCard(
                  "Returned",
                  p.returned,
                  Icons.check_circle,
                  Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                buildStatCard("Overdue", p.overdue, Icons.warning, Colors.red),
                buildStatCard(
                  "Total",
                  p.list.length,
                  Icons.dashboard,
                  Colors.blue,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 📌 TITLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "รายการล่าสุด",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  child: const Text("ดูทั้งหมด"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ListScreen()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 📦 RECENT LIST
            Expanded(
              child: p.list.isEmpty
                  ? const Center(child: Text("ยังไม่มีข้อมูล"))
                  : ListView.builder(
                      itemCount: p.list.length > 5
                          ? 5
                          : p.list.length, // 5 ล่าสุด
                      itemBuilder: (_, i) {
                        final item = p.list[i];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
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
                            title: Text(item.itemName),
                            subtitle: Text(item.borrower),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailScreen(record: item),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ➕ ปุ่มยืม
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("ยืมอุปกรณ์"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditScreen()),
          );
        },
      ),
    );
  }
}
