import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name'), validator: (v)=> (v==null||v.isEmpty)?'Required':null),
                TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), validator: (v)=> (v==null||v.isEmpty)?'Required':null),
                TextFormField(controller: _message, decoration: const InputDecoration(labelText: 'Message'), maxLines: 4, validator: (v)=> (v==null||v.isEmpty)?'Required':null),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    await FirebaseFirestore.instance.collection('contacts').add({
                      'name': _name.text.trim(),
                      'email': _email.text.trim(),
                      'message': _message.text.trim(),
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sent')));
                      _name.clear(); _email.clear(); _message.clear();
                    }
                  },
                  child: const Text('Send'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
