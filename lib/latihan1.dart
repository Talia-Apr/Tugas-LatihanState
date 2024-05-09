// Import package flutter/material.dart yang berisi widget-widget
// untuk Material Design
import 'package:flutter/material.dart';

// Import package http untuk melakukan HTTP requests
import 'package:http/http.dart' as http;

// Import package convert untuk mengubah data ke format JSON
import 'dart:convert';

// Import package url_launcher untuk membuka URL di browser
import 'package:url_launcher/url_launcher.dart';

// Fungsi main() yang menjalankan aplikasi Flutter
void main() {
  runApp(const MyApp());
}

// Class University untuk merepresentasikan data universitas
// Mendefinisikan dua properti dalam kelas University,
// yaitu name dan website, yang akan digunakan untuk menyimpan nama universitas dan website-nya.
class University {
  String name;
  String website;

  // Menerima dua parameter yang wajib diisi (required),
  // yaitu name dan website, dan langsung menginisialisasi properti name
  // dan website dari objek yang dibuat dengan nilai parameter yang diterima.
  University({required this.name, required this.website});

  // Factory method untuk membuat objek University dari JSON
  factory University.fromJson(Map<String, dynamic> json) {
    // Mengembalikan instance baru dari kelas University.
    return University(
      // Mengambil nilai dari key 'name' dalam json dan menggunakannya
      // sebagai nilai untuk parameter name dalam konstruktor University.
      name: json['name'],
      // Mengambil nilai dari key 'web_pages' dalam json, yang merupakan list,
      // dan mengambil elemen pertama [0] dari list tersebut sebagai nilai
      // untuk parameter website dalam konstruktor University.
      website: json['web_pages'][0],
    );
  }
}

// Class MyApp sebagai root widget aplikasi
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Mendefinisikan list aseanCountries yang berisi nama-nama negara ASEAN.
  // List ini akan digunakan sebagai pilihan dalam dropdown menu untuk memilih negara.
  List<String> aseanCountries = [
    'Singapore',
    'Malaysia',
    'Indonesia',
    'Thailand',
    'Philippines',
    'Vietnam',
    'Myanmar',
    'Cambodia',
    'Laos',
    'Brunei'
  ];

  // Nilai default untuk dropdown
  String selectedCountry = 'Indonesia';

  // Future untuk menyimpan data universitas
  late Future<List<University>> universitiesFuture;

  // menginisialisasi data awal yang diperlukan oleh widget,
  // seperti mengambil data dari server atau melakukan
  // persiapan lain sebelum widget dirender.
  @override
  void initState() {
    super.initState();
    // Menginisialisasi selectedCountry dengan nilai default 'Indonesia'.
    // Nilai ini akan digunakan untuk menyimpan negara yang dipilih dari dropdown menu.
    universitiesFuture = fetchUniversities('Indonesia');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Menghilangkan tulisan debug
      debugShowCheckedModeBanner: false,
      // Mengembalikan widget Scaffold yang merupakan kerangka dasar untuk tata letak aplikasi.
      home: Scaffold(
         // Menetapkan AppBar pada aplikasi dengan judul 'Universitas di Negara ASEAN'.
        appBar: AppBar(
          title: const Text(
            // Judul AppBar
            'Universitas di Negara ASEAN',
            style: TextStyle(
              // Warna teks judul AppBar
              color: Colors.white,
              // Ketebalan teks judul AppBar
              fontWeight: FontWeight.bold,
            ),
          ),
          // Pusatkan judul AppBar
          centerTitle: true,
          // Warna latar belakang AppBar
          backgroundColor: const Color.fromARGB(255, 0, 128, 255),
        ),
        // Column untuk tata letak dropdown dan ListView
        body: Column(
          children: [
            // Dropdown untuk memilih negara ASEAN
            DropdownButton<String>(
              // Menentukan nilai yang dipilih saat ini dalam dropdown
              value: selectedCountry,
              // Menerima parameter newValue yang merupakan nilai
              // dari opsi yang dipilih oleh pengguna.
              onChanged: (String? newValue) {
                // Membangun ulang widget
                setState(() {
                  // Mengupdate nilai
                  selectedCountry = newValue!;
                  // Memperbarui universitiesFuture dengan Future hasil pemanggilan 
                  universitiesFuture = fetchUniversities(selectedCountry);
                });
              },
              // mengubah setiap elemen dalam list menjadi dropdown
              items: aseanCountries.map<DropdownMenuItem<String>>((String value) {
                // Mengembalikan sebuah DropdownMenuItem baru
                // dengan nilai value dari elemen saat ini 
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
                // Mengubah hasil dari map menjadi list 
              }).toList(),
            ),
            // Membuat FutureBuilder untuk menampilkan data universitas
            FutureBuilder<List<University>>(
              // Future untuk mendapatkan data universitas dari API
              future: universitiesFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                          // Card untuk menampilkan informasi universitas
                          return Card(
                            // Properti elevation digunakan untuk mengatur tingkat bayangan (elevation) dari kartu.
                          elevation: 2,
                          // memberikan jarak antara kartu dengan elemen-elemen di sekitarnya. 
                          margin: const EdgeInsets.all(5),
                          // Menampilkan konten dalam format baris dengan judul, subtitle, dan ikon.
                          child: ListTile(
                            // Menampilkan judul universitas. snapshot.data![index] mengambil
                            // data universitas pada indeks tertentu dari snapshot.data,
                            // dan .name mengambil nama universitas dari data tersebut.
                            title: Text(snapshot.data![index].name),
                            // Menampilkan website universitas. snapshot.data![index] mengambil
                            // data universitas pada indeks tertentu dari snapshot.data,
                            // dan .website mengambil website universitas dari data tersebut.
                            subtitle: Text(snapshot.data![index].website),
                            // Menambahkan aksi ketika ListTile di-tap.
                            // maka akan menjalankan fungsi yang membuka website universitas.
                            onTap: () {
                              // Menggunakan URL Launcher untuk
                              // membuka website universitas
                              launchURL(snapshot.data![index].website);
                            },
                            // Menambahkan icon di bagian kanan ListTile.
                            trailing: const Icon(Icons.school_rounded),
                          ),
                        );
                      },
                    ),
                  );
                // Blok ini akan dieksekusi jika terjadi error saat memuat data.
                // snapshot.hasError akan bernilai true jika terdapat error.
                } else if (snapshot.hasError) {
                  // Jika terjadi error, akan ditampilkan teks
                  // 'Error: ${snapshot.error}' di tengah layar menggunakan widget Center.
                  return Center(
                    // Menampilkan pesan error jika terjadi
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                // Jika tidak terjadi error dan data masih dalam proses dimuat
                // (status ConnectionState.waiting), maka akan ditampilkan
                // indikator loading CircularProgressIndicator()
                // di tengah layar menggunakan widget Center.
                return const Center(
                  // Menampilkan indikator loading
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk mengambil data universitas dari API berdasarkan negara
  Future<List<University>> fetchUniversities(String country) async {
    // Menggunakan package http untuk melakukan HTTP GET request ke URL API
    final response = await http.get(Uri.parse(
        'http://universities.hipolabs.com/search?country=$country'));
    // Memeriksa apakah respons dari server memiliki status code 200,
    // yang artinya request berhasil.
    if (response.statusCode == 200) {
      // Mengubah respons dari server menjadi bentuk list JSON
      List<dynamic> data = jsonDecode(response.body);
      // Membuat list kosong universities yang akan berisi objek University.
      List<University> universities = [];
      // Melakukan iterasi terhadap list JSON
      for (var item in data) {
        universities.add(University.fromJson(item));
      }
      // Mengembalikan list
      return universities;
      // Melempar exception jika respons dari server tidak
      // memiliki status code 200, yang berarti gagal mengambil data universitas.
    } else {
      throw Exception('Failed to load universities');
    }
  }

  // Menerima parameter url sebagai URL yang akan dibuka
  void launchURL(String url) async {
    // Menggunakan fungsi canLaunch untuk memeriksa 
    if (await canLaunch(url)) {
      // Mengembalikan true, maka fungsi launch
      // akan dipanggil untuk membuka URL.
      await launch(url);
      // Menangani situasi di mana URL tidak dapat dibuka oleh browser.
    } else {
      throw 'Could not launch $url';
    }
  }
}
