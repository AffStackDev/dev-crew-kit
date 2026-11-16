# Video and audio (ffmpeg, Descript, DaVinci Resolve, Premiere, OBS, captions)

## What it's for in this workflow

Tutorials, product videos, podcasts and social clips: recording, cutting, captions, loudness, exports, and the checks
that catch a bad video before anyone sees it. The agents are good at the repeatable parts (recording scripted screen
sessions, cutting by time codes, captions, measuring, checking) and at keeping track of versions and files.

## Way in

| Tool | Way in |
|---|---|
| **ffmpeg** | In Docker (Ubuntu's `ffmpeg` package in a small image, or an official build). Cutting, joining, encoding, captions, measuring. The workhorse. |
| Screen recordings of web apps | Playwright in Docker records the browser to video; scripted, repeatable, no desktop needed |
| OBS | Built-in WebSocket control (obs-websocket) for start/stop/scene switching, if the user records with OBS |
| Descript | A web and desktop app; work through it in the browser with the user's sign-in, or through its own export and import. It's credit-based: see guardrails |
| DaVinci Resolve | Has a Python/Lua scripting API; driving it from outside the app needs the Studio edition in current versions (check Blackmagic's scripting README for the installed version) |
| Premiere Pro / After Effects | Adobe's scripting (ExtendScript/UXP) inside the app; limited from outside |
| Captions / transcripts | A speech-to-text model run locally (see `data-and-ai.md`), or the editor's own transcription |

## Install

ffmpeg image (ask first; small):

```dockerfile
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg ca-certificates && rm -rf /var/lib/apt/lists/*
```

Run it with the media folder mounted and **a memory cap**: `docker run --rm --memory=4g --memory-swap=4g -v
<media folder>:/media <image> ffmpeg ...`. An uncapped encode container once took 18 of 20 GB and the computer ran
out of memory.

## Files

- Media doesn't go in Git (too big, and Git keeps every version forever). Keep it in `Dev-local\<project>\media\`
  with a small manifest in Git (file name, SHA-256, length, source, date) so versions are traceable. Git LFS is an
  option for small sets; check GitHub's LFS quotas first.
- **One canonical export.** Exports often land in Downloads. Find the real file (check the actual extension: an
  "audio" export may be an `.mp4` container), **move** it (not copy) into the project's media folder, verify it
  arrived and the Downloads copy is gone, and record both paths. Compare hashes before deleting a duplicate.
- Trigger one download or export and wait for the file; don't start a second while the first one's outcome is
  unknown.

## Guardrails worth setting

- **Credits and money.** Tools that charge per minute or per AI action (voices, transcription, generative features):
  record the plan's limits in `TOOLS.md`; **read the remaining credits before a job**, and don't start one that can't
  finish on what's left; never buy or top up credits; tell the user when credits run out and when they reset.
- **Publishing** (YouTube, social) only on the user's go; drafts and scheduled posts are states, not "published".
- Recordings never show secrets: test accounts, fake data, keys masked.

## Checks to add (per video)

| Check | ffmpeg way |
|---|---|
| Length within the target | `ffprobe -show_entries format=duration` |
| Loudness at the platform's target | `ffmpeg -i in.mp4 -af loudnorm=print_format=json -f null -` (integrated LUFS, true peak) |
| No long frozen or silent stretches | `freezedetect` and `silencedetect` filters |
| Resolution and frame rate as intended | `ffprobe -show_streams` (measure the encoded file, not the requested viewport) |
| Captions in sync and readable | Each caption's start within ~1.5 s of the words; no caption over two lines; the burned-in or sidecar file present |
| The right content | Spot-check frames at the moments the script names (`-ss <t> -frames:v 1`) |

## For tutorials recorded by script

- Show the real actions: visible typing, the pointer moving to each thing it clicks, scrolling through what's being
  explained. Prefilled forms and pasted values look fake.
- Prepare the app's state before recording (accounts, data), off camera.
- Keep an action log with time codes; compare it with the encoded file's times before cutting.
- Narration timing: each scene inside its paragraph of narration; record pickups for late lines rather than stretching
  video.

## Prove it

Cut a 10-second clip from an existing video in Docker, normalize its loudness, add a caption file, and run the checks
above; show the user the numbers and the clip.

## Checked against

ffmpeg documentation (filters: loudnorm, freezedetect, silencedetect, subtitles), the vendors' scripting docs.
