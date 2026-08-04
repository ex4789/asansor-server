import 'dart:convert';
// WEB'DE DOSYA İNDİRMEK İÇİN GEREKLİ KÜTÜPHANELER
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// Web için özel indirme paketi (Sadece web ortamında çalışır)
import 'package:universal_html/html.dart' as html;

final ValueNotifier<ThemeMode> temaNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const AsansorApp());
}

class AsansorApp extends StatelessWidget {
  const AsansorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Asansör Takip & Yedekleme Sistemi',
          themeMode: currentThemeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
          ),
          home: const AnaSayfa(),
        );
      },
    );
  }
}

class AylikBakim {
  String ayYil;
  double ucret;
  double odenen;
  String notlar;
  String degisenParcalar;
  
  bool butonKontrol;
  bool sinyalAmpul;
  bool kilitKontrol;
  bool fisKontak;

  bool regulatorAgirlik;
  bool tabloKontrol;
  bool halatKontrol;
  bool saptirmaGresorluk;
  bool tahrikKasnagi;
  bool makineFren;
  bool guvenlikDuzeni;

  bool makinaYaglari;
  bool diktatorlerKontrol;
  bool patenlerKontrol;

  AylikBakim({
    required this.ayYil,
    required this.ucret,
    required this.odenen,
    this.notlar = '',
    this.degisenParcalar = '',
    this.butonKontrol = false,
    this.sinyalAmpul = false,
    this.kilitKontrol = false,
    this.fisKontak = false,
    this.regulatorAgirlik = false,
    this.tabloKontrol = false,
    this.halatKontrol = false,
    this.saptirmaGresorluk = false,
    this.tahrikKasnagi = false,
    this.makineFren = false,
    this.guvenlikDuzeni = false,
    this.makinaYaglari = false,
    this.diktatorlerKontrol = false,
    this.patenlerKontrol = false,
  });

  double get kalanBorc => ucret - odenen;

  void tumunuIsaretle(bool durum) {
    butonKontrol = durum;
    sinyalAmpul = durum;
    kilitKontrol = durum;
    fisKontak = durum;
    regulatorAgirlik = durum;
    tabloKontrol = durum;
    halatKontrol = durum;
    saptirmaGresorluk = durum;
    tahrikKasnagi = durum;
    makineFren = durum;
    guvenlikDuzeni = durum;
    makinaYaglari = durum;
    diktatorlerKontrol = durum;
    patenlerKontrol = durum;
  }

  Map<String, dynamic> toJson() => {
        'ayYil': ayYil,
        'ucret': ucret,
        'odenen': odenen,
        'notlar': notlar,
        'degisenParcalar': degisenParcalar,
        'butonKontrol': butonKontrol,
        'sinyalAmpul': sinyalAmpul,
        'kilitKontrol': kilitKontrol,
        'fisKontak': fisKontak,
        'regulatorAgirlik': regulatorAgirlik,
        'tabloKontrol': tabloKontrol,
        'halatKontrol': halatKontrol,
        'saptirmaGresorluk': saptirmaGresorluk,
        'tahrikKasnagi': tahrikKasnagi,
        'makineFren': makineFren,
        'guvenlikDuzeni': guvenlikDuzeni,
        'makinaYaglari': makinaYaglari,
        'diktatorlerKontrol': diktatorlerKontrol,
        'patenlerKontrol': patenlerKontrol,
      };

  factory AylikBakim.fromJson(Map<String, dynamic> json) => AylikBakim(
        ayYil: json['ayYil'] ?? '',
        ucret: (json['ucret'] ?? 0.0).toDouble(),
        odenen: (json['odenen'] ?? 0.0).toDouble(),
        notlar: json['notlar'] ?? '',
        degisenParcalar: json['degisenParcalar'] ?? '',
        butonKontrol: json['butonKontrol'] ?? false,
        sinyalAmpul: json['sinyalAmpul'] ?? false,
        kilitKontrol: json['kilitKontrol'] ?? false,
        fisKontak: json['fisKontak'] ?? false,
        regulatorAgirlik: json['regulatorAgirlik'] ?? false,
        tabloKontrol: json['tabloKontrol'] ?? false,
        halatKontrol: json['halatKontrol'] ?? false,
        saptirmaGresorluk: json['saptirmaGresorluk'] ?? false,
        tahrikKasnagi: json['tahrikKasnagi'] ?? false,
        makineFren: json['makineFren'] ?? false,
        guvenlikDuzeni: json['guvenlikDuzeni'] ?? false,
        makinaYaglari: json['makinaYaglari'] ?? false,
        diktatorlerKontrol: json['diktatorlerKontrol'] ?? false,
        patenlerKontrol: json['patenlerKontrol'] ?? false,
      );
}

class AsansorModel {
  String binaAdi;
  String adres; 
  String yonetici;
  String telefon;
  String bolge;
  List<AylikBakim> aylar;

  AsansorModel({
    required this.binaAdi,
    required this.adres,
    required this.yonetici,
    required this.telefon,
    required this.bolge,
    List<AylikBakim>? aylar,
  }) : aylar = aylar ?? [];

  double get toplamBorc {
    double aktifBorc = 0.0;
    for (var ay in aylar) {
      if (ay.kalanBorc > 0) aktifBorc += ay.kalanBorc;
    }
    return aktifBorc;
  }

  double get toplamOdenen {
    double toplam = 0.0;
    for (var ay in aylar) {
      toplam += ay.odenen;
    }
    return toplam;
  }

  void guncelAyiEkle() {
    DateTime simdi = DateTime.now();
    List<String> ayIsimleri = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];
    
    for (int i = 0; i < simdi.month; i++) {
      String donguAyi = ayIsimleri[i];
      if (!aylar.any((a) => a.ayYil == donguAyi)) {
        aylar.add(AylikBakim(ayYil: donguAyi, ucret: 1000, odenen: 1000));
      }
    }
    aylar.sort((a, b) => ayIsimleri.indexOf(a.ayYil).compareTo(ayIsimleri.indexOf(b.ayYil)));
  }

  Map<String, dynamic> toJson() => {
        'binaAdi': binaAdi,
        'adres': adres,
        'yonetici': yonetici,
        'telefon': telefon,
        'bolge': bolge,
        'aylar': aylar.map((e) => e.toJson()).toList(),
      };

  factory AsansorModel.fromJson(Map<String, dynamic> json) => AsansorModel(
        binaAdi: json['binaAdi'] ?? '',
        adres: json['adres'] ?? '',
        yonetici: json['yonetici'] ?? '',
        telefon: json['telefon'] ?? '',
        bolge: json['bolge'] ?? '',
        aylar: json['aylar'] != null ? (json['aylar'] as List).map((e) => AylikBakim.fromJson(e)).toList() : [],
      );
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  String secilenBolge = 'TÜMÜ';
  String secilenAy = 'Ağustos';
  String aramaKelimesi = '';

  final List<String> bolgeler = [
    'TÜMÜ', 'MURADİYE', 'SARUHANLI', 'EGE', 'ALAYBEY',
    'HOROZKÖY', 'KARAKÖY', 'YENİ MAHALLE', 'ETRAF'
  ];

  final List<String> aylarListesi = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  List<AsansorModel> asansorler = [];
  final String hafizaAnahtari = 'ASANSOR_KALICI_VERI_SISTEMI';

  @override
  void initState() {
    super.initState();
    verileriYukle();
  }

  Future<void> verileriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final String? kayitliVeri = prefs.getString(hafizaAnahtari);
    if (kayitliVeri != null) {
      List decoded = jsonDecode(kayitliVeri);
      setState(() {
        asansorler = decoded.map((e) {
          var bina = AsansorModel.fromJson(e);
          bina.guncelAyiEkle(); 
          return bina;
        }).toList();
      });
      verileriKaydet();
    }
  }

  Future<void> verileriKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    String encoded = jsonEncode(asansorler.map((e) => e.toJson()).toList());
    await prefs.setString(hafizaAnahtari, encoded);
  }

  // WEB VE MOBİL UYUMLU GÜVENLİ DOSYA İNDİRME
  Future<void> yedekDosyaIndir() async {
    String encodedData = jsonEncode(asansorler.map((e) => e.toJson()).toList());
    try {
      DateTime simdi = DateTime.now();
      String dosyaAdi = "asansor_yedek_${simdi.year}-${simdi.month}-${simdi.day}.json";

      if (kIsWeb) {
        // Tarayıcı (Chrome) üzerinden dosya indirme yöntemi
        final bytes = utf8.encode(encodedData);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", dosyaAdi)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobil / Masaüstü uygulaması için
        await FilePicker.platform.saveFile(
          dialogTitle: 'Sistem Yedeğini Kaydet',
          fileName: dosyaAdi,
          bytes: utf8.encode(encodedData),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yedek dosyası başarıyla indirildi!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yedek indirilemedi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // YEDEK DOSYASINDAN GERİ YÜKLE
  Future<void> yedekDosyaYukle() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'txt'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      try {
        final bytes = result.files.single.bytes!;
        String dosyaIcerigi = utf8.decode(bytes);
        List decoded = jsonDecode(dosyaIcerigi);
        setState(() {
          asansorler = decoded.map((e) => AsansorModel.fromJson(e)).toList();
        });
        await verileriKaydet();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Yedek dosyadan başarıyla geri yüklendi!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Hata"),
              content: Text("Yedek yüklenirken hata oluştu: $e"),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tamam"))],
            ),
          );
        }
      }
    }
  }

  double get secilenAyToplamBorc {
    double toplam = 0;
    for (var b in asansorler) {
      for (var ay in b.aylar) {
        if (ay.ayYil == secilenAy) {
          toplam += ay.kalanBorc;
        }
      }
    }
    return toplam;
  }

  double get secilenAyToplamTahsilat {
    double toplam = 0;
    for (var b in asansorler) {
      for (var ay in b.aylar) {
        if (ay.ayYil == secilenAy) {
          toplam += ay.odenen;
        }
      }
    }
    return toplam;
  }

  void binaEkleDuzenleDialog({AsansorModel? mevcutBina}) {
    final binaAdiController = TextEditingController(text: mevcutBina?.binaAdi ?? '');
    final adresController = TextEditingController(text: mevcutBina?.adres ?? '');
    final yoneticiController = TextEditingController(text: mevcutBina?.yonetici ?? '');
    final telefonController = TextEditingController(text: mevcutBina?.telefon ?? '');
    String secilenBolgeForm = mevcutBina?.bolge ?? 'MURADİYE';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(mevcutBina == null ? '➕ Yeni Bina Ekle' : '✏️ Binayı Düzenle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: binaAdiController, decoration: const InputDecoration(labelText: 'Bina Adı (Örn: Yıldız Apt)')),
              const SizedBox(height: 8),
              TextField(controller: adresController, decoration: const InputDecoration(labelText: 'Adres')),
              const SizedBox(height: 8),
              TextField(controller: yoneticiController, decoration: const InputDecoration(labelText: 'Yönetici Adı')),
              const SizedBox(height: 8),
              TextField(controller: telefonController, decoration: const InputDecoration(labelText: 'Telefon Numarası', hintText: '05...'), keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: bolgeler.contains(secilenBolgeForm) && secilenBolgeForm != 'TÜMÜ' ? secilenBolgeForm : 'MURADİYE',
                items: bolgeler.where((b) => b != 'TÜMÜ').map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (val) {
                  if (val != null) secilenBolgeForm = val;
                },
                decoration: const InputDecoration(labelText: 'Bölge Seçin'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
            onPressed: () {
              if (binaAdiController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bina adı boş bırakılamaz!'), backgroundColor: Colors.red));
                return;
              }
              setState(() {
                if (mevcutBina == null) {
                  var yeniBina = AsansorModel(
                    binaAdi: binaAdiController.text.trim(),
                    adres: adresController.text.trim(),
                    yonetici: yoneticiController.text.trim().isEmpty ? '-' : yoneticiController.text.trim(),
                    telefon: telefonController.text.trim(),
                    bolge: secilenBolgeForm,
                  );
                  yeniBina.guncelAyiEkle();
                  asansorler.add(yeniBina);
                } else {
                  mevcutBina.binaAdi = binaAdiController.text.trim();
                  mevcutBina.adres = adresController.text.trim();
                  mevcutBina.yonetici = yoneticiController.text.trim().isEmpty ? '-' : yoneticiController.text.trim();
                  mevcutBina.telefon = telefonController.text.trim();
                  mevcutBina.bolge = secilenBolgeForm;
                }
                verileriKaydet();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bina bilgileri başarıyla kaydedildi!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> dosyaIceriAktar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      try {
        final bytes = result.files.single.bytes!;
        String dosyaIcerigi = '';
        try {
          dosyaIcerigi = utf8.decode(bytes);
        } catch (_) {
          dosyaIcerigi = latin1.decode(bytes);
        }

        List<String> satirlar = dosyaIcerigi.split(RegExp(r'\r\n|\n|\r'));
        List<AsansorModel> yeniListe = [];
        String dosyaAdi = result.files.single.name.toUpperCase();
        
        String tespitEdilenBolge = 'TÜMÜ';
        for (var b in bolgeler) {
          if (dosyaAdi.contains(b)) {
            tespitEdilenBolge = b;
            break;
          }
        }

        List<String> ayIsimleri = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];

        for (int i = 0; i < satirlar.length; i++) {
          String satir = satirlar[i].trim();
          if (satir.isEmpty) continue;

          List<String> sutunlar = satir.contains(';') ? satir.split(';') : satir.split(',');

          if (sutunlar.length > 2) {
            String binaAdi = sutunlar.length > 1 ? sutunlar[1].trim().replaceAll('"', '') : '';
            if (binaAdi.toLowerCase().contains('apt') && i == 0 || binaAdi.isEmpty) continue; 

            String adres = sutunlar.length > 2 ? sutunlar[2].trim().replaceAll('"', '') : '';
            String telefon = sutunlar.length > 3 ? sutunlar[3].trim().replaceAll('"', '') : '';
            String yonetici = sutunlar.length > 4 ? sutunlar[4].trim().replaceAll('"', '') : '-';
            
            String eskiBorcStr = sutunlar.length > 5 ? sutunlar[5].trim().replaceAll('"', '') : '0';
            String yeniBorcStr = sutunlar.length > 6 ? sutunlar[6].trim().replaceAll('"', '') : '1000';

            double eskiBorc = double.tryParse(eskiBorcStr) ?? 0.0;
            double aylikUcret = double.tryParse(yeniBorcStr) ?? 1000.0;
            if (aylikUcret == 0) aylikUcret = 1000.0; 

            List<AylikBakim> yillikAylar = [];
            int odenmeyenAySayisi = 0;
            if (eskiBorc > 0) {
              odenmeyenAySayisi = (eskiBorc / aylikUcret).ceil(); 
            }

            for (int m = 0; m < 6; m++) {
              bool borclu = (5 - m) < odenmeyenAySayisi; 
              yillikAylar.add(AylikBakim(
                ayYil: ayIsimleri[m],
                ucret: aylikUcret,
                odenen: borclu ? 0.0 : aylikUcret, 
              ));
            }

            yillikAylar.add(AylikBakim(
              ayYil: ayIsimleri[6],
              ucret: aylikUcret,
              odenen: 0.0, 
            ));

            var yeniBina = AsansorModel(
              binaAdi: binaAdi,
              adres: adres,
              yonetici: yonetici,
              telefon: telefon,
              bolge: tespitEdilenBolge,
              aylar: yillikAylar,
            );
            
            yeniBina.guncelAyiEkle(); 
            yeniListe.add(yeniBina);
          }
        }

        setState(() {
          asansorler.addAll(yeniListe);
        });
        await verileriKaydet();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('BAŞARILI! ${yeniListe.length} Bina Yüklendi!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Hata"),
              content: Text("Okuma Hatası: $e"),
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
      final bolgeUygun = secilenBolge == 'TÜMÜ' || a.bolge.toUpperCase().contains(secilenBolge.toUpperCase());
      final aramaUygun = a.binaAdi.toLowerCase().contains(aramaKelimesi.toLowerCase()) ||
          a.yonetici.toLowerCase().contains(aramaKelimesi.toLowerCase());
      return bolgeUygun && aramaUygun;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Asansör Sistem (${asansorler.length} Bina)'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Yedek Dosyası İndir (.json)',
            onPressed: yedekDosyaIndir,
          ),
          IconButton(
            icon: const Icon(Icons.upload),
            tooltip: 'Yedek Dosyasından Geri Yükle',
            onPressed: yedekDosyaYukle,
          ),
          IconButton(
            icon: Icon(temaNotifier.value == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Koyu / Aydınlık Mod',
            onPressed: () {
              setState(() {
                temaNotifier.value = temaNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, size: 28),
            tooltip: 'Yıllık Total Raporu',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => YillikRaporSayfasi(asansorler: asansorler),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'CSV Yükle',
            onPressed: dosyaIceriAktar,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => binaEkleDuzenleDialog(),
        label: const Text('Yeni Bina Ekle'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: aylarListesi.length,
              itemBuilder: (context, index) {
                final ay = aylarListesi[index];
                final seciliMi = secilenAy == ay;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: ChoiceChip(
                    label: Text(ay, style: TextStyle(fontWeight: FontWeight.bold, color: seciliMi ? Colors.white : null)),
                    selected: seciliMi,
                    selectedColor: Colors.blueAccent,
                    onSelected: (val) {
                      setState(() {
                        secilenAy = ay;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade800, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text("$secilenAy AYI BİLANÇOSU", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const Divider(color: Colors.white30, height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text("$secilenAy Borç", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text("${secilenAyToplamBorc.toStringAsFixed(0)} TL", style: const TextStyle(color: Colors.redAccent, fontSize: 17, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(height: 30, width: 1, color: Colors.white30),
                    Column(
                      children: [
                        Text("$secilenAy Tahsilat", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text("${secilenAyToplamTahsilat.toStringAsFixed(0)} TL", style: const TextStyle(color: Colors.greenAccent, fontSize: 17, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(height: 30, width: 1, color: Colors.white30),
                    Column(
                      children: [
                        const Text("Toplam Bina", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text("${asansorler.length}", style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TextField(
              onChanged: (val) => setState(() => aramaKelimesi = val),
              decoration: InputDecoration(
                hintText: 'Bina veya Yönetici Ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: bolgeler.length,
              itemBuilder: (context, index) {
                final b = bolgeler[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(b, style: const TextStyle(fontSize: 12)),
                    selected: secilenBolge == b,
                    onSelected: (selected) => setState(() => secilenBolge = b),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: filtrelenmisListe.isEmpty 
              ? const Center(child: Text("Bina bulunamadı. Alttan yeni bina ekleyin veya CSV yükleyin."))
              : ListView.builder(
              itemCount: filtrelenmisListe.length,
              itemBuilder: (context, index) {
                final item = filtrelenmisListe[index];
                var ilgiliAy = item.aylar.firstWhere(
                  (a) => a.ayYil == secilenAy,
                  orElse: () => AylikBakim(ayYil: secilenAy, ucret: 1000, odenen: 0),
                );

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: ilgiliAy.kalanBorc > 0 ? Colors.red.shade400 : Colors.green.shade600,
                      child: Icon(ilgiliAy.kalanBorc > 0 ? Icons.warning : Icons.check, color: Colors.white),
                    ),
                    title: Text(item.binaAdi, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('$secilenAy Ayı Borç: ${ilgiliAy.kalanBorc} TL | Ödenen: ${ilgiliAy.odenen} TL\n🔥 Total Birikmiş Borç: ${item.toplamBorc} TL'),
                    isThreeLine: true,
                    trailing: Chip(
                      label: Text(item.bolge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BinaDetaySayfasi(
                            bina: item,
                            secilenAy: secilenAy,
                            onKayitGuncellendi: () {
                              setState(() {});
                              verileriKaydet(); 
                            },
                            onBinaDuzenleIstegi: () {
                              binaEkleDuzenleDialog(mevcutBina: item);
                            },
                            onBinaSilIstegi: () {
                              setState(() {
                                asansorler.remove(item);
                              });
                              verileriKaydet();
                            },
                          ),
                        ),
                      );
                    },
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

class YillikRaporSayfasi extends StatelessWidget {
  final List<AsansorModel> asansorler;

  const YillikRaporSayfasi({super.key, required this.asansorler});

  @override
  Widget build(BuildContext context) {
    double toplamAlinmayanBorc = 0;
    double toplamAlinanTahsilat = 0;

    for (var b in asansorler) {
      toplamAlinmayanBorc += b.toplamBorc;
      toplamAlinanTahsilat += b.toplamOdenen;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Yıllık Total Raporu ve Bilanço'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(width: 2),
              ),
              child: Column(
                children: [
                  const Text("GENEL YILLIK ÖZET BİLANÇO", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Toplam Alınmayan Borç:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("${toplamAlinmayanBorc.toStringAsFixed(0)} TL", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Toplam Alınan Tahsilat:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("${toplamAlinanTahsilat.toStringAsFixed(0)} TL", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Kayıtlı Bina Adedi:", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      Text("${asansorler.length} Bina", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Binalara Göre Yıllık Alacak Listesi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: asansorler.length,
                itemBuilder: (context, index) {
                  var b = asansorler[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(b.binaAdi, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Yönetici: ${b.yonetici} | Bölge: ${b.bolge}"),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Kalan: ${b.toplamBorc} TL", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          Text("Alınan: ${b.toplamOdenen} TL", style: const TextStyle(color: Colors.green, fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BinaDetaySayfasi extends StatefulWidget {
  final AsansorModel bina;
  final String secilenAy;
  final VoidCallback onKayitGuncellendi;
  final VoidCallback onBinaDuzenleIstegi;
  final VoidCallback onBinaSilIstegi;

  const BinaDetaySayfasi({
    super.key, 
    required this.bina, 
    required this.secilenAy, 
    required this.onKayitGuncellendi,
    required this.onBinaDuzenleIstegi,
    required this.onBinaSilIstegi,
  });

  @override
  State<BinaDetaySayfasi> createState() => _BinaDetaySayfasiState();
}

class _BinaDetaySayfasiState extends State<BinaDetaySayfasi> {
  Future<void> haritadaAc() async {
    String adresStr = widget.bina.adres;
    if (adresStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu bina için adres girilmemiş!'), backgroundColor: Colors.red),
      );
      return;
    }
    final Uri mapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(adresStr)}');
    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harita açılamadı!'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> whatsappMesajGonder(AylikBakim ay) async {
    String tel = widget.bina.telefon.replaceAll(RegExp(r'\D'), '');
    if (tel.startsWith('0')) {
      tel = '90$tel';
    } else if (!tel.startsWith('90') && tel.length == 10) {
      tel = '90$tel';
    }

    String mesaj = "Merhaba ${widget.bina.yonetici}, ${widget.bina.binaAdi} asansörünün ${widget.secilenAy} ayı bakımı yapılmış ve formu doldurulmuştur. Bu aya ait kalan borcunuz: ${ay.kalanBorc} TL'dir. İyi günler dileriz.";
    
    final Uri whatsappUri = Uri.parse('https://wa.me/$tel?text=${Uri.encodeComponent(mesaj)}');
    
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp açılamadı! Telefon numarasını kontrol edin.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void binaSilmeIkiAsamaliOnay() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("⚠️ Binayı Sil"),
        content: Text("${widget.bina.binaAdi} adlı binayı silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context2) => AlertDialog(
                  title: const Text("🚨 KESİN KARARLI MISINIZ?", style: TextStyle(color: Colors.red)),
                  content: const Text("Bu bina ve geçmiş tüm bakım/borç verileri sistemden KALICI OLARAK silinecektir. Bu işlem geri alınamaz!"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context2), child: const Text("Vazgeç")),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      onPressed: () {
                        Navigator.pop(context2);
                        widget.onBinaSilIstegi();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bina kalıcı olarak silindi.'), backgroundColor: Colors.red),
                        );
                      },
                      child: const Text("Evet, Kalıcı Olarak Sil"),
                    ),
                  ],
                ),
              );
            },
            child: const Text("Evet, Devam Et"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var ay = widget.bina.aylar.firstWhere(
      (a) => a.ayYil == widget.secilenAy,
      orElse: () => AylikBakim(ayYil: widget.secilenAy, ucret: 1000, odenen: 0),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.bina.binaAdi} (${widget.secilenAy})'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Binayı Düzenle',
            onPressed: () {
              widget.onBinaDuzenleIstegi();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white70),
            tooltip: 'Bu Binayı Sil',
            onPressed: binaSilmeIkiAsamaliOnay,
          ),
          IconButton(
            icon: const Icon(Icons.done_all, size: 28),
            tooltip: '${widget.secilenAy} Ayının Formunu Tek Tuşla İşaretle',
            onPressed: () {
              setState(() {
                ay.tumunuIsaretle(true);
                widget.onKayitGuncellendi();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${widget.secilenAy} ayı bakım maddeleri eksiksiz işaretlendi!'), backgroundColor: Colors.green),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Expanded(child: Text(widget.bina.adres, style: const TextStyle(fontSize: 15))),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: haritadaAc,
                        icon: const Icon(Icons.map, color: Colors.white, size: 16),
                        label: const Text("Harita", style: TextStyle(color: Colors.white, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.green),
                          const SizedBox(width: 8),
                          Text("${widget.bina.yonetici} - ${widget.bina.telefon.isEmpty ? 'Yok' : widget.bina.telefon}", style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                      if (widget.bina.telefon.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () => whatsappMesajGonder(ay),
                          icon: const Icon(Icons.chat, color: Colors.white, size: 18),
                          label: const Text("WhatsApp", style: TextStyle(color: Colors.white, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text("${widget.secilenAy} Ayı Kalan Borç: ${ay.kalanBorc} TL", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 4),
                  Text("🔥 Binanın Total Birikmiş Borcu: ${widget.bina.toplamBorc} TL", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.indigo)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text("🛠️ ${widget.secilenAy} Ayı Resmi Bakım Formu & Tahsilat", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 10),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: TextEditingController(text: ay.odenen.toString())..selection = TextSelection.fromPosition(TextPosition(offset: ay.odenen.toString().length)),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Bu Ay Tahsil Edilen Tutar', border: OutlineInputBorder()),
                      onChanged: (val) {
                        ay.odenen = double.tryParse(val) ?? 0.0;
                        widget.onKayitGuncellendi();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: TextEditingController(text: ay.ucret.toString())..selection = TextSelection.fromPosition(TextPosition(offset: ay.ucret.toString().length)),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Bu Ayki Bakım Ücreti', border: OutlineInputBorder()),
                      onChanged: (val) {
                        ay.ucret = double.tryParse(val) ?? 1000.0;
                        widget.onKayitGuncellendi();
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Resmi Bakım Formu Maddeleri", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blueGrey)),
                        TextButton.icon(
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text("Temizle"),
                          onPressed: () {
                            setState(() {
                              ay.tumunuIsaretle(false);
                              widget.onKayitGuncellendi();
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(),

                    CheckboxListTile(title: const Text("Butonların Kontrolü"), value: ay.butonKontrol, activeColor: Colors.green, onChanged: (v) { setState(() { ay.butonKontrol = v ?? false; widget.onKayitGuncellendi(); }); }),
                    CheckboxListTile(title: const Text("Sinyal Ampül Kontrolü"), value: ay.sinyalAmpul, activeColor: Colors.green, onChanged: (v) { setState(() { ay.sinyalAmpul = v ?? false; widget.onKayitGuncellendi(); }); }),
                    CheckboxListTile(title: const Text("Kilitlerin Kontrolü"), value: ay.kilitKontrol, activeColor: Colors.green, onChanged: (v) { setState(() { ay.kilitKontrol = v ?? false; widget.onKayitGuncellendi(); }); }),
                    CheckboxListTile(title: const Text("Fiş Kontakların Kontrolü"), value: ay.fisKontak, activeColor: Colors.green, onChanged: (v) { setState(() { ay.fisKontak = v ?? false; widget.onKayitGuncellendi(); }); }),

                    CheckboxListTile(title: const Text("Regülatör Ağırlık Kontrolü"), value: ay.regulatorAgirlik, activeColor: Colors.green, onChanged: (v) { setState(() { ay.regulatorAgirlik = v ?? false; widget.onKayitGuncellendi(); }); }),
                    CheckboxListTile(title: const Text("Tabloların Kontrolü"), value: ay.tabloKontrol, activeColor: Colors.green, onChanged: (v) { setState(() { ay.tabloKontrol = v ?? false; widget.onKayitGuncellendi(); }); }),
                    CheckboxListTile(title: const Text("Halatların Kontrolü"), value: ay.halatKontrol, activeColor: Colors.green, onChanged: (v) { setState(() { ay.halatKontrol = v ?? false; widget.onKayitGuncellendi(); }); }),
                    CheckboxListTile(title: const Text("Saptırma Gresörlük Kontrolü"), value: ay.saptirmaGresorluk, activeColor: Colors.green, onChanged: (v) { setState(() { ay.saptirmaGresorluk = v ?? false; widget.onKayitGuncellendi(); }); }),
                    CheckboxListTile(title: const Text("Tahrik Kasnağı Kontrolü"), value: ay.tahrikKasnagi, activeColor: Colors.green, onChanged: (v) { setState(() { ay.tahrikKasnagi = v ?? false; widget.onKayitGuncellendi(); }); }),
                    CheckboxListTile(title: const Text("Makine Fren Kontrolü"), value: ay.makineFren, activeColor: Colors.green, onChanged: (v) { setState(() { ay.makineFren = v ?? false; widget.onKayitGuncellendi(); }); }),
                    CheckboxListTile(title: const Text("Güvenlik Düzeni Kontrolü"), value: ay.guvenlikDuzeni, activeColor: Colors.green, onChanged: (v) { setState(() { ay.guvenlikDuzeni = v ?? false; widget.onKayitGuncellendi(); }); }),

                    CheckboxListTile(title: const Text("Makina Yağlarının Kontrolü"), value: ay.makinaYaglari, activeColor: Colors.green, onChanged: (v) { setState(() { ay.makinaYaglari = v ?? false; widget.onKayitGuncellendi(); }); }),
                    CheckboxListTile(title: const Text("Diktatörlerin Kontrolü"), value: ay.diktatorlerKontrol, activeColor: Colors.green, onChanged: (v) { setState(() { ay.diktatorlerKontrol = v ?? false; widget.onKayitGuncellendi(); }); }),
                    CheckboxListTile(title: const Text("Patenlerin Kontrolü"), value: ay.patenlerKontrol, activeColor: Colors.green, onChanged: (v) { setState(() { ay.patenlerKontrol = v ?? false; widget.onKayitGuncellendi(); }); }),

                    const SizedBox(height: 20),
                    TextField(
                      controller: TextEditingController(text: ay.degisenParcalar)..selection = TextSelection.fromPosition(TextPosition(offset: ay.degisenParcalar.length)),
                      decoration: const InputDecoration(
                        labelText: 'Değişen ve Değişmesi Gereken Parçalar',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.build_circle),
                        filled: true,
                      ),
                      maxLines: 3,
                      onChanged: (val) {
                        ay.degisenParcalar = val;
                        widget.onKayitGuncellendi();
                      },
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
}