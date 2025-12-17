@echo off
setlocal
cd /d %~dp0

REM Optional:
REM set EMBEDDING_MODEL_NAME=openai/clip-vit-base-patch32
REM set EMBEDDING_DEVICE=cpu

uvicorn app:app --host 0.0.0.0 --port 9001
