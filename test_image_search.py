#!/usr/bin/env python3
"""
Chương trình test tìm kiếm sản phẩm bằng hình ảnh trong ChromaDB
"""
import requests
import base64
import json
import sys
from pathlib import Path

# Cấu hình
EMBEDDING_SERVICE_URL = "http://localhost:9001"
CHROMA_BASE_URL = "http://localhost:8000"
COLLECTION_NAME = "sneakers-collection"

def encode_image_to_base64(image_path):
    """Chuyển đổi ảnh thành base64"""
    try:
        with open(image_path, 'rb') as image_file:
            image_data = image_file.read()
            base64_encoded = base64.b64encode(image_data).decode('utf-8')
            return base64_encoded
    except Exception as e:
        print(f"❌ Lỗi khi đọc file ảnh: {e}")
        return None

def embed_image(image_base64):
    """Gọi Python Embedding Service để embed ảnh"""
    try:
        print("🔄 Đang mã hóa ảnh thành vector...")
        response = requests.post(
            f"{EMBEDDING_SERVICE_URL}/embed/image",
            json={"image_base64": image_base64},
            timeout=60
        )
        
        if response.status_code == 200:
            result = response.json()
            embedding = result.get('embedding', [])
            print(f"✅ Mã hóa thành công! Vector có {len(embedding)} chiều")
            return embedding
        else:
            print(f"❌ Lỗi khi mã hóa ảnh: {response.status_code}")
            print(f"   Response: {response.text}")
            return None
    except requests.exceptions.ConnectionError:
        print(f"❌ Không thể kết nối đến Embedding Service tại {EMBEDDING_SERVICE_URL}")
        print("   Hãy đảm bảo Python Embedding Service đang chạy")
        return None
    except Exception as e:
        print(f"❌ Lỗi khi gọi Embedding Service: {e}")
        return None

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
    except Exception as e:
        print(f"❌ Lỗi khi lấy collection ID: {e}")
        return None

def search_in_chromadb(embedding, top_k=5):
    """Tìm kiếm trong ChromaDB bằng vector embedding"""
    try:
        collection_id = get_collection_id()
        if not collection_id:
            print(f"❌ Không tìm thấy collection: {COLLECTION_NAME}")
            return []
        
        print(f"🔍 Đang tìm kiếm trong ChromaDB (top {top_k})...")
        
        # Tăng n_results để có đủ kết quả sau khi filter duplicates
        # Mỗi sản phẩm có thể có 2 documents (text + image), nên cần lấy nhiều hơn
        query_limit = top_k * 3
        
        # ChromaDB query API yêu cầu query_embeddings (list of lists)
        response = requests.post(
            f"{CHROMA_BASE_URL}/api/v1/collections/{collection_id}/query",
            json={
                "query_embeddings": [embedding],  # List of embeddings
                "n_results": query_limit  # Lấy nhiều hơn để có đủ sau khi filter
            },
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            results = []
            
            if 'ids' in data and len(data['ids']) > 0:
                ids = data['ids'][0] if isinstance(data['ids'][0], list) else data['ids']
                metadatas = data.get('metadatas', [[]])[0] if data.get('metadatas') else []
                documents = data.get('documents', [[]])[0] if data.get('documents') else []
                distances = data.get('distances', [[]])[0] if data.get('distances') else []
                
                print(f"   📊 ChromaDB trả về {len(ids)} kết quả")
                
                for i in range(len(ids)):
                    results.append({
                        'id': ids[i],
                        'metadata': metadatas[i] if i < len(metadatas) else {},
                        'document': documents[i] if i < len(documents) else "",
                        'distance': distances[i] if i < len(distances) else None
                    })
            
            return results
        else:
            print(f"❌ Lỗi khi query ChromaDB: {response.status_code}")
            print(f"   Response: {response.text}")
            return []
    except Exception as e:
        print(f"❌ Lỗi khi tìm kiếm trong ChromaDB: {e}")
        return []

def display_results(results, top_k=5):
    """Hiển thị kết quả tìm kiếm"""
    if not results:
        print("\n❌ Không tìm thấy sản phẩm nào tương tự")
        return
    
    # Filter duplicates: chỉ giữ kết quả có distance thấp nhất (tương đồng cao nhất) cho mỗi product_id
    product_map = {}  # product_id -> best result (lowest distance)
    
    for result in results:
        metadata = result.get('metadata', {})
        product_id = metadata.get('product_id')
        distance = result.get('distance')
        
        if product_id:
            # Nếu chưa có hoặc distance thấp hơn (tương đồng cao hơn), cập nhật
            if product_id not in product_map or (distance is not None and 
                (product_map[product_id].get('distance') is None or 
                 distance < product_map[product_id].get('distance'))):
                product_map[product_id] = result
    
    # Chuyển về list và sắp xếp theo distance
    unique_results = list(product_map.values())
    unique_results.sort(key=lambda x: x.get('distance') if x.get('distance') is not None else float('inf'))
    
    # Kiểm tra duplicates
    product_ids = []
    for result in results:
        metadata = result.get('metadata', {})
        product_id = metadata.get('product_id')
        if product_id:
            product_ids.append(product_id)
    
    unique_count = len(set(product_ids))
    duplicate_count = len(product_ids) - unique_count
    
    print(f"\n{'=' * 80}")
    print(f"✅ ChromaDB trả về {len(results)} kết quả")
    print(f"📦 Sau khi filter duplicates: {len(unique_results)} sản phẩm duy nhất")
    if duplicate_count > 0:
        print(f"⚠️  Đã loại bỏ {duplicate_count} kết quả trùng lặp")
    print(f"{'=' * 80}\n")
    
    # Hiển thị top K sản phẩm unique
    display_count = 0
    for i, result in enumerate(unique_results[:top_k], 1):
        metadata = result.get('metadata', {})
        product_id = metadata.get('product_id')
        distance = result.get('distance')
        document = result.get('document', '')
        
        display_count += 1
        
        print(f"{'─' * 80}")
        print(f"Kết quả #{display_count}")
        print(f"{'─' * 80}")
        
        if distance is not None:
            similarity = (1 - distance) * 100  # Convert distance to similarity percentage
            print(f"📊 Độ tương đồng: {similarity:.2f}% (distance: {distance:.4f})")
        
        print(f"🆔 Product ID: {product_id if product_id else 'N/A'}")
        print(f"📦 Tên sản phẩm: {metadata.get('product_name', 'N/A')}")
        print(f"🏷️  Danh mục: {metadata.get('category_name', 'N/A')}")
        print(f"💰 Giá: {metadata.get('price', 'N/A'):,} VND" if isinstance(metadata.get('price'), (int, float)) else f"💰 Giá: {metadata.get('price', 'N/A')} VND")
        
        discount = metadata.get('discount', 0)
        if discount and (isinstance(discount, (int, float)) and discount > 0 or isinstance(discount, str) and discount.isdigit() and int(discount) > 0):
            print(f"🎯 Giảm giá: {discount}%")
        
        features = metadata.get('features', '')
        if features:
            print(f"⚙️  Tính năng: {features}")
        
        doc_type = metadata.get('type', 'unknown')
        print(f"📄 Loại: {doc_type}")
        
        if document and doc_type == 'product':
            preview = document[:200] + "..." if len(document) > 200 else document
            print(f"\n📝 Mô tả (preview):\n   {preview}")
        
        print()

def main():
    print("=" * 80)
    print("🖼️  TEST TÌM KIẾM SẢN PHẨM BẰNG HÌNH ẢNH - CHROMADB")
    print("=" * 80)
    print()
    
    # Kiểm tra tham số dòng lệnh
    if len(sys.argv) < 2:
        print("📖 Cách sử dụng:")
        print(f"   python {sys.argv[0]} <đường_dẫn_ảnh> [top_k]")
        print()
        print("📝 Ví dụ:")
        print(f"   python {sys.argv[0]} image.jpg")
        print(f"   python {sys.argv[0]} image.jpg 10")
        print()
        sys.exit(1)
    
    image_path = sys.argv[1]
    top_k = int(sys.argv[2]) if len(sys.argv) > 2 else 5
    
    # Kiểm tra file tồn tại
    if not Path(image_path).exists():
        print(f"❌ File không tồn tại: {image_path}")
        sys.exit(1)
    
    print(f"📁 File ảnh: {image_path}")
    print(f"🔢 Top K: {top_k}")
    print()
    
    # Bước 1: Encode ảnh thành base64
    print("📸 Bước 1: Đang đọc và mã hóa ảnh...")
    image_base64 = encode_image_to_base64(image_path)
    if not image_base64:
        sys.exit(1)
    print(f"✅ Đã mã hóa ảnh thành base64 ({len(image_base64)} ký tự)\n")
    
    # Bước 2: Embed ảnh thành vector
    print("🧮 Bước 2: Đang embed ảnh thành vector...")
    embedding = embed_image(image_base64)
    if not embedding:
        sys.exit(1)
    print()
    
    # Bước 3: Tìm kiếm trong ChromaDB
    print("🔎 Bước 3: Đang tìm kiếm trong ChromaDB...")
    results = search_in_chromadb(embedding, top_k)
    print()
    
    # Bước 4: Hiển thị kết quả
    print("📊 Bước 4: Kết quả tìm kiếm:")
    display_results(results, top_k)
    
    print("=" * 80)
    print("✅ Hoàn tất!")
    print("=" * 80)

if __name__ == "__main__":
    main()

