import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

/// ---------------------------------------------------------------------------
/// MODEL
/// ---------------------------------------------------------------------------
class Mahasiswa {
  final String nim;
  final String nama;
  final String programStudi;
  final String kelas;

  const Mahasiswa({
    required this.nim,
    required this.nama,
    required this.programStudi,
    required this.kelas,
  });
}

/// Hasil yang dikembalikan halaman detail ke halaman daftar.
class DetailResult {
  final Mahasiswa? updated;
  final bool deleted;
  const DetailResult({this.updated, this.deleted = false});
}

/// Dialog konfirmasi hapus (dipakai di daftar & detail).
Future<bool> konfirmasiHapus(BuildContext context) async {
  final hasil = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Konfirmasi'),
      content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  return hasil ?? false;
}

/// ---------------------------------------------------------------------------
/// APP
/// ---------------------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DataMahasiswaPage(),
    );
  }
}

/// ---------------------------------------------------------------------------
/// TAHAP 1, 2, 6, 7 + Tantangan: HALAMAN DAFTAR
/// ---------------------------------------------------------------------------
class DataMahasiswaPage extends StatefulWidget {
  const DataMahasiswaPage({super.key});

  @override
  State<DataMahasiswaPage> createState() => _DataMahasiswaPageState();
}

class _DataMahasiswaPageState extends State<DataMahasiswaPage> {
  static const List<String> _opsiFilter = [
    'Semua',
    'Informatika',
    'Sistem Informasi',
    'Teknik Komputer',
  ];

  // Penyimpanan sementara menggunakan List + setState()
  final List<Mahasiswa> _daftar = [
    const Mahasiswa(nim: '231001', nama: 'Andi Saputra', programStudi: 'Informatika', kelas: 'TI-3A'),
    const Mahasiswa(nim: '231002', nama: 'Budi Santoso', programStudi: 'Informatika', kelas: 'TI-3A'),
    const Mahasiswa(nim: '231003', nama: 'Citra Lestari', programStudi: 'Sistem Informasi', kelas: 'SI-3B'),
    const Mahasiswa(nim: '231004', nama: 'Dewi Anggraini', programStudi: 'Sistem Informasi', kelas: 'SI-3B'),
    const Mahasiswa(nim: '231005', nama: 'Eko Prasetyo', programStudi: 'Teknik Komputer', kelas: 'TK-3A'),
    const Mahasiswa(nim: '231006', nama: 'Fitri Handayani', programStudi: 'Informatika', kelas: 'TI-3B'),
    const Mahasiswa(nim: '231007', nama: 'Gilang Ramadhan', programStudi: 'Teknik Komputer', kelas: 'TK-3A'),
    const Mahasiswa(nim: '231008', nama: 'Hana Pertiwi', programStudi: 'Sistem Informasi', kelas: 'SI-3A'),
    const Mahasiswa(nim: '231009', nama: 'Indra Wijaya', programStudi: 'Informatika', kelas: 'TI-3C'),
    const Mahasiswa(nim: '231010', nama: 'Joko Susilo', programStudi: 'Teknik Komputer', kelas: 'TK-3B'),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _keyword = '';
  String _filterProdi = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Daftar hasil pencarian (nama / NIM) + filter program studi.
  List<Mahasiswa> get _hasilTampil {
    final kw = _keyword.trim().toLowerCase();
    return _daftar.where((m) {
      final cocokCari = kw.isEmpty ||
          m.nama.toLowerCase().contains(kw) ||
          m.nim.toLowerCase().contains(kw);
      final cocokProdi = _filterProdi == 'Semua' ||
          m.programStudi.toLowerCase() == _filterProdi.toLowerCase();
      return cocokCari && cocokProdi;
    }).toList();
  }

  // Tahap 2: tambah data
  Future<void> _tambah() async {
    final baru = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(
        builder: (_) => FormMahasiswaPage(
          nimTerpakai: _daftar.map((m) => m.nim).toList(),
        ),
      ),
    );
    if (baru != null) {
      setState(() => _daftar.add(baru));
    }
  }

  // Tahap 4 & 5: buka detail (di dalamnya ada edit & hapus)
  Future<void> _bukaDetail(Mahasiswa m) async {
    final hasil = await Navigator.push<DetailResult>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailMahasiswaPage(
          mahasiswa: m,
          nimTerpakai: _daftar.where((x) => x != m).map((x) => x.nim).toList(),
        ),
      ),
    );
    if (hasil == null) return;
    setState(() {
      final idx = _daftar.indexOf(m);
      if (idx == -1) return;
      if (hasil.deleted) {
        _daftar.removeAt(idx);
      } else if (hasil.updated != null) {
        _daftar[idx] = hasil.updated!;
      }
    });
  }

  // Tahap 6: hapus dengan konfirmasi
  Future<void> _hapus(Mahasiswa m) async {
    final ya = await konfirmasiHapus(context);
    if (ya) {
      setState(() => _daftar.remove(m));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tampil = _hasilTampil;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tantangan 2: jumlah mahasiswa (otomatis berubah)
            Text(
              'Total Mahasiswa: ${_daftar.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Tahap 7: pencarian
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari nama atau NIM...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: _keyword.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _keyword = '');
                        },
                      ),
              ),
              onChanged: (v) => setState(() => _keyword = v),
            ),
            const SizedBox(height: 10),

            // Tantangan 1: filter program studi
            DropdownButtonFormField<String>(
             initialValue: _filterProdi,
              decoration: InputDecoration(
                labelText: 'Filter Program Studi',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _opsiFilter
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _filterProdi = v ?? 'Semua'),
            ),
            const SizedBox(height: 10),

            // Tahap 2: tombol tambah
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _tambah,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Mahasiswa'),
              ),
            ),
            const SizedBox(height: 10),

            // Tahap 1: ListView.builder + Card
            Expanded(
              child: _daftar.isEmpty
                  // Tantangan 3: empty state
                  ? const Center(child: Text('Belum ada data mahasiswa'))
                  : tampil.isEmpty
                      ? const Center(child: Text('Data tidak ditemukan'))
                      : ListView.builder(
                          itemCount: tampil.length,
                          itemBuilder: (context, index) {
                            final m = tampil[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                onTap: () => _bukaDetail(m),
                                leading: CircleAvatar(
                                  child: Text(m.nama.isNotEmpty ? m.nama[0].toUpperCase() : '?'),
                                ),
                                title: Text('${m.nim}  •  ${m.nama}'),
                                subtitle: Text('${m.programStudi}\n${m.kelas}'),
                                isThreeLine: true,
                                trailing: IconButton(
                                  tooltip: 'Hapus',
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _hapus(m),
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

/// ---------------------------------------------------------------------------
/// TAHAP 2, 3, 5: FORM TAMBAH / EDIT
/// ---------------------------------------------------------------------------
class FormMahasiswaPage extends StatefulWidget {
  final Mahasiswa? mahasiswa; // null = tambah, ada isi = edit
  final List<String> nimTerpakai;

  const FormMahasiswaPage({
    super.key,
    this.mahasiswa,
    this.nimTerpakai = const [],
  });

  @override
  State<FormMahasiswaPage> createState() => _FormMahasiswaPageState();
}

class _FormMahasiswaPageState extends State<FormMahasiswaPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nimC;
  late final TextEditingController _namaC;
  late final TextEditingController _prodiC;
  late final TextEditingController _kelasC;

  bool get _modeEdit => widget.mahasiswa != null;

  @override
  void initState() {
    super.initState();
    // Tahap 5: data lama otomatis muncul pada form
    _nimC = TextEditingController(text: widget.mahasiswa?.nim ?? '');
    _namaC = TextEditingController(text: widget.mahasiswa?.nama ?? '');
    _prodiC = TextEditingController(text: widget.mahasiswa?.programStudi ?? '');
    _kelasC = TextEditingController(text: widget.mahasiswa?.kelas ?? '');
  }

  @override
  void dispose() {
    _nimC.dispose();
    _namaC.dispose();
    _prodiC.dispose();
    _kelasC.dispose();
    super.dispose();
  }

  void _simpan() {
    // Tahap 3: validasi form
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        Mahasiswa(
          nim: _nimC.text.trim(),
          nama: _namaC.text.trim(),
          programStudi: _prodiC.text.trim(),
          kelas: _kelasC.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Mahasiswa' : 'Form Tambah Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nimC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'NIM',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'NIM wajib diisi';
                  if (widget.nimTerpakai.contains(v.trim())) {
                    return 'NIM sudah terdaftar';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _namaC,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prodiC,
                decoration: const InputDecoration(
                  labelText: 'Program Studi',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Program Studi wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kelasC,
                decoration: const InputDecoration(
                  labelText: 'Kelas',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Kelas wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _simpan,
                  child: Text(_modeEdit ? 'Simpan Perubahan' : 'Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// TAHAP 4, 5, 6: DETAIL MAHASISWA
/// ---------------------------------------------------------------------------
class DetailMahasiswaPage extends StatefulWidget {
  final Mahasiswa mahasiswa;
  final List<String> nimTerpakai;

  const DetailMahasiswaPage({
    super.key,
    required this.mahasiswa,
    this.nimTerpakai = const [],
  });

  @override
  State<DetailMahasiswaPage> createState() => _DetailMahasiswaPageState();
}

class _DetailMahasiswaPageState extends State<DetailMahasiswaPage> {
  late Mahasiswa _m;

  @override
  void initState() {
    super.initState();
    _m = widget.mahasiswa;
  }

  Future<void> _edit() async {
    final hasil = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(
        builder: (_) => FormMahasiswaPage(
          mahasiswa: _m,
          nimTerpakai: widget.nimTerpakai,
        ),
      ),
    );
    if (hasil != null && mounted) {
      // Kembali ke daftar membawa data terbaru
      Navigator.pop(context, DetailResult(updated: hasil));
    }
  }

  Future<void> _hapus() async {
    final ya = await konfirmasiHapus(context);
    if (ya && mounted) {
      Navigator.pop(context, const DetailResult(deleted: true));
    }
  }

  Widget _baris(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 2),
          Text(nilai, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _baris('NIM', _m.nim),
                      _baris('Nama', _m.nama),
                      _baris('Program Studi', _m.programStudi),
                      _baris('Kelas', _m.kelas),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _edit,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _hapus,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
