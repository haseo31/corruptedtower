# Audio

- `sfx/*.wav`: sound effects, generated from simple waves and noise by `tools/audio/generate_sfx.py`
  (stdlib only, deterministic). Original, no third-party samples.
- `music/*.mp3`: six instrumental loops (title, office, poll, hr, boss, ending), about 60 s each,
  generated with ACE-Step 1.5 (turbo DiT, no language model) by `tools/audio/generate_music.py`.
  Prompts and tempos are in that script.

## Licence

ACE-Step 1.5 and its weights are published under the MIT licence; the model card says the
generated music may be used commercially. Source: https://huggingface.co/ACE-Step/Ace-Step1.5
(model card checked 2026-10-28).

## Regenerating music (6 GB GPU)

1. Close other GPU programs. Start the ACE-Step API from its `.venv` with
   `ACESTEP_INIT_LLM=false`, `ACESTEP_CONFIG_PATH=acestep-v15-turbo` and
   `ACESTEP_OFFLOAD_DIT_TO_CPU=true` (without the last one the audio decode falls back to the CPU and
   takes more than 15 minutes).
2. `python tools/audio/generate_music.py [track ...]`

The tracks are plain loops: the end does not match the start, so a small seam can be heard on repeat.
