import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inisialisasi Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jadwal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  final List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  void _fetchSchedules() async {
    try {
      User? user = FirebaseAuth
          .instance.currentUser; // Ambil pengguna yang sedang terautentikasi

      if (user != null) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('tambah_jadwal')
            .where('userId', isEqualTo: user.uid) // Filter berdasarkan user ID
            .orderBy('tanggal_waktu') // Mengurutkan berdasarkan tanggal_waktu
            .get();
        setState(() {
          _schedules.clear();
          for (var doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;

            // Konversi dari Timestamp ke DateTime
            if (data['tanggal_waktu'] is Timestamp) {
              DateTime dateTime = (data['tanggal_waktu'] as Timestamp).toDate();
              data['tanggal_waktu'] = dateTime; // Simpan sebagai DateTime
            }

            _schedules.add(data);
          }
        });
      }
    } catch (e) {
      print('Gagal mengambil jadwal: $e');
    }
  }

  void _addSchedule(Map<String, dynamic> schedule) async {
    try {
      User? user = FirebaseAuth
          .instance.currentUser; // Ambil pengguna yang sedang terautentikasi

      if (user != null) {
        // Tambahkan userId ke data jadwal
        schedule['userId'] = user.uid;

        // Simpan data ke Firestore
        await FirebaseFirestore.instance
            .collection('tambah_jadwal')
            .add(schedule);
        setState(() {
          _schedules.add(schedule);
        });
      }
    } catch (e) {
      print('Gagal menyimpan jadwal: $e');
    }
  }

  void _showAddScheduleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Jadwal Imunisasi'),
          content: SingleChildScrollView(
            child: JadwalForm(onSave: _addSchedule),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                // Logika penyimpanan sudah ada di JadwalForm
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _editSchedule(int index) async {
    Map<String, dynamic> schedule = _schedules[index];
    print('Editing schedule with ID: ${schedule['id']}');

    // Simpan konteks yang lebih tinggi
    BuildContext dialogContext = context;

    showDialog(
      context: dialogContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Jadwal Imunisasi'),
          content: SingleChildScrollView(
            child: JadwalForm(
              onSave: (updatedSchedule) async {
                print('Updated schedule data: $updatedSchedule');
                try {
                  await FirebaseFirestore.instance
                      .collection('tambah_jadwal')
                      .doc(schedule['id'])
                      .update(updatedSchedule);
                  print('Schedule updated successfully');
                  _fetchSchedules(); // Memper barui daftar jadwal

                  // Tutup dialog setelah menyimpan
                  Navigator.of(dialogContext).pop(); // Tutup dialog

                  // Tampilkan informasi jadwal yang diperbarui
                  setState(() {
                    // Memperbarui tampilan dengan data terbaru
                    _schedules[index] =
                        updatedSchedule; // Memperbarui jadwal di daftar
                  });
                } catch (e, stackTrace) {
                  print('Gagal mengupdate jadwal: $e');
                  print('Stack trace: $stackTrace');
                  if (mounted) {
                    showDialog(
                      context: dialogContext,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Kesalahan'),
                          content: const Text('Gagal mengupdate jadwal.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Tutup dialog
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
              initialData: schedule,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                // Panggil fungsi onSave untuk menyimpan jadwal yang diperbarui
                // Ini sudah ditangani di JadwalForm
              },
              child: const Text('Simpan'),
            )
          ],
        );
      },
    );
  }

  void _deleteSchedule(int index) async {
    await FirebaseFirestore.instance
        .collection('tambah_jadwal')
        .doc(_schedules[index]['id'])
        .delete();
    setState(() {
      _schedules.removeAt(index); // Perbaiki di sini
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Imunisasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: _schedules.length,
          itemBuilder: (context, index) {
            final schedule = _schedules[index];
            return Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nama: ${schedule['nama']}'),
                    Text('Jenis Kelamin: ${schedule['jenis_kelamin']}'),
                    Text('Jenis Vaksin: ${schedule['jenis_vaksin']}'),
                    Text(
                      'Tanggal: ${schedule['tanggal_waktu'] is DateTime ? DateFormat('yyyy-MM-dd').format(schedule['tanggal_waktu']) : 'Tidak ada'}',
                    ),
                    Text(
                      'Jam: ${schedule['tanggal_waktu'] is DateTime ? DateFormat('HH:mm').format(schedule['tanggal_waktu']) : 'Tidak ada'}',
                    ),
                    Text('Keluhan: ${schedule['keluhan'] ?? 'Tidak ada'}'),
                    Text('Dokter: ${schedule['dokter']}'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editSchedule(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteSchedule(index),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddScheduleDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

class JadwalForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  JadwalForm({super.key, required this.onSave, this.initialData});

  @override
  _JadwalFormState createState() => _JadwalFormState();
}

class _JadwalFormState extends State<JadwalForm> {
  final _formKey = GlobalKey<FormState>();
  String? _nama;
  String? _jenisKelamin;
  String? _jenisVaksin;
  DateTime? _selectedDateTime;
  String? _keluhan;
  String? _dokter;
  String? _klinik; // Tambahkan variabel untuk klinik

  final List<String> _genders = ['Laki-laki', 'Perempuan'];
  final List<String> _vaccines = [
    'Vaksin DPT',
    'Vaksin Polio',
    'Vaksin Hepatitis B',
    'Vaksin BCG',
    'Vaksin HIB'
  ];
  final List<String> _doctors = ['Dr. Andi', 'Dr. Budi', 'Dr. Citra'];

  final TextEditingController _dateTimeController = TextEditingController();

  List<String> _namaAnak = []; // Daftar nama anak
  List<String> _clinics = []; // Daftar klinik

  @override
  void initState() {
    super.initState();
    _fetchChildrenNames(); // Ambil nama anak
    _fetchClinics(); // Ambil daftar klinik

    if (widget.initialData != null) {
      _nama = widget.initialData!['nama'];
      _jenisKelamin = widget.initialData!['jenis_kelamin'];
      _jenisVaksin = widget.initialData!['jenis_vaksin'];

      if (widget.initialData!['tanggal_waktu'] is Timestamp) {
        _selectedDateTime =
            (widget.initialData!['tanggal_waktu'] as Timestamp).toDate();
      } else {
        _selectedDateTime = widget.initialData!['tanggal_waktu'];
      }

      _dokter = widget.initialData!['dokter'];

      _dateTimeController.text = _selectedDateTime != null
          ? DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!)
          : '';
    }
  }

  void _fetchChildrenNames() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('tb_anak') // Ganti dengan nama koleksi yang sesuai
          .where('userId', isEqualTo: userId)
          .get();

      List<String> names = [];
      for (var doc in snapshot.docs) {
        names.add(doc['nama']); // Ganti 'nama' dengan field yang sesuai
      }

      setState(() {
        _namaAnak = names;
      });
    } catch (e) {
      print('Gagal mengambil nama anak: $e');
    }
  }

  void _fetchClinics() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('klinik') // Ganti dengan nama koleksi yang sesuai
          .get();

      List<String> clinics = [];
      for (var doc in snapshot.docs) {
        clinics.add(
            doc['nama_klinik']); // Ganti 'nama_klinik' dengan field yang sesuai
      }

      setState(() {
        _clinics = clinics;
      });
    } catch (e) {
      print('Gagal mengambil daftar klinik: $e');
    }
  }

  void _selectDateTime(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDateTime ?? now,
        ),
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
              DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!);
        });
      }
    }
  }

  void _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedDateTime != null) {
        final schedule = {
          'nama': _nama,
          'jenis_kelamin': _jenisKelamin,
          'jenis_vaksin': _jenisVaksin,
          'tanggal_waktu': Timestamp.fromDate(
              _selectedDateTime!), // Simpan sebagai Timestamp
          'keluhan': _keluhan,
          'dokter': _dokter,
          'klinik': _klinik, // Simpan klinik yang dipilih
        };

        // Debugging: Print data yang akan disimpan
        print('Data yang akan disimpan: $schedule');

        widget
            .onSave(schedule); // Panggil fungsi onSave yang diberikan dari luar
        Navigator.of(context).pop();
      } else {
        // Tampilkan pesan kesalahan jika tanggal tidak dipilih
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Kesalahan'),
              content: const Text('Silakan pilih tanggal dan jam.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Kesalahan'),
            content: const Text('Silakan periksa input Anda.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Nama Anak'),
            items: _namaAnak.map((String name) {
              return DropdownMenuItem<String>(
                value: name,
                child: Text(name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _nama = value;
              });
            },
            validator: (value) => value == null ? 'Pilih nama anak' : null,
            value: _nama,
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
            items: _genders.map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _jenisKelamin = value;
              });
            },
            validator: (value) => value == null ? 'Pilih jenis kelamin' : null,
            value: _jenisKelamin,
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Jenis Vaksin'),
            items: _vaccines.map((String vaccine) {
              return DropdownMenuItem<String>(
                value: vaccine,
                child: Text(vaccine),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _jenisVaksin = value;
              });
            },
            validator: (value) => value == null ? 'Pilih jenis vaksin' : null,
            value: _jenisVaksin,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Tanggal dan Jam'),
            readOnly: true,
            controller: _dateTimeController,
            onTap: () => _selectDateTime(context),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Keluhan'),
            onSaved: (value) {
              _keluhan = value;
            },
            initialValue: _keluhan,
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Dokter'),
            items: _doctors.map((String doctor) {
              return DropdownMenuItem<String>(
                value: doctor,
                child: Text(doctor),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _dokter = value;
              });
            },
            validator: (value) => value == null ? 'Pilih dokter' : null,
            value: _dokter,
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Klinik'),
            items: _clinics.map((String clinic) {
              return DropdownMenuItem<String>(
                value: clinic,
                child: Text(clinic),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _klinik = value; // Simpan klinik yang dipilih
              });
            },
            validator: (value) => value == null ? 'Pilih klinik' : null,
            value: _klinik,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveSchedule, // Pastikan ini memanggil _saveSchedule
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
