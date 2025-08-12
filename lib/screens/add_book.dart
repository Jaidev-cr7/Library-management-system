import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _isbn = TextEditingController();
  String? _localImagePath;

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<FirestoreService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => (v==null||v.isEmpty)?'Required':null),
              TextFormField(controller: _author, decoration: const InputDecoration(labelText: 'Author'), validator: (v) => (v==null||v.isEmpty)?'Required':null),
              TextFormField(controller: _isbn, decoration: const InputDecoration(labelText: 'ISBN'), validator: (v) => (v==null||v.isEmpty)?'Required':null),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final res = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                      );
                      if (res != null && res.files.single.path != null) {
                        setState(() {
                          _localImagePath = res.files.single.path;
                        });
                      }
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose Cover'),
                  ),
                  const SizedBox(width: 12),
                  if (_localImagePath != null) Expanded(child: Text(_localImagePath!, overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  // create a unique copyId
                  final copyId = 'C-${DateTime.now().millisecondsSinceEpoch}';
                  final book = Book(title: _title.text, author: _author.text, isbn: _isbn.text, copyId: copyId);
                  await svc.addBookCopy(book, localImagePath: _localImagePath);
                  if (mounted) Navigator.of(context).pop();
                },
                child: const Text('Add'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
