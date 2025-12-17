# Python Embedding Service (CLIP)

This service provides **text** and **image** embeddings using CLIP and exposes a simple HTTP API for the Spring Boot backend.

## Endpoints

- `GET /health`
- `POST /embed/text`  
  Body: `{ "text": "..." }`
- `POST /embed/image`  
  Body: `{ "image_base64": "..." }`

Both return: `{ "embedding": [ ... ] }` (512-dim floats for `openai/clip-vit-base-patch32`).

## Setup (Windows)

From repo root:

```powershell
cd python-embedding-service
python -m venv .venv
.\.venv\Scripts\Activate.ps1

# Install torch CPU (recommended):
pip install --index-url https://download.pytorch.org/whl/cpu torch

pip install -r requirements.txt

# Run
uvicorn app:app --host 0.0.0.0 --port 9001
```

## Config

- Model: `EMBEDDING_MODEL_NAME` (default: `openai/clip-vit-base-patch32`)
- Device: `EMBEDDING_DEVICE` (default: `cpu`)

Example:

```powershell
$env:EMBEDDING_MODEL_NAME = "openai/clip-vit-base-patch32"
$env:EMBEDDING_DEVICE = "cpu"
uvicorn app:app --host 0.0.0.0 --port 9001
```
