# GDD 10 — Audio

> Versi: 0.1 | Terkait: `09-narrative.md`, `11-technical.md`

## 1. Arah Umum

Hybrid **orchestral playfulness + chiptune texture**. Hangat, penuh *clack* balok, tidak serius. Mirip soundtrack mainan yang sedang petualangan — nada naik-turun, ada *pluck* dan *marimba*, ditambah synth halus di bioma futuristik.

Tiga kata kunci: **clicky, playful, warm**.

## 2. Layer Musik Dinamis

Musik tersusun dari 3 layer yang bisa masuk/keluar sesuai state:

| Layer | Isi | Aktif saat |
| --- | --- | --- |
| `Base` | Melodi utama + harmoni | Selalu di play mode |
| `Tension` | Rhythm + bass tambahan | Musuh nearby / bos |
| `Wonder` | Pad + arpeggio terang | Build Mode / puzzle / discovery |

Crossfade 0.8–1.5 dtk via `AudioManager.play_music()`. Transisi di-bar agar tidak "loncat".

## 3. Tema per Area

| Area | Instrumentasi | Tempo | Karakter |
| --- | --- | --- | --- |
| Nexus | Marimba + strings + chime | 96 BPM | Hangat, "rumah" |
| Brickwood | Woodwind + plucked strings | 104 BPM | Hutan ceria |
| Sandbox | Hand drum + bassoon + shaker | 112 BPM | Groovy, berdebu |
| Frost Circuit | Bell + synth pad + glockenspiel | 88 BPM | Dingin tapi ceria |
| Neon Metropolis | Synthwave + chiptune lead | 124 BPM | Energik |
| Cosmic Void | Choir pad + sparse piano | 72 BPM | Lapang, reflektif |
| Boss | Full percussion + brass motif | 132 BPM | Epic, tidak menakutkan |
| Ending | Piano + strings + children choir | 80 BPM | Hangat, penuh harap |

## 4. SFX Khas (Signature Sounds)

| SFX | Deskripsi | Pemakaian |
| --- | --- | --- |
| `clack_place` | Klik balok + reverb pendek | Place blueprint |
| `snap_confirm` | "tuk" tajam + chime | Valid snap |
| `pop_break` | Retak → berhamburan | Musuh/objek pecah |
| `stud_ping` | Logam kecil naik nada | Dapat Stud |
| `core_hum` | Dengung bernapas | Core / portal |
| `suit_whoosh` | whoosh + sparkle | Ganti Suit |
| `error_buzz` | Buzz lembut (tidak menyakitkan) | Place invalid |
| `pixel_beep` | 3 nada robot | Pixel bicara |

> **Aturan:** setiap SFX destraksi harus terdengar "mainan", bukan "daging". Hindari suara base berat.

## 5. Ambience

| Area | Ambience |
| --- | --- |
| Brickwood | Daun balok berderak + burung chiptune |
| Sandbox | Angin + pasir bergeser |
| Frost Circuit | Listrik statis + tetes es |
| Metropolis | Lalu lintas jauh + neon hum |
| Cosmic Void | Angin ruang + dengung Core |

Ambience dipetakan per chunk dan di-crossfade saat berpindah bioma.

## 6. Voice

- **Tanpa full voice acting** di v1.0 (biaya & lokalisasi).
- NPC memakai *vocalizations* pendek (aha!, hmm!, wow!) + subtitle.
- Pixel = beep melodis (lihat `pixel_beep`).
- Ini konsisten dengan tone "mainan" dan memudahkan tambah bahasa.

## 7. Teknis

| Item | Spesifikasi |
| --- | --- |
| Format source | `.wav` 48 kHz / 24-bit |
| Format game | `.ogg` (musik), `.wav` compresed / `.ogg` (SFX) |
| Bus | `Master → Music, SFX, Ambience, UI` (4 bus + master) |
| Max simultaneous SFX | 24 (pool `AudioStreamPlayer2D/3D`) |
| Dynamic range | Target -14 LUFS integrated |
| Streaming | Musik dari `user://` stream, SFX prefetch |
| Priority | SFX penting (bos telegraph) tidak boleh ter-voice-steal |

## 8. Implementasi Godot

```text
assets/audio/music/     # .ogg, 8-10 track + stem layer
assets/audio/sfx/       # .ogg, ~60 file
assets/audio/voice/     # vocalization pendek
resources/settings/sfx_db.tres   # mapping StringName -> AudioStream + bus
scripts/autoloads/AudioManager.gd
```

**Todo AudioManager (M3):**
- [ ] Buat bus Music/SFX/Ambience/UI di Audio Layout
- [ ] Ganti `print()` di `AudioManager` dengan `AudioStreamPlayer` pool
- [ ] Implementasi crossfade layer per state & bioma
- [ ] Volume settings tersimpan di `SaveManager`

## 9. Checklist Konten

- [ ] 1 tema Nexus + 5 tema bioma + 1 bos + 1 ending
- [ ] 3 stem layer per tema (Base/Tension/Wonder)
- [ ] ±60 SFX + 8 signature
- [ ] 5 ambience loop
- [ ] Loop point tanpa jeda (test 10× berturut)
