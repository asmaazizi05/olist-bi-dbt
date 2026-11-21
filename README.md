# 🎙️ Speech Data Collection Pipeline

Pipeline automatisé pour extraire **≥ 10 heures d'audio** contenant uniquement
de la parole humaine, destiné aux projets de **détection de langue parlée** (ML).

---

## 🏗️ Architecture du pipeline

```
YouTube URLs
    │
    ▼
[1] yt-dlp — Téléchargement vidéos
    │
    ▼
[2] ffmpeg — Conversion WAV mono 16kHz
    │
    ▼
[3] inaSpeechSegmenter / pyannote — Segmentation
    │  ├── speech ✓
    │  ├── music  ✗
    │  ├── noise  ✗
    │  └── silence ✗
    ▼
[4] Filtrage → segments speech uniquement
    │
    ▼
[5] ffmpeg — Extraction + suppression silences
    │
    ▼
[6] Accumulation jusqu'à ≥ 10h
    │
    ├── segments/seg_00001.wav
    ├── segments/seg_00002.wav
    ├── ...
    ├── speech_dataset_final.wav  (optionnel)
    ├── segments_YYYYMMDD.csv
    └── segments_YYYYMMDD.json
```

---

## 📦 Installation

### Prérequis système
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y ffmpeg python3-pip python3-venv

# macOS
brew install ffmpeg
```

### Installation automatique
```bash
chmod +x setup.sh
./setup.sh
```

### Installation manuelle
```bash
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

pip install yt-dlp pydub numpy scipy tqdm
pip install inaSpeechSegmenter  # + TensorFlow
```

---

## 🚀 Utilisation

### Lancement standard (10h)
```bash
source venv/bin/activate
python pipeline.py --target-hours 10
```

### Avec sources personnalisées
```bash
# Éditer sources_example.json ou créer le vôtre
python pipeline.py --sources-file mes_sources.json --target-hours 10
```

### Options complètes
```bash
python pipeline.py \
  --output-dir    dataset/           # Répertoire de sortie
  --target-hours  10                 # Heures cibles
  --sources-file  sources.json       # Sources YouTube
  --pyannote-token HF_TOKEN          # Token HuggingFace (optionnel)
  --no-concat                        # Ne pas créer le fichier final
  --no-silence-removal               # Garder les silences
  --log-level     INFO               # DEBUG, INFO, WARNING
```

---

## 📁 Structure des sorties

```
dataset/
├── raw/                    # Fichiers téléchargés (originaux)
├── converted/              # WAV 16kHz mono convertis
├── segments/               # Segments speech extraits
│   ├── seg_00001_video1.wav
│   ├── seg_00002_video1.wav
│   └── ...
├── speech_dataset_YYYYMMDD.wav   # Dataset final concaténé
├── segments_YYYYMMDD.csv         # Métadonnées CSV
├── segments_YYYYMMDD.json        # Métadonnées JSON
└── pipeline.log                  # Logs du pipeline
```

### Format CSV/JSON
```json
{
  "label": "speech",
  "start": 12.345,
  "end": 28.901,
  "duration": 16.556,
  "source_file": "abc123_16k.wav",
  "output_file": "seg_00001_abc123.wav",
  "actual_duration": 14.2,
  "total_accumulated_hours": 0.004
}
```

---

## 🔧 Segmenteurs disponibles

### inaSpeechSegmenter (recommandé)
- ✅ Simple à installer, pas de token requis
- ✅ Distingue speech / music / noise
- ✅ Détecte male/female (optionnel)
- ⚠️ Nécessite TensorFlow

```bash
pip install inaSpeechSegmenter
```

### pyannote.audio (plus précis)
- ✅ State-of-the-art, très précis
- ✅ Speaker diarization intégré
- ⚠️ Nécessite un token HuggingFace gratuit
- ⚠️ Nécessite PyTorch

```bash
pip install pyannote.audio
# Token: https://huggingface.co/settings/tokens
```

---

## 🎁 Modules bonus

### Diarisation des locuteurs
```python
from diarization_bonus import diarize_audio, split_by_speaker

segments = diarize_audio(wav_path, hf_token="votre_token")
files_by_speaker = split_by_speaker(wav_path, segments, output_dir)
```

### Organisation par langue
```python
from diarization_bonus import organize_by_language

stats = organize_by_language(segments_dir, output_dir)
# Crée: dataset/fr/, dataset/en/, dataset/ar/, ...
```

### Rapport de qualité
```python
from diarization_bonus import generate_quality_report

report = generate_quality_report(segments_dir, "report.json")
```

---

## 💡 Conseils pour maximiser la qualité

1. **Privilégier les sources propres** : interviews radio, TED Talks, documentaires
2. **Éviter** les vidéos avec musique de fond (vlogs, clips musicaux)
3. **Durée minimale** : vidéos > 5 minutes pour rentabiliser le traitement
4. **Diversifier les sources** pour un dataset équilibré
5. **Vérifier manuellement** un échantillon des segments exportés

---

## ⚡ Performance attendue

| Source | Durée vidéo | Speech extrait | Temps traitement |
|--------|-------------|----------------|------------------|
| TED Talk | 15 min | ~12 min | ~3 min |
| Podcast | 60 min | ~50 min | ~12 min |
| Interview | 30 min | ~25 min | ~6 min |

**Pour 10h de speech ≈ 12-15h de vidéos source ≈ 2-4h de traitement**

---

## 📜 Licence

Usage libre pour projets de recherche et ML.
Respecter les CGU YouTube et les droits d'auteur des contenus téléchargés.
