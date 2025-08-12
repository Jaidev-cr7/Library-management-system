import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/book.dart';
import 'borrow_return_book.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final svc = Provider.of<FirestoreService>(context, listen: false);
      svc.preloadTenBooksIfEmpty();
    });
  }

  int _getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<FirestoreService>(context, listen: false);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF9013FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📚 Dashboard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              /// Live counts update
              StreamBuilder<Map<String, int>>(
                stream: svc.streamCounts(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final counts = snap.data!;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _StatCard('Total', counts['total'] ?? 0,
                          color: const Color.fromARGB(255, 255, 255, 91)),
                      _StatCard('Available', counts['available'] ?? 0,
                          color: Colors.greenAccent),
                      _StatCard('Borrowed', counts['borrowed'] ?? 0,
                          color: Colors.orangeAccent),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              /// Books grid
              Expanded(
                child: StreamBuilder<List<Book>>(
                  stream: svc.streamAllBooks(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final books = snap.data!;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _getCrossAxisCount(context),
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, idx) {
                        final b = books[idx];
                        final String imageUrl = (b.coverUrl != null &&
                                b.coverUrl!.trim().isNotEmpty)
                            ? b.coverUrl!
                            : 'https://i.ibb.co/4ZSNYGJ5/book-covers-big-2019101610.jpg';

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BorrowReturnBookScreen(book: b),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white.withOpacity(0.9),
                            elevation: 6,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                    child: Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        b.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      Text(
                                        b.author,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Copy ID: ${b.copyId}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'Status: ${b.status}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: b.status == 'available'
                                              ? Colors.green
                                              : Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;
  const _StatCard(this.title, this.value, {super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.9), fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
