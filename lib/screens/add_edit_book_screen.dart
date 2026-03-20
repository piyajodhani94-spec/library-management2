// 🎨 ONLY COLORS UPDATED — LOGIC SAME

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/book_model.dart';
import '../providers/book_provider.dart';

class AddEditBookScreen extends StatefulWidget {
  final Book? book;

  const AddEditBookScreen({super.key, this.book});

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final title = TextEditingController();
  final author = TextEditingController();
  final isbn = TextEditingController();
  final quantity = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.book != null) {
      title.text = widget.book!.title;
      author.text = widget.book!.author;
      isbn.text = widget.book!.isbn;
      quantity.text = widget.book!.quantity.toString();
    }
  }

  @override
  void dispose() {
    title.dispose();
    author.dispose();
    isbn.dispose();
    quantity.dispose();
    super.dispose();
  }

  String generateBookId() {
    return '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(999)}';
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<BookProvider>();

    final book = Book(
      id: widget.book?.id ?? generateBookId(),
      title: title.text.trim(),
      author: author.text.trim(),
      isbn: isbn.text.trim(),
      quantity: int.parse(quantity.text.trim()),
      isIssued: widget.book?.isIssued ?? false,
    );

    if (widget.book == null) {
      await provider.addBook(book);
    } else {
      await provider.updateBook(widget.book!.id, book);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.book == null
              ? 'Book saved successfully!'
              : 'Book updated successfully!',
        ),
        backgroundColor: const Color(0xff9575CD),
        behavior: SnackBarBehavior.floating,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _showSavePopup() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xffEDE7F6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            widget.book == null ? 'Save Book?' : 'Update Book?',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          content: Text(
            widget.book == null
                ? 'Do you want to save this book to library?'
                : 'Do you want to update this book?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff9575CD),
              ),
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _saveBook();
    }
  }

  Widget _label(String text) {
    return const Text(
      '',
    ); // keep structure same (color applied below)
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      validator: (value) {
        final text = value?.trim() ?? '';

        if (text.isEmpty) return '$label is required';

        if (label == 'ISBN-13') {
          if (!RegExp(r'^\d+$').hasMatch(text)) {
            return 'ISBN must contain numbers only';
          }
        }

        if (label == 'Quantity') {
          if (int.tryParse(text) == null) return 'Enter valid quantity';
          if (int.parse(text) <= 0) return 'Quantity must be greater than 0';
        }

        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: const Color(0xff9575CD),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xffEDE7F6);
    const primary = Color(0xff9575CD);
    const titleColor = Colors.white;
    const subtitleColor = Colors.white70;
    const cardColor = Color(0xff7E57C2);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: const BoxDecoration(
                color: Color(0xff7E57C2),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Library Manager',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      widget.book == null
                          ? 'Add Collection'
                          : 'Update Collection',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _inputField(
                                controller: title,
                                hint: "Book Title",
                                label: "Book Title"),
                            const SizedBox(height: 12),
                            _inputField(
                                controller: author,
                                hint: "Author",
                                label: "Author"),
                            const SizedBox(height: 12),
                            _inputField(
                                controller: isbn,
                                hint: "ISBN",
                                label: "ISBN"),
                            const SizedBox(height: 12),
                            _inputField(
                                controller: quantity,
                                hint: "Quantity",
                                label: "Quantity"),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _showSavePopup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                              ),
                              child: const Text(
                                "Save",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}