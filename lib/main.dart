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

  // variable untuk penampung teks limit runner
  TextEditingController limitProccess = TextEditingController();

  Future<void> worker() async {
    // Update indikator child proses pada UI
    setState(() {
      currentProccess++;
      logs.add('proses nomor: $currentProccess dimulai');
    });

    // ini spawn child proses
    await compute((message) => null, 0);

    // Update indikator child proses UI
    setState(() {
      logs.add('proses nomor: $currentProccess selesai');
      currentProccess--;
    });
  }

  // Jalankan child proses
  void tryRun() {
    // Ubah dulu ke int, karna teks form jenis String
    int workerLimit = int.parse(limitProccess.value.text);

    // ini jumlah worker yg sudah di spawn ketika 1x klik
    int spawnedWorker = 0;

    // jalankan worker/child proses sejumlah limit nya
    while (spawnedWorker < workerLimit) {
      worker();
      spawnedWorker++;
    }
  }

  // Setup saat pertama dijalankan
  @override
  void initState() {
    super.initState();

    // Set default teks form nya menjadi 0 agar tidak kosong
    limitProccess.text = '0';
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
                  labelText: 'Proses limit',
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                ],
              ),
            ),
            if (currentProccess == 0)
              ElevatedButton(onPressed: tryRun, child: const Text('Run'))
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
