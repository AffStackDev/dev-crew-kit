# Data, notebooks, GPUs and other AI services

## What it's for in this workflow

Scripts and notebooks that crunch data, local AI models (speech-to-text, image models, local LLMs), and calls to
other AI services, all reproducible and without surprise bills.

## Way in

| Need | Way |
|---|---|
| Notebooks | JupyterLab in Docker (the Jupyter project's images on quay.io), the project mounted, bound to `127.0.0.1` |
| Scripts | The project's runner image with Python (or R) and pinned packages |
| GPU work | Docker with the NVIDIA runtime: Docker Desktop on Windows supports GPUs through WSL 2 with a current NVIDIA driver; `docker run --gpus all ...`. Check `docker run --rm --gpus all nvidia/cuda:<tag> nvidia-smi` (ask first: the image is large) |
| Local models | A local model server in Docker (Ollama and similar) or the model's own tools; models are large downloads: ask, and keep them in one known volume |
| Other AI services | Their official SDKs or APIs, keys from the environment |

## Files

- Datasets and model files in `Dev-local\<project>\data\` (or a volume), not Git. A manifest in Git (name, SHA-256,
  size, source, licence, date). Tools like DVC are an option if the user wants dataset versioning.
- Personal or customer data: only with the user's OK, minimized, never in Git, deleted when done.

## Guardrails worth setting

- **Costs:** paid API calls and GPU cloud time are the user's money. Record limits in `TOOLS.md`; estimate a job's
  cost before running it; stop at the limit; never raise a spending limit.
- **Memory caps still apply** to GPU containers (system RAM); GPU memory is separate and shared by everything on the
  card: one GPU job at a time unless the user says otherwise.
- Model and dataset licences: note them; the user decides what's acceptable for commercial use.

## Prove it

A small script or notebook cell runs in Docker against a sample of the data and writes its output to the evidence
folder; for GPU work, `nvidia-smi` inside a container shows the card.

## Checks to add

Notebook execution from the command line (`jupyter nbconvert --execute` or `papermill`) so notebooks are tested like
code; data validation (row counts, schema, ranges); fixed random seeds for anything compared run to run.
