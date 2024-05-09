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

// Mendefinisikan dua properti pada kelas University,
// yaitu name untuk menyimpan nama universitas dan
// website untuk menyimpan URL website universitas.
class University {
  String name;
  String website;

  // Mendefinisikan constructor untuk kelas University yang
  // mengharuskan kedua properti name dan website untuk diisi
  // ketika membuat instance baru dari kelas University.
  University({required this.name, required this.website});

  // Mendefinisikan sebuah factory method bernama fromJson
  // yang digunakan untuk membuat instance University dari
  // data JSON. Method ini mengambil parameter berupa Map<String, dynamic>
  // yang berisi data JSON dan mengembalikan instance University.
  factory University.fromJson(Map<String, dynamic> json) {
    // Mengembalikan instance University baru dengan
    // menggunakan data dari json. json['name'] digunakan
    // untuk mengambil nilai nama universitas dari data JSON,
    // sedangkan json['web_pages'][0] digunakan untuk mengambil
    // URL website universitas. Karena web_pages adalah array,
    // menggunakan indeks [0] untuk mengambil URL website pertama dalam array tersebut.
    return University(
      name: json['name'],
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
  // Mendefinisikan list negara-negara ASEAN yang
  // akan ditampilkan dalam dropdown untuk memilih negara.
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

  // Menginisialisasi selectedCountry dengan nilai default 'Indonesia'.
  // Nilai ini akan digunakan untuk menyimpan negara yang dipilih dari dropdown menu.
  String selectedCountry = 'Indonesia';

  // Future untuk menyimpan data universitas
  late Future<List<University>> universitiesFuture;

  @override
  void initState() {
    super.initState();
    universitiesFuture = fetchUniversities('Indonesia');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Menghilangkan tulisan debug
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // AppBar aplikasi
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
              // Merupakan fungsi callback yang dipanggil ketika pengguna memilih
              // opsi dari dropdown. Pada bagian ini, setState digunakan untuk mengubah
              // state widget dan memperbarui tampilan ketika nilai dipilih berubah.
              // Nilai selectedCountry diubah menjadi nilai baru (newValue) yang dipilih
              // oleh pengguna, dan kemudian universitiesFuture diubah
              // dengan memanggil fungsi fetchUniversities(selectedCountry).
              value: selectedCountry,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCountry = newValue!;
                  universitiesFuture = fetchUniversities(selectedCountry);
                });
              },
              // Mengubah hasil map menjadi daftar yang dapat ditampilkan dalam DropdownButton.
              items: aseanCountries.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
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
                          // Elevasi Card
                          elevation: 2,
                          // Margin Card
                          margin: const EdgeInsets.all(5),
                          child: ListTile(
                            // Judul universitas
                            title: Text(snapshot.data![index].name),
                            // Website universitas
                            subtitle: Text(snapshot.data![index].website),
                            onTap: () {
                              // Menggunakan URL Launcher untuk
                              // membuka website universitas
                              launchURL(snapshot.data![index].website);
                            },
                            // Icon untuk membuka browser
                            trailing: const Icon(Icons.school_rounded),
                          ),
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    // Menampilkan pesan error jika terjadi
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
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
    // Membuat HTTP GET request ke URL tertentu yang mengandung parameter negara (country) yang diberikan.
    final response = await http.get(Uri.parse(
        'http://universities.hipolabs.com/search?country=$country'));
    // Mengecek status code response. Jika status code adalah 200 (OK), berarti request berhasil dan data universitas diterima.
    if (response.statusCode == 200) {
      // Mengubah data response (yang dalam format JSON) menjadi
      // list of map (List<dynamic> data), dimana setiap map mewakili satu universitas.
      List<dynamic> data = jsonDecode(response.body);
      // Menginisialisasi list kosong universities yang akan
      // diisi dengan objek University yang dibuat dari setiap map universitas.
      List<University> universities = [];
      for (var item in data) {
        universities.add(University.fromJson(item));
      }
      // Mengembalikan list universities jika request berhasil.
      return universities;
    } else {
      // Jika status code bukan 200, maka throw exception dengan pesan 'Failed to load universities'.
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
