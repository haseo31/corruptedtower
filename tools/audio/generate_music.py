"""Generates the game's music with a locally running ACE-Step 1.5 API server (stdlib only).

Start the server first (see production notes), then:
    python tools/audio/generate_music.py            # every track missing from assets/audio/music
    python tools/audio/generate_music.py title boss # just these (overwrites)
Writes assets/audio/music/<name>.mp3. All tracks are instrumental loops of about a minute.
"""
import json
import os
import sys
import time
import urllib.parse
import urllib.request

SERVER = "http://127.0.0.1:8001"
OUT = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "audio", "music")
DURATION = 60
STYLE = "16-bit chiptune, retro JRPG, square wave lead, instrumental, loopable, "

TRACKS = {
    "title": (STYLE + "mysterious and dramatic title theme, minor key, slow arpeggios, ominous but heroic", 90),
    "office": (STYLE + "tense bureaucratic office exploration, steady bassline, light staccato melody, suspenseful", 110),
    "poll": (STYLE + "busy election polling station, marching rhythm, nervous playful melody, mid tempo", 120),
    "hr": (STYLE + "cold corporate personnel office, sneaky walking bass, eerie and sly, minor key", 100),
    "boss": (STYLE + "intense boss battle, fast driving rhythm, urgent arpeggios, high energy, dark", 150),
    "ending": (STYLE + "hopeful bittersweet ending theme, warm major key, gentle melody, slow, triumphant at the end", 80),
}


def post(path: str, body: dict) -> dict:
    request = urllib.request.Request(SERVER + path, json.dumps(body).encode(), {"Content-Type": "application/json"})
    with urllib.request.urlopen(request, timeout=60) as response:
        return json.load(response)


def generate(name: str) -> None:
    prompt, bpm = TRACKS[name]
    task = post("/release_task", {
        "prompt": prompt, "lyrics": "[Instrumental]", "thinking": False, "batch_size": 1,
        "audio_duration": DURATION, "bpm": bpm, "audio_format": "mp3", "vocal_language": "en",
    })["data"]["task_id"]
    print(name, "submitted", task, flush=True)
    while True:
        time.sleep(5)
        row = post("/query_result", {"task_id_list": [task]})["data"][0]
        if row["status"] == 2:
            raise RuntimeError("generation failed for " + name + ": " + str(row["result"]))
        if row["status"] == 1:
            file_url = json.loads(row["result"])[0]["file"]
            break
    os.makedirs(OUT, exist_ok=True)
    with urllib.request.urlopen(SERVER + file_url, timeout=120) as response:
        data = response.read()
    with open(os.path.join(OUT, name + ".mp3"), "wb") as handle:
        handle.write(data)
    print(name, "saved", len(data), "bytes", flush=True)


def main() -> None:
    names = sys.argv[1:] or [n for n in TRACKS if not os.path.exists(os.path.join(OUT, n + ".mp3"))]
    for name in names:
        generate(name)


if __name__ == "__main__":
    main()
