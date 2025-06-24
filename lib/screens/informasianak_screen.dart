import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class InformasiAnakScreen extends StatefulWidget {
  const InformasiAnakScreen({super.key});

  @override
  State<InformasiAnakScreen> createState() => _InformasiAnakScreenState();
}

class _InformasiAnakScreenState extends State<InformasiAnakScreen> {
  Stream<QuerySnapshot>? _childrenStream;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _childrenStream = FirebaseFirestore.instance
            .collection('tb_anak')
            .where('userId', isEqualTo: user.uid)
            .snapshots();
      });
    }
  }

  void _refreshStream() {
    _initializeStream();
  }

  void _addChild(Map<String, dynamic> childData) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        childData['userId'] = user.uid;
        childData['updated_at'] = Timestamp.now();

        await FirebaseFirestore.instance.collection('tb_anak').add(childData);
        _showSuccessDialog();
      }
    } catch (e) {
      debugPrint('Gagal menyimpan data anak: $e');
      _showErrorDialog('Gagal menyimpan data anak: $e');
    }
  }

  void _editChild(String docId, Map<String, dynamic> updatedData) async {
    try {
      updatedData['updated_at'] = Timestamp.now();
      await FirebaseFirestore.instance
          .collection('tb_anak')
          .doc(docId)
          .update(updatedData);
      _showSuccessDialog('Data anak berhasil diperbarui!');
    } catch (e) {
      debugPrint('Gagal mengupdate data anak: $e');
      _showErrorDialog('Gagal mengupdate data anak: $e');
    }
  }

  void _deleteChild(String docId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus data anak ini?'),
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
            .collection('tb_anak')
            .doc(docId)
            .delete();
        _showSuccessDialog('Data anak berhasil dihapus!');
      } catch (e) {
        debugPrint('Gagal menghapus data anak: $e');
        _showErrorDialog('Gagal menghapus data anak: $e');
      }
    }
  }

  void _showAddChildDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsif berdasarkan lebar layar
            double maxWidth = MediaQuery.of(context).size.width;
            double dialogWidth = maxWidth > 600 ? 500 : maxWidth * 0.9;

            return Container(
              width: dialogWidth,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
                maxWidth: dialogWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: maxWidth > 400 ? 20 : 16,
                      vertical: maxWidth > 400 ? 20 : 16,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFCDB4DB), Color(0xFFFFC8DD)],
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
                        const Icon(Icons.child_care_rounded,
                            color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Tambah Data Anak',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(maxWidth > 400 ? 20 : 16),
                      child: InformasiAnakForm(onSave: (childData) {
                        _addChild(childData);
                        Navigator.of(context).pop();
                      }),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showEditChildDialog(Map<String, dynamic> childData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsif berdasarkan lebar layar
            double maxWidth = MediaQuery.of(context).size.width;
            double dialogWidth = maxWidth > 600 ? 500 : maxWidth * 0.9;

            return Container(
              width: dialogWidth,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
                maxWidth: dialogWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: maxWidth > 400 ? 20 : 16,
                      vertical: maxWidth > 400 ? 20 : 16,
                    ),
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
                        const Expanded(
                          child: Text(
                            'Edit Data Anak',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(maxWidth > 400 ? 20 : 16),
                      child: InformasiAnakForm(
                        initialData: childData,
                        onSave: (updatedData) {
                          _editChild(childData['id'], updatedData);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
            const Expanded(child: Text('Berhasil')),
          ],
        ),
        content: Text(message ?? 'Data anak berhasil disimpan!'),
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
            const Expanded(child: Text('Error')),
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
          title: const Text('Informasi Anak'),
          backgroundColor: const Color(0xFFCDB4DB),
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
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFCDB4DB),
                    Color(0xFFFFC8DD),
                    Color(0xFFFFAFCC),
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
                            Icons.child_care_rounded,
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
                                'Informasi Anak',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Kelola data anak untuk imunisasi',
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
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: FloatingActionButton(
                            onPressed: _showAddChildDialog,
                            backgroundColor: Colors.white.withOpacity(0.9),
                            foregroundColor: const Color(0xFFCDB4DB),
                            elevation: 4,
                            mini: true,
                            heroTag: "add_child_fab",
                            child: const Icon(Icons.add_rounded, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _childrenStream == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFFCDB4DB),
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Menginisialisasi...',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: _childrenStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 64, color: Colors.red[300]),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Text(
                                    'Terjadi kesalahan: ${snapshot.error}',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _refreshStream,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFCDB4DB),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Color(0xFFCDB4DB),
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
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCDB4DB)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
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
                                    'Tambahkan data anak pertama Anda\ndengan menekan tombol + di pojok kanan atas',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                      fontFamily: 'Poppins',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final docs = snapshot.data!.docs;
                        docs.sort((a, b) {
                          final aData = a.data() as Map<String, dynamic>;
                          final bData = b.data() as Map<String, dynamic>;

                          final aTimestamp = aData['updated_at'] as Timestamp?;
                          final bTimestamp = bData['updated_at'] as Timestamp?;

                          if (aTimestamp == null && bTimestamp == null)
                            return 0;
                          if (aTimestamp == null) return 1;
                          if (bTimestamp == null) return -1;

                          return bTimestamp.compareTo(aTimestamp);
                        });

                        return ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            Map<String, dynamic> data =
                                doc.data()! as Map<String, dynamic>;
                            data['id'] = doc.id;

                            // Handle tglLahir sebagai string
                            String? tanggalLahirStr =
                                data['tglLahir'] as String?;

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
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: data['jenis_kelamin'] ==
                                                      'Laki-laki'
                                                  ? [
                                                      const Color(0xFFBDE0FE),
                                                      const Color(0xFFA2D2FF)
                                                    ]
                                                  : [
                                                      const Color(0xFFFFAFCC),
                                                      const Color(0xFFFFC8DD)
                                                    ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            data['jenis_kelamin'] == 'Laki-laki'
                                                ? Icons.male_rounded
                                                : Icons.female_rounded,
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
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                tanggalLahirStr != null
                                                    ? tanggalLahirStr
                                                    : 'Tanggal lahir tidak tersedia',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                  fontFamily: 'Poppins',
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: data['jenis_kelamin'] ==
                                                    'Laki-laki'
                                                ? const Color(0xFF3B82F6)
                                                    .withOpacity(0.1)
                                                : const Color(0xFFEC4899)
                                                    .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            data['jenis_kelamin'] ?? '-',
                                            style: TextStyle(
                                              color: data['jenis_kelamin'] ==
                                                      'Laki-laki'
                                                  ? const Color(0xFF3B82F6)
                                                  : const Color(0xFFEC4899),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
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
                                            value: data['nama_ortu'] ?? '-',
                                            color: const Color(0xFFBDE0FE),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildDetailItem(
                                                  icon: Icons
                                                      .monitor_weight_rounded,
                                                  label: 'Berat Badan',
                                                  value: data['berat'] != null
                                                      ? '${data['berat']} kg'
                                                      : '-',
                                                  color:
                                                      const Color(0xFFCDB4DB),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: _buildDetailItem(
                                                  icon: Icons.height_rounded,
                                                  label: 'Tinggi Badan',
                                                  value: data['tinggi'] != null
                                                      ? '${data['tinggi']} cm'
                                                      : '-',
                                                  color:
                                                      const Color(0xFFA2D2FF),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (data['terakhirImunisasi'] !=
                                                  null &&
                                              data['terakhirImunisasi']
                                                  .toString()
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            _buildDetailRow(
                                              icon: Icons.vaccines_rounded,
                                              label: 'Terakhir Imunisasi',
                                              value: data['terakhirImunisasi']
                                                  .toString(),
                                              color: const Color(0xFFFFAFCC),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (data['keluhan'] != null &&
                                        data['keluhan']
                                            .toString()
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFAFCC)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                                  color:
                                                      const Color(0xFF6B46C1),
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3B82F6)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.edit_rounded,
                                                color: Color(0xFF3B82F6)),
                                            onPressed: () =>
                                                _showEditChildDialog(data),
                                            tooltip: 'Edit Data Anak',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                                Icons.delete_rounded,
                                                color: Color(0xFFEF4444)),
                                            onPressed: () =>
                                                _deleteChild(doc.id),
                                            tooltip: 'Hapus Data Anak',
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
                overflow: TextOverflow.ellipsis,
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

class InformasiAnakForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const InformasiAnakForm({super.key, required this.onSave, this.initialData});

  @override
  _InformasiAnakFormState createState() => _InformasiAnakFormState();
}

class _InformasiAnakFormState extends State<InformasiAnakForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _namaOrtuController = TextEditingController();
  final _beratController = TextEditingController();
  final _tinggiController = TextEditingController();
  final _keluhanController = TextEditingController();
  final _terakhirImunisasiController = TextEditingController();

  DateTime? _tglLahir;
  String? _jenisKelamin;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    if (widget.initialData != null) {
      _namaController.text = widget.initialData!['nama'] ?? '';
      _namaOrtuController.text = widget.initialData!['nama_ortu'] ?? '';
      _beratController.text = widget.initialData!['berat']?.toString() ?? '';
      _tinggiController.text = widget.initialData!['tinggi']?.toString() ?? '';
      _keluhanController.text = widget.initialData!['keluhan'] ?? '';
      _terakhirImunisasiController.text =
          widget.initialData!['terakhirImunisasi'] ?? '';
      _jenisKelamin = widget.initialData!['jenis_kelamin'];

      // Handle tglLahir sebagai string atau Timestamp
      if (widget.initialData!['tglLahir'] is String) {
        try {
          _tglLahir =
              DateFormat('dd MMMM yyyy').parse(widget.initialData!['tglLahir']);
        } catch (e) {
          debugPrint('Gagal parse tglLahir: $e');
        }
      } else if (widget.initialData!['tglLahir'] is Timestamp) {
        _tglLahir = (widget.initialData!['tglLahir'] as Timestamp).toDate();
      }
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && widget.initialData == null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _namaOrtuController.text =
                userData['username'] ?? userData['nama'] ?? '';
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar untuk responsivitas
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Data Anak'),
          SizedBox(height: isSmallScreen ? 8 : 12),
          _buildInputField(
            controller: _namaController,
            label: 'Nama Lengkap Anak',
            icon: Icons.child_care_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama anak harus diisi';
              }
              return null;
            },
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildInputField(
            controller: _namaOrtuController,
            label: 'Nama Orang Tua',
            icon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama orang tua harus diisi';
              }
              return null;
            },
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildGenderSelector(),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildDatePicker(),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildSectionTitle('Data Fisik'),
          SizedBox(height: isSmallScreen ? 8 : 12),
          // Membuat Row responsif untuk layar kecil
          isSmallScreen
              ? Column(
                  children: [
                    _buildInputField(
                      controller: _beratController,
                      label: 'Berat Badan (kg)',
                      icon: Icons.monitor_weight_rounded,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Berat badan harus diisi';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _tinggiController,
                      label: 'Tinggi Badan (cm)',
                      icon: Icons.height_rounded,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tinggi badan harus diisi';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _beratController,
                        label: 'Berat Badan (kg)',
                        icon: Icons.monitor_weight_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Berat badan harus diisi';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Masukkan angka yang valid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        controller: _tinggiController,
                        label: 'Tinggi Badan (cm)',
                        icon: Icons.height_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tinggi badan harus diisi';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Masukkan angka yang valid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildSectionTitle('Riwayat Kesehatan'),
          SizedBox(height: isSmallScreen ? 8 : 12),
          _buildInputField(
            controller: _terakhirImunisasiController,
            label: 'Terakhir Imunisasi (Opsional)',
            icon: Icons.vaccines_rounded,
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildInputField(
            controller: _keluhanController,
            label: 'Keluhan (Opsional)',
            icon: Icons.note_rounded,
            maxLines: 3,
          ),
          SizedBox(height: isSmallScreen ? 24 : 30),
          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 48 : 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCDB4DB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.initialData == null
                          ? 'Simpan Data Anak'
                          : 'Update Data Anak',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Text(
      title,
      style: TextStyle(
        fontSize: isSmallScreen ? 14 : 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1F2937),
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
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
              borderSide: const BorderSide(color: Color(0xFFCDB4DB), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 12 : 16),
          ),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Kelamin',
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _jenisKelamin = 'Laki-laki'),
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: _jenisKelamin == 'Laki-laki'
                        ? const Color(0xFFBDE0FE).withOpacity(0.2)
                        : const Color(0xFFF9FAFB),
                    border: Border.all(
                      color: _jenisKelamin == 'Laki-laki'
                          ? const Color(0xFFBDE0FE)
                          : const Color(0xFFE5E7EB),
                      width: _jenisKelamin == 'Laki-laki' ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.male_rounded,
                        color: _jenisKelamin == 'Laki-laki'
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF9CA3AF),
                        size: isSmallScreen ? 18 : 20,
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Flexible(
                        child: Text(
                          'Laki-laki',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: isSmallScreen ? 12 : 14,
                            color: _jenisKelamin == 'Laki-laki'
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF6B7280),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _jenisKelamin = 'Perempuan'),
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: _jenisKelamin == 'Perempuan'
                        ? const Color(0xFFFFAFCC).withOpacity(0.2)
                        : const Color(0xFFF9FAFB),
                    border: Border.all(
                      color: _jenisKelamin == 'Perempuan'
                          ? const Color(0xFFFFAFCC)
                          : const Color(0xFFE5E7EB),
                      width: _jenisKelamin == 'Perempuan' ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.female_rounded,
                        color: _jenisKelamin == 'Perempuan'
                            ? const Color(0xFFEC4899)
                            : const Color(0xFF9CA3AF),
                        size: isSmallScreen ? 18 : 20,
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Flexible(
                        child: Text(
                          'Perempuan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: isSmallScreen ? 12 : 14,
                            color: _jenisKelamin == 'Perempuan'
                                ? const Color(0xFFEC4899)
                                : const Color(0xFF6B7280),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal Lahir',
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _tglLahir ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFFCDB4DB),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() => _tglLahir = date);
            }
          },
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: const Color(0xFF9CA3AF),
                  size: isSmallScreen ? 18 : 20,
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Expanded(
                  child: Text(
                    _tglLahir != null
                        ? DateFormat('dd MMMM yyyy').format(_tglLahir!)
                        : 'Pilih tanggal lahir',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: isSmallScreen ? 12 : 14,
                      color: _tglLahir != null
                          ? const Color(0xFF1F2937)
                          : const Color(0xFF9CA3AF),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_jenisKelamin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jenis kelamin')),
      );
      return;
    }
    if (_tglLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal lahir')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User tidak login');

      final childData = {
        'nama': _namaController.text.trim(),
        'nama_ortu': _namaOrtuController.text.trim(),
        'jenis_kelamin': _jenisKelamin,
        'tglLahir': DateFormat('dd MMMM yyyy').format(_tglLahir!),
        'berat': double.tryParse(_beratController.text.trim()) ?? 0.0,
        'tinggi': double.tryParse(_tinggiController.text.trim()) ?? 0.0,
        'keluhan': _keluhanController.text.trim().isEmpty
            ? null
            : _keluhanController.text.trim(),
        'terakhirImunisasi': _terakhirImunisasiController.text.trim().isEmpty
            ? null
            : _terakhirImunisasiController.text.trim(),
      };

      widget.onSave(childData);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _namaOrtuController.dispose();
    _beratController.dispose();
    _tinggiController.dispose();
    _keluhanController.dispose();
    _terakhirImunisasiController.dispose();
    super.dispose();
  }
}
