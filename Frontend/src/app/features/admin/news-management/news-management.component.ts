import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { NewsService } from '../../../core/services/news.service';
import { ToastService } from '../../../core/services/toast.service';

interface News {
  id?: number;
  title: string;
  content: string;
  image_url?: string;
  status: string;
  created_at?: string;
}

@Component({
  selector: 'app-news-management',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './news-management.component.html',
  styleUrls: ['./news-management.component.scss']
})
export class NewsManagementComponent implements OnInit {
  newsList: News[] = [];
  filteredNews: News[] = [];
  
  showModal = false;
  isEditing = false;
  currentNews: News = this.getEmptyNews();
  
  searchKeyword = '';
  selectedStatus = '';
  currentPage = 1;
  itemsPerPage = 10;
  totalNews = 0;

  constructor(
    private newsService: NewsService,
    private toastService: ToastService
  ) {}

  ngOnInit(): void {
    this.loadNews();
  }

  getEmptyNews(): News {
    return {
      title: '',
      content: '',
      image_url: '',
      status: 'ACTIVE'
    };
  }

  loadNews(): void {
    this.newsService.getAllNews(
      this.searchKeyword,
      this.selectedStatus,
      this.currentPage - 1,
      this.itemsPerPage
    ).subscribe({
      next: (response: any) => {
        this.newsList = response.news || [];
        this.filteredNews = this.newsList;
        this.totalNews = response.totalNews || 0;
      },
      error: (error) => {
        console.error('Error loading news:', error);
        this.toastService.showError('Không thể tải tin tức');
      }
    });
  }

  searchNews(): void {
    this.currentPage = 1;
    this.loadNews();
  }

  filterByStatus(): void {
    this.currentPage = 1;
    this.loadNews();
  }

  openAddModal(): void {
    this.isEditing = false;
    this.currentNews = this.getEmptyNews();
    this.showModal = true;
  }

  openEditModal(news: News): void {
    this.isEditing = true;
    this.currentNews = { ...news };
    this.showModal = true;
  }

  closeModal(): void {
    this.showModal = false;
    this.currentNews = this.getEmptyNews();
  }

  saveNews(): void {
    if (!this.validateNews()) {
      return;
    }

    if (this.isEditing && this.currentNews.id) {
      this.updateNews();
    } else {
      this.createNews();
    }
  }

  validateNews(): boolean {
    if (!this.currentNews.title.trim()) {
      this.toastService.showError('Vui lòng nhập tiêu đề');
      return false;
    }
    if (!this.currentNews.content.trim()) {
      this.toastService.showError('Vui lòng nhập nội dung');
      return false;
    }
    return true;
  }

  createNews(): void {
    this.newsService.createNews(this.currentNews as any).subscribe({
      next: (response) => {
        this.toastService.showSuccess('Thêm tin tức thành công');
        this.closeModal();
        this.loadNews();
      },
      error: (error) => {
        console.error('Error creating news:', error);
        this.toastService.showError('Không thể thêm tin tức');
      }
    });
  }

  updateNews(): void {
    if (!this.currentNews.id) return;

    this.newsService.updateNews(this.currentNews.id, this.currentNews as any).subscribe({
      next: (response) => {
        this.toastService.showSuccess('Cập nhật tin tức thành công');
        this.closeModal();
        this.loadNews();
      },
      error: (error) => {
        console.error('Error updating news:', error);
        this.toastService.showError('Không thể cập nhật tin tức');
      }
    });
  }

  deleteNews(news: News): void {
    if (!news.id) return;

    if (!confirm(`Bạn có chắc chắn muốn xóa tin tức "${news.title}"?`)) {
      return;
    }

    this.newsService.deleteNews(news.id).subscribe({
      next: (response) => {
        this.toastService.showSuccess('Xóa tin tức thành công');
        this.loadNews();
      },
      error: (error) => {
        console.error('Error deleting news:', error);
        this.toastService.showError('Không thể xóa tin tức');
      }
    });
  }

  goToPage(page: number): void {
    this.currentPage = page;
    this.loadNews();
  }

  get totalPages(): number {
    return Math.ceil(this.totalNews / this.itemsPerPage);
  }

  get pages(): number[] {
    const pages = [];
    for (let i = 1; i <= this.totalPages; i++) {
      pages.push(i);
    }
    return pages;
  }

  formatDate(dateString?: string): string {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleDateString('vi-VN');
  }
}

