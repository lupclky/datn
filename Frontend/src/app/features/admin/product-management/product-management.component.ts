import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ProductService } from '../../../core/services/product.service';
import { CategoryService } from '../../../core/services/category.service';
import { ToastService } from '../../../core/services/toast.service';

interface Product {
  id?: number;
  name: string;
  price: number;
  thumbnail: string;
  description: string;
  discount: number;
  quantity: number;
  category_id: number;
}

interface Category {
  id: number;
  name: string;
}

@Component({
  selector: 'app-product-management',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './product-management.component.html',
  styleUrls: ['./product-management.component.scss']
})
export class ProductManagementComponent implements OnInit {
  products: Product[] = [];
  categories: Category[] = [];
  filteredProducts: Product[] = [];
  
  showModal = false;
  isEditing = false;
  currentProduct: Product = this.getEmptyProduct();
  
  searchKeyword = '';
  selectedCategory = 0;
  currentPage = 1;
  itemsPerPage = 10;
  totalProducts = 0;

  constructor(
    private productService: ProductService,
    private categoryService: CategoryService,
    private toastService: ToastService
  ) {}

  ngOnInit(): void {
    this.loadCategories();
    this.loadProducts();
  }

  getEmptyProduct(): Product {
    return {
      name: '',
      price: 0,
      thumbnail: '',
      description: '',
      discount: 0,
      quantity: 0,
      category_id: 0
    };
  }

  loadCategories(): void {
    this.categoryService.getAllCategories().subscribe({
      next: (response: any) => {
        this.categories = response;
      },
      error: (error) => {
        console.error('Error loading categories:', error);
        this.toastService.showError('Không thể tải danh mục');
      }
    });
  }

  loadProducts(): void {
    this.productService.getAllProduct().subscribe({
      next: (response: any) => {
        this.products = response.products || [];
        // Filter by search keyword and category if needed
        let filtered = this.products;
        if (this.searchKeyword) {
          filtered = filtered.filter((p: any) => 
            p.name.toLowerCase().includes(this.searchKeyword.toLowerCase())
          );
        }
        if (this.selectedCategory > 0) {
          filtered = filtered.filter((p: any) => p.category_id === this.selectedCategory);
        }
        this.filteredProducts = filtered;
        this.totalProducts = filtered.length;
      },
      error: (error: any) => {
        console.error('Error loading products:', error);
        this.toastService.showError('Không thể tải sản phẩm');
      }
    });
  }

  searchProducts(): void {
    this.currentPage = 1;
    this.loadProducts();
  }

  filterByCategory(): void {
    this.currentPage = 1;
    this.loadProducts();
  }

  openAddModal(): void {
    this.isEditing = false;
    this.currentProduct = this.getEmptyProduct();
    this.showModal = true;
  }

  openEditModal(product: Product): void {
    this.isEditing = true;
    this.currentProduct = { ...product };
    this.showModal = true;
  }

  closeModal(): void {
    this.showModal = false;
    this.currentProduct = this.getEmptyProduct();
  }

  saveProduct(): void {
    if (!this.validateProduct()) {
      return;
    }

    if (this.isEditing && this.currentProduct.id) {
      this.updateProduct();
    } else {
      this.createProduct();
    }
  }

  validateProduct(): boolean {
    if (!this.currentProduct.name.trim()) {
      this.toastService.showError('Vui lòng nhập tên sản phẩm');
      return false;
    }
    if (this.currentProduct.price <= 0) {
      this.toastService.showError('Giá sản phẩm phải lớn hơn 0');
      return false;
    }
    if (this.currentProduct.category_id === 0) {
      this.toastService.showError('Vui lòng chọn danh mục');
      return false;
    }
    return true;
  }

  createProduct(): void {
    this.productService.uploadProduct(this.currentProduct as any).subscribe({
      next: (response) => {
        this.toastService.showSuccess('Thêm sản phẩm thành công');
        this.closeModal();
        this.loadProducts();
      },
      error: (error) => {
        console.error('Error creating product:', error);
        this.toastService.showError('Không thể thêm sản phẩm');
      }
    });
  }

  updateProduct(): void {
    if (!this.currentProduct.id) return;

    this.productService.updateProduct(this.currentProduct as any, this.currentProduct.id).subscribe({
      next: (response) => {
        this.toastService.showSuccess('Cập nhật sản phẩm thành công');
        this.closeModal();
        this.loadProducts();
      },
      error: (error) => {
        console.error('Error updating product:', error);
        this.toastService.showError('Không thể cập nhật sản phẩm');
      }
    });
  }

  deleteProduct(product: Product): void {
    if (!product.id) return;

    if (!confirm(`Bạn có chắc chắn muốn xóa sản phẩm "${product.name}"?`)) {
      return;
    }

    this.productService.deleteProduct(product.id.toString()).subscribe({
      next: (response) => {
        this.toastService.showSuccess('Xóa sản phẩm thành công');
        this.loadProducts();
      },
      error: (error) => {
        console.error('Error deleting product:', error);
        this.toastService.showError('Không thể xóa sản phẩm');
      }
    });
  }

  getCategoryName(categoryId: number): string {
    const category = this.categories.find(c => c.id === categoryId);
    return category ? category.name : 'N/A';
  }

  formatPrice(price: number): string {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND'
    }).format(price);
  }

  goToPage(page: number): void {
    this.currentPage = page;
    this.loadProducts();
  }

  get totalPages(): number {
    return Math.ceil(this.totalProducts / this.itemsPerPage);
  }

  get pages(): number[] {
    const pages = [];
    for (let i = 1; i <= this.totalPages; i++) {
      pages.push(i);
    }
    return pages;
  }
}

