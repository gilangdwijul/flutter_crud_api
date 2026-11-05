
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

// ==========================================
// 1. MODEL CLASS POST
// ==========================================

class Post {
  final int id;
  final int userId;
  final String title;
  final String body;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'] ?? 1,
      title: json['title'],
      body: json['body'],
      createdAt: DateTime.now(),
    );
  }
}

// ==========================================
// 2. MAIN DAN MYAPP
// ==========================================

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD Demo',
      theme: ThemeData(
        primaryColor: Colors.indigo[900],
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: Colors.lightBlueAccent),
        scaffoldBackgroundColor: Colors.blueGrey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo[900],
          elevation: 4,
          titleTextStyle: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ==========================================
// 3. HOMEPAGE
// ==========================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Post? createdPost;

  // ==========================================
  // 4. CREATE POST (HTTP POST)
  // ==========================================

  Future<void> createPost(String title, String body) async {
    final url = Uri.parse(
      'https://jsonplaceholder.typicode.com/posts',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'title': title,
          'body': body,
          'userId': 1,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        setState(() {
          createdPost = Post.fromJson(data);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menambahkan post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ==========================================
  // 5. UPDATE POST (HTTP PUT)
  // ==========================================

  Future<void> updatePost(
      int id,
      String title,
      String body,
      ) async {
    // Menggunakan ID 1 sesuai contoh modul
    final url = Uri.parse(
      'https://jsonplaceholder.typicode.com/posts/1',
    );

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'id': 1,
          'title': title,
          'body': body,
          'userId': 1,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          createdPost = Post(
            id: data['id'],
            userId: data['userId'] ?? createdPost!.userId,
            title: data['title'],
            body: data['body'],
            createdAt: createdPost!.createdAt,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengupdate post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ==========================================
  // 6. DELETE POST (HTTP DELETE)
  // ==========================================

  Future<void> deletePost(int id) async {
    final url = Uri.parse(
      'https://jsonplaceholder.typicode.com/posts/$id',
    );

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          createdPost = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================
  // 7. DIALOG TAMBAH POST
  // ==========================================

  void showAddPostDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                ),
              ),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(
                  labelText: 'Pekerjaan',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final body = bodyController.text.trim();

                if (title.isEmpty || body.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Nama dan Pekerjaan harus diisi',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                createPost(title, body);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    ).then((_) {
      titleController.dispose();
      bodyController.dispose();
    });
  }

  // ==========================================
  // 8. DIALOG UPDATE POST
  // ==========================================

  void showUpdatePostDialog(Post currentPost) {
    final titleController = TextEditingController(
      text: currentPost.title,
    );

    final bodyController = TextEditingController(
      text: currentPost.body,
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                ),
              ),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(
                  labelText: 'Pekerjaan',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedTitle =
                titleController.text.trim();

                final updatedBody =
                bodyController.text.trim();

                if (updatedTitle.isEmpty ||
                    updatedBody.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Nama dan Pekerjaan harus diisi',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                updatePost(
                  currentPost.id,
                  updatedTitle,
                  updatedBody,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    ).then((_) {
      titleController.dispose();
      bodyController.dispose();
    });
  }

  // ==========================================
  // 9. DIALOG KONFIRMASI DELETE
  // ==========================================

  void showDeleteConfirmationDialog(int id) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus post ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                deletePost(id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // 10. BUILD UI
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo CRUD client-server'),
      ),

      body: Center(
        child: createdPost == null

        // Tampilan awal
            ? Text(
          'Demo CRUD client-server di Flutter',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.indigo[900],
          ),
        )

        // Tampilan data
            : ListView(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Card(
                elevation: 8,
                shadowColor: Colors.indigo.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Judul dan menu
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              createdPost!.title,
                              style: GoogleFonts.montserrat(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.indigo[900],
                              ),
                            ),
                          ),

                          PopupMenuButton<String>(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'update',
                                child: Text('Update'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],

                            onSelected: (value) {
                              if (value == 'update') {
                                if (createdPost != null) {
                                  showUpdatePostDialog(
                                    createdPost!,
                                  );
                                }
                              } else if (value == 'delete') {
                                if (createdPost != null) {
                                  showDeleteConfirmationDialog(
                                    createdPost!.id,
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Isi post
                      Text(
                        createdPost!.body,
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          height: 1.5,
                          color: Colors.blueGrey[900],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ID post
                      Text(
                        'id: ${createdPost!.id}',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          color: Colors.blueGrey[600],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // User ID
                      Text(
                        'userID: ${createdPost!.userId}',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          color: Colors.blueGrey[600],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tanggal pembuatan
                      Text(
                        DateFormat(
                          "dd MMMM yyyy, HH:mm 'WIB'",
                        ).format(createdPost!.createdAt),
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          color: Colors.blueGrey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Tombol tambah
      floatingActionButton: FloatingActionButton(
        onPressed: showAddPostDialog,
        backgroundColor: Colors.indigo[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.add,
          size: 28,
        ),
      ),
    );
  }
}
