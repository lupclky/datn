#!/usr/bin/env python3
"""
Test tìm kiếm sản phẩm cụ thể GATEMAN F300-FH
"""
import requests
import base64
import sys
from pathlib import Path

EMBEDDING_SERVICE_URL = "http://localhost:9001"
CHROMA_BASE_URL = "http://localhost:8000"
COLLECTION_NAME = "sneakers-collection"

def get_collection_id():
    """Lấy collection ID"""
    try:
        response = requests.get(f"{CHROMA_BASE_URL}/api/v1/collections", timeout=10)
        if response.status_code == 200:
            collections = response.json()
            for col in collections:
                if col.get('name') == COLLECTION_NAME:
                    return col.get('id')
        return None
    except Exception as e:
        print(f"❌ Lỗi: {e}")
        return None

def get_all_f300fh_documents():
    """Lấy tất cả documents của GATEMAN F300-FH"""
    try:
        collection_id = get_collection_id()
        if not collection_id:
            return []
        
        # Lấy tất cả documents
        all_docs = []
        offset = 0
        limit = 100
        
        while True:
            response = requests.post(
                f"{CHROMA_BASE_URL}/api/v1/collections/{collection_id}/get",
                json={"limit": limit, "offset": offset},
                timeout=30
            )
            
            if response.status_code != 200:
                break
            
            data = response.json()
            if 'ids' not in data or len(data['ids']) == 0:
                break
            
            ids = data['ids']
            metadatas = data.get('metadatas', [])
            documents = data.get('documents', [])
            
            for i in range(len(ids)):
                metadata = metadatas[i] if i < len(metadatas) and metadatas[i] else {}
                product_id = metadata.get('product_id')
                product_name = metadata.get('product_name', '')
                
                # Tìm F300-FH
                if product_id == 14 or 'F300' in product_name.upper():
                    all_docs.append({
                        'id': ids[i],
                        'metadata': metadata,
                        'document': documents[i] if i < len(documents) else ""
                    })
            
            if len(ids) < limit:
                break
            
            offset += limit
        
        return all_docs
    except Exception as e:
        print(f"❌ Lỗi: {e}")
        return []

def embed_image(image_path):
    """Embed ảnh"""
    try:
        with open(image_path, 'rb') as f:
            image_data = f.read()
            image_base64 = base64.b64encode(image_data).decode('utf-8')
        
        response = requests.post(
            f"{EMBEDDING_SERVICE_URL}/embed/image",
            json={"image_base64": image_base64},
            timeout=60
        )
        
        if response.status_code == 200:
            return response.json().get('embedding', [])
        return None
    except Exception as e:
        print(f"❌ Lỗi embed: {e}")
        return None

def search_with_all_results(embedding):
    """Tìm kiếm với tất cả kết quả (không giới hạn minimum score)"""
    try:
        collection_id = get_collection_id()
        if not collection_id:
            return []
        
        # Query với n_results lớn và không có minimum score filter
        response = requests.post(
            f"{CHROMA_BASE_URL}/api/v1/collections/{collection_id}/query",
            json={
                "query_embeddings": [embedding],
                "n_results": 50  # Lấy nhiều kết quả
            },
            timeout=30
        )
        
        if response.status_code != 200:
            print(f"❌ Lỗi query: {response.status_code}")
            return []
        
        data = response.json()
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
        
        return results
    except Exception as e:
        print(f"❌ Lỗi search: {e}")
        return []

def main():
    if len(sys.argv) < 2:
        print("Usage: python test_specific_product.py <image_path>")
        sys.exit(1)
    
    image_path = sys.argv[1]
    
    print("=" * 80)
    print("🔍 KIỂM TRA TẠI SAO GATEMAN F300-FH KHÔNG XUẤT HIỆN")
    print("=" * 80)
    print()
    
    # Bước 1: Kiểm tra documents F300-FH trong ChromaDB
    print("📦 Bước 1: Kiểm tra documents GATEMAN F300-FH trong ChromaDB...")
    f300_docs = get_all_f300fh_documents()
    print(f"✅ Tìm thấy {len(f300_docs)} documents cho F300-FH")
    
    if f300_docs:
        print("\n📄 Chi tiết documents:")
        for i, doc in enumerate(f300_docs[:5], 1):  # Chỉ hiển thị 5 đầu
            metadata = doc.get('metadata', {})
            print(f"  {i}. ID: {doc.get('id')}")
            print(f"     Product ID: {metadata.get('product_id')}")
            print(f"     Tên: {metadata.get('product_name')}")
            print(f"     Type: {metadata.get('type')}")
            print()
    
    # Bước 2: Embed ảnh upload
    print(f"🖼️  Bước 2: Đang embed ảnh: {image_path}...")
    embedding = embed_image(image_path)
    if not embedding:
        print("❌ Không thể embed ảnh")
        sys.exit(1)
    print(f"✅ Đã embed thành công ({len(embedding)} chiều)\n")
    
    # Bước 3: Tìm kiếm với tất cả kết quả
    print("🔍 Bước 3: Tìm kiếm với tất cả kết quả (không filter minimum score)...")
    all_results = search_with_all_results(embedding)
    print(f"✅ ChromaDB trả về {len(all_results)} kết quả\n")
    
    # Bước 4: Tìm F300-FH trong kết quả
    print("🎯 Bước 4: Tìm GATEMAN F300-FH trong kết quả...")
    f300_results = []
    for result in all_results:
        metadata = result.get('metadata', {})
        product_id = metadata.get('product_id')
        product_name = metadata.get('product_name', '')
        
        if product_id == 14 or 'F300' in product_name.upper():
            f300_results.append(result)
    
    if f300_results:
        print(f"✅ Tìm thấy {len(f300_results)} kết quả cho F300-FH:\n")
        for i, result in enumerate(f300_results, 1):
            metadata = result.get('metadata', {})
            distance = result.get('distance')
            similarity = (1 - distance) * 100 if distance is not None else 0
            
            print(f"  Kết quả #{i}:")
            print(f"    Product ID: {metadata.get('product_id')}")
            print(f"    Tên: {metadata.get('product_name')}")
            print(f"    Type: {metadata.get('type')}")
            print(f"    Độ tương đồng: {similarity:.2f}% (distance: {distance:.4f})")
            print()
            
            if similarity < 40:
                print(f"    ⚠️  Độ tương đồng quá thấp ({similarity:.2f}%) - bị filter bởi minimum score 0.4")
                print(f"    💡 Giải pháp: Giảm minimum score xuống {distance:.2f} hoặc thấp hơn")
                print()
    else:
        print("❌ KHÔNG tìm thấy GATEMAN F300-FH trong kết quả!")
        print("\n🔍 Top 10 kết quả gần nhất:")
        for i, result in enumerate(all_results[:10], 1):
            metadata = result.get('metadata', {})
            distance = result.get('distance')
            similarity = (1 - distance) * 100 if distance is not None else 0
            
            print(f"  {i}. {metadata.get('product_name', 'N/A')} (ID: {metadata.get('product_id', 'N/A')})")
            print(f"     Tương đồng: {similarity:.2f}% (distance: {distance:.4f})")
    
    print("\n" + "=" * 80)

if __name__ == "__main__":
    main()

