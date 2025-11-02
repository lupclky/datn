import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { NewsService } from '../../../core/services/news.service';
import { NewsDto, NewsPage } from '../../../core/dtos/news.dto';
import { BaseComponent } from '../../../core/commonComponent/base.component';
import { Subject, debounceTime, takeUntil } from 'rxjs';
import { CardModule } from 'primeng/card';
import { PaginatorModule } from 'primeng/paginator';
import { InputTextModule } from 'primeng/inputtext';
import { TagModule } from 'primeng/tag';
import { DialogModule } from 'primeng/dialog';

@Component({
  selector: 'app-news',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    CardModule,
    PaginatorModule,
    InputTextModule,
    TagModule,
    DialogModule
  ],
  templateUrl: './news.component.html',
  styleUrl: './news.component.scss'
})
export class NewsComponent extends BaseComponent implements OnInit, OnDestroy {
  public newsList: NewsDto[] = [];
  public isLoading: boolean = false;
  public searchQuery: string = '';
  public currentPage: number = 0;
  public pageSize: number = 6;
  public totalRecords: number = 0;
  private searchSubject = new Subject<string>();

  constructor(private newsService: NewsService) {
    super();
    this.searchSubject.pipe(
      debounceTime(300),
      takeUntil(this.destroyed$)
    ).subscribe(() => {
      this.loadNews();
    });
  }

  ngOnInit(): void {
    this.loadNews();
  }

  loadNews(): void {
    this.isLoading = true;
    // Load ALL news from admin
    this.newsService.getAllNews(this.searchQuery || '', '', this.currentPage, this.pageSize)
      .pipe(takeUntil(this.destroyed$))
      .subscribe({
        next: (response: any) => {
          console.log('News response:', response); // Debug
          // Handle both NewsPage and simple array responses
          if (response.news) {
            this.newsList = response.news;
            this.totalRecords = response.totalElements || response.news.length;
          } else if (Array.isArray(response)) {
            this.newsList = response;
            this.totalRecords = response.length;
          } else {
            this.newsList = [];
            this.totalRecords = 0;
          }
          console.log('Loaded news:', this.newsList.length); // Debug
          this.isLoading = false;
        },
        error: (err) => {
          console.error('Error loading news:', err); // Debug
          this.isLoading = false;
          this.newsList = [];
        }
      });
  }

  onSearch(): void {
    this.currentPage = 0;
    this.searchSubject.next(this.searchQuery);
  }

  onPageChange(event: any): void {
    this.currentPage = event.first / event.rows;
    this.pageSize = event.rows;
    this.loadNews();
  }

  formatDate(date?: Date): string {
    if (!date) return '';
    const d = new Date(date);
    return `${d.getDate().toString().padStart(2, '0')}/${(d.getMonth() + 1).toString().padStart(2, '0')}`;
  }

  formatFullDate(date?: Date): string {
    if (!date) return '';
    return new Date(date).toLocaleDateString('vi-VN', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  }

  getExcerpt(content: string): string {
    if (!content) return '';
    const plainText = content.replace(/<[^>]*>/g, '').trim();
    return plainText.length > 120 ? plainText.substring(0, 120) + '...' : plainText;
  }

  // Modal properties & methods
  showDetailModal: boolean = false;
  selectedNews: NewsDto | null = null;

  openNewsDetail(news: NewsDto): void {
    this.selectedNews = news;
    this.showDetailModal = true;
  }

  closeModal(): void {
    this.showDetailModal = false;
    this.selectedNews = null;
  }
}
