import base64
import io
import os

import numpy as np
import torch
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from PIL import Image
from transformers import CLIPModel, CLIPProcessor
from rembg import remove

MODEL_NAME = os.getenv("EMBEDDING_MODEL_NAME", "openai/clip-vit-base-patch32")
# Tên model embedding
DEVICE = os.getenv("EMBEDDING_DEVICE", "cpu")
# Thiết bị embedding
app = FastAPI(title="LockerKorea Embedding Service", version="1.0")
# Khởi động FastAPI app

class TextRequest(BaseModel):
    text: str


class ImageRequest(BaseModel):
    image_base64: str


class EmbeddingResponse(BaseModel):
    embedding: list[float]


_processor: CLIPProcessor | None = None
_model: CLIPModel | None = None


@app.on_event("startup")
def _startup() -> None:
    global _processor, _model
    _processor = CLIPProcessor.from_pretrained(MODEL_NAME)
    _model = CLIPModel.from_pretrained(MODEL_NAME)
    _model.eval()
    _model.to(DEVICE)
# Khởi động model embedding

def _normalize(vec: torch.Tensor) -> torch.Tensor:
    vec = vec / (vec.norm(dim=-1, keepdim=True) + 1e-12)
    return vec
# Normalize vector

@app.get("/health")
def health() -> dict:
    return {"status": "ok", "model": MODEL_NAME, "device": DEVICE}
# Health check


@app.post("/embed/text", response_model=EmbeddingResponse)
def embed_text(req: TextRequest) -> EmbeddingResponse:
    if _processor is None or _model is None:
        raise HTTPException(status_code=503, detail="Model not initialized")

    text = (req.text or "").strip()
    if not text:
        raise HTTPException(status_code=400, detail="text is empty")

    inputs = _processor(text=[text], return_tensors="pt", padding=True, truncation=True)
    inputs = {k: v.to(DEVICE) for k, v in inputs.items()}

    with torch.no_grad():
        feats = _model.get_text_features(**inputs)
        feats = _normalize(feats)

    emb = feats[0].detach().cpu().numpy().astype(np.float32).tolist()
    return EmbeddingResponse(embedding=emb)
# Embed text


@app.post("/embed/image", response_model=EmbeddingResponse)
def embed_image(req: ImageRequest) -> EmbeddingResponse:
    if _processor is None or _model is None:
        raise HTTPException(status_code=503, detail="Model not initialized")

    try:
        raw = base64.b64decode(req.image_base64)
        img = Image.open(io.BytesIO(raw))
        
        # Remove background
        img_no_bg = remove(img)
        
        # Create white background
        new_img = Image.new("RGB", img_no_bg.size, (255, 255, 255))
        
        # Composite image over white background if it has alpha channel
        if img_no_bg.mode == 'RGBA':
            new_img.paste(img_no_bg, mask=img_no_bg.split()[3])
        else:
            new_img = img_no_bg.convert("RGB")
            
        img = new_img
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid image_base64: {e}")

    inputs = _processor(images=[img], return_tensors="pt")
    inputs = {k: v.to(DEVICE) for k, v in inputs.items()}

    with torch.no_grad():
        feats = _model.get_image_features(**inputs)
        feats = _normalize(feats)

    emb = feats[0].detach().cpu().numpy().astype(np.float32).tolist()
    return EmbeddingResponse(embedding=emb)
# Embed image