# Feature Spec — `<Nama Fitur>`

> Template untuk fitur baru (minimal dipakai sejak M1).
> Salin ke `docs/design/specs/<nama-fitur>.md` lalu isi.

| Field | Isi |
| --- | --- |
| ID | `FS-###` |
| Milestone | M1 |
| Status | Draft / In Review / Approved / Implemented |
| Owner | `@nama` |
| Terkait GDD | `../gdd/03-character-system.md` |
| Terkait ADR | ADR-001 |

## 1. Masalah

Apa yang salah atau belum ada sekarang? (2–3 kalimat)

## 2. Tujuan

Apa yang harus berubah setelah fitur ini ada? Terukur.

- [ ] Tujuan 1
- [ ] Tujuan 2

## 3. Non-Tujuan

Apa yang **tidak** dikerjakan di sini (biar tidak scope creep).

- Tidak termasuk …

## 4. Desain

### 4.1 Alur Pengguna
```text
1. Pemain menekan …
2. Sistem …
3. Hasil …
```

### 4.2 Aturan & Edge Case

| Kasus | Perlakuan |
| --- | --- |
| Input invalid | … |
| Balok tidak cukup | … |
| Save saat fitur aktif | … |

### 4.3 UI / Feedback

- Ikon: …
- Toast: …
- SFX: …

## 5. Teknis

| Aspek | Rencana |
| --- | --- |
| File baru | `scripts/systems/…`, `scenes/gameplay/…` |
| Resource | `resources/.../....tres` |
| EventBus | `signal …` baru? ya/tidak |
| Autoload baru | ya/tidak (jika ya → wajib ADR) |
| Performa | Budget ≤ … ms |

## 6. Data & Lokalisasi

| Key | id_ID | en_US |
| --- | --- | --- |
| `FEATURE_X_TITLE` | … | … |

## 7. Test

- [ ] Unit: …
- [ ] Integration: …
- [ ] Playtest: …

## 8. Checklist Selesai (DoD)

- [ ] Kode sesuai `../guides/coding-standards.md`
- [ ] GDD bab terkait di-update
- [ ] CHANGELOG `Unreleased` diisi
- [ ] Test lulus & performa dalam budget
- [ ] Lokalisasi tersedia
