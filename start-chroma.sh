#!/bin/bash

# Script to start ChromaDB for Sneakers AI Chatbot
# Author: Locker Korea Team
# Date: 2025-11-04

set -e

echo "🚀 Starting ChromaDB for Sneakers AI Chatbot..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "⚠️  docker-compose not found, trying 'docker compose'..."
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

# Check if ChromaDB is already running
if docker ps | grep -q sneakers-chromadb; then
    echo "⚠️  ChromaDB is already running!"
    echo "Container ID: $(docker ps | grep sneakers-chromadb | awk '{print $1}')"
    
    read -p "Do you want to restart it? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔄 Restarting ChromaDB..."
        $DOCKER_COMPOSE -f docker-compose-chroma.yml restart
    else
        echo "✅ Using existing ChromaDB instance"
    fi
else
    echo "📦 Starting ChromaDB container..."
    $DOCKER_COMPOSE -f docker-compose-chroma.yml up -d
fi

# Wait for ChromaDB to be ready
echo "⏳ Waiting for ChromaDB to be ready..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if curl -s http://localhost:8000/api/v1/heartbeat > /dev/null 2>&1; then
        echo "✅ ChromaDB is ready!"
        break
    fi
    
    attempt=$((attempt + 1))
    if [ $attempt -eq $max_attempts ]; then
        echo "❌ ChromaDB failed to start after 30 attempts"
        echo "Check logs with: docker logs sneakers-chromadb"
        exit 1
    fi
    
    echo "   Attempt $attempt/$max_attempts..."
    sleep 2
done

# Display status
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ChromaDB Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 URL: http://localhost:8000"
echo "📊 Heartbeat: http://localhost:8000/api/v1/heartbeat"
echo "📦 Container: sneakers-chromadb"
echo ""

# Test connection
echo "🔍 Testing connection..."
if response=$(curl -s http://localhost:8000/api/v1/heartbeat 2>&1); then
    echo "✅ Connection successful!"
    echo "Response: $response"
else
    echo "⚠️  Could not connect to ChromaDB"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Useful Commands:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "View logs:    docker logs sneakers-chromadb -f"
echo "Stop:         docker-compose -f docker-compose-chroma.yml stop"
echo "Restart:      docker-compose -f docker-compose-chroma.yml restart"
echo "Remove:       docker-compose -f docker-compose-chroma.yml down -v"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎉 ChromaDB is running! You can now start the backend server."

