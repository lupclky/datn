# System Architecture - Locker Korea

This document outlines the high-level architecture of the Locker Korea system, including its services, databases, and external integrations.

## Architecture Diagram

```mermaid
graph TD
    subgraph "Client Side"
        Browser[Web Browser]
    end

    subgraph "Infrastructure / Gateway"
        CF[Cloudflare Tunnel]
        Nginx[Nginx Proxy]
    end

    subgraph "Application Services"
        Frontend[Frontend Service<br/>(Angular)]
        Backend[Backend Service<br/>(Java Spring Boot)]
        PythonService[AI Embedding Service<br/>(Python FastAPI)]
    end

    subgraph "Data Persistence"
        MySQL[(MySQL Database)]
        ChromaDB[(ChromaDB<br/>Vector Store)]
    end

    subgraph "External Services"
        Gemini[Google Gemini AI]
        GCS[Google Cloud Storage]
        Gmail[Gmail SMTP]
    end

    %% Connections
    Browser -->|HTTPS| CF
    CF -->|HTTP| Nginx
    Nginx -->|Route /| Frontend
    Nginx -->|Route /api| Backend

    Frontend -->|API Calls| Backend

    Backend -->|Read/Write| MySQL
    Backend -->|Vector Search| ChromaDB
    Backend -->|Get Embeddings| PythonService
    Backend -->|GenAI| Gemini
    Backend -->|File Storage| GCS
    Backend -->|Send Email| Gmail

    PythonService -->|Load Model| CLIP[CLIP Model]
    
    %% Ports
    Backend -.->|Port 8089| Nginx
    Frontend -.->|Port 80| Nginx
    PythonService -.->|Port 9000| Backend
    ChromaDB -.->|Port 8000| Backend
    MySQL -.->|Port 3306| Backend
```

## Component Details

### 1. Frontend (Angular)
- **Container:** `lockerkorea-frontend`
- **Role:** User Interface for the application.
- **Communication:** Consumes REST APIs exposed by the Backend.

### 2. Backend (Java Spring Boot)
- **Container:** `lockerkorea-backend`
- **Role:** Core business logic, API management, and orchestration.
- **Key Integrations:**
  - **MySQL:** Primary relational database for user data, products, orders, etc.
  - **ChromaDB:** Vector database for semantic search and RAG (Retrieval-Augmented Generation).
  - **Python Service:** Internal microservice for generating text and image embeddings using CLIP.
  - **Google Gemini:** External LLM for advanced AI features (chat, content generation).
  - **Google Cloud Storage:** Storing uploaded files and images.
  - **Gmail SMTP:** Sending email notifications.

### 3. AI Embedding Service (Python)
- **Container:** `lockerkorea-python`
- **Framework:** FastAPI
- **Port:** 9000
- **Role:** Provides endpoints (`/embed/text`, `/embed/image`) to convert text and images into vector embeddings using the CLIP model (`openai/clip-vit-base-patch32`). These embeddings are used by the Backend and stored in ChromaDB.

### 4. Data Stores
- **MySQL:** Relational data (Users, Products, Orders).
- **ChromaDB:** Vector data for AI-powered search capabilities.

### 5. Infrastructure
- **Docker Compose:** Orchestrates all services.
- **Nginx Proxy:** Reverse proxy to route traffic to appropriate containers.
- **Cloudflare Tunnel:** Securely exposes the local services to the internet without opening ports.
