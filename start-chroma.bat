@echo off
REM Script to start ChromaDB for Sneakers AI Chatbot (Windows)
REM Author: Locker Korea Team
REM Date: 2025-11-04

echo.
echo ========================================
echo   Starting ChromaDB for Sneakers AI
echo ========================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not installed or not in PATH
    echo Please install Docker Desktop from: https://docs.docker.com/desktop/install/windows-install/
    pause
    exit /b 1
)

REM Check if docker-compose is available
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Using 'docker compose' instead of 'docker-compose'
    set DOCKER_COMPOSE=docker compose
) else (
    set DOCKER_COMPOSE=docker-compose
)

REM Check if ChromaDB is already running
docker ps | findstr sneakers-chromadb >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo WARNING: ChromaDB is already running!
    echo.
    set /p restart="Do you want to restart it? (Y/N): "
    if /i "%restart%"=="Y" (
        echo.
        echo Restarting ChromaDB...
        %DOCKER_COMPOSE% -f docker-compose-chroma.yml restart
    ) else (
        echo.
        echo Using existing ChromaDB instance
        goto :status
    )
) else (
    echo Starting ChromaDB container...
    %DOCKER_COMPOSE% -f docker-compose-chroma.yml up -d
)

REM Wait for ChromaDB to be ready
echo.
echo Waiting for ChromaDB to be ready...
set /a attempts=0
set /a max_attempts=30

:wait_loop
set /a attempts+=1
if %attempts% gtr %max_attempts% (
    echo.
    echo ERROR: ChromaDB failed to start after 30 attempts
    echo Check logs with: docker logs sneakers-chromadb
    pause
    exit /b 1
)

curl -s http://localhost:8000/api/v1/heartbeat >nul 2>&1
if %errorlevel% neq 0 (
    echo Attempt %attempts%/%max_attempts%...
    timeout /t 2 /nobreak >nul
    goto :wait_loop
)

echo.
echo ChromaDB is ready!

:status
echo.
echo ========================================
echo   ChromaDB Status
echo ========================================
echo URL:       http://localhost:8000
echo Heartbeat: http://localhost:8000/api/v1/heartbeat
echo Container: sneakers-chromadb
echo.

REM Test connection
echo Testing connection...
curl -s http://localhost:8000/api/v1/heartbeat
if %errorlevel% equ 0 (
    echo.
    echo Connection successful!
) else (
    echo.
    echo WARNING: Could not connect to ChromaDB
)

echo.
echo ========================================
echo   Useful Commands
echo ========================================
echo View logs:  docker logs sneakers-chromadb -f
echo Stop:       docker-compose -f docker-compose-chroma.yml stop
echo Restart:    docker-compose -f docker-compose-chroma.yml restart
echo Remove:     docker-compose -f docker-compose-chroma.yml down -v
echo ========================================
echo.
echo ChromaDB is running! You can now start the backend server.
echo.
pause

