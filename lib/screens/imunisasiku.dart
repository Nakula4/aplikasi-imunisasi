import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Imunisasiku extends StatefulWidget {
  const Imunisasiku({super.key});

  @override
  State<Imunisasiku> createState() => _ImunisasikuState();
}

class _ImunisasikuState extends State<Imunisasiku> {
  String? _selectedFilter = 'Semua';
  final List<String> _filterOptions = [
    'Semua',
    'Bulan Ini',
    '3 Bulan Terakhir',
    'Tahun Ini'
  ];
  List<String> _userChildrenNames = [];
  bool _isLoadingChildren = true;

  @override
  void initState() {
    super.initState();
    _loadUserChildren();
  }

  Future<void> _loadUserChildren() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoadingChildren = false;
      });
      return;
    }

    try {
      // Ambil data anak dari koleksi users atau informasi_anak
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      List<String> childrenNames = [];

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Jika ada field children di user document
        if (userData.containsKey('children')) {
          final children = userData['children'] as List<dynamic>?;
          if (children != null) {
            childrenNames = children.map((child) => child.toString()).toList();
          }
        }
      }

      // Jika tidak ada di user document, coba ambil dari koleksi informasi_anak
      if (childrenNames.isEmpty) {
        final childrenQuery = await FirebaseFirestore.instance
            .collection('informasi_anak')
            .where('userId', isEqualTo: user.uid)
            .get();

        for (var doc in childrenQuery.docs) {
          final data = doc.data();
          if (data.containsKey('nama')) {
            childrenNames.add(data['nama'].toString());
          }
        }
      }

      // Jika masih kosong, coba ambil dari tambah_jadwal
      if (childrenNames.isEmpty) {
        final jadwalQuery = await FirebaseFirestore.instance
            .collection('tambah_jadwal')
            .where('userId', isEqualTo: user.uid)
            .get();

        for (var doc in jadwalQuery.docs) {
          final data = doc.data();
          if (data.containsKey('nama')) {
            final namaAnak = data['nama'].toString();
            if (!childrenNames.contains(namaAnak)) {
              childrenNames.add(namaAnak);
            }
          }
        }
      }

      print('Found children names: $childrenNames');

      setState(() {
        _userChildrenNames = childrenNames;
        _isLoadingChildren = false;
      });
    } catch (e) {
      print('Error loading children: $e');
      setState(() {
        _isLoadingChildren = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan gradient modern
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFAFCC), // fairy-tale
                    Color(0xFFFFC8DD), // fairy-tale-light
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
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Laporan Imunisasi',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Rekam jejak lengkap imunisasi anak',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Filter
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          dropdownColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                          items: _filterOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedFilter = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            title: 'Total Imunisasi',
                            icon: Icons.vaccines_rounded,
                            color: const Color(0xFFBDE0FE),
                            streamBuilder: _getTotalImunisasiStream(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            title: 'Bulan Ini',
                            icon: Icons.calendar_month_rounded,
                            color: const Color(0xFFFFAFCC),
                            streamBuilder: _getMonthlyImunisasiStream(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Debug Info
                    if (_userChildrenNames.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Anak Terdaftar: ${_userChildrenNames.join(", ")}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_userChildrenNames.isNotEmpty)
                      const SizedBox(height: 12),

                    // List Laporan
                    Expanded(
                      child: _isLoadingChildren
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Color(0xFFFFAFCC),
                                    strokeWidth: 3,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Memuat data anak...',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _userChildrenNames.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFAFCC)
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.child_care_rounded,
                                          size: 48,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Belum Ada Data Anak',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF6B7280),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tambahkan informasi anak terlebih dahulu',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                          fontFamily: 'Poppins',
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : StreamBuilder<List<QueryDocumentSnapshot>>(
                                  stream: _getLaporanStream(),
                                  builder: (context, snapshot) {
                                    print(
                                        'StreamBuilder state: ${snapshot.connectionState}');
                                    print('Has data: ${snapshot.hasData}');
                                    print('Has error: ${snapshot.hasError}');
                                    if (snapshot.hasError) {
                                      print('Error: ${snapshot.error}');
                                    }
                                    if (snapshot.hasData) {
                                      print(
                                          'Documents count: ${snapshot.data!.length}');
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              color: Color(0xFFFFAFCC),
                                              strokeWidth: 3,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'Memuat laporan...',
                                              style: TextStyle(
                                                color: Color(0xFF6B7280),
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    if (snapshot.hasError) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFF6B6B)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.error_outline_rounded,
                                                size: 48,
                                                color: Color(0xFFFF6B6B),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Terjadi Kesalahan',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1F2937),
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Error: ${snapshot.error}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontFamily: 'Poppins',
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFAFCC)
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.assignment_rounded,
                                                size: 48,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Belum Ada Laporan',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF6B7280),
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Laporan imunisasi akan muncul setelah pemeriksaan',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[500],
                                                fontFamily: 'Poppins',
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () {
                                                _loadUserChildren();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFFFFAFCC),
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text('Refresh'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    final docs = snapshot.data!;
                                    return ListView.builder(
                                      itemCount: docs.length,
                                      itemBuilder: (context, index) {
                                        final data = docs[index].data()
                                            as Map<String, dynamic>;
                                        return _buildImunisasiCard(
                                            data, docs[index].id);
                                      },
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required IconData icon,
    required Color color,
    required StreamBuilder<int> streamBuilder,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          streamBuilder,
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  StreamBuilder<int> _getTotalImunisasiStream() {
    if (_userChildrenNames.isEmpty) {
      return StreamBuilder<int>(
        stream: Stream.value(0),
        builder: (context, snapshot) => const Text(
          '0',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
      );
    }

    return StreamBuilder<int>(
      stream: _getCombinedLaporanCount(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        );
      },
    );
  }

  StreamBuilder<int> _getMonthlyImunisasiStream() {
    if (_userChildrenNames.isEmpty) {
      return StreamBuilder<int>(
        stream: Stream.value(0),
        builder: (context, snapshot) => const Text(
          '0',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
      );
    }

    return StreamBuilder<int>(
      stream: _getCombinedLaporanCount(monthlyOnly: true),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        );
      },
    );
  }

  Stream<int> _getCombinedLaporanCount({bool monthlyOnly = false}) async* {
    if (_userChildrenNames.isEmpty) {
      yield 0;
      return;
    }

    await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
      try {
        int totalCount = 0;

        for (String childName in _userChildrenNames) {
          Query query = FirebaseFirestore.instance
              .collection('laporan')
              .where('nama_anak', isEqualTo: childName);

          if (monthlyOnly) {
            final now = DateTime.now();
            final startOfMonth = DateTime(now.year, now.month, 1);
            final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

            query = query
                .where('tanggal_pemeriksaan',
                    isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
                .where('tanggal_pemeriksaan',
                    isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth));
          }

          final snapshot = await query.get();
          totalCount += snapshot.docs.length;
        }

        yield totalCount;
      } catch (e) {
        print('Error getting count: $e');
        yield 0;
      }
    }
  }

  Stream<List<QueryDocumentSnapshot>> _getLaporanStream() async* {
    if (_userChildrenNames.isEmpty) {
      yield [];
      return;
    }

    print('Getting laporan stream for children: $_userChildrenNames');
    print('Selected filter: $_selectedFilter');

    await for (final _ in Stream.periodic(const Duration(seconds: 2))) {
      try {
        List<QueryDocumentSnapshot> allDocs = [];

        for (String childName in _userChildrenNames) {
          print('Querying for child: $childName');

          Query query = FirebaseFirestore.instance
              .collection('laporan')
              .where('nama_anak', isEqualTo: childName);

          // Apply filter based on selected option
          if (_selectedFilter == 'Bulan Ini') {
            final now = DateTime.now();
            final startOfMonth = DateTime(now.year, now.month, 1);
            final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

            query = query
                .where('tanggal_pemeriksaan',
                    isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
                .where('tanggal_pemeriksaan',
                    isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth));
          } else if (_selectedFilter == '3 Bulan Terakhir') {
            final now = DateTime.now();
            final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);

            query = query.where('tanggal_pemeriksaan',
                isGreaterThanOrEqualTo: Timestamp.fromDate(threeMonthsAgo));
          } else if (_selectedFilter == 'Tahun Ini') {
            final now = DateTime.now();
            final startOfYear = DateTime(now.year, 1, 1);
            final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);

            query = query
                .where('tanggal_pemeriksaan',
                    isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
                .where('tanggal_pemeriksaan',
                    isLessThanOrEqualTo: Timestamp.fromDate(endOfYear));
          }

          final snapshot = await query.get();
          print('Found ${snapshot.docs.length} documents for $childName');
          allDocs.addAll(snapshot.docs);
        }

        // Sort by date descending
        allDocs.sort((a, b) {
          try {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            final aDate = aData['tanggal_pemeriksaan'] is Timestamp
                ? (aData['tanggal_pemeriksaan'] as Timestamp).toDate()
                : DateTime.now();
            final bDate = bData['tanggal_pemeriksaan'] is Timestamp
                ? (bData['tanggal_pemeriksaan'] as Timestamp).toDate()
                : DateTime.now();

            return bDate.compareTo(aDate);
          } catch (e) {
            return 0;
          }
        });

        print('Total documents found: ${allDocs.length}');
        yield allDocs;
      } catch (e) {
        print('Error in stream: $e');
        yield [];
      }
    }
  }

  Widget _buildImunisasiCard(Map<String, dynamic> data, String docId) {
    print('Building card for document: $docId');
    print('Card data: $data');

    // Handle tanggal_pemeriksaan with multiple possible formats
    DateTime tanggalPemeriksaan = DateTime.now();

    try {
      if (data['tanggal_pemeriksaan'] != null) {
        if (data['tanggal_pemeriksaan'] is Timestamp) {
          tanggalPemeriksaan =
              (data['tanggal_pemeriksaan'] as Timestamp).toDate();
        } else if (data['tanggal_pemeriksaan'] is String) {
          tanggalPemeriksaan = DateTime.parse(data['tanggal_pemeriksaan']);
        }
      }
    } catch (e) {
      print('Error parsing date: $e');
      tanggalPemeriksaan = DateTime.now();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFAFCC), Color(0xFFFFC8DD)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.vaccines_rounded,
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
                              data['jenis_imunisasi']?.toString() ??
                                  'Jenis tidak tersedia',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy')
                                  .format(tanggalPemeriksaan),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Detail Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          icon: Icons.child_care_rounded,
                          label: 'Nama Anak',
                          value: data['nama_anak']?.toString() ?? '-',
                          color: const Color(0xFFCDB4DB),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailItem(
                          icon: Icons.cake_rounded,
                          label: 'Usia',
                          value:
                              '${data['usia_anak']?.toString() ?? '-'} bulan',
                          color: const Color(0xFFBDE0FE),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          icon: Icons.monitor_weight_rounded,
                          label: 'Berat',
                          value: '${data['berat_badan']?.toString() ?? '-'} kg',
                          color: const Color(0xFFA2D2FF),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailItem(
                          icon: Icons.height_rounded,
                          label: 'Tinggi',
                          value:
                              '${data['tinggi_badan']?.toString() ?? '-'} cm',
                          color: const Color(0xFFFFAFCC),
                        ),
                      ),
                    ],
                  ),
                  if (data['kode_vaksin'] != null &&
                      data['kode_vaksin'].toString().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailItem(
                      icon: Icons.qr_code_rounded,
                      label: 'Kode Vaksin',
                      value: data['kode_vaksin'].toString(),
                      color: const Color(0xFFFFC8DD),
                    ),
                  ],
                ],
              ),
            ),

            // Catatan (jika ada)
            if (data['catatan'] != null &&
                data['catatan'].toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFAFCC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFAFCC).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.note_rounded,
                          color: Color(0xFF6B46C1),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Catatan Dokter',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B46C1),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['catatan'].toString(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontFamily: 'Poppins',
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color.withOpacity(0.8),
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
