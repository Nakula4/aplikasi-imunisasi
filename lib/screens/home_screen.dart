import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:imunisasiku/screens/klinik.dart';
import 'package:imunisasiku/screens/informasianak_screen.dart';
import 'package:imunisasiku/screens/jadwal_imunisasi.dart';
import 'package:imunisasiku/screens/login_screen.dart';
import 'package:imunisasiku/screens/profile.dart';
import 'package:imunisasiku/screens/riwayat.dart';
import 'package:imunisasiku/screens/search_screen.dart';
import 'package:imunisasiku/screens/notification_screen.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? userName;

  final List<Widget> _pages = [
    const HomePage(), // Halaman Beranda
    const ChildInfoScreen(), // Halaman Informasi Anak
    Search(), // Halaman Pencarian
    Notif(), // Halaman Notifikasi
    const ProfileScreen(), // Halaman Profil
  ];

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  // Fungsi untuk mengambil data pengguna dari Firestore
  Future<void> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
          if (data.containsKey('username')) {
            if (mounted) {
              setState(() {
                userName = data['username'];
              });
            }
          } else {
            if (mounted) {
              setState(() {
                userName = 'User ';
              });
            }
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            userName = 'User ';
          });
        }
        print('Error fetching user data: $e');
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (Route<dynamic> route) => false,
    );
  }

  Future<bool> _onWillPop() async {
    _logout(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(
                icon: Icon(Icons.child_care), label: 'Informasi Anak'),
            BottomNavigationBarItem(
                icon: Icon(Icons.search), label: 'Pencarian'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: 'Notifikasi'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.black,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Menampilkan nama pengguna
            SizedBox(
              width: double.infinity, // Lebar penuh
              child: Text(
                'Welcome, ${context.findAncestorStateOfType<_HomeScreenState>()?.userName ?? 'user'}!',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.left, // Teks rata kanan
              ),
            ),
            const SizedBox(height: 20), // Container untuk Grid Kartu
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
              child: Column(
                children: [
                  // Grid Kartu
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildCard(
                        context,
                        title: 'Informasi Anak',
                        icon: Icons.child_care,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ChildInfoScreen()),
                          );
                        },
                      ),
                      _buildCard(
                        context,
                        title: 'Riwayat Imunisasi',
                        icon: Icons.history,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Riwayat()),
                          );
                        },
                      ),
                      _buildCard(
                        context,
                        title: 'Jadwal Imunisasi',
                        icon: Icons.calendar_today,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Jadwal()),
                          );
                        },
                      ),
                      _buildCard(
                        context,
                        title: 'Klinik',
                        icon: Icons.health_and_safety,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Klinik()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Container untuk "Imunisasi yang Akan Datang"
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 250, 227, 253),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pengingat',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Menggunakan Container dengan tinggi tetap untuk ListView
                  Container(
                    height: 200,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('tambah_jadwal')
                          .where('userId',
                              isEqualTo: FirebaseAuth.instance.currentUser
                                  ?.uid) // Filter berdasarkan user ID
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error loading data'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text('Tidak Ada Jadwal Mendatang'));
                        }

                        final immunizationData = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: immunizationData.length,
                          itemBuilder: (context, index) {
                            var doc = immunizationData[index];
                            Map<String, dynamic> data =
                                doc.data() as Map<String, dynamic>;

                            String name = data['nama'] ?? 'No Name Available';
                            String gender =
                                data['jenis_kelamin'] ?? 'No Gender Available';
                            String vaccineType = data['jenis_vaksin'] ??
                                'No Vaccine Type Available';

                            // Mengonversi Timestamp menjadi DateTime
                            DateTime dateTime =
                                (data['tanggal_waktu'] as Timestamp).toDate();
                            String date = DateFormat('yyyy-MM-dd')
                                .format(dateTime); // Format tanggal
                            String time = DateFormat('HH:mm')
                                .format(dateTime); // Format jam
                            String complaint =
                                data['keluhan'] ?? 'No Complaint Available';
                            String doctor =
                                data['dokter'] ?? 'No Doctor Available';

                            return Card(
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Nama: $name',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text('Jenis Kelamin: $gender'),
                                    Text('Jenis Vaksin: $vaccineType'),
                                    Text('Tanggal: $date'),
                                    Text('Jam: $time'),
                                    Text('Keluhan: $complaint'),
                                    Text('Dokter: $doctor'),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Container untuk Rekomendasi Vaksin Berikutnya
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 250, 227, 253),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rekomendasi Vaksin Berikutnya',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Menggunakan Container dengan tinggi tetap untuk ListView
                  Container(
                    height: 150,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('rekomendasi_vaksin')
                          .where('userId',
                              isEqualTo: FirebaseAuth.instance.currentUser
                                  ?.uid) // Filter berdasarkan user ID
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error loading data'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text('Tidak Ada Rekomendasi Vaksin'));
                        }

                        final rekomendasiVaksin = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: rekomendasiVaksin.length,
                          itemBuilder: (context, index) {
                            var doc = rekomendasiVaksin[index];
                            Map<String, dynamic> data =
                                doc.data() as Map<String, dynamic>;

                            String jenisVaksin = data['jenis_vaksin'] ??
                                'No Vaccine Type Available';
                            String tanggalVaksin = data['tanggal_vaksin'] ??
                                'No Vaccine Date Available';

                            return Card(
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Jenis Vaksin: $jenisVaksin',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text('Tanggal Vaksin: $tanggalVaksin'),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blueAccent),
            const SizedBox(height: 10),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
