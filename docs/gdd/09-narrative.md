# GDD 09 — Narrative

> Versi: 0.1 | Terkait: `00-overview.md`, `07-quests.md`, `10-audio.md`

## 1. Tone

Optimis, penuh rasa ingin tahu, humor ringan ala mainan. Tidak ada darah, tidak ada depresi. Konfliknya adalah **"dunia berantakan, mari kita rakit lagi"**, bukan "selamatkan dunia dari kehancuran total".

> Prinsip: *Setiap kegagalan adalah bahan bangunan untuk percobaan berikutnya.*

## 2. Premise Singkat

**The Great Shatter** terjadi ketika **The Shatterer** — mantan murid The Architect — menolak ide bahwa dunia harus selalu "selesai". Ia memecah Great Build menjadi lima fragmen agar dunia tetap bisa berubah selamanya. The Architect mengirim **Infinity Human**, minifigure biasa yang satu-satunya masih bisa merakit, untuk memulihkan fragmen. Di akhir, pemain menghadapi pilihan: kembalikan dunia seperti semula, atau terima perubahan Shatterer.

## 3. Struktur Story (5 Bab + Prolog + Epilog)

| Bab | Fragment | Plot beat | Emosi |
| --- | --- | --- | --- |
| Prolog | Nexus | Dunia pecah, pemain bangun | Awe |
| 1 | Brickwood | Belajar merakit lagi; temui Pixel | Harap |
| 2 | Sandbox | Shatterer mulai muncul; moral ambigu | Ragu |
| 3 | Frost Circuit | Menyalakan sirkuit hidup lagi; kilas balik Shatterer | Empati |
| 4 | Neon Metropolis | Kota melayang; kebenaran The Architect | Ketegangan |
| 5 | Cosmic Void | Hadapi bayangan diri sendiri | Refleksi |
| Epilog | The Core | Pilihan akhir + rebuild bersama | Hangat |

## 4. Karakter

| Karakter | Peran | Kepribadian | Visual |
| --- | --- | --- | --- |
| **Infinity Human** | Player | Diam, ekspresif, ulet | Minifigure polos dengan aksen kuning |
| **Pixel** | Companion | Robot kecil, rasa ingin tahu tinggi, comic relief | Kubus biru bermata LED |
| **The Architect** | Mentor | Bijak, agak kaku, punya rahasia | Minifigure putih dengan jubah balok |
| **The Shatterer** | Antagonis | Idealist yang tersesat, bukan jahat murni | Fragmen hitam berdenyut emas |
| **Vera** | NPC vendors | Praktis, suka menawar | Minifigure merah muda dengan karton |
| **Glimmer** | NPC lore | Pensiunan penjaga, suka bercerita | Minifigure transparan |

## 5. Sistem Dialog

- Dialogue node berbasis `DialogueDef` resource (atau plugin Dialogic jika disetujui — lihat ADR-002).
- Format: `{id, speaker, text, choices[], condition,next}`.
- Pilihan dialog **tidak mengubah quest utama**, hanya warna NPC & bonus kecil → bebas eksplorasi tanpa takut "salah pilih".
- Typewriter speed default 30 char/dtk, bisa di-skip.
- Subtitle selalu aktif (lihat `08-ui-ux.md`).

## 6. Environment Storytelling

Prioritas urutan penyampaian:
1. **Visual** — jembatan putus, patung pecah → pemain bertanya.
2. **Interaksi** — pecah balok, temukan mini-record → pemain mendapat jawaban kecil.
3. **Dialog** — NPC memberi nama pada kejadian → konfirmasi.
4. **Cutscene** — hanya di prolog, bab 3, dan epilog.

## 7. Cutscene

| ID | Durasi | Trigger | Bisa di-skip |
| --- | --- | --- | --- |
| `CS_INTRO` | 60 dtk | New Game | ✅ |
| `CS_PIXEL` | 20 dtk | First meet Pixel | ✅ |
| `CS_FLASHBACK` | 45 dtk | Shrine Bab 3 | ✅ |
| `CS_FINAL` | 90 dtk | The Core | ✅ |

Semua cutscene memakai *in-engine scene*, bukan video prarender → mudah di-localisasi.

## 8. Lore Ringkas (World Bible)

- **Great Build** = struktur asal yang menyatukan semua balok; sekarang pecah.
- **Infinity Expanse** = ruang antara fragmen, berisi sisa-sisa balok melayang.
- **Core** = jantung Great Build; memberi warna pada langit tiap fragmen.
- **Rule per bioma** = "kebiasaan" balok di fragmen itu, bukan sihir acak.
- **Minifigure** = makhluk yang paling bisa beradaptasi; itulah sebabnya mereka dipilih.

## 9. Aturan Penulisan

- Kalimat pendek, aktif, kata konkret ("balok", "jembatan", "nyala"), bukan abstrak ("harmoni", "destiny").
- Humor berasal dari situasi (Pixel terkubur balok), bukan lelucon tertulis.
- Hindari exposition dump; maksimal 3 kalimat per NPC interaction.
- Selalu tawarkan harapan di akhir tiap bab.

## 10. Checklist

- [ ] `DialogueDef` resource + test pilihan & condition
- [ ] Semua dialog lewat `tr()` untuk lokalisasi
- [ ] Cutscene pakai `EventBus.cutscene_requested`
- [ ] Story bible versi panjang dibuat di M4 (dokumen terpisah)
