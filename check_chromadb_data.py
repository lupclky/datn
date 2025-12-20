#!/usr/bin/env python3
"""
Script để kiểm tra dữ liệu sản phẩm trong ChromaDB
"""
import requests
import json
import sys

CHROMA_BASE_URL = "http://localhost:8000"
COLLECTION_NAME = "sneakers-collection"

def check_chromadb_health():
    """Kiểm tra ChromaDB có đang chạy không"""
    try:
        response = requests.get(f"{CHROMA_BASE_URL}/api/v1/heartbeat", timeout=5)
        if response.status_code == 200:
            print("✅ ChromaDB đang chạy")
            return True
        else:
            print(f"❌ ChromaDB trả về status code: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Không thể kết nối đến ChromaDB tại http://localhost:8000")
        print("   Hãy đảm bảo ChromaDB đang chạy:")
        print("   - docker-compose up -d chroma-container")
        print("   - hoặc: chroma run --host 0.0.0.0 --port 8000")
        return False
    except Exception as e:
        print(f"❌ Lỗi khi kiểm tra ChromaDB: {e}")
        return False

def list_collections():
    """Liệt kê tất cả collections trong ChromaDB"""
    try:
        response = requests.get(f"{CHROMA_BASE_URL}/api/v1/collections", timeout=10)
        if response.status_code == 200:
            collections = response.json()
            print(f"\n📦 Danh sách Collections ({len(collections)}):")
            for col in collections:
                print(f"   - {col.get('name', 'N/A')} (id: {col.get('id', 'N/A')})")
            return collections
        else:
            print(f"❌ Không thể lấy danh sách collections: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Lỗi khi lấy danh sách collections: {e}")
        return []

def get_collection_info(collection_name):
    """Lấy thông tin về collection cụ thể"""
    try:
        # Lấy danh sách collections để tìm ID
        collections = list_collections()
        collection_id = None
        for col in collections:
            if col.get('name') == collection_name:
                collection_id = col.get('id')
                break
        
        if not collection_id:
            print(f"❌ Không tìm thấy collection: {collection_name}")
            return None
        
        # Trả về thông tin cơ bản từ list collections
        for col in collections:
            if col.get('name') == collection_name:
                return col
        
        return None
    except Exception as e:
        print(f"❌ Lỗi khi lấy thông tin collection: {e}")
        return None

def count_documents(collection_name):
    """Đếm số lượng documents trong collection"""
    try:
        collections = list_collections()
        collection_id = None
        for col in collections:
            if col.get('name') == collection_name:
                collection_id = col.get('id')
                break
        
        if not collection_id:
            return 0
        
        # Dùng GET endpoint để lấy tất cả documents
        response = requests.post(
            f"{CHROMA_BASE_URL}/api/v1/collections/{collection_id}/get",
            json={
                "limit": 10000  # Lấy tối đa để đếm
            },
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            if 'ids' in data and len(data['ids']) > 0:
                return len(data['ids'])
            return 0
        else:
            print(f"⚠️  Response status: {response.status_code}")
            return 0
    except Exception as e:
        print(f"⚠️  Lỗi khi đếm documents: {e}")
        return 0

def get_sample_documents(collection_name, limit=10):
    """Lấy mẫu documents từ collection"""
    try:
        collections = list_collections()
        collection_id = None
        for col in collections:
            if col.get('name') == collection_name:
                collection_id = col.get('id')
                break
        
        if not collection_id:
            print(f"❌ Không tìm thấy collection: {collection_name}")
            return []
        
        # Query để lấy sample documents
        response = requests.post(
            f"{CHROMA_BASE_URL}/api/v1/collections/{collection_id}/get",
            json={
                "limit": limit
            },
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            documents = []
            
            if 'ids' in data and len(data['ids']) > 0:
                ids = data['ids']
                metadatas = data.get('metadatas', [])
                documents_data = data.get('documents', [])
                
                # ids có thể là list of lists hoặc list
                if isinstance(ids[0], list):
                    ids = ids[0]
                
                for i in range(min(len(ids), limit)):
                    doc = {
                        'id': ids[i] if i < len(ids) else None,
                        'metadata': metadatas[i] if i < len(metadatas) and metadatas[i] else {},
                        'document': documents_data[i] if i < len(documents_data) and documents_data[i] else ""
                    }
                    documents.append(doc)
            
            return documents
        else:
            print(f"❌ Không thể lấy documents: {response.status_code}")
            print(f"   Response: {response.text}")
            return []
    except Exception as e:
        print(f"❌ Lỗi khi lấy documents: {e}")
        return []

def main():
    print("=" * 60)
    print("🔍 KIỂM TRA DỮ LIỆU CHROMADB - LOCKER KOREA")
    print("=" * 60)
    
    # Kiểm tra ChromaDB health
    if not check_chromadb_health():
        sys.exit(1)
    
    # Liệt kê collections
    collections = list_collections()
    
    if not collections:
        print("\n⚠️  Không có collection nào trong ChromaDB")
        print("   Có thể cần chạy index dữ liệu từ Backend:")
        print("   POST /api/v1/ai/initialize/index-all")
        sys.exit(0)
    
    # Kiểm tra collection sneakers-collection
    print(f"\n📊 Kiểm tra collection: {COLLECTION_NAME}")
    collection_info = get_collection_info(COLLECTION_NAME)
    
    if collection_info:
        print(f"✅ Tìm thấy collection: {collection_info.get('name')}")
        print(f"   ID: {collection_info.get('id')}")
    else:
        print(f"⚠️  Không thể lấy thông tin chi tiết collection, nhưng collection có trong danh sách")
    
    # Đếm số lượng documents
    print("\n🔢 Đang đếm số lượng documents...")
    count = count_documents(COLLECTION_NAME)
    print(f"   Tổng số documents: {count}")
    
    if count == 0:
        print("\n⚠️  Collection trống, chưa có dữ liệu được index")
        print("   Để index dữ liệu, gọi API:")
        print("   POST http://localhost:8089/api/v1/ai/initialize/index-all")
        sys.exit(0)
    
    # Lấy mẫu documents
    print(f"\n📄 Lấy mẫu {min(10, count)} documents đầu tiên...")
    sample_docs = get_sample_documents(COLLECTION_NAME, limit=10)
    
    if sample_docs:
        print(f"\n✅ Tìm thấy {len(sample_docs)} documents mẫu:\n")
        for i, doc in enumerate(sample_docs, 1):
            print(f"{'=' * 60}")
            print(f"Document #{i}")
            print(f"{'=' * 60}")
            print(f"ID: {doc.get('id', 'N/A')}")
            print(f"\nMetadata:")
            metadata = doc.get('metadata', {})
            for key, value in metadata.items():
                print(f"  - {key}: {value}")
            
            document_text = doc.get('document', '')
            if document_text:
                # Hiển thị 200 ký tự đầu
                preview = document_text[:200] + "..." if len(document_text) > 200 else document_text
                print(f"\nContent preview:")
                print(f"  {preview}")
            print()
    else:
        print("⚠️  Không thể lấy mẫu documents")
    
    # Thống kê theo metadata
    print("\n📈 Thống kê theo loại dữ liệu:")
    type_counts = {}
    for doc in sample_docs:
        metadata = doc.get('metadata', {})
        doc_type = metadata.get('type', 'unknown')
        type_counts[doc_type] = type_counts.get(doc_type, 0) + 1
    
    for doc_type, count in type_counts.items():
        print(f"  - {doc_type}: {count} documents")
    
    print("\n" + "=" * 60)
    print("✅ Hoàn tất kiểm tra!")
    print("=" * 60)

if __name__ == "__main__":
    main()

