import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';

class BorrowReturnBookScreen extends StatefulWidget {
  final Book book;
  const BorrowReturnBookScreen({super.key, required this.book});

  @override
  State<BorrowReturnBookScreen> createState() => _BorrowReturnBookScreenState();
}

class _BorrowReturnBookScreenState extends State<BorrowReturnBookScreen> {
  final _nameController = TextEditingController();
  DateTime? _dueDate;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<FirestoreService>(context, listen: false);
    final isAvailable = widget.book.status.toLowerCase() == 'available';

    return Scaffold(
      appBar: AppBar(
        title:
            Text('${widget.book.title} (${isAvailable ? "Borrow" : "Return"})'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.book.coverUrl != null)
              Center(
                child: Image.network(widget.book.coverUrl!, height: 200),
              ),
            const SizedBox(height: 16),
            Text('Title: ${widget.book.title}',
                style: Theme.of(context).textTheme.titleMedium),
            Text('Author: ${widget.book.author}'),
            Text('Copy ID: ${widget.book.copyId}'),
            Text('Status: ${widget.book.status}'),
            const Divider(height: 32),
            if (isAvailable) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _dueDate = picked);
                  }
                },
                child: Text(
                  _dueDate == null
                      ? 'Select Due Date'
                      : 'Due: ${_dueDate!.toLocal()}'.split(' ')[0],
                ),
              ),
            ],
            const Spacer(),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: () async {
                      setState(() => _loading = true);

                      String? error;
                      if (isAvailable) {
                        if (_nameController.text.isEmpty || _dueDate == null) {
                          error = 'Please fill in all fields';
                        } else {
                          error = await svc.borrowByCopyId(
                            widget.book.copyId,
                            _nameController.text,
                            _dueDate!,
                          );
                        }
                      } else {
                        error = await svc.returnByCopyId(widget.book.copyId);
                      }

                      setState(() => _loading = false);

                      if (error != null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(error)));
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(isAvailable
                        ? Icons.shopping_cart
                        : Icons.keyboard_return),
                    label: Text(isAvailable ? 'Borrow Book' : 'Return Book'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
