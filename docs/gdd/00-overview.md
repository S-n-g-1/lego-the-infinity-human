# GDD 00 — Overview

> Versi: 0.1 | Status: Draft | Update terakhir: 2026-11-18 | Owner: Game Design

## 1. Visi

> *"Alam semesta ini pecah. Kamu bukan pahlawan yang menyelamatkan dunia — kamu adalah orang yang merakitnya kembali, satu balok demi satu balok."*

**LEGO — The Infinity Human** adalah open-world adventure PC tempat pemain menjelajahi fragmen dunia yang melayang, memecah segalanya menjadi balok, lalu membangun kembali apa pun yang mereka butuhkan untuk maju. Tidak ada kelas tetap; yang ada adalah imajinasi, blueprint, dan kebebasan merakit.

## 2. Identitas Singkat

| Aspek | Nilai |
| --- | --- |
| Genre | Open-World Adventure + Building / Light Action |
| Engine | Godot 4.6 (GDScript, Jolt, GL Compatibility) |
| Platform | PC — Windows & Linux (Steam-ready) |
| Target usia | 7+ (family-friendly), playtest dewasa tetap nyaman |
| Session length | 20–45 menit, dengan checkpoint tiap 5–8 menit |
| Main path | 6–10 jam; 100% ≈ 20 jam |
| Camera | Third-person, shoulder switch, orbit saat Build Mode |
| Monetisasi | **Pembelian premium sekali** — tidak ada IAP / gacha |
| Multiplayer | Tidak di v1.0; design disiapkan untuk drop-in co-op 2 pemain |

## 3. Premise

Peristiwa **The Great Shatter** menghancurkan *Great Build* menjadi lima World Fragment yang melayang di kekosongan bernama **Infinity Expanse**. Sang penjaga, *The Architect*, mengirim satu-satunya minifigure yang masih bisa merakit — **Infinity Human** — untuk memulihkan tiap fragmen. Di ujung perjalanan, pemain menghadapi **The Shatterer**, entitas yang yakin dunia lebih baik jika dibiarkan pecah.

## 4. Unique Selling Points (USP)

1. **Break-to-Build Loop** — hampir semua objek bisa dipecah jadi balok, lalu balok itu langsung jadi bahan bangunan. Tidak ada inventory "sample" yang tidak terpakai.
2. **World Fragments** — dunia bukan peta statis; tiap fragmen adalah pulau dengan *Build Rule* sendiri (gravitasi terbalik, balok melayang, dll.).
3. **Classless Suits** — progresi lewat *Suit* dan *Blueprint*, bukan kelas. Pemain bisa jadi explorer, builder, dan fighter bergantian dalam satu sesi.
4. **Readable Chaos** — efek LEGO yang berantakan tetap mudah dibaca: warna, suara, dan ikon memberi tahu balok mana yang bisa diambil.

## 5. Design Pillars

| Pilar | Artinya | Dampak ke desain |
| --- | --- | --- |
| **Segalanya bisa dibongkar** | Destruksi adalah sumber daya utama | Setiap prop punya `breakable` flag & drop table |
| **Bangun = solusi** | Masalah diberi ruang untuk diselesaikan dengan kreativitas | Quest punya ≥ 2 solusi (bangun vs. alternatif) |
| **Jelas dalam keramaian** | Visual sibuk tapi informatif | Warna item konsisten, outline interaksi, SFX khas |
| **Ramah untuk semua** | Tidak ada punishment berlebih | Respawn cepat, tanpa kehilangan material |

## 6. Referensi & Pembeda

| Referensi | Diambil | Pembeda kita |
| --- | --- | --- |
| LEGO Universe | Wonder build, minifigure charm | Duniafragmen + build rule per bioma |
| Zelda: Tears of the Kingdom | Fizik & kreativitas | Sistem snap lebih mudah dipelajari, bukan simulasi penuh |
| Terraria / Minecraft | Eksplorasi & crafting | Fokus pada *perbaikan*, bukan survival/crafting grind |

## 7. Scope Awal (v1.0)

**Termasuk:** 5 bioma, 5 World Fragment, 1 hub, ±20 quest, 5 bos + 1 final, 40+ blueprint, 12 Suit, save 3 slot, aksesibilitas dasar.

**Tidak termasuk (v1.0):** multiplayer, user-generated world sharing, mod tools, mobile, VR, battle pass.

## 8. Metrik Keberhasilan

- 80% playtester menyelesaikan tutorial build dalam < 5 menit tanpa bantuan.
- Rata-rata sesi ≥ 20 menit.
- ≥ 70% playtester mencoba blueprint di luar yang diwajibkan quest (indikator kreativitas).
- 0 crash blocker saat main path 6 jam.

## 9. Risiko Awal

| Risiko | Mitigasi |
| --- | --- |
| Build mode terlalu rumit | Mulai dari snap-grid 3 blueprint; tambah kebebasan bertahap (M1 → M2) |
| Dunia terlalu luas sampai kosong | POI tiap ≤ 90 detik perjalanan; chunk berisi 3–5 aktivitas |
| Aset balok berat | Material instancing + shared mesh; lihat `11-technical.md` |
| Legalitas nama "LEGO" | **Perlu klarifikasi legal sebelum rilis** — lihat catatan di bawah |

> ⚠️ **Catatan legal:** Penggunaan nama dan aesthetics LEGO® memerlukan izin/licensing. Sebelum publikasi, konsultasikan nama/branding atau ganti dengan nama orisinal bermotif balok. Ini blocker untuk M6.
