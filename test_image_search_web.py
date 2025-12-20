#!/usr/bin/env python3
"""
Web app đơn giản để test tìm kiếm sản phẩm bằng hình ảnh
Chạy: python test_image_search_web.py
Truy cập: http://localhost:5000
"""
from flask import Flask, render_template_string, request, jsonify
import requests
import base64
import os

app = Flask(__name__)

# Cấu hình
EMBEDDING_SERVICE_URL = "http://localhost:9001"
CHROMA_BASE_URL = "http://localhost:8000"
COLLECTION_NAME = "sneakers-collection"

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>Test Image Search - ChromaDB</title>
    <meta charset="UTF-8">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 40px;
        }
        h1 {
            color: #333;
            margin-bottom: 30px;
            text-align: center;
        }
        .upload-area {
            border: 3px dashed #667eea;
            border-radius: 15px;
            padding: 40px;
            text-align: center;
            margin-bottom: 30px;
            background: #f8f9ff;
            transition: all 0.3s;
        }
        .upload-area:hover {
            border-color: #764ba2;
            background: #f0f2ff;
        }
        .upload-area.dragover {
            border-color: #764ba2;
            background: #e8ebff;
        }
        input[type="file"] {
            display: none;
        }
        .upload-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 40px;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            cursor: pointer;
            transition: transform 0.2s;
        }
        .upload-btn:hover {
            transform: scale(1.05);
        }
        .preview {
            margin: 20px 0;
            text-align: center;
        }
        .preview img {
            max-width: 300px;
            max-height: 300px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        .search-btn {
            background: #28a745;
            color: white;
            padding: 15px 40px;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            cursor: pointer;
            width: 100%;
            margin-top: 20px;
            transition: background 0.3s;
        }
        .search-btn:hover {
            background: #218838;
        }
        .search-btn:disabled {
            background: #ccc;
            cursor: not-allowed;
        }
        .loading {
            text-align: center;
            padding: 20px;
            color: #667eea;
            font-size: 18px;
        }
        .results {
            margin-top: 40px;
        }
        .result-item {
            background: #f8f9ff;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            border-left: 5px solid #667eea;
        }
        .result-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }
        .result-title {
            font-size: 20px;
            font-weight: bold;
            color: #333;
        }
        .similarity {
            background: #667eea;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 14px;
        }
        .result-details {
            color: #666;
            line-height: 1.8;
        }
        .result-details strong {
            color: #333;
        }
        .error {
            background: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 10px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔍 Test Tìm Kiếm Sản Phẩm Bằng Hình Ảnh</h1>
        
        <div class="upload-area" id="uploadArea">
            <p style="font-size: 18px; margin-bottom: 20px;">📸 Kéo thả ảnh vào đây hoặc click để chọn</p>
            <input type="file" id="imageInput" accept="image/*">
            <label for="imageInput" class="upload-btn">Chọn ảnh</label>
        </div>
        
        <div class="preview" id="preview" style="display: none;">
            <img id="previewImg" src="" alt="Preview">
        </div>
        
        <button class="search-btn" id="searchBtn" disabled>Tìm kiếm sản phẩm</button>
        
        <div id="loading" class="loading" style="display: none;">
            🔄 Đang xử lý...
        </div>
        
        <div id="results" class="results"></div>
    </div>

    <script>
        const uploadArea = document.getElementById('uploadArea');
        const imageInput = document.getElementById('imageInput');
        const preview = document.getElementById('preview');
        const previewImg = document.getElementById('previewImg');
        const searchBtn = document.getElementById('searchBtn');
        const loading = document.getElementById('loading');
        const results = document.getElementById('results');
        
        let selectedFile = null;

        // Drag and drop
        uploadArea.addEventListener('dragover', (e) => {
            e.preventDefault();
            uploadArea.classList.add('dragover');
        });

        uploadArea.addEventListener('dragleave', () => {
            uploadArea.classList.remove('dragover');
        });

        uploadArea.addEventListener('drop', (e) => {
            e.preventDefault();
            uploadArea.classList.remove('dragover');
            const file = e.dataTransfer.files[0];
            if (file && file.type.startsWith('image/')) {
                handleFile(file);
            }
        });

        imageInput.addEventListener('change', (e) => {
            const file = e.target.files[0];
            if (file) {
                handleFile(file);
            }
        });

        function handleFile(file) {
            selectedFile = file;
            const reader = new FileReader();
            reader.onload = (e) => {
                previewImg.src = e.target.result;
                preview.style.display = 'block';
                searchBtn.disabled = false;
            };
            reader.readAsDataURL(file);
        }

        searchBtn.addEventListener('click', async () => {
            if (!selectedFile) return;

            searchBtn.disabled = true;
            loading.style.display = 'block';
            results.innerHTML = '';

            const formData = new FormData();
            formData.append('image', selectedFile);

            try {
                const response = await fetch('/search', {
                    method: 'POST',
                    body: formData
                });

                const data = await response.json();

                if (data.success) {
                    displayResults(data.results);
                } else {
                    results.innerHTML = `<div class="error">❌ ${data.error}</div>`;
                }
            } catch (error) {
                results.innerHTML = `<div class="error">❌ Lỗi: ${error.message}</div>`;
            } finally {
                searchBtn.disabled = false;
                loading.style.display = 'none';
            }
        });

        function displayResults(results) {
            if (!results || results.length === 0) {
                results.innerHTML = '<div class="error">❌ Không tìm thấy sản phẩm nào tương tự</div>';
                return;
            }

            let html = '<h2 style="margin-bottom: 20px;">📦 Kết quả tìm kiếm:</h2>';
            
            results.forEach((result, index) => {
                const metadata = result.metadata || {};
                const similarity = result.distance !== null ? ((1 - result.distance) * 100).toFixed(2) : 'N/A';
                
                html += `
                    <div class="result-item">
                        <div class="result-header">
                            <div class="result-title">${index + 1}. ${metadata.product_name || 'N/A'}</div>
                            <div class="similarity">${similarity}% tương đồng</div>
                        </div>
                        <div class="result-details">
                            <strong>🆔 Product ID:</strong> ${metadata.product_id || 'N/A'}<br>
                            <strong>🏷️ Danh mục:</strong> ${metadata.category_name || 'N/A'}<br>
                            <strong>💰 Giá:</strong> ${metadata.price ? parseInt(metadata.price).toLocaleString('vi-VN') : 'N/A'} VND<br>
                            ${metadata.discount && metadata.discount > 0 ? `<strong>🎯 Giảm giá:</strong> ${metadata.discount}%<br>` : ''}
                            ${metadata.features ? `<strong>⚙️ Tính năng:</strong> ${metadata.features}<br>` : ''}
                            <strong>📄 Loại:</strong> ${metadata.type || 'unknown'}
                        </div>
                    </div>
                `;
            });

            results.innerHTML = html;
        }
    </script>
</body>
</html>
"""

def get_collection_id():
    """Lấy collection ID từ ChromaDB"""
    try:
        response = requests.get(f"{CHROMA_BASE_URL}/api/v1/collections", timeout=10)
        if response.status_code == 200:
            collections = response.json()
            for col in collections:
                if col.get('name') == COLLECTION_NAME:
                    return col.get('id')
        return None
    except:
        return None

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

@app.route('/search', methods=['POST'])
def search():
    try:
        if 'image' not in request.files:
            return jsonify({'success': False, 'error': 'Không có file ảnh'})
        
        file = request.files['image']
        if file.filename == '':
            return jsonify({'success': False, 'error': 'File rỗng'})
        
        # Đọc và encode ảnh
        image_data = file.read()
        image_base64 = base64.b64encode(image_data).decode('utf-8')
        
        # Bước 1: Embed ảnh
        try:
            embed_response = requests.post(
                f"{EMBEDDING_SERVICE_URL}/embed/image",
                json={"image_base64": image_base64},
                timeout=60
            )
            
            if embed_response.status_code != 200:
                return jsonify({
                    'success': False,
                    'error': f'Lỗi khi embed ảnh: {embed_response.status_code}'
                })
            
            embedding = embed_response.json().get('embedding', [])
        except requests.exceptions.ConnectionError:
            return jsonify({
                'success': False,
                'error': 'Không thể kết nối đến Embedding Service. Hãy đảm bảo service đang chạy tại http://localhost:9001'
            })
        
        # Bước 2: Tìm kiếm trong ChromaDB
        collection_id = get_collection_id()
        if not collection_id:
            return jsonify({
                'success': False,
                'error': f'Không tìm thấy collection: {COLLECTION_NAME}'
            })
        
        try:
            chroma_response = requests.post(
                f"{CHROMA_BASE_URL}/api/v1/collections/{collection_id}/query",
                json={
                    "query_embeddings": [embedding],
                    "n_results": 5
                },
                timeout=30
            )
            
            if chroma_response.status_code != 200:
                return jsonify({
                    'success': False,
                    'error': f'Lỗi khi query ChromaDB: {chroma_response.status_code}'
                })
            
            data = chroma_response.json()
            results = []
            
            if 'ids' in data and len(data['ids']) > 0:
                ids = data['ids'][0] if isinstance(data['ids'][0], list) else data['ids']
                metadatas = data.get('metadatas', [[]])[0] if data.get('metadatas') else []
                documents = data.get('documents', [[]])[0] if data.get('documents') else []
                distances = data.get('distances', [[]])[0] if data.get('distances') else []
                
                for i in range(len(ids)):
                    results.append({
                        'id': ids[i],
                        'metadata': metadatas[i] if i < len(metadatas) else {},
                        'document': documents[i] if i < len(documents) else "",
                        'distance': distances[i] if i < len(distances) else None
                    })
            
            return jsonify({
                'success': True,
                'results': results
            })
        
        except requests.exceptions.ConnectionError:
            return jsonify({
                'success': False,
                'error': 'Không thể kết nối đến ChromaDB. Hãy đảm bảo ChromaDB đang chạy tại http://localhost:8000'
            })
    
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Lỗi: {str(e)}'
        })

if __name__ == '__main__':
    print("=" * 60)
    print("🚀 Web App Test Image Search - ChromaDB")
    print("=" * 60)
    print(f"📡 Embedding Service: {EMBEDDING_SERVICE_URL}")
    print(f"📡 ChromaDB: {CHROMA_BASE_URL}")
    print(f"📦 Collection: {COLLECTION_NAME}")
    print()
    print("🌐 Truy cập: http://localhost:5000")
    print("=" * 60)
    print()
    
    app.run(debug=True, host='0.0.0.0', port=5000)

