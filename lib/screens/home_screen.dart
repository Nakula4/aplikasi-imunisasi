import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tambahkan import ini
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:imunisasiku/screens/klinik.dart';
import 'package:imunisasiku/screens/informasianak_screen.dart';
import 'package:imunisasiku/screens/jadwal_imunisasi.dart';
import 'package:imunisasiku/screens/login_screen.dart';
import 'package:imunisasiku/screens/profile.dart';
import 'package:imunisasiku/screens/riwayat.dart';
import 'package:imunisasiku/screens/imunisasiku.dart';
import 'package:imunisasiku/screens/notification_screen.dart';
import 'package:imunisasiku/screens/notificationservice.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF8F9FF),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String? userName;
  late List<Widget> _pages;
  final NotificationService _notificationService = NotificationService();

  // Animation controllers untuk FAB
  AnimationController? _fabAnimationController;
  Animation<double>? _fabAnimation;
  AnimationController? _menuAnimationController;
  Animation<double>? _menuAnimation;
  bool _isMenuOpen = false;
  bool _animationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePages();
    _notificationService.initialize(context);

    // Delay initialization to avoid setState in constructor
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAnimations();
      _getUserData();
    });
  }

  void _initializeAnimations() {
    if (!mounted) return;

    try {
      // Initialize animation controllers
      _fabAnimationController = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _menuAnimationController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );

      _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _fabAnimationController!, curve: Curves.easeInOut),
      );
      _menuAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _menuAnimationController!, curve: Curves.elasticOut),
      );

      if (mounted) {
        setState(() {
          _animationsInitialized = true;
        });
        _fabAnimationController!.forward();
      }
    } catch (e) {
      print('Error initializing animations: $e');
      if (mounted) {
        setState(() {
          _animationsInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fabAnimationController?.dispose();
    _menuAnimationController?.dispose();
    super.dispose();
  }

  void _initializePages() {
    _pages = [
      HomePage(
        onFeatureTap: _onItemTapped,
      ),
      const InformasiAnakScreen(),
      const Imunisasiku(),
      Notif(),
      const ProfileScreen(),
    ];
  }

  Future<void> _getUserData() async {
    if (!mounted) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userData.exists && mounted) {
          Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
          setState(() {
            userName = data['username'] ?? 'User';
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            userName = 'User';
          });
        }
      }
    }
  }

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Fungsi logout (untuk tombol logout di UI)
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.logout, color: Colors.red[600]),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Konfirmasi Logout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun?',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            color: Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
                (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Ya, Logout',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PERBAIKAN: Fungsi untuk menangani tombol back Android
  Future<bool> _onWillPop() async {
    // Jika menu floating terbuka, tutup menu dulu
    if (_isMenuOpen) {
      _toggleMenu();
      return false; // Jangan keluar aplikasi
    }

    // Tampilkan dialog konfirmasi keluar aplikasi
    return await _showExitConfirmationDialog() ?? false;
  }

  // BARU: Dialog konfirmasi keluar aplikasi
  Future<bool?> _showExitConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // User harus memilih opsi
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFAFCC).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.exit_to_app_rounded,
                  color: Color(0xFFEC4899),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Keluar Aplikasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              color: Color(0xFF6B7280),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Tidak',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                // Keluar dari aplikasi menggunakan SystemNavigator
                SystemNavigator.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC4899),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Ya, Keluar',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleMenu() {
    if (!_animationsInitialized || _menuAnimationController == null || !mounted)
      return;

    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });

    if (_isMenuOpen) {
      _menuAnimationController!.forward();
    } else {
      _menuAnimationController!.reverse();
    }
  }

  void _navigateToJadwalImunisasi() {
    _toggleMenu(); // Close menu first
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Jadwal()),
    );
  }

  // Helper method untuk mendapatkan nilai opacity yang aman
  double _getSafeOpacity(Animation<double>? animation) {
    if (animation == null || !_animationsInitialized) return 0.0;
    final value = animation.value;
    return value.clamp(0.0, 1.0); // Memastikan nilai antara 0.0 dan 1.0
  }

  // Helper method untuk mendapatkan nilai scale yang aman
  double _getSafeScale(Animation<double>? animation) {
    if (animation == null || !_animationsInitialized) return 0.0;
    final value = animation.value;
    return value.clamp(0.0, 2.0); // Memastikan nilai tidak negatif
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Menggunakan fungsi yang sudah diperbaiki
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FF),
        body: Stack(
          children: [
            _pages[_selectedIndex],

            // Overlay untuk menutup menu ketika tap di luar
            if (_isMenuOpen)
              GestureDetector(
                onTap: _toggleMenu,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

            // Floating menu items
            if (_animationsInitialized && _menuAnimation != null)
              Positioned(
                right: 20,
                bottom: 160, // Di atas FAB
                child: AnimatedBuilder(
                  animation: _menuAnimation!,
                  builder: (context, child) {
                    final opacity = _getSafeOpacity(_menuAnimation);
                    final scale = _getSafeScale(_menuAnimation);

                    return Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildMenuItem(
                              icon: Icons.schedule_rounded,
                              label: 'Tambah Jadwal',
                              onTap: _navigateToJadwalImunisasi,
                              color: const Color(0xFFBDE0FE),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFCDB4DB), // thistle
                Color(0xFFFFC8DD), // fairy-tale
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            child: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.child_care_rounded),
                  label: 'Info Anak',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.vaccines_rounded),
                  label: 'Imunisasi',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_rounded),
                  label: 'Notifikasi',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: 'Profil',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0xFF6B46C1),
              unselectedItemColor: const Color(0xFF9CA3AF),
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              elevation: 0,
              onTap: _onItemTapped,
            ),
          ),
        ),
        floatingActionButton: _animationsInitialized && _fabAnimation != null
            ? AnimatedBuilder(
                animation: _fabAnimation!,
                builder: (context, child) {
                  final scale = _getSafeScale(_fabAnimation);

                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isMenuOpen
                              ? [
                                  const Color(0xFFFF6B6B),
                                  const Color(0xFFFF8E8E)
                                ]
                              : [
                                  const Color(0xFFCDB4DB),
                                  const Color(0xFFFFC8DD)
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: (_isMenuOpen
                                    ? const Color(0xFFFF6B6B)
                                    : const Color(0xFFCDB4DB))
                                .withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: FloatingActionButton(
                        onPressed: _toggleMenu,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        child: AnimatedRotation(
                          turns:
                              _isMenuOpen ? 0.125 : 0.0, // 45 degrees rotation
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _isMenuOpen
                                ? Icons.close_rounded
                                : Icons.add_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFCDB4DB), Color(0xFFFFC8DD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFCDB4DB).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: _toggleMenu,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Button
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// HomePage class tetap sama seperti kode asli Anda
class HomePage extends StatefulWidget {
  final Function(int) onFeatureTap;

  const HomePage({super.key, required this.onFeatureTap});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    // Ambil userName dari parent state dengan aman
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    final userName = homeState?.userName ?? 'User';

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          // Header dengan gradient modern
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFBDE0FE), // uranian-blue
                  Color(0xFFA2D2FF), // light-sky-blue
                  Color(0xFFCDB4DB), // thistle
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.vaccines_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, $userName! 👋',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Jaga kesehatan si kecil dengan imunisasi tepat waktu',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildFeatureSection(context),
                const SizedBox(height: 24),
                _buildPengingatSection(context),
                const SizedBox(height: 24),
                _buildRekomendasiSection(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fitur Utama',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
          children: [
            _buildFeatureCard(
              'Informasi\nAnak',
              Icons.child_care_rounded,
              const Color(0xFFCDB4DB),
              const Color(0xFFFFC8DD),
              1,
            ),
            _buildFeatureCard(
              'Imunisasi\nku',
              Icons.vaccines_rounded,
              const Color(0xFFFFAFCC),
              const Color(0xFFFFC8DD),
              2,
            ),
            _buildFeatureCard(
              'Notifikasi',
              Icons.notifications_rounded,
              const Color(0xFFBDE0FE),
              const Color(0xFFA2D2FF),
              3,
            ),
            _buildFeatureCard(
              'Profil',
              Icons.person_rounded,
              const Color(0xFFA2D2FF),
              const Color(0xFFCDB4DB),
              4,
            ),
            _buildStatCard(
              'Jadwal\nHari Ini',
              '2',
              Icons.today_rounded,
              const Color(0xFFFFAFCC),
              const Color(0xFFFFC8DD),
            ),
            _buildStatCard(
              'Selesai\nBulan Ini',
              '5',
              Icons.check_circle_rounded,
              const Color(0xFFBDE0FE),
              const Color(0xFFA2D2FF),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    String title,
    IconData icon,
    Color startColor,
    Color endColor,
    int tabIndex,
  ) {
    return GestureDetector(
      onTap: () => widget.onFeatureTap(tabIndex),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: startColor.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color startColor,
    Color endColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPengingatSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pengingat Imunisasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                    fontFamily: 'Poppins',
                  ),
                ),
                TextButton(
                  onPressed: () => widget.onFeatureTap(3),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFBDE0FE).withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tambah_jadwal')
                  .where('userId',
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFFBDE0FE),
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBDE0FE).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications_off_rounded,
                            size: 32,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tidak Ada Jadwal Mendatang',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tambahkan jadwal imunisasi untuk mendapatkan pengingat',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final doc = snapshot.data!.docs.first;
                final data = doc.data() as Map<String, dynamic>;
                final dateTime = (data['tanggal_waktu'] as Timestamp).toDate();

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFBDE0FE),
                        Color(0xFFA2D2FF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['nama'] ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Vaksin: ${data['jenis_vaksin'] ?? '-'}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              DateFormat('dd MMM yyyy, HH:mm').format(dateTime),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _notificationService
                                      .scheduleNotification(
                                    doc.id,
                                    dateTime,
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Pengingat berhasil dijadwalkan',
                                          style:
                                              TextStyle(fontFamily: 'Poppins'),
                                        ),
                                        duration: const Duration(seconds: 2),
                                        backgroundColor:
                                            const Color(0xFF10B981),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF3B82F6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Set Pengingat',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRekomendasiSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFAFCC),
                        Color(0xFFFFC8DD),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.recommend_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Rekomendasi Vaksinasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(5, (index) {
              final vaccines = [
                {
                  'name': 'Hepatitis B',
                  'age': '0-1 bulan',
                  'icon': Icons.shield_rounded
                },
                {
                  'name': 'BCG',
                  'age': '2-3 bulan',
                  'icon': Icons.health_and_safety_rounded
                },
                {
                  'name': 'DPT',
                  'age': '2-4 bulan',
                  'icon': Icons.medical_services_rounded
                },
                {
                  'name': 'Polio',
                  'age': '2-4 bulan',
                  'icon': Icons.vaccines_rounded
                },
                {
                  'name': 'Campak',
                  'age': '9-12 bulan',
                  'icon': Icons.coronavirus_rounded
                },
              ];

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBDE0FE).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        vaccines[index]['icon'] as IconData,
                        color: const Color(0xFF3B82F6),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vaccines[index]['name'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            'Usia: ${vaccines[index]['age']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey[400],
                      size: 12,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
