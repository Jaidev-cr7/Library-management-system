import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String? id;
  final String title;
  final String author;
  final String isbn;
  final String copyId;
  final String status;
  final String? coverUrl;
  final String? borrowerName;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.copyId,
    this.status = 'available',
    this.coverUrl,
    this.borrowerName,
  });

  factory Book.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: d['title'] ?? '',
      author: d['author'] ?? '',
      isbn: d['isbn'] ?? '',
      copyId: d['copyId'] ?? '',
      status: d['status'] ?? 'available',
      coverUrl: d['coverUrl'],
      borrowerName: d['borrowerName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'isbn': isbn,
      'copyId': copyId,
      'status': status,
      'coverUrl': coverUrl,
      'borrowerName': borrowerName,
    };
  }
}
