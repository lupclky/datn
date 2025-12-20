#!/usr/bin/env python3
"""
Script để liệt kê tất cả sản phẩm trong ChromaDB
"""
import requests
import json
from collections import defaultdict

CHROMA_BASE_URL = "http://localhost:8000"
COLLECTION_NAME = "sneakers-collection"

def get_all_products():
    """Lấy tất cả sản phẩm từ ChromaDB"""
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
        
        # Lấy tất cả documents
        all_products = {}
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
            
            # Xử lý từng document
            for i in range(len(ids)):
                metadata = metadatas[i] if i < len(metadatas) and metadatas[i] else {}
                doc_type = metadata.get('type', 'unknown')
                
                # Chỉ lấy product (không lấy product_image)
                if doc_type == 'product':
                    product_id = metadata.get('product_id')
                    if product_id:
                        if product_id not in all_products:
                            all_products[product_id] = {
                                'id': product_id,
                                'name': metadata.get('product_name', 'N/A'),
                                'category': metadata.get('category_name', 'N/A'),
                                'price': metadata.get('price', 0),
                                'discount': metadata.get('discount', 0),
                                'features': metadata.get('features', ''),
                                'thumbnail': metadata.get('thumbnail', '')
                            }
            
            # Kiểm tra còn dữ liệu không
            if len(ids) < limit:
                break
            
            offset += limit
        
        return list(all_products.values())
    
    except Exception as e:
        print(f"❌ Lỗi khi lấy danh sách sản phẩm: {e}")
        return []

def main():
    print("=" * 80)
    print("📦 DANH SÁCH SẢN PHẨM TRONG CHROMADB")
    print("=" * 80)
    
    products = get_all_products()
    
    if not products:
        print("⚠️  Không tìm thấy sản phẩm nào")
        return
    
    print(f"\n✅ Tìm thấy {len(products)} sản phẩm:\n")
    
    # Nhóm theo category
    by_category = defaultdict(list)
    for product in products:
        by_category[product['category']].append(product)
    
    # Sắp xếp theo category
    for category in sorted(by_category.keys()):
        print(f"\n{'=' * 80}")
        print(f"📁 {category} ({len(by_category[category])} sản phẩm)")
        print(f"{'=' * 80}")
        
        for product in sorted(by_category[category], key=lambda x: x['name']):
            print(f"\n  • ID: {product['id']}")
            print(f"    Tên: {product['name']}")
            price = product['price']
            if isinstance(price, (int, float)):
                print(f"    Giá: {price:,} VND")
            else:
                print(f"    Giá: {price} VND")
            
            discount = product['discount']
            if isinstance(discount, (int, float)) and discount > 0:
                print(f"    Giảm giá: {discount}%")
            elif isinstance(discount, str) and discount.isdigit() and int(discount) > 0:
                print(f"    Giảm giá: {discount}%")
            if product['features']:
                print(f"    Tính năng: {product['features']}")
            print(f"    Thumbnail: {product['thumbnail']}")
    
    print(f"\n{'=' * 80}")
    print(f"📊 Tổng kết: {len(products)} sản phẩm trong {len(by_category)} danh mục")
    print(f"{'=' * 80}")
    
    # Thống kê theo category
    print("\n📈 Thống kê theo danh mục:")
    for category in sorted(by_category.keys()):
        print(f"  - {category}: {len(by_category[category])} sản phẩm")

if __name__ == "__main__":
    main()

