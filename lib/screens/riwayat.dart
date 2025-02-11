import 'package:flutter/material.dart';

class Riwayat extends StatelessWidget {
  const Riwayat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Imunisasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildImmunizationCard(
              date: '2023-01-15',
              time: '09:00',
              vaccine: 'Vaksin DPT',
              doctor: 'Dr. Andi',
            ),
            const SizedBox(height: 20),
            _buildImmunizationCard(
              date: '2023-02-20',
              time: '10:30',
              vaccine: 'Vaksin Polio',
              doctor: 'Dr. Budi',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImmunizationCard({
    required String date,
    required String time,
    required String vaccine,
    required String doctor,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text('Waktu: $time'),
            Text('Jenis Vaksin: $vaccine'),
            Text('Dokter: $doctor'),
          ],
        ),
      ),
    );
  }
}
