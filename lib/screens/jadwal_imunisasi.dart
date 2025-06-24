import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jadwal Imunisasi',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Poppins',
      ),
      home: const Jadwal(),
    );
  }
}

class Jadwal extends StatefulWidget {
  const Jadwal({super.key});

  @override
  _JadwalScreenState createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<Jadwal> {
  late final Stream<QuerySnapshot> _jadwalStream;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _jadwalStream = FirebaseFirestore.instance
          .collection('tambah_jadwal')
          .where('userId', isEqualTo: user.uid)
          .orderBy('tanggal_waktu')
          .snapshots();
    }
  }

  void _addSchedule(Map<String, dynamic> schedule) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        schedule['userId'] = user.uid;
        schedule['userEmail'] = user.email;
        schedule['created_at'] = Timestamp.now();
        schedule['updated_at'] = Timestamp.now();

        await FirebaseFirestore.instance
            .collection('tambah_jadwal')
            .add(schedule);
        _showSuccessDialog();
      }
    } catch (e) {
      debugPrint('Gagal menyimpan jadwal: $e');
      _showErrorDialog('Gagal menyimpan jadwal: $e');
    }
  }

  void _editSchedule(String docId, Map<String, dynamic> updatedSchedule) async {
    try {
      updatedSchedule['updated_at'] = Timestamp.now();
      await FirebaseFirestore.instance
          .collection('tambah_jadwal')
          .doc(docId)
          .update(updatedSchedule);
      _showSuccessDialog('Jadwal berhasil diperbarui!');
    } catch (e) {
      debugPrint('Gagal mengupdate jadwal: $e');
      _showErrorDialog('Gagal mengupdate jadwal: $e');
    }
  }

  void _deleteSchedule(String docId) async {
    // Show confirmation dialog first
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('tambah_jadwal')
            .doc(docId)
            .delete();
        _showSuccessDialog('Jadwal berhasil dihapus!');
      } catch (e) {
        debugPrint('Gagal menghapus jadwal: $e');
        _showErrorDialog('Gagal menghapus jadwal: $e');
      }
    }
  }

  void _showAddScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFAFCC), Color(0xFFFFC8DD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Tambah Jadwal Imunisasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: JadwalForm(onSave: (schedule) {
                    _addSchedule(schedule);
                    Navigator.of(context).pop();
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditScheduleDialog(Map<String, dynamic> schedule) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFBDE0FE), Color(0xFFA2D2FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Edit Jadwal Imunisasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: JadwalForm(
                    initialData: schedule,
                    onSave: (updatedSchedule) {
                      _editSchedule(schedule['id'], updatedSchedule);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog([String? message]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600]),
            const SizedBox(width: 8),
            const Text('Berhasil'),
          ],
        ),
        content: Text(message ??
            'Jadwal berhasil dibuat, mohon untuk datang sebelum jam yang sudah ditentukan.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FF),
        appBar: AppBar(
          title: const Text('Jadwal Imunisasi'),
          backgroundColor: const Color(0xFFFFAFCC),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'User belum login',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      // ✅ SOLUSI 1: Gunakan extendBody untuk FAB tidak tertutup bottom nav
      extendBody: true,
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
                            Icons.schedule_rounded,
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
                                'Jadwal Imunisasi',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Kelola jadwal imunisasi anak Anda',
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
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _jadwalStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 64, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Terjadi kesalahan: ${snapshot.error}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFFFFAFCC),
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Memuat jadwal...',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFAFCC).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.schedule_rounded,
                              size: 48,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum Ada Jadwal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tambahkan jadwal imunisasi pertama Anda',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          // ✅ SOLUSI 2: Tambah tombol alternatif di tengah layar kosong
                          ElevatedButton.icon(
                            onPressed: _showAddScheduleDialog,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Tambah Jadwal Pertama'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFAFCC),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    // ✅ SOLUSI 3: Tambah padding bottom untuk FAB
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      Map<String, dynamic> data =
                          doc.data()! as Map<String, dynamic>;
                      data['id'] = doc.id;

                      if (data['tanggal_waktu'] is Timestamp) {
                        data['tanggal_waktu'] =
                            (data['tanggal_waktu'] as Timestamp).toDate();
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
                              // Header Card
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFFAFCC),
                                          Color(0xFFFFC8DD)
                                        ],
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['nama'] ?? '-',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1F2937),
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Text(
                                          data['jenis_vaksin'] ?? '-',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Terjadwal',
                                      style: TextStyle(
                                        color: Color(0xFF3B82F6),
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
                                    _buildDetailRow(
                                      icon: Icons.person_rounded,
                                      label: 'Nama Orang Tua',
                                      value: data['nama_orang_tua'] ?? '-',
                                      color: const Color(0xFFBDE0FE),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildDetailItem(
                                            icon: Icons.wc_rounded,
                                            label: 'Jenis Kelamin',
                                            value: data['jenis_kelamin'] ?? '-',
                                            color: const Color(0xFFCDB4DB),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildDetailItem(
                                            icon: Icons.local_hospital_rounded,
                                            label: 'Dokter',
                                            value: data['dokter'] ?? '-',
                                            color: const Color(0xFFA2D2FF),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildDetailItem(
                                            icon: Icons.calendar_today_rounded,
                                            label: 'Tanggal',
                                            value: data['tanggal_waktu']
                                                    is DateTime
                                                ? DateFormat('dd MMM yyyy')
                                                    .format(
                                                        data['tanggal_waktu'])
                                                : '-',
                                            color: const Color(0xFFFFAFCC),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildDetailItem(
                                            icon: Icons.access_time_rounded,
                                            label: 'Jam',
                                            value: data['tanggal_waktu']
                                                    is DateTime
                                                ? DateFormat('HH:mm').format(
                                                    data['tanggal_waktu'])
                                                : '-',
                                            color: const Color(0xFFFFC8DD),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDetailRow(
                                      icon: Icons.location_on_rounded,
                                      label: 'Klinik',
                                      value: data['klinik'] ?? '-',
                                      color: const Color(0xFFCDB4DB),
                                    ),
                                  ],
                                ),
                              ),

                              // Keluhan (jika ada)
                              if (data['keluhan'] != null &&
                                  data['keluhan'].toString().isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFAFCC)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFFFAFCC)
                                          .withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.note_rounded,
                                            color: const Color(0xFF6B46C1),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Keluhan',
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
                                        data['keluhan'].toString(),
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

                              const SizedBox(height: 16),

                              // Action Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.edit_rounded,
                                          color: Color(0xFF3B82F6)),
                                      onPressed: () =>
                                          _showEditScheduleDialog(data),
                                      tooltip: 'Edit Jadwal',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.delete_rounded,
                                          color: Color(0xFFEF4444)),
                                      onPressed: () => _deleteSchedule(doc.id),
                                      tooltip: 'Hapus Jadwal',
                                    ),
                                  ),
                                ],
                              ),
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
      // ✅ SOLUSI 4: FAB dengan positioning yang lebih baik
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: _showAddScheduleDialog,
          backgroundColor: const Color(0xFFFFAFCC),
          foregroundColor: Colors.white,
          elevation: 8,
          icon: const Icon(Icons.add_rounded, size: 24),
          label: const Text(
            'Tambah Jadwal',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          // ✅ HERO TAG UNIK untuk menghindari konflik
          heroTag: "add_schedule_fab",
        ),
      ),
      // ✅ SOLUSI 5: Posisi FAB yang tepat
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildDetailRow({
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
        const SizedBox(width: 12),
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
                  fontSize: 14,
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
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// JadwalForm class tetap sama seperti sebelumnya...
class JadwalForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const JadwalForm({super.key, required this.onSave, this.initialData});

  @override
  _JadwalFormState createState() => _JadwalFormState();
}

class _JadwalFormState extends State<JadwalForm> {
  final _formKey = GlobalKey<FormState>();
  String? _nama;
  String? _namaOrangTua;
  String? _jenisKelamin;
  String? _jenisVaksin;
  DateTime? _selectedDateTime;
  String? _keluhan;
  String? _dokter;
  String? _klinik;

  final List<String> _genders = ['Laki-laki', 'Perempuan'];
  final List<String> _vaccines = [
    'Vaksin DPT',
    'Vaksin Polio',
    'Vaksin Hepatitis B',
    'Vaksin BCG',
    'Vaksin HIB',
    'Vaksin MMR',
    'Vaksin Rotavirus',
    'Vaksin Pneumokokus',
    'Vaksin Influenza',
    'Vaksin Varicella',
  ];
  final List<String> _doctors = [
    'Dr. Andi Pratama, Sp.A',
    'Dr. Budi Santoso, Sp.A',
    'Dr. Citra Dewi, Sp.A',
    'Dr. Dian Sari, Sp.A',
    'Dr. Eko Wijaya, Sp.A',
  ];

  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _keluhanController = TextEditingController();

  List<Map<String, dynamic>> _childrenData = [];
  List<String> _clinics = [];
  bool _isLoadingChildren = true;
  bool _isLoadingClinics = true;

  @override
  void initState() {
    super.initState();
    _fetchChildrenData();
    _fetchClinics();

    if (widget.initialData != null) {
      _nama = widget.initialData!['nama'];
      _namaOrangTua = widget.initialData!['nama_orang_tua'];
      _jenisKelamin = widget.initialData!['jenis_kelamin'];
      _jenisVaksin = widget.initialData!['jenis_vaksin'];

      if (widget.initialData!['tanggal_waktu'] is Timestamp) {
        _selectedDateTime =
            (widget.initialData!['tanggal_waktu'] as Timestamp).toDate();
      } else if (widget.initialData!['tanggal_waktu'] is DateTime) {
        _selectedDateTime = widget.initialData!['tanggal_waktu'];
      }

      _keluhan = widget.initialData!['keluhan'];
      _keluhanController.text = _keluhan ?? '';
      _dokter = widget.initialData!['dokter'];
      _klinik = widget.initialData!['klinik'];

      _dateTimeController.text = _selectedDateTime != null
          ? DateFormat('dd MMMM yyyy, HH:mm').format(_selectedDateTime!)
          : '';
    }
  }

  void _fetchChildrenData() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Try to get from informasi_anak collection first
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('informasi_anak')
          .where('userId', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> childrenData = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        childrenData.add({
          'nama': data['nama'] ?? '',
          'nama_orang_tua': data['nama_orang_tua'] ?? '',
          'jenis_kelamin': data['jenis_kelamin'] ?? '',
        });
      }

      // If no data found, try tb_anak collection (fallback)
      if (childrenData.isEmpty) {
        QuerySnapshot tbAnakSnapshot = await FirebaseFirestore.instance
            .collection('tb_anak')
            .where('userId', isEqualTo: userId)
            .get();

        for (var doc in tbAnakSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          childrenData.add({
            'nama': data['nama'] ?? '',
            'nama_orang_tua': data['nama_orang_tua'] ?? '',
            'jenis_kelamin': data['jenis_kelamin'] ?? '',
          });
        }
      }

      setState(() {
        _childrenData = childrenData;
        _isLoadingChildren = false;
      });
    } catch (e) {
      debugPrint('Gagal mengambil data anak: $e');
      setState(() {
        _isLoadingChildren = false;
      });
    }
  }

  void _fetchClinics() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('klinik').get();

      List<String> clinics = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        clinics.add(data['nama_klinik'] ?? doc.id);
      }

      // Add default clinics if none found
      if (clinics.isEmpty) {
        clinics = [
          'Klinik Sehat Bersama',
          'Puskesmas Kecamatan',
          'RS Ibu dan Anak',
          'Klinik Pratama Medika',
          'Puskesmas Kelurahan',
        ];
      }

      setState(() {
        _clinics = clinics;
        _isLoadingClinics = false;
      });
    } catch (e) {
      debugPrint('Gagal mengambil daftar klinik: $e');
      setState(() {
        _clinics = [
          'Klinik Sehat Bersama',
          'Puskesmas Kecamatan',
          'RS Ibu dan Anak',
          'Klinik Pratama Medika',
          'Puskesmas Kelurahan',
        ];
        _isLoadingClinics = false;
      });
    }
  }

  void _onChildSelected(String? childName) {
    if (childName != null) {
      final selectedChild = _childrenData.firstWhere(
        (child) => child['nama'] == childName,
        orElse: () => {},
      );

      setState(() {
        _nama = childName;
        _namaOrangTua = selectedChild['nama_orang_tua'] ?? '';
        _jenisKelamin = selectedChild['jenis_kelamin'] ?? '';
      });
    }
  }

  void _selectDateTime(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFAFCC),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? now),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFFFAFCC),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dateTimeController.text =
              DateFormat('dd MMMM yyyy, HH:mm').format(_selectedDateTime!);
        });
      }
    }
  }

  void _saveSchedule() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedDateTime != null) {
        final schedule = {
          'nama': _nama,
          'nama_orang_tua': _namaOrangTua,
          'jenis_kelamin': _jenisKelamin,
          'jenis_vaksin': _jenisVaksin,
          'tanggal_waktu': Timestamp.fromDate(_selectedDateTime!),
          'keluhan': _keluhanController.text.trim().isEmpty
              ? null
              : _keluhanController.text.trim(),
          'dokter': _dokter,
          'klinik': _klinik,
        };

        widget.onSave(schedule);
      } else {
        _showErrorDialog('Silakan pilih tanggal dan jam.');
      }
    } else {
      _showErrorDialog('Silakan periksa input Anda.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text('Kesalahan'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Anak
          _buildSectionTitle('Data Anak'),
          const SizedBox(height: 12),
          _buildDropdownField(
            label: 'Nama Anak',
            icon: Icons.child_care_rounded,
            value: _nama,
            items: _isLoadingChildren
                ? []
                : _childrenData
                    .map((child) => child['nama'] as String)
                    .toList(),
            onChanged: _onChildSelected,
            validator: (value) => value == null ? 'Pilih nama anak' : null,
            isLoading: _isLoadingChildren,
            emptyMessage:
                'Belum ada data anak. Tambahkan di menu Informasi Anak.',
          ),
          const SizedBox(height: 16),

          // Nama Orang Tua (Auto-filled, but editable)
          _buildInputField(
            label: 'Nama Orang Tua',
            icon: Icons.person_rounded,
            initialValue: _namaOrangTua,
            onSaved: (value) => _namaOrangTua = value,
            validator: (value) => (value == null || value.isEmpty)
                ? 'Nama orang tua harus diisi'
                : null,
          ),
          const SizedBox(height: 16),

          // Jenis Kelamin (Auto-filled, but editable)
          _buildDropdownField(
            label: 'Jenis Kelamin',
            icon: Icons.wc_rounded,
            value: _jenisKelamin,
            items: _genders,
            onChanged: (value) => setState(() => _jenisKelamin = value),
            validator: (value) => value == null ? 'Pilih jenis kelamin' : null,
          ),
          const SizedBox(height: 20),

          // Informasi Imunisasi
          _buildSectionTitle('Informasi Imunisasi'),
          const SizedBox(height: 12),
          _buildDropdownField(
            label: 'Jenis Vaksin',
            icon: Icons.vaccines_rounded,
            value: _jenisVaksin,
            items: _vaccines,
            onChanged: (value) => setState(() => _jenisVaksin = value),
            validator: (value) => value == null ? 'Pilih jenis vaksin' : null,
          ),
          const SizedBox(height: 16),

          // Tanggal dan Waktu
          _buildDateTimeField(),
          const SizedBox(height: 16),

          // Keluhan (Optional)
          _buildInputField(
            label: 'Keluhan (Opsional)',
            icon: Icons.note_rounded,
            controller: _keluhanController,
            maxLines: 3,
            onSaved: (value) => _keluhan = value,
          ),
          const SizedBox(height: 20),

          // Informasi Klinik
          _buildSectionTitle('Informasi Klinik'),
          const SizedBox(height: 12),
          _buildDropdownField(
            label: 'Dokter',
            icon: Icons.local_hospital_rounded,
            value: _dokter,
            items: _doctors,
            onChanged: (value) => setState(() => _dokter = value),
            validator: (value) => value == null ? 'Pilih dokter' : null,
          ),
          const SizedBox(height: 16),

          _buildDropdownField(
            label: 'Klinik',
            icon: Icons.location_on_rounded,
            value: _klinik,
            items: _clinics,
            onChanged: (value) => setState(() => _klinik = value),
            validator: (value) => value == null ? 'Pilih klinik' : null,
            isLoading: _isLoadingClinics,
          ),
          const SizedBox(height: 30),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFAFCC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Simpan Jadwal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F2937),
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    String? initialValue,
    TextEditingController? controller,
    int maxLines = 1,
    void Function(String?)? onSaved,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: controller == null ? initialValue : null,
          controller: controller,
          maxLines: maxLines,
          onSaved: onSaved,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFFAFCC), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
    bool isLoading = false,
    String? emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFFFAFCC),
                      ),
                    ),
                  )
                : Icon(icon, color: const Color(0xFF9CA3AF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFFAFCC), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: items.isEmpty && !isLoading
              ? [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      emptyMessage ?? 'Tidak ada data tersedia',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ]
              : items
                  .map((item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                        ),
                      ))
                  .toList(),
          onChanged: isLoading ? null : onChanged,
          validator: validator,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal dan Waktu',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateTimeController,
          readOnly: true,
          onTap: () => _selectDateTime(context),
          validator: (value) => (value == null || value.isEmpty)
              ? 'Pilih tanggal dan waktu'
              : null,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_today_rounded,
                color: Color(0xFF9CA3AF)),
            suffixIcon:
                const Icon(Icons.arrow_drop_down, color: Color(0xFF9CA3AF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFFAFCC), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            hintText: 'Pilih tanggal dan waktu',
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontFamily: 'Poppins',
            ),
          ),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _dateTimeController.dispose();
    _keluhanController.dispose();
    super.dispose();
  }
}
