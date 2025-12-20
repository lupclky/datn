#!/usr/bin/env python3
"""
Kiểm tra chi tiết sản phẩm F300-FH trong ChromaDB
"""
import requests
import json

CHROMA_BASE_URL = "http://localhost:8000"
COLLECTION_NAME = "sneakers-collection"

def search_product_by_name(product_name):
    """Tìm sản phẩm theo tên trong ChromaDB"""
    try:
        # Lấy collection ID
        response = requests.get(f"{CHROMA_BASE_URL}/api/v1/collections", timeout=10)
        if response.status_code != 200:
            print("❌ Không thể lấy danh sách collections")
            return []
        
        collections = response.json()
        collection_id = None
        for col in collections:
            if col.get('name') == COLLECTION_NAME:
                collection_id = col.get('id')
                break
        
        if not collection_id:
            print(f"❌ Không tìm thấy collection: {COLLECTION_NAME}")
            return []
        
        # Tìm kiếm bằng query text
        print(f"🔍 Đang tìm kiếm: '{product_name}'...")
        response = requests.post(
            f"{CHROMA_BASE_URL}/api/v1/collections/{collection_id}/query",
            json={
                "query_texts": [product_name],
                "n_results": 10
            },
            timeout=30
        )
        
        if response.status_code != 200:
            print(f"❌ Lỗi khi query: {response.status_code}")
            print(f"Response: {response.text}")
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
        print(f"❌ Lỗi khi tìm kiếm: {e}")
        return []

def get_all_f300fh_documents():
    """Lấy tất cả documents liên quan đến F300-FH"""
    try:
        # Lấy collection ID
        response = requests.get(f"{CHROMA_BASE_URL}/api/v1/collections", timeout=10)
        collections = response.json()
        collection_id = None
        for col in collections:
            if col.get('name') == COLLECTION_NAME:
                collection_id = col.get('id')
                break
        
        if not collection_id:
            return []
        
        # Lấy tất cả documents và filter
        all_docs = []
        offset = 0
        limit = 100
        
        while True:
            response = requests.post(
                f"{CHROMA_BASE_URL}/api/v1/collections/{collection_id}/get",
                json={
                    "limit": limit,
                    "offset": offset
                },
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
                product_name = metadata.get('product_name', '')
                if 'F300' in product_name.upper() or 'F300-FH' in product_name.upper():
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

def main():
    print("=" * 80)
    print("🔍 KIỂM TRA SẢN PHẨM F300-FH TRONG CHROMADB")
    print("=" * 80)
    
    # Tìm kiếm với các từ khóa khác nhau
    search_terms = [
        "F300-FH",
        "F300FH",
        "F300 FH",
        "GATEMAN F300",
        "GATEMAN F300-FH",
        "khóa vân tay F300",
        "F300"
    ]
    
    print("\n1️⃣ Tìm kiếm bằng các từ khóa khác nhau:\n")
    for term in search_terms:
        results = search_product_by_name(term)
        if results:
            print(f"✅ Tìm thấy {len(results)} kết quả cho '{term}':")
            for i, result in enumerate(results[:3], 1):  # Chỉ hiển thị 3 kết quả đầu
                metadata = result.get('metadata', {})
                print(f"   {i}. {metadata.get('product_name', 'N/A')} (ID: {metadata.get('product_id', 'N/A')})")
                if result.get('distance'):
                    print(f"      Distance: {result['distance']:.4f}")
            print()
        else:
            print(f"❌ Không tìm thấy kết quả cho '{term}'\n")
    
    # Lấy tất cả documents F300-FH
    print("\n2️⃣ Tất cả documents liên quan đến F300-FH trong ChromaDB:\n")
    all_docs = get_all_f300fh_documents()
    
    if all_docs:
        print(f"✅ Tìm thấy {len(all_docs)} documents:\n")
        for i, doc in enumerate(all_docs, 1):
            print(f"{'=' * 80}")
            print(f"Document #{i}")
            print(f"{'=' * 80}")
            metadata = doc.get('metadata', {})
            print(f"ID: {doc.get('id')}")
            print(f"Product ID: {metadata.get('product_id', 'N/A')}")
            print(f"Tên sản phẩm: {metadata.get('product_name', 'N/A')}")
            print(f"Category: {metadata.get('category_name', 'N/A')}")
            print(f"Giá: {metadata.get('price', 'N/A')} VND")
            print(f"Type: {metadata.get('type', 'N/A')}")
            print(f"Features: {metadata.get('features', 'N/A')}")
            
            doc_text = doc.get('document', '')
            if doc_text:
                preview = doc_text[:300] + "..." if len(doc_text) > 300 else doc_text
                print(f"\nContent preview:\n{preview}")
            print()
    else:
        print("❌ Không tìm thấy documents nào liên quan đến F300-FH")
    
    print("=" * 80)

if __name__ == "__main__":
    main()

