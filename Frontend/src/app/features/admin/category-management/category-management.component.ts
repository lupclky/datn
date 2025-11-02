import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CategoryService } from '../../../core/services/category.service';
import { ToastService } from '../../../core/services/toast.service';

interface Category {
  id?: number;
  name: string;
}

@Component({
  selector: 'app-category-management',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './category-management.component.html',
  styleUrls: ['./category-management.component.scss']
})
export class CategoryManagementComponent implements OnInit {
  categories: Category[] = [];
  filteredCategories: Category[] = [];
  
  showModal = false;
  isEditing = false;
  currentCategory: Category = this.getEmptyCategory();
  
  searchKeyword = '';

  constructor(
    private categoryService: CategoryService,
    private toastService: ToastService
  ) {}

  ngOnInit(): void {
    this.loadCategories();
  }

  getEmptyCategory(): Category {
    return {
      name: ''
    };
  }

  loadCategories(): void {
    this.categoryService.getAllCategories().subscribe({
      next: (response: any) => {
        this.categories = response;
        this.filteredCategories = response;
      },
      error: (error) => {
        console.error('Error loading categories:', error);
        this.toastService.showError('Không thể tải danh mục');
      }
    });
  }

  searchCategories(): void {
    if (!this.searchKeyword.trim()) {
      this.filteredCategories = this.categories;
    } else {
      const keyword = this.searchKeyword.toLowerCase();
      this.filteredCategories = this.categories.filter(cat => 
        cat.name.toLowerCase().includes(keyword)
      );
    }
  }

  openAddModal(): void {
    this.isEditing = false;
    this.currentCategory = this.getEmptyCategory();
    this.showModal = true;
  }

  openEditModal(category: Category): void {
    this.isEditing = true;
    this.currentCategory = { ...category };
    this.showModal = true;
  }

  closeModal(): void {
    this.showModal = false;
    this.currentCategory = this.getEmptyCategory();
  }

  saveCategory(): void {
    if (!this.validateCategory()) {
      return;
    }

    if (this.isEditing && this.currentCategory.id) {
      this.updateCategory();
    } else {
      this.createCategory();
    }
  }

  validateCategory(): boolean {
    if (!this.currentCategory.name.trim()) {
      this.toastService.showError('Vui lòng nhập tên danh mục');
      return false;
    }
    return true;
  }

  createCategory(): void {
    this.categoryService.createCategory(this.currentCategory).subscribe({
      next: (response) => {
        this.toastService.showSuccess('Thêm danh mục thành công');
        this.closeModal();
        this.loadCategories();
      },
      error: (error) => {
        console.error('Error creating category:', error);
        this.toastService.showError('Không thể thêm danh mục');
      }
    });
  }

  updateCategory(): void {
    if (!this.currentCategory.id) return;

    this.categoryService.updateCategory(this.currentCategory.id, this.currentCategory).subscribe({
      next: (response) => {
        this.toastService.showSuccess('Cập nhật danh mục thành công');
        this.closeModal();
        this.loadCategories();
      },
      error: (error) => {
        console.error('Error updating category:', error);
        this.toastService.showError('Không thể cập nhật danh mục');
      }
    });
  }

  deleteCategory(category: Category): void {
    if (!category.id) return;

    if (!confirm(`Bạn có chắc chắn muốn xóa danh mục "${category.name}"?`)) {
      return;
    }

    this.categoryService.deleteCategory(category.id).subscribe({
      next: (response) => {
        this.toastService.showSuccess('Xóa danh mục thành công');
        this.loadCategories();
      },
      error: (error) => {
        console.error('Error deleting category:', error);
        this.toastService.showError('Không thể xóa danh mục');
      }
    });
  }
}

