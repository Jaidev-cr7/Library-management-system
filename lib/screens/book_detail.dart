// book_detail.dart
import 'package:flutter/material.dart';

class BookDetail extends StatelessWidget {
  final String title;
  final String author;

  BookDetail({required this.title, required this.author});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: $title', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Author: $author', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
