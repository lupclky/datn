import base64
import io
import os

import cv2
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


def _preprocess_image(img: Image.Image) -> Image.Image:
    """
    Tiền xử lý ảnh trước khi embedding:
    1. Khử nhiễu bằng Bilateral Filter (giữ nguyên cạnh, làm mịn vùng phẳng)
    2. Cân bằng tương phản bằng CLAHE (Contrast Limited Adaptive Histogram Equalization)
    """
    # Chuyển PIL Image sang numpy array (BGR cho OpenCV)
    img_array = np.array(img)
    
    # Nếu ảnh là grayscale, chuyển sang RGB
    if len(img_array.shape) == 2:
        img_array = cv2.cvtColor(img_array, cv2.COLOR_GRAY2RGB)
    
    # Chuyển RGB sang BGR cho OpenCV
    img_bgr = cv2.cvtColor(img_array, cv2.COLOR_RGB2BGR)
    
    # Bước 1: Khử nhiễu bằng Bilateral Filter
    # d=9: đường kính vùng lọc
    # sigmaColor=75: lọc màu
    # sigmaSpace=75: lọc không gian
    img_denoised = cv2.bilateralFilter(img_bgr, d=9, sigmaColor=75, sigmaSpace=75)
    
    # Bước 2: Cân bằng tương phản bằng CLAHE
    # Chuyển sang LAB color space để xử lý kênh L (độ sáng)
    img_lab = cv2.cvtColor(img_denoised, cv2.COLOR_BGR2LAB)
    l_channel, a_channel, b_channel = cv2.split(img_lab)
    
    # Áp dụng CLAHE lên kênh L
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    l_enhanced = clahe.apply(l_channel)
    
    # Gộp lại các kênh
    img_lab_enhanced = cv2.merge([l_enhanced, a_channel, b_channel])
    img_enhanced = cv2.cvtColor(img_lab_enhanced, cv2.COLOR_LAB2BGR)
    
    # Chuyển BGR về RGB và trả về PIL Image
    img_rgb = cv2.cvtColor(img_enhanced, cv2.COLOR_BGR2RGB)
    return Image.fromarray(img_rgb)
# Tiền xử lý ảnh (khử nhiễu + cân bằng tương phản)

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
        
        # Bước 1: Chuyển sang RGB nếu cần
        if img.mode != 'RGB':
            img = img.convert('RGB')
        
        # Bước 2: Tiền xử lý ảnh (khử nhiễu + cân bằng tương phản)
        img = _preprocess_image(img)
        
        # Bước 3: Xóa nền ảnh
        img_no_bg = remove(img)
        
        # Bước 4: Tạo nền trắng
        new_img = Image.new("RGB", img_no_bg.size, (255, 255, 255))
        
        # Ghép ảnh sản phẩm lên nền trắng
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