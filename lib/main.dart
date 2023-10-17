import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeApp(),
    );
  }
}

class HomeApp extends StatefulWidget {
  const HomeApp({super.key});

  @override
  State<HomeApp> createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  // variable untuk indikator berapa jumlah proses yg sedang berjalan
  int currentProccess = 0;
  List<String> logs = [''];

  // variable untuk penampung teks limit runner & CPU difficulty
  TextEditingController limitProccess = TextEditingController();
  TextEditingController cpuStressLevel = TextEditingController();

  Future<void> worker(int number, int level) async {
    // spawn child proses
    String result = await compute(
      (Map message) {
        Random rng = Random();
        int a = rng.nextInt(message['level']);
        List b = [];
        while (a - 1 != 1) {
          b.add(a);
          a = rng.nextInt(message['level']);
        }

        return 'proses ke: ${message['number']} selesai';
      },
      {'number': number, 'level': level},
    );

    // Update indikator child proses UI
    setState(() {
      logs.add(result);
      currentProccess--;
    });
  }

  // Jalankan child proses
  void runner() {
    // Kosongkan dulu logs
    setState(() {
      logs = [''];
    });

    // Ubah dulu ke int, karna teks form jenis String
    int workerLimit = int.parse(limitProccess.value.text);
    int level = int.parse(cpuStressLevel.value.text);

    // Update UI nya sesuai berapa jumlah yang dijalankan
    setState(() {
      currentProccess = workerLimit;
    });

    // jalankan worker/child proses sejumlah limit nya
    int spawnedWorker = 0;
    while (spawnedWorker < workerLimit) {
      worker(spawnedWorker, level);
      spawnedWorker++;
    }
  }

  // Setup saat pertama dijalankan
  @override
  void initState() {
    super.initState();

    // Set default teks form nya menjadi 0 agar tidak kosong
    limitProccess.text = '0';
    cpuStressLevel.text = '1000';
  }

  // Bagian UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asynchronous Child Proccess Test'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Proses berjalan: $currentProccess'),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: limitProccess,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Jumlah Child Proses',
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: cpuStressLevel,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Tingkat Stress CPU',
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                ],
              ),
            ),
            if (currentProccess == 0)
              ElevatedButton(onPressed: runner, child: const Text('Run'))
            else
              const CircularProgressIndicator(),
            Column(
              verticalDirection: VerticalDirection.up,
              children: <Widget>[
                for (String log in logs) Text(log),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
