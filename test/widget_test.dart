import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

void main() {
  runApp(const AsansorApp());
}

class AsansorApp extends StatelessWidget {
  const AsansorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asansor Takip',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AnaSayfa(),
    );
  }
}

class AsansorModel {
  String binaAdi;
  String yonetici;
  String bolge;

  AsansorModel({required this.binaAdi, required this.yonetici, required this.bolge});
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  String secilenBolge = 'TUMU';
  String aramaKelimesi = '';

  final List<String> bolgeler = [
    'TUMU',
    'MURADIYE',
    'SARUHANLI',
    'EGE',
    'ALAYBEY',
    'HOROZKOY',
    'KARAKOY',
    'YENI MAHALLE',
    'ETRAF'
  ];

  // SİSTEMİN ÇALIŞTIĞINI GÖRMEN İÇİN GARANTİ TEST LİSTESİ
  List<AsansorModel> asansorler = [
    AsansorModel(binaAdi: "TEST BİNASI (Sistem Aktif)", yonetici: "Yönetici Yok", bolge: "MURADIYE"),
  ];

  // WPS CSV DOSYASINI OKUMA FONKSİYONU
  Future<void> dosyaIceriAktar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      try {
        final bytes = result.files.single.bytes!;
        // Türkçe karakterler bozulmasın diye ISO-8859-9 (Türkçe Windows) veya UTF-8 deniyoruz
        String dosyaIcerigi = '';
        try {
          dosyaIcerigi = utf8.decode(bytes);
        } catch (_) {
          dosyaIcerigi = latin1.decode(bytes);
        }

        List<String> satirlar = dosyaIcerigi.split('\n');
        List<AsansorModel> yeniListe = [];
        String dosyaAdi = result.files.single.name.toUpperCase();
        
        // Hangi bölgeye ait olduğunu dosya adından bulalım
        String tespitEdilenBolge = 'TUMU';
        for (var b in bolgeler) {
          if (dosyaAdi.contains(b)) {
            tespitEdilenBolge = b;
            break;
          }
        }

        for (int i = 0; i < satirlar.length; i++) {
          String satir = satirlar[i].trim();
          if (satir.isEmpty) continue;

          // WPS Türkçe CSV'lerde noktalı virgül (;) veya virgül (,) kullanılır
          List<String> sutunlar = satir.contains(';') ? satir.split(';') : satir.split(',');

          if (sutunlar.isNotEmpty) {
            String bina = sutunlar[0].trim().replaceAll('"', '');
            // Başlık satırıysa atla
            if (bina.toLowerCase().contains('bina') || bina.toLowerCase().contains('adı')) continue;

            String yonetici = sutunlar.length > 1 ? sutunlar[1].trim().replaceAll('"', '') : '-';
            String bolge = sutunlar.length > 2 && sutunlar[2].trim().isNotEmpty 
                ? sutunlar[2].trim().replaceAll('"', '').toUpperCase() 
                : tespitEdilenBolge;

            if (bina.isNotEmpty) {
              yeniListe.add(AsansorModel(
                binaAdi: bina,
                yonetici: yonetici.isEmpty ? '-' : yonetici,
                bolge: bolge,
              ));
            }
          }
        }

        setState(() {
          asansorler.addAll(yeniListe);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('BAŞARILI! ${yeniListe.length} bina listeye eklendi.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Hata"),
              content: Text("Okunamadı: $e"),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tamam"))],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtrelenmisListe = asansorler.where((a) {
      final bolgeUygun = secilenBolge == 'TUMU' || a.bolge.toUpperCase().contains(secilenBolge.toUpperCase());
      final aramaUygun = a.binaAdi.toLowerCase().contains(aramaKelimesi.toLowerCase()) ||
          a.yonetici.toLowerCase().contains(aramaKelimesi.toLowerCase());
      return bolgeUygun && aramaUygun;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asansor Takip & CSV Aktarim'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'CSV Dosyasi Yukle',
            onPressed: dosyaIceriAktar,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  aramaKelimesi = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Bina veya Yonetici Ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: bolgeler.length,
              itemBuilder: (context, index) {
                final b = bolgeler[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(b),
                    selected: secilenBolge == b,
                    onSelected: (selected) {
                      setState(() {
                        secilenBolge = b;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: filtrelenmisListe.isEmpty 
              ? const Center(child: Text("Bu bölgede kayıt bulunamadı."))
              : ListView.builder(
              itemCount: filtrelenmisListe.length,
              itemBuilder: (context, index) {
                final item = filtrelenmisListe[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.business, color: Colors.blueAccent),
                    title: Text(item.binaAdi, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Yonetici: ${item.yonetici}'),
                    trailing: Chip(
                      label: Text(item.bolge, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.blue.shade50,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}