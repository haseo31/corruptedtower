"""Generates the game's sound effects as 16-bit mono WAV files (stdlib only, deterministic).

Run:  python tools/audio/generate_sfx.py
Writes assets/audio/sfx/<name>.wav. Every sound is made here from simple waves and noise,
so they are original and reproducible.
"""
import math
import os
import random
import struct
import wave

RATE = 22050
OUT = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "audio", "sfx")


def square(phase: float, duty: float = 0.5) -> float:
    return 1.0 if (phase % 1.0) < duty else -1.0


def tri(phase: float) -> float:
    return 4.0 * abs((phase % 1.0) - 0.5) - 1.0


def tone(freq_fn, length: float, wave_fn=square, vol: float = 0.5, attack: float = 0.004, release: float = 0.05):
    """freq_fn(t) -> Hz. Returns a list of samples with a short attack and release."""
    n = int(length * RATE)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / RATE
        phase += freq_fn(t) / RATE
        env = min(1.0, t / attack) * min(1.0, (length - t) / release)
        out.append(wave_fn(phase) * vol * max(env, 0.0))
    return out


def noise(length: float, vol: float = 0.4, decay: float = 20.0, seed: int = 1):
    rng = random.Random(seed)
    n = int(length * RATE)
    return [(rng.random() * 2 - 1) * vol * math.exp(-decay * i / RATE) for i in range(n)]


def seq(notes, wave_fn=square, vol=0.4, gap=0.0):
    """notes: list of (hz, seconds). hz 0 is a rest."""
    out = []
    for hz, sec in notes:
        out += tone(lambda t, h=hz: h, sec, wave_fn, vol) if hz else [0.0] * int(sec * RATE)
        out += [0.0] * int(gap * RATE)
    return out


def mix(*tracks):
    n = max(len(t) for t in tracks)
    return [sum(t[i] if i < len(t) else 0.0 for t in tracks) for i in range(n)]


def write(name: str, samples) -> None:
    os.makedirs(OUT, exist_ok=True)
    with wave.open(os.path.join(OUT, name + ".wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32000)) for s in samples))


def main() -> None:
    write("ui_move", tone(lambda t: 880, 0.04, square, 0.25))
    write("ui_select", seq([(660, 0.05), (990, 0.09)], square, 0.3))
    write("ui_back", seq([(520, 0.05), (330, 0.09)], square, 0.3))
    write("blip", tone(lambda t: 520, 0.03, square, 0.18, release=0.02))
    write("step", noise(0.06, 0.25, 45, seed=3))
    write("pickup", seq([(784, 0.05), (988, 0.05), (1318, 0.12)], tri, 0.45))
    write("locked", mix(tone(lambda t: 110, 0.18, square, 0.4), noise(0.1, 0.3, 30, seed=4)))
    write("correct", seq([(523, 0.08), (659, 0.08), (784, 0.08), (1047, 0.22)], square, 0.3))
    write("wrong", mix(tone(lambda t: 196 - 60 * t, 0.3, square, 0.35), tone(lambda t: 185 - 60 * t, 0.3, square, 0.3)))
    write("hit", mix(tone(lambda t: 300 * math.exp(-8 * t) + 60, 0.2, square, 0.5), noise(0.15, 0.4, 25, seed=5)))
    write("counter", mix(seq([(440, 0.05), (880, 0.05), (1760, 0.14)], square, 0.3), noise(0.08, 0.2, 40, seed=6)))
    write("stairs", seq([(330, 0.07), (392, 0.07), (494, 0.07), (659, 0.16)], tri, 0.5))
    write("save", seq([(659, 0.07), (784, 0.07), (988, 0.14)], tri, 0.45))
    write("win", seq([(523, 0.12), (523, 0.12), (523, 0.12), (659, 0.2), (784, 0.12), (659, 0.12), (784, 0.5)], square, 0.3))
    write("lose", seq([(392, 0.2), (370, 0.2), (349, 0.2), (294, 0.55)], tri, 0.5))
    print("wrote", len(os.listdir(OUT)), "files to", os.path.normpath(OUT))


if __name__ == "__main__":
    main()
