# 🔐 Google Cloud Setup - Hướng Dẫn Cấu Hình

## ❌ Lỗi Hiện Tại

```
Your default credentials were not found. To set up Application Default Credentials for your environment
```

## ✅ Giải Pháp

### Cách 1: Setup Application Default Credentials (Khuyến nghị)

#### Bước 1: Tạo Service Account Key

1. Vào [Google Cloud Console](https://console.cloud.google.com/)
2. Chọn project của bạn
3. Vào **IAM & Admin** → **Service Accounts**
4. Click **Create Service Account**
5. Đặt tên: `sneakers-ai-service`
6. Click **Create and Continue**
7. Chọn role: **Vertex AI User**
8. Click **Done**

#### Bước 2: Tạo Key File

1. Click vào service account vừa tạo
2. Vào tab **Keys**
3. Click **Add Key** → **Create new key**
4. Chọn **JSON**
5. Download file JSON (ví dụ: `sneakers-ai-key.json`)

#### Bước 3: Set Environment Variable

**Windows (PowerShell):**
```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="D:\do_an_tot_nghiep\locker_korea\Backend\sneakers-ai-key.json"
```

**Windows (CMD):**
```cmd
set GOOGLE_APPLICATION_CREDENTIALS=D:\do_an_tot_nghiep\locker_korea\Backend\sneakers-ai-key.json
```

**Linux/Mac:**
```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/sneakers-ai-key.json
```

**Permanent (Windows):**
1. System Properties → Environment Variables
2. Add new User variable:
   - Name: `GOOGLE_APPLICATION_CREDENTIALS`
   - Value: `D:\do_an_tot_nghiep\locker_korea\Backend\sneakers-ai-key.json`

**Permanent (Linux/Mac):**
```bash
# Add to ~/.bashrc or ~/.zshrc
echo 'export GOOGLE_APPLICATION_CREDENTIALS=/path/to/sneakers-ai-key.json' >> ~/.bashrc
source ~/.bashrc
```

#### Bước 4: Kiểm Tra

```bash
# Windows
echo %GOOGLE_APPLICATION_CREDENTIALS%

# Linux/Mac
echo $GOOGLE_APPLICATION_CREDENTIALS
```

### Cách 2: Sử dụng gcloud CLI

```bash
# Install gcloud CLI (nếu chưa có)
# https://cloud.google.com/sdk/docs/install

# Login
gcloud auth login

# Set default project
gcloud config set project YOUR_PROJECT_ID

# Set application default credentials
gcloud auth application-default login
```

### Cách 3: Thêm vào application.yaml (Không khuyến nghị cho production)

```yaml
spring:
  google:
    ai:
      project-id: your-project-id
      location: us-central1
      model: gemini-2.0-flash-001
      credentials-file: ${GOOGLE_APPLICATION_CREDENTIALS:path/to/key.json}
```

## 🔧 Cấu Hình Project

### 1. Enable Vertex AI API

```bash
gcloud services enable aiplatform.googleapis.com
```

Hoặc trong Console:
1. **APIs & Services** → **Library**
2. Tìm "Vertex AI API"
3. Click **Enable**

### 2. Kiểm Tra Project ID

File `application.yaml`:
```yaml
spring:
  google:
    ai:
      project-id: first-strength-460610-i4  # Đổi thành project ID của bạn
```

### 3. Kiểm Tra Quyền

Service account cần các roles:
- ✅ **Vertex AI User** (aiplatform.endpoints.predict)
- ✅ **Service Account User** (nếu cần)

## 🧪 Test Kết Nối

### Test trong Java:

```java
import com.google.cloud.aiplatform.v1beta1.PredictionServiceClient;
import com.google.auth.oauth2.GoogleCredentials;

public class TestCredentials {
    public static void main(String[] args) {
        try {
            GoogleCredentials credentials = GoogleCredentials.getApplicationDefault();
            System.out.println("✅ Credentials loaded successfully!");
            System.out.println("Project: " + credentials.getProjectId());
        } catch (Exception e) {
            System.err.println("❌ Error: " + e.getMessage());
        }
    }
}
```

### Test qua Terminal:

```bash
# Windows PowerShell
$env:GOOGLE_APPLICATION_CREDENTIALS="path\to\key.json"
java -cp your-app.jar YourMainClass

# Linux/Mac
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json
java -cp your-app.jar YourMainClass
```

## 🚀 Chạy Backend với Credentials

### Option 1: Environment Variable

```bash
# Windows
set GOOGLE_APPLICATION_CREDENTIALS=D:\path\to\key.json
mvn spring-boot:run

# Linux/Mac
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json
mvn spring-boot:run
```

### Option 2: IntelliJ IDEA

1. Run → Edit Configurations
2. Chọn Spring Boot configuration
3. Environment variables:
   ```
   GOOGLE_APPLICATION_CREDENTIALS=D:\path\to\key.json
   ```
4. Apply → Run

### Option 3: Eclipse

1. Run → Run Configurations
2. Chọn Java Application
3. Environment tab
4. Add:
   - Name: `GOOGLE_APPLICATION_CREDENTIALS`
   - Value: `D:\path\to\key.json`

### Option 4: VS Code

`.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "java",
      "name": "Spring Boot",
      "request": "launch",
      "env": {
        "GOOGLE_APPLICATION_CREDENTIALS": "${workspaceFolder}/Backend/sneakers-ai-key.json"
      }
    }
  ]
}
```

## 📁 Cấu Trúc Thư Mục Đề Xuất

```
Backend/
├── src/
├── sneakers-ai-key.json  ← Đặt file key ở đây
├── pom.xml
└── .gitignore           ← Đảm bảo key.json trong .gitignore
```

## ⚠️ Security Best Practices

### 1. .gitignore

```gitignore
# Google Cloud credentials
*.json
!package.json
!tsconfig.json
sneakers-ai-key.json
**/credentials/**
**/*-key.json
```

### 2. Không Commit Key File

```bash
# Kiểm tra
git status

# Nếu key.json đã được commit, remove:
git rm --cached Backend/sneakers-ai-key.json
git commit -m "Remove credentials"
```

### 3. Production Deployment

**Docker:**
```dockerfile
COPY sneakers-ai-key.json /app/credentials/
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/credentials/sneakers-ai-key.json
```

**Kubernetes Secret:**
```bash
kubectl create secret generic google-credentials \
  --from-file=key.json=sneakers-ai-key.json
```

## 🔍 Troubleshooting

### Lỗi: "File not found"

**Kiểm tra:**
```bash
# Windows
dir D:\do_an_tot_nghiep\locker_korea\Backend\sneakers-ai-key.json

# Linux/Mac
ls -la /path/to/sneakers-ai-key.json
```

**Fix:** Đảm bảo đường dẫn đúng và file tồn tại.

### Lỗi: "Invalid credentials"

**Kiểm tra:**
1. File JSON có đúng format không?
2. Service account có đủ quyền không?
3. Project ID có đúng không?

**Fix:**
```bash
# Re-download key file từ Google Cloud Console
```

### Lỗi: "Permission denied"

**Kiểm tra quyền file:**
```bash
# Linux/Mac
chmod 600 sneakers-ai-key.json
```

### Lỗi: "Project not found"

**Kiểm tra:**
1. Project ID trong `application.yaml`
2. Project có được enable Vertex AI API chưa?

**Fix:**
```bash
gcloud config set project YOUR_PROJECT_ID
gcloud services enable aiplatform.googleapis.com
```

## 📊 Kiểm Tra Setup

### Checklist:

- [ ] Google Cloud project đã tạo
- [ ] Vertex AI API đã enable
- [ ] Service account đã tạo với role "Vertex AI User"
- [ ] Key file JSON đã download
- [ ] Environment variable `GOOGLE_APPLICATION_CREDENTIALS` đã set
- [ ] Project ID trong `application.yaml` đúng
- [ ] Backend có thể start không lỗi

### Test Endpoint:

```bash
# Sau khi backend start thành công
curl http://localhost:8089/api/v1/ai/chat/text \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello"}'

# Nếu thành công → credentials OK ✅
```

## 🎯 Quick Fix

Nếu cần chạy ngay mà chưa setup credentials:

1. **Tạm thời disable AI features:**

```yaml
# application.yaml
ai:
  enabled: false
```

2. **Hoặc comment out AI beans:**

```java
// @Configuration
// @ConditionalOnProperty(name = "ai.enabled", havingValue = "true")
public class GeminiConfig { ... }
```

## 📞 Support

Nếu vẫn gặp vấn đề:
1. Kiểm tra logs: `Backend/logs/sneakers-app.log`
2. Xem Google Cloud Console → IAM & Admin → Service Accounts
3. Verify API enabled: APIs & Services → Enabled APIs

---

**Version**: 1.0.0  
**Last Updated**: 04/11/2025

