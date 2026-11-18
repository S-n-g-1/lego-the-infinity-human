# Panduan — Alur Git & Konvensi Commit

## 1. Branch

| Branch | Fungsi | Boleh di-commit langsung? |
| --- | --- | --- |
| `main` | Rilis stabil, selalu bisa di-export | ❌ |
| `develop` | Integrasi fitur | ⚠️ lewat PR |
| `feature/<nama>` | Fitur baru | ✅ |
| `fix/<nama>` | Bug fix | ✅ |
| `docs/<nama>` | Dokumentasi saja | ✅ |
| `refactor/<nama>` | Refactor tanpa ubah perilaku | ✅ |

Contoh: `feature/build-mode-undo`, `docs/gdd-chapter-08`, `fix/save-migration`.

## 2. Conventional Commits

Format: `<type>(<scope>): <deskripsi singkat>`

| Type | Dipakai untuk | Contoh |
| --- | --- | --- |
| `feat` | Fitur baru | `feat(build): tambah undo stack` |
| `fix` | Bug fix | `fix(save): cegah save korup saat crash` |
| `docs` | Dokumentasi | `docs(gdd): bab 08 UI/UX` |
| `refactor` | Refactor | `refactor(quest): pindah state ke resource` |
| `test` | Test | `test(inventory): round-trip save/load` |
| `chore` | Build, dependency, config | `chore: aktifkan gdUnit4` |
| `perf` | Optimasi | `perf(chunk): MultiMesh untuk balok` |
| `style` | Format tanpa ubah logika | `style: indent tab` |

**Breaking change** → tambah `!` atau footer `BREAKING CHANGE: ...`.

Commit body opsional, maksimal 72 karakter per baris.

## 3. Hubungan dengan CHANGELOG

| Commit | Entri CHANGELOG |
| --- | --- |
| `feat(...)` | `Added` |
| `fix(...)` | `Fixed` |
| `refactor(...)`, `perf(...)` | `Changed` |
| `docs(...)` | `Added`/`Changed` di bagian docs |
| `chore(...)`, `style(...)`, `test(...)` | Biasanya tidak dicatat |

Setiap PR wajib menambah/mengubah entri di `## [Unreleased]`.

## 4. Alur Kerja

```bash
# 1. Update & buat branch
git checkout develop
git pull origin develop
git checkout -b feature/nama-fitur

# 2. Kerja, lalu commit
git add .
git commit -m "feat(build): tambah ghost validasi merah"

# 3. Push & buat PR ke develop
git push -u origin feature/nama-fitur
```

Sebelum PR:
- [ ] Godot tidak ada error
- [ ] Test lulus
- [ ] GDD & CHANGELOG di-update
- [ ] Tidak ada file `.godot/` / `exports/` yang ter-commit
- [ ] Diff mudah dibaca (tidak ada generator output tak sengaja)

## 5. Merge & Rilis

```text
feature/* → develop → (milestone selesai) → main → tag vX.Y.Z
```

- `develop → main` lewat PR + checklist milestone di ROADMAP.
- Tag rilis: `git tag -a v0.1.0 -m "M1 Vertical Slice"`.
- Setelah tag: pindahkan `Unreleased` di CHANGELOG ke versi baru + tanggal.

## 6. Penanganan Konflik Aset

- File biner (`.png`, `.ogg`, `.tscn`) sulit di-merge → **jangan edit barengan**.
- Koordinasi di issue sebelum mengubah scene yang sama.
- Simpan scene besar dalam beberapa scene kecil (`Player.tscn`, `PlayerMesh.tscn`) untuk kurangi konflik.

## 7. .gitignore yang Berlaku

```text
.godot/
/exports/*
!/exports/.gitkeep
/saves/
*.log
*.tmp
.DS_Store
Thumbs.db
```

Jika file sudah ter-track sebelum masuk `.gitignore`:
```bash
git rm --cached <file>
```

## 8. Aturan Tambahan

- Jangan commit file hasil generate jika generator belum di-commit.
- Jangan commit kredensial/token (meski proyek ini offline).
- Pesan commit dalam **Bahasa Indonesia atau Inggris**, konsisten per PR.

## 9. CI Otomatis

Setiap push/PR ke `main` atau `develop` menjalankan dua job (lihat [`ci.md`](ci.md)):

1. **Lint** — `gdlint` pada `scripts/` dan `tests/`
2. **Test** — gdUnit4 di Godot 4.6.3 headless

PR hanya boleh di-merge jika keduanya hijau. Detail perintah & troubleshooting ada di panduan CI.
