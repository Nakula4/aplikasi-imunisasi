import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:imunisasiku/screens/home_screen.dart';

class ChildInfoScreen extends StatefulWidget {
  const ChildInfoScreen({super.key});

  @override
  _ChildInfoScreenState createState() => _ChildInfoScreenState();
}

class _ChildInfoScreenState extends State<ChildInfoScreen> {
  List<Map<String, dynamic>> children = [];

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('tb_anak')
          .where('userId', isEqualTo: user.uid)
          .get();
      setState(() {
        children = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Anak'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: children.length,
          itemBuilder: (context, index) {
            final child = children[index];
            return Card(
              elevation: 8,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 225, 130, 252),
                      Colors.white
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Icon(
                          Icons.child_care,
                          size: 100,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Nama Anak: ${child['nama']}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Tanggal Lahir: ${child['tglLahir']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Jenis Kelamin: ${child['jenis_kelamin']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Keluhan: ${child['keluhan']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Tanggal Imunisasi Terakhir: ${child['terakhirImunisasi']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Dokter: ${child['dokter']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Berat Badan: ${child['berat']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Tinggi Badan: ${child['tinggi']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Lingkar Kepala: ${child['lingkarkpl']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showEditChildDialog(context, child);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddChildDialog(context);
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Data Anak',
      ),
    );
  }

  void _showAddChildDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String nama = '';
    String tglLahir = '';
    String jenisKelamin = '';
    String keluhan = '';
    String lastImmunizationDate = '';
    String berat = '';
    String tinggi = '';

    TextEditingController birthDateController = TextEditingController();
    TextEditingController lastImmunizationDateController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Data Anak'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nama'),
                    onSaved: (value) {
                      nama = value!;
                    },
                  ),
                  TextFormField(
                    controller: birthDateController,
                    decoration:
                        const InputDecoration(labelText: 'Tanggal Lahir'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        birthDateController.text =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      }
                    },
                    onSaved: (value) {
                      tglLahir = value!;
                    },
                  ),
                  DropdownButtonFormField(
                    decoration:
                        const InputDecoration(labelText: 'Jenis Kelamin'),
                    items: const [
                      DropdownMenuItem(
                        child: Text('Laki-laki'),
                        value: 'Laki-laki',
                      ),
                      DropdownMenuItem(
                        child: Text('Perempuan'),
                        value: 'Perempuan',
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        jenisKelamin = value as String;
                      });
                    },
                    onSaved: (value) {
                      jenisKelamin = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Keluhan'),
                    onSaved: (value) {
                      keluhan = value!;
                    },
                  ),
                  TextFormField(
                    controller: lastImmunizationDateController,
                    decoration: const InputDecoration(
                        labelText: 'Tanggal Imunisasi Terakhir'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        lastImmunizationDateController.text =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      }
                    },
                    onSaved: (value) {
                      lastImmunizationDate = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Berat Badan'),
                    onSaved: (value) {
                      berat = value!;
                    },
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Tinggi Badan'),
                    onSaved: (value) {
                      tinggi = value!;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  User? user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    await FirebaseFirestore.instance.collection('tb_anak').add({
                      'nama': nama,
                      'tglLahir': tglLahir,
                      'jenis_kelamin': jenisKelamin,
                      'keluhan': keluhan,
                      'terakhirImunisasi': lastImmunizationDate,
                      'berat': berat,
                      'tinggi': tinggi,
                      'userId': user.uid,
                    });

                    _fetchChildren();

                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Simpan'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  void _showEditChildDialog(BuildContext context, Map<String, dynamic> child) {
    final _formKey = GlobalKey<FormState>();
    String nama = child['nama'];
    String tglLahir = child['tglLahir'];
    String jenisKelamin = child['jenis_kelamin'];
    String keluhan = child['keluhan'];
    String lastImmunizationDate = child['terakhirImunisasi'];
    String berat = child['berat'];
    String tinggi = child['tinggi'];

    TextEditingController birthDateController =
        TextEditingController(text: tglLahir);
    TextEditingController lastImmunizationDateController =
        TextEditingController(text: lastImmunizationDate);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ubah Data Anak'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nama'),
                    initialValue: nama,
                    onSaved: (value) {
                      nama = value!;
                    },
                  ),
                  TextFormField(
                    controller: birthDateController,
                    decoration:
                        const InputDecoration(labelText: 'Tanggal Lahir'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        birthDateController.text =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      }
                    },
                    onSaved: (value) {
                      tglLahir = value!;
                    },
                  ),
                  DropdownButtonFormField(
                    decoration:
                        const InputDecoration(labelText: 'Jenis Kelamin'),
                    value: jenisKelamin,
                    items: const [
                      DropdownMenuItem(
                        child: Text('Laki-laki'),
                        value: 'Laki-laki',
                      ),
                      DropdownMenuItem(
                        child: Text('Perempuan'),
                        value: 'Perempuan',
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        jenisKelamin = value as String;
                      });
                    },
                    onSaved: (value) {
                      jenisKelamin = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Keluhan'),
                    initialValue: keluhan,
                    onSaved: (value) {
                      keluhan = value!;
                    },
                  ),
                  TextFormField(
                    controller: lastImmunizationDateController,
                    decoration: const InputDecoration(
                        labelText: 'Tanggal Imunisasi Terakhir'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        lastImmunizationDateController.text =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      }
                    },
                    onSaved: (value) {
                      lastImmunizationDate = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Berat Badan'),
                    initialValue: berat,
                    onSaved: (value) {
                      berat = value!;
                    },
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Tinggi Badan'),
                    initialValue: tinggi,
                    onSaved: (value) {
                      tinggi = value!;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  await FirebaseFirestore.instance
                      .collection('tb_anak')
                      .doc(child['id'])
                      .update({
                    'nama': nama,
                    'tglLahir': tglLahir,
                    'jenis_kelamin': jenisKelamin,
                    'keluhan': keluhan,
                    'terakhirImunisasi': lastImmunizationDate,
                    'berat': berat,
                    'tinggi': tinggi,
                  });

                  _fetchChildren();

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Simpan'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }
}
