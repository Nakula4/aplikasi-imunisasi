import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userName;
  String? userEmail;
  String? userPhone;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  // Fungsi untuk mengambil data pengguna dari Firestore
  Future<void> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        userName = userData['username'] ?? 'User  ';
        userEmail = userData['email'] ?? 'No Email';
        userPhone = userData['phone'] ?? 'No Phone';
      });
    }
  }

  // Fungsi untuk logout
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    // Navigasi kembali ke halaman login setelah logout
    Navigator.of(context)
        .pushReplacementNamed('/login'); // Pastikan rute ini sesuai
  }

  // Fungsi untuk memperbarui data pengguna
  Future<void> updateUserData(String field, String newValue) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({field: newValue});
      // Memperbarui state setelah data diubah
      if (field == 'name') {
        setState(() {
          userName = newValue;
        });
      } else if (field == 'email') {
        setState(() {
          userEmail = newValue;
        });
      } else if (field == 'phone') {
        setState(() {
          userPhone = newValue;
        });
      }
    }
  }

  // Dialog untuk mengedit data pengguna
  void _showEditDialog(String field, String currentValue) {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: field),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                String newValue = controller.text.trim();
                if (newValue.isNotEmpty) {
                  await updateUserData(field, newValue);
                }
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengaturan Profil',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  child: const Icon(Icons.person,
                                      size: 40, color: Colors.grey),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  userName ?? 'User  ',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.logout),
                              onPressed: () {
                                logout();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Ubah Nomor Telepon',
                                          style: TextStyle(fontSize: 18)),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          _showEditDialog(
                                              'phone', userPhone ?? '');
                                        },
                                      ),
                                    ],
                                  ),
                                  Divider(thickness: 1, color: Colors.grey),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Ubah Email',
                                          style: TextStyle(fontSize: 18)),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          _showEditDialog(
                                              'email', userEmail ?? '');
                                        },
                                      ),
                                    ],
                                  ),
                                  Divider(thickness: 1, color: Colors.grey),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Ubah Kata Sandi',
                                          style: TextStyle(fontSize: 18)),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          // Implement dialog for changing password
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
