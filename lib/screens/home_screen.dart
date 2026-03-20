import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/book_provider.dart';
import '../routes/app_routes.dart';
import 'add_edit_book_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, .05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().loadBooks();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredBooks(BookProvider provider) {
    final query = _searchController.text.trim().toLowerCase();

    return provider.books.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.isbn.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookProvider>(context);
    final books = _getFilteredBooks(provider);

    // 🎨 UPDATED COLORS
    const bgColor = Color(0xffEDE7F6);
    const primary = Color(0xffB39DDB);
    const titleColor = Colors.white;
    const subtitleColor = Colors.white70;
    const mutedColor = Colors.white60;
    const borderColor = Color(0xffD1C4E9);
    const purpleColor = Color(0xff9575CD);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: const BoxDecoration(
                color: Color(0xff7E57C2),
              ),
              child: Row(
                children: [
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_book, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Lumina',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "logout") {
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.login);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: "profile", child: Text("Profile")),
                      PopupMenuItem(value: "logout", child: Text("Logout")),
                    ],
                    child: const Icon(Icons.person, color: Colors.white),
                  )
                ],
              ),
            ),

            /// BODY
            Expanded(
              child: FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(
                  position: slideAnimation,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text(
                        'Global Catalog',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Manage ${provider.books.length} books',
                        style: const TextStyle(color: Colors.white70),
                      ),

                      const SizedBox(height: 20),

                      /// SEARCH
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search...",
                          hintStyle:
                              const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: purpleColor,
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// ADD BUTTON
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.addBook);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                        ),
                        child: const Text(
                          "Add Book",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// LIST
                      provider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : books.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No Books Found",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : Column(
                                  children: books.map((book) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: purpleColor,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.book,
                                              color: Colors.white),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(book.title,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(book.author,
                                                    style: const TextStyle(
                                                        color:
                                                            Colors.white70)),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.white),
                                            onPressed: () {
                                              provider.deleteBook(book.id);
                                            },
                                          )
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}