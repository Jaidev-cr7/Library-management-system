import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/book.dart';
import 'borrow_return_book.dart'; // new screen we'll use

class BooksListScreen extends StatelessWidget {
  const BooksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<FirestoreService>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Books', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<Book>>(
              stream: svc.streamAllBooks(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final books = snap.data!;
                return ListView.separated(
                  itemCount: books.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, idx) {
                    final b = books[idx];
                    return ListTile(
                      leading: b.coverUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                b.coverUrl!,
                                width: 48,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.book, size: 40),
                      title: Text(b.title),
                      subtitle: Text('${b.author} • ${b.copyId}'),
                      trailing: Text(b.status),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BorrowReturnBookScreen(book: b),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
