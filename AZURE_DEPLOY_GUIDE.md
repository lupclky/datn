# Azure Deployment Guide

This guide explains how to set up your GitHub repository and Azure resources to enable the automated CI/CD pipeline.

## 1. Azure Resources Setup

You can automate the creation of all necessary Azure resources using the provided scripts.

### Option A: Automated Setup (Recommended)

**For Windows (PowerShell):**
1.  Open PowerShell.
2.  Login to Azure CLI: `az login`
3.  Run the script:
    ```powershell
    .\setup-azure.ps1
    ```

**For Linux/Mac/Git Bash:**
1.  Open a terminal.
2.  Login to Azure CLI: `az login`
3.  Run the script:
    ```bash
    chmod +x setup-azure.sh
    ./setup-azure.sh
    ```

4.  **Save the output!** It contains resource names and keys you will need for the next steps.

### Option B: Manual Setup

If you prefer to create resources manually via the Azure Portal:

1.  **Resource Group**: Create a resource group (e.g., `rg-lockerkorea`).
2.  **Azure Web App for Frontend**:
    *   Create a Web App.
    *   Publish: Code.
    *   Runtime stack: Node 18 LTS (or higher).
    *   Operating System: Linux.
    *   Name: e.g., `lockerkorea-frontend`.
3.  **Azure Web App for Backend**:
    *   Create a Web App.
    *   Publish: Code.
    *   Runtime stack: Java 17.
    *   Java web server stack: Java SE (Embedded Web Server).
    *   Operating System: Linux.
    *   Name: e.g., `lockerkorea-backend`.
4.  **Azure Database for MySQL**:
    *   Create a Flexible Server.
    *   Configure firewall to allow access from Azure services (Allow public access from any Azure service within Azure to this server).
5.  **Azure Storage Account**:
    *   Create a Storage Account.
    *   Create a container named `lockerkorea-images`.
6.  **Azure Container Instances (for Python Service & ChromaDB)**:
    *   The pipeline will create/update these automatically.

## 2. GitHub Secrets Configuration

Go to your GitHub Repository -> Settings -> Secrets and variables -> Actions -> New repository secret.

Add the following secrets:

### Azure Authentication (Using Publish Profile)
Since student accounts often cannot create Service Principals, we use Publish Profiles.

*   `AZURE_FRONTEND_PUBLISH_PROFILE`: The content of the `.publishsettings` file for your Frontend Web App.
    *   Get this from Azure Portal -> App Service (Frontend) -> "Get publish profile".
*   `AZURE_BACKEND_PUBLISH_PROFILE`: The content of the `.publishsettings` file for your Backend Web App.
    *   Get this from Azure Portal -> App Service (Backend) -> "Get publish profile".

### Resource Names
*   `AZURE_RESOURCE_GROUP`: Name of your resource group (e.g., `rg-lockerkorea`).
*   `AZURE_WEBAPP_FRONTEND_NAME`: Name of your Frontend Web App (e.g., `lockerkorea-frontend`).
*   `AZURE_WEBAPP_BACKEND_NAME`: Name of your Backend Web App (e.g., `lockerkorea-backend`).

### Docker Hub (for Container Images)
*   `DOCKERHUB_USERNAME`: Your Docker Hub username.
*   `DOCKERHUB_TOKEN`: Your Docker Hub access token.

### Application Configuration (Optional but Recommended)
You should configure these as **Environment Variables** in your Azure Web Apps (Settings -> Environment variables).

**Backend Web App Environment Variables:**
*   `SPRING_DATASOURCE_URL`: `jdbc:mysql://{your-mysql-server}.mysql.database.azure.com:3306/lockerkorea?useSSL=true&requireSSL=false`
*   `SPRING_DATASOURCE_USERNAME`: Your MySQL username.
*   `SPRING_DATASOURCE_PASSWORD`: Your MySQL password.
*   `AZURE_STORAGE_ACCOUNT_NAME`: Your Azure Storage Account Name.
*   `AZURE_STORAGE_ACCOUNT_KEY`: Your Azure Storage Account Key.
*   `AZURE_STORAGE_ENDPOINT`: Your Azure Storage Endpoint.
*   `AZURE_STORAGE_CONTAINER_NAME`: Your Container Name.
*   `CHROMA_BASE_URL`: `http://lockerkorea-chroma.southeastasia.azurecontainer.io:8000` (Adjust region if needed)
*   `AI_EMBEDDING_BASE_URL`: `http://lockerkorea-python.southeastasia.azurecontainer.io:8000` (Adjust region if needed)

**Frontend Web App Environment Variables:**
*   You may need to update `environment.prod.ts` or use a startup script to inject API URLs.

## 3. Workflow Overview

The `ci-cd.yml` workflow performs the following:

1.  **Frontend Job**: Builds the Angular app and deploys it to the Azure Web App (Frontend).
2.  **Backend Job**: Builds the Spring Boot JAR and deploys it to the Azure Web App (Backend).
3.  **Python Job**: Builds the Docker image for the Python embedding service, pushes it to Docker Hub, and deploys it to Azure Container Instances.
4.  **ChromaDB Job**: Deploys the official ChromaDB image to Azure Container Instances.
