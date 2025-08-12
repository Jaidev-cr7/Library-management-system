import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/firestore_service.dart';
import 'screens/dashboard.dart';
import 'screens/books_list.dart';
import 'screens/borrow_return.dart';
import 'screens/contact.dart';
import 'screens/add_book.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<FirestoreService>(
      create: (_) => FirestoreService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Library Manager',
        theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const MainShell(),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final _pages = const [
    DashboardScreen(),
    BooksListScreen(),
    BorrowReturnScreen(),
    BorrowReturnScreen(returnMode: true),
    ContactScreen(),
  ];

  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // close drawer after selection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Manager'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.local_library, size: 36),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Library Manager',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your books easily',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Home'),
              onTap: () => _navigateTo(0),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Books'),
              onTap: () => _navigateTo(1),
            ),
            ListTile(
              leading: const Icon(Icons.person_search),
              title: const Text('Borrow'),
              onTap: () => _navigateTo(2),
            ),
            ListTile(
              leading: const Icon(Icons.keyboard_return),
              title: const Text('Return'),
              onTap: () => _navigateTo(3),
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail),
              title: const Text('Contact'),
              onTap: () => _navigateTo(4),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.book), label: 'Books'),
          NavigationDestination(
              icon: Icon(Icons.person_search), label: 'Borrow'),
          NavigationDestination(
              icon: Icon(Icons.keyboard_return), label: 'Return'),
          NavigationDestination(
              icon: Icon(Icons.contact_mail), label: 'Contact'),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddBookScreen()),
                );
              },
              label: const Text('Add Book'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }
}
