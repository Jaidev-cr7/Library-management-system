import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';

class BorrowReturnScreen extends StatefulWidget {
  final bool returnMode;
  const BorrowReturnScreen({super.key, this.returnMode = false});

  @override
  State<BorrowReturnScreen> createState() => _BorrowReturnScreenState();
}

class _BorrowReturnScreenState extends State<BorrowReturnScreen> {
  final _copyId = TextEditingController();
  final _student = TextEditingController();
  DateTime? _due;

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<FirestoreService>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.returnMode ? 'Return Book' : 'Borrow Book', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          TextField(controller: _copyId, decoration: const InputDecoration(labelText: 'Copy ID')),
          if (!widget.returnMode) ...[
            const SizedBox(height: 8),
            TextField(controller: _student, decoration: const InputDecoration(labelText: 'Student Name')),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(context: context, initialDate: now, firstDate: now, lastDate: now.add(const Duration(days: 365)));
                    if (picked != null) setState(()=> _due = picked);
                  },
                  child: const Text('Pick Due Date'),
                ),
                const SizedBox(width: 12),
                if (_due != null) Text('${_due!.toLocal().toIso8601String().split("T").first}'),
              ],
            ),
          ],
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              final copyId = _copyId.text.trim();
              if (copyId.isEmpty) return;
              String? res;
              if (widget.returnMode) {
                res = await svc.returnByCopyId(copyId);
              } else {
                if (_student.text.trim().isEmpty || _due==null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter student and pick due date')));
                  return;
                }
                res = await svc.borrowByCopyId(copyId, _student.text.trim(), _due!);
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res ?? 'Success')));
            },
            child: Text(widget.returnMode ? 'Return' : 'Borrow'),
          )
        ],
      ),
    );
  }
}
