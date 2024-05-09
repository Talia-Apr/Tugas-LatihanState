// Import package flutter/material.dart yang berisi widget-widget
// untuk Material Design
import 'package:flutter/material.dart';

// Mengimpor semua fungsi dan kelas yang diperlukan dari paket flutter_bloc. 
import 'package:flutter_bloc/flutter_bloc.dart';

// Import package http untuk melakukan HTTP requests
import 'package:http/http.dart' as http;

// Import package convert untuk mengubah data ke format JSON
import 'dart:convert';

// Import package url_launcher untuk membuka URL di browser
import 'package:url_launcher/url_launcher.dart';

// Class University untuk merepresentasikan data universitas
// Mendefinisikan dua properti dalam kelas University,
// yaitu name dan website, yang akan digunakan untuk menyimpan nama universitas dan website-nya.
class University {
  final String name;
  final String website;

  // Menerima dua parameter yang wajib diisi (required),
  // yaitu name dan website, dan langsung menginisialisasi properti name
  // dan website dari objek yang dibuat dengan nilai parameter yang diterima.
  University({
    required this.name,
    required this.website,
  });

  // Membuat objek University dari data JSON.
  factory University.fromJson(Map<String, dynamic> json) {
    // Mengembalikan objek University baru dengan menggunakan
    // constructor yang telah didefinisikan sebelumnya.
    return University(
      // Mengambil nilai dari key 'name' dalam
      // json dan menggunakannya sebagai nilai
      // untuk properti name dari objek University.
      name: json['name'],
      // Mengambil nilai dari key 'web_pages' dalam json,
      // yang merupakan list, dan mengambil elemen pertama [0]
      // dari list tersebut sebagai nilai untuk properti
      // website dari objek University.
      website: json['web_pages'][0],
    );
  }
}

// Mendefinisikan kelas abstrak UniversityEvent yang
// akan menjadi dasar untuk semua event yang terkait
// dengan manajemen data universitas.
abstract class UniversityEvent {}

// Mendefinisikan sebuah event khusus FetchUniversities
// yang digunakan untuk memicu proses pengambilan data
// universitas dari API berdasarkan negara tertentu.
class FetchUniversitiesEvent extends UniversityEvent {
   // Menyimpan negara yang akan dicari universitasnya.
  final String country;
  FetchUniversitiesEvent(this.country);
}

class UniversityBloc extends Bloc<UniversityEvent, List<University>> {
  // Memanggil konstruktor super dengan inisialisasi state awal berupa list kosong [].
  UniversityBloc() : super([]) {
    // Method on yang akan memanggil method _fetchUniversities ketika event tersebut diterima.
    on<FetchUniversitiesEvent>(_fetchUniversities);
  }
  // Menerima event dan emit function yang digunakan untuk mengeluarkan state baru.
  Future<void> _fetchUniversities(
    FetchUniversitiesEvent event,
    Emitter<List<University>> emit,
  ) async {
    try {
      // Dilakukan pemanggilan _fetchUniversitiesFromApi dengan parameter negara yang diperoleh dari event. Jika berhasil, hasil universitas akan di-emit 
      final universities = await _fetchUniversitiesFromApi(event.country);
      emit(universities);
    } catch (e) {
      print('Error: $e');
      emit([]);
    }
  }

  // Mengambil parameter country sebagai negara yang akan dicari universitasnya.
  // Fungsi ini mengembalikan Future<List<University>>, yang artinya
  // akan mengembalikan list universitas ketika proses pengambilan data selesai.
  Future<List<University>> _fetchUniversitiesFromApi(String country) async {
    // Menggunakan package http untuk melakukan HTTP GET 
    final response = await http.get(
        Uri.parse('http://universities.hipolabs.com/search?country=$country'));
    // Memeriksa apakah respons dari server memiliki status code 200, yang artinya request berhasil.
    if (response.statusCode == 200) {
      // Mengubah respons dari server (dalam bentuk JSON) menjadi list
      // dynamic menggunakan jsonDecode. Data universitas akan berada dalam bentuk list JSON.
      final List<dynamic> data = jsonDecode(response.body);
      // Mengembalikan list universities setelah proses pengubahan selesai.
      return data.map((json) => University.fromJson(json)).toList();
    } else {
      // Melempar exception jika respons dari server tidak memiliki
      // status code 200, yang berarti gagal mengambil data universitas.
      throw Exception('Failed to load universities data');
    }
  }
}

void main() {
  runApp(MyApp());
}


// Mendefinisikan kelas MyApp yang merupakan turunan dari
// StatelessWidget, artinya kelas ini tidak memiliki state yang berubah.
class MyApp extends StatelessWidget {
  // Override method build dari StatelessWidget yang
  // digunakan untuk membangun tampilan widget.
  @override
  Widget build(BuildContext context) {
    //  Mengembalikan widget MaterialApp, yang merupakan root
    // dari aplikasi Flutter dan menyediakan fitur-fitur
    // dasar seperti routing, manajemen theme, dan lain-lain.
    return MaterialApp(
      // Menonaktifkan banner debug pada aplikasi.
      debugShowCheckedModeBanner: false,
      // Mengatur halaman utama (home) aplikasi dengan BlocProvider.
      // BlocProvider adalah bagian dari Flutter Bloc library
      // yang menyediakan state management dengan BLoC pattern.
      home: BlocProvider(
        // Membuat instance dari UniversityBloc yang akan digunakan sebagai
        // provider untuk BlocProvider. Instance ini akan digunakan
        // oleh widget HomeScreen dan widget lainnya di dalam BlocProvider.
        create: (context) => UniversityBloc(),
        // Menetapkan UniversitiesPage sebagai child dari BlocProvider. 
        child: UniversitiesPage(),
      ),
    );
  }
}

class UniversitiesPage extends StatefulWidget {
  @override
  _UniversitiesPageState createState() => _UniversitiesPageState();
}

class _UniversitiesPageState extends State<UniversitiesPage> {
  // Mendefinisikan list aseanCountries yang berisi nama-nama negara ASEAN.
  // List ini akan digunakan sebagai pilihan dalam dropdown menu untuk memilih negara.
  final List<String> _aseanCountries = [
    'Indonesia',
    'Singapore',
    'Malaysia',
    'Thailand',
    'Philippines',
    'Viet Nam',
    "Lao People's Democratic Republic",
    'Cambodia',
    'Myanmar',
    'Brunei Darussalam'

  ];

  // Menginisialisasi selectedCountry dengan nilai default 'Indonesia'.
  // Nilai ini akan digunakan untuk menyimpan negara yang dipilih dari dropdown menu.
  String _selectedCountry = 'Indonesia';

  @override
  void initState() {
    // Memanggil method initState() dari superclass, yaitu State.
    super.initState();
    // digunakan untuk mendapatkan instance dari UniversityBloc yang
    // ada di dalam widget tree. context.read mengambil instance
    // bloc tanpa membangun ulang widget tree.
    context
        .read<UniversityBloc>()
        // menambahkan event FetchUniversitiesEvent ke bloc
        // UniversityBloc dengan parameter _selectedCountry.
        // Event ini akan memulai proses untuk mengambil
        // data universitas dari API berdasarkan negara yang dipilih.
        .add(FetchUniversitiesEvent(_selectedCountry));
  }

  @override
  Widget build(BuildContext context) {
    // Mengembalikan widget Scaffold yang merupakan kerangka dasar untuk tata letak aplikasi.
    return Scaffold(
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            // Menampilkan dropdown button untuk memilih negara ASEAN.
            // Value dari dropdown button ini akan diupdate ketika pengguna
            // memilih negara baru, dan akan memicu event FetchUniversities
            // untuk mengambil data universitas dari negara yang dipilih.
            child: DropdownButton<String>(
              // Menetapkan nilai default dari dropdown button yang akan ditampilkan.
              value: _selectedCountry,
              // Callback yang dipanggil ketika pengguna memilih nilai baru dari dropdown. 
              onChanged: (String? newValue) {
                // Mengubah nilai selectedCountry dengan nilai baru yang dipilih
                setState(() {
                  //mengatur nilai yang dipilih pada dropdown sesuai dengan nilai yang disimpan dalam _selectedCountry.
                  _selectedCountry = newValue!;
                  context
                      .read<UniversityBloc>()
                      .add(FetchUniversitiesEvent(newValue));
                });
              },
              // Digunakan untuk mengonversi daftar negara ASEAN menjadi daftar DropdownMenuItem. Setiap DropdownMenuItem memiliki nilai
              // yang sama dengan nama negara dan child berupa Text widget yang menampilkan nama negara.
              items: _aseanCountries
                  .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                  .toList(),
            ),
          ),
          // Menggunakan BlocBuilder untuk membangun tampilan berdasarkan
          // state dari UniversityBloc. Ketika state berubah, widget ini
          // akan secara otomatis diperbarui sesuai dengan state yang baru.
          BlocBuilder<UniversityBloc, List<University>>(
            // Parameter builder merupakan callback yang akan dipanggil
            // ketika state dari UniversityBloc berubah. Parameter
            // context adalah BuildContext dan state adalah objek
            // state terbaru dari UniversityBloc.
            builder: (context, universities) {
              // Memeriksa apakah state saat ini adalah UniversityInitial,
              // yang menandakan bahwa proses pengambilan data
              // universitas sedang berlangsung atau belum dimulai.
              // Jika iya, maka akan ditampilkan widget CircularProgressIndicator di tengah layar.
              if (universities.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return Expanded(
                // Menggunakan widget Expanded agar ListView.builder dapat mengambil
                // sebagian besar ruang yang tersedia di layar,
                // sehingga daftar universitas dapat ditampilkan dengan baik.
                child: ListView.builder(
                  // Menetapkan jumlah item dalam ListView.builder
                  // berdasarkan panjang list universities dalam state UniversityLoaded.
                  itemCount: universities.length,
                  // Callback yang akan dipanggil untuk membangun setiap
                  // item dalam ListView.builder. Setiap item akan berupa Card yang berisi informasi universitas.
                  itemBuilder: (context, index) {
                    final university = universities[index];
                    return Card(
                      // Properti elevation digunakan untuk mengatur tingkat bayangan (elevation) dari kartu.
                      elevation: 2,
                      // Memberikan jarak antara kartu dengan elemen-elemen di sekitarnya. 
                      margin: const EdgeInsets.all(5),
                      // Menampilkan konten dalam format baris dengan judul, subtitle, dan ikon.
                      child: ListTile(
                        // Properti title dari ListTile berisi teks yang merupakan nama universitas.
                        // Nilainya diambil dari objek University dalam list state.universities berdasarkan indeks index.
                        title: Text(
                          university.name
                        ),
                        // Properti subtitle dari ListTile berisi teks yang merupakan website universitas.
                        // Nilainya diambil dari objek University dalam list state.universities berdasarkan indeks index.
                        subtitle: Text(
                          university.website,
                        ),
                        onTap: () {
                              // Menggunakan URL Launcher untuk
                              // membuka website universitas
                              launchURL(university.website);
                            },
                        // Properti trailing dari ListTile berisi ikon yang akan ditampilkan
                        // di sebelah kanan. Dalam hal ini, digunakan ikon sekolah
                        // (Icons.school_rounded) sebagai ikon trailing.
                        trailing: const Icon((Icons.school_rounded),
                        ),
                        
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
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