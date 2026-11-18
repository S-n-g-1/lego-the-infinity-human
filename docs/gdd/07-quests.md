# GDD 07 — Quests

> Versi: 0.1 | Terkait: `05-progression.md`, `09-narrative.md`

## 1. Jenis Quest

| Tipe | Prefix ID | Durasi | Contoh |
| --- | --- | --- | --- |
| Main Story | `MS_` | 60–120 mnt | "Pulihkan Brickwood Forest" |
| Side Quest | `SQ_` | 5–15 mnt | "Bantu Pixel cari suku cadang" |
| Build Contract | `BC_` | 3–8 mnt | "Bangun menara setinggi 12 m" |
| Bounty | `BT_` | 5–10 mnt | "Pecah 3 Neon Drone" |
| Discovery | `DS_` | Eksplorasi | "Temukan 5 cache tersembunyi" |

Target v1.0: **1 main path (5 chapter) + 15 side + 5 contract + 3 bounty + 2 discovery** (≈ 20–25 quest).

## 2. Struktur Quest (resource)

```gdscript
class_name QuestDef
extends Resource

@export var id: StringName
@export var title: String
@export var quest_type: QuestType
@export var description: String
@export var objectives: Array[ObjectiveDef]
@export var rewards: Dictionary      # {xp, studs, cores, blueprint_fragment}
@export var prerequisite: Array[StringName]
@export var unlocks_fragment: StringName
```

Objective: `{ id, type, target, required, current }` dengan tipe: `collect`, `build`, `defeat`, `interact`, `explore`, `talk`.

## 3. State Machine

```mermaid
stateDiagram-v2
	[*] --> Locked
	Locked --> Available: prerequisite terpenuhi
	Available --> Active: diterima
	Active --> Active: objective progress
	Active --> Completed: semua objective selesai
	Completed --> [*]: reward diklaim
	Active --> Failed: (opsional, quest khusus)
	Failed --> Active: retry
```

- Quest aktif disimpan di save; maksimal **3 aktif + 1 main** ditampilkan di HUD.
- Objective yang sudah selesai dicentang, bukan hilang → pemain tahu progres.

## 4. Contoh Quest Lengkap

### `BC_001 — "Perbaiki Jembatan Nexus"`

| Field | Isi |
| --- | --- |
| Type | Build Contract (tutorial) |
| Prasyarat | Tutorial break selesai |
| Objective 1 | Kumpulkan 12 Brick (`collect`) |
| Objective 2 | Place blueprint `bridge_4m` di gap (`build`) |
| Objective 3 | Biarkan NPC menyeberang (`interact`) |
| Reward | 60 XP, 30 Stud, Suit Builder |
| Perubahan dunia | Jembatan permanen, NPC pindah ke seberang |
| Alternatif | Bisa pakai katapel jika already unlock (M2) |

## 5. Prinsip Desain Quest

1. **Setiap quest mengubah dunia.** Tidak ada "kembali ke NPC yang sama dan bilang selesai" tanpa efek.
2. **Berikan ≥ 2 solusi** untuk quest build (bangun vs. gadget), kecuali tutorial.
3. **Reward dijelaskan di awal**, tidak kejutan di akhir.
4. **Objective tracker selalu akurat** — sinkron via `EventBus.quest_objective_updated`.
5. **Tidak ada quest yang gagal karena eksplorasi lama.** Tidak ada timer kecuali bos.

## 6. Integrasi Sistem

| Event | Reaksi |
| --- | --- |
| `item_collected` | Objective `collect` bertambah |
| `structure_built` | Objective `build` selesai |
| musuh pop | Objective `defeat` bertambah |
| `area_entered` | Objective `explore` selesai |
| `dialogue_finished` | Objective `talk` selesai |
| semua objective done | `EventBus.quest_completed` → Claim UI → reward |

QuestManager menyimpan state di `SaveManager` sebagai:
```json
{ "active": ["BC_001"], "completed": ["DS_002"], "progress": { "BC_001": { "obj_1": 12 } } }
```

## 7. Quest Log UI

- Tab: `Main`, `Side`, `Contracts`, `Completed`.
- Sortir: terdekat, level reward, terbaru.
- Klik quest → panah compass aktif + highlight di peta.
- Opsi "Track" maksimal 1 quest + 1 contract.

## 8. Checklist

- [ ] `QuestDef`, `ObjectiveDef` resource
- [ ] QuestManager dengan state machine & save integration
- [ ] Test: progress tidak dobel saat load save
- [ ] Test: prerequisite multiple tidak menyebabkan quest doaktif
