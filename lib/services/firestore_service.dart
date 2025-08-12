import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';
import '../models/book.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final String booksCol = 'books';
  final String txCol = 'transactions';

  Future<void> addBookCopy(Book book, {String? localImagePath}) async {
    final data = book.toMap();
    if (localImagePath != null) {
      final url = await _uploadCover(localImagePath, book.copyId);
      data['coverUrl'] = url;
    }
    await _db.collection(booksCol).add(data);
  }

  Stream<List<Book>> streamAllBooks() {
    return _db
        .collection(booksCol)
        .orderBy('title')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Book.fromDoc(d)).toList());
  }

  Future<Map<String, int>> getCounts() async {
    final totalSnap = await _db.collection(booksCol).get();
    final availableSnap = await _db
        .collection(booksCol)
        .where('status', isEqualTo: 'available')
        .get();
    final borrowedSnap = await _db
        .collection(booksCol)
        .where('status', isEqualTo: 'borrowed')
        .get();
    return {
      'total': totalSnap.size,
      'available': availableSnap.size,
      'borrowed': borrowedSnap.size,
    };
  }

  /// ✅ Live stream counts for dashboard
  Stream<Map<String, int>> streamCounts() {
    final totalStream = _db.collection(booksCol).snapshots();
    final availableStream = _db
        .collection(booksCol)
        .where('status', isEqualTo: 'available')
        .snapshots();
    final borrowedStream = _db
        .collection(booksCol)
        .where('status', isEqualTo: 'borrowed')
        .snapshots();

    return Rx.combineLatest3<QuerySnapshot, QuerySnapshot, QuerySnapshot,
        Map<String, int>>(
      totalStream,
      availableStream,
      borrowedStream,
      (totalSnap, availSnap, borrowSnap) => {
        'total': totalSnap.size,
        'available': availSnap.size,
        'borrowed': borrowSnap.size,
      },
    );
  }

  Future<String?> borrowByCopyId(
      String copyId, String studentName, DateTime dueDate) async {
    final q = await _db
        .collection(booksCol)
        .where('copyId', isEqualTo: copyId)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return 'Book copy not found';
    final doc = q.docs.first;
    final data = doc.data();
    if (data['status'] == 'borrowed') return 'Book already borrowed';
    await doc.reference.update({
      'status': 'borrowed',
      'borrowerName': studentName,
      'borrowDate': Timestamp.fromDate(DateTime.now()),
      'dueDate': Timestamp.fromDate(dueDate),
    });
    await _db.collection(txCol).add({
      'copyId': copyId,
      'isbn': data['isbn'],
      'studentName': studentName,
      'borrowDate': Timestamp.fromDate(DateTime.now()),
      'status': 'borrowed',
    });
    return null;
  }

  Future<String?> returnByCopyId(String copyId) async {
    final q = await _db
        .collection(booksCol)
        .where('copyId', isEqualTo: copyId)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return 'Book copy not found';
    final doc = q.docs.first;
    final data = doc.data();
    if (data['status'] == 'available') return 'Book is already available';
    await doc.reference.update({
      'status': 'available',
      'borrowerName': null,
      'borrowDate': null,
      'dueDate': null,
    });
    await _db.collection(txCol).add({
      'copyId': copyId,
      'isbn': data['isbn'],
      'studentName': data['borrowerName'],
      'returnDate': Timestamp.fromDate(DateTime.now()),
      'status': 'returned',
    });
    return null;
  }

  Future<Book?> findByCopyId(String copyId) async {
    final q = await _db
        .collection(booksCol)
        .where('copyId', isEqualTo: copyId)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return Book.fromDoc(q.docs.first);
  }

  /// ✅ Preload with 10 real books if empty
  Future<void> preloadTenBooksIfEmpty() async {
    final snap = await _db.collection(booksCol).limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final realBooks = [
      {
        "title": "To Kill a Mockingbird",
        "author": "Harper Lee",
        "isbn": "9780061120084"
      },
      {"title": "1984", "author": "George Orwell", "isbn": "9780451524935"},
      {
        "title": "The Great Gatsby",
        "author": "F. Scott Fitzgerald",
        "isbn": "9780743273565"
      },
      {
        "title": "Pride and Prejudice",
        "author": "Jane Austen",
        "isbn": "9780141439518"
      },
      {
        "title": "Moby-Dick",
        "author": "Herman Melville",
        "isbn": "9781503280786"
      },
      {
        "title": "The Hobbit",
        "author": "J.R.R. Tolkien",
        "isbn": "9780547928227"
      },
      {
        "title": "The Catcher in the Rye",
        "author": "J.D. Salinger",
        "isbn": "9780316769488"
      },
      {
        "title": "The Lord of the Rings",
        "author": "J.R.R. Tolkien",
        "isbn": "9780544003415"
      },
      {
        "title": "Animal Farm",
        "author": "George Orwell",
        "isbn": "9780451526342"
      },
      {
        "title": "War and Peace",
        "author": "Leo Tolstoy",
        "isbn": "9781400079988"
      },
    ];

    for (int i = 0; i < realBooks.length; i++) {
      final book = realBooks[i];
      for (int c = 1; c <= 10; c++) {
        final copyId =
            'B${(i + 1).toString().padLeft(2, '0')}-C${c.toString().padLeft(3, '0')}';
        await _db.collection(booksCol).add({
          'title': book['title'],
          'author': book['author'],
          'isbn': book['isbn'],
          'copyId': copyId,
          'status': 'available',
          'coverUrl': null,
        });
      }
    }
  }

  Future<String> _uploadCover(String localPath, String copyId) async {
    final ref = _storage.ref().child('covers/$copyId.jpg');
    final file = File(localPath);
    final task = await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
