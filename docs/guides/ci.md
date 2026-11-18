# Panduan — CI (GitHub Actions)

> Workflow: [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml)
> Berjalan pada push/PR ke `main` dan `develop`.

## 1. Dua Job

| Job | Tool | Fungsi |
| --- | --- | --- |
| `lint` | `gdtoolkit` (`gdlint` 4.x) | Cek style & sintaks GDScript di `scripts/` dan `tests/` |
| `test` | Godot 4.6.3 + gdUnit4 v6.2.3 | Jalankan seluruh test suite di `tests/` |

Keduanya **wajib hijau** sebelum PR boleh di-merge.

## 2. Perintah yang Dijalankan CI

```bash
# Lint
python -m pip install "gdtoolkit>=4,<5"
find scripts tests -type f -name '*.gd' -print0 | xargs -0 gdlint

# Test
godot --headless --path . --editor --quit   # bangun cache class_name
godot --headless --path . -s \
  res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests --ignoreHeadlessMode
```

`--ignoreHeadlessMode` wajib karena gdUnit4 melarang headless secara default.
`--editor --quit` wajib di runners bersih supaya `class_name` dari addon terdaftar.

## 3. Menjalankan Locally

```bash
# Test
godot --headless --path . -s \
  res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests --ignoreHeadlessMode

# Lint (pakai virtualenv)
python3 -m venv .venv-tools
.venv-tools/bin/pip install "gdtoolkit>=4,<5"
.venv-tools/bin/gdlint scripts tests
```

Atau lewat editor Godot: menu **gdUnit4 → Run Tests**.

## 4. Versi Terkunci

| Komponen | Versi | Alasan |
| --- | --- | --- |
| Godot | 4.6.3 | Sesuai `project.godot` |
| gdUnit4 | 6.2.3 | Kompatibel dengan Godot 4.6.x |
| gdtoolkit | 4.x | Mendukung sintaks GDScript 2.0 |
| Python | 3.12 | Runner Ubuntu |

Saat upgrade Godot, **update `version:` di workflow dan gdUnit4 jika perlu** (lihat tabel kompatibilitas di README gdUnit4).

## 5. Menambah Test

1. Buat `tests/test_<modul>.gd`:

```gdscript
class_name TestNamaModul
extends GdUnitTestSuite


func test_kasus_dasar() -> void:
	assert_int(1 + 1).is_equal(2)
```

2. Awali nama file dengan `test_` agar terdeteksi.
3. Jalankan lokal, lalu push — CI akan otomatis menjalankannya.
4. Test yang menyentuh autoload harus mengembalikan state ke awal di akhir test.

## 6. Artefak

Laporan HTML & JUnit ada di `reports/report_<n>/` dan di-upload sebagai artefak GitHub (`gdunit4-reports`) pada setiap run, termasuk saat gagal. Folder ini sudah masuk `.gitignore`.

## 7. Troubleshooting

| Gejala | Penyebab | Solusi |
| --- | --- | --- |
| `Could not find type "GdUnitTestCIRunner"` | Cache class belum ada | Tambah/jalankan langkah `--editor --quit` |
| `Headless mode is not allowed` | Kurang flag | Tambah `--ignoreHeadlessMode` |
| `remote port must be between 1 and 65535` | Port `tcp://...:0` | Jangan pakai remote-debug di headless |
| gdlint gagal di `addons/` | Lint ke plugin pihak ketiga | Lint hanya `scripts` & `tests` |
| Test gagal setelah restart editor | State autoload kotor | Reset state di akhir tiap test |
