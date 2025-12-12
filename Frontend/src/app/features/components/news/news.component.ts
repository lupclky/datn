import { Component, OnInit, ChangeDetectionStrategy, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { NewsService } from '../../../core/services/news.service';
import { NewsDto } from '../../../core/dtos/news.dto';
import { environment } from '../../../../environments/environment.development';
import { LinkPreviewCardComponent, LinkPreview } from '../../../shared/components/link-preview-card/link-preview-card.component';

@Component({
  selector: 'app-news',
  standalone: true,
  imports: [CommonModule, RouterLink, FormsModule, LinkPreviewCardComponent],
  templateUrl: './news.component.html',
  styleUrl: './news.component.scss'
  // Tạm thời tắt OnPush để đảm bảo trang load được
  // changeDetection: ChangeDetectionStrategy.OnPush
})
export class NewsComponent implements OnInit {
  newsList: NewsDto[] = [];
  latestNews: NewsDto[] = [];
  searchKeyword: string = '';
  currentPage: number = 0;
  totalPages: number = 0;
  pageSize: number = 9; // Tăng pageSize để hiển thị nhiều tin hơn
  isLoading: boolean = false;
  currentView: 'grid' | 'table' = 'grid'; // Thêm biến để quản lý view
  private searchTimeout: any;

  constructor(
    private newsService: NewsService,
    private router: Router,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.loadPublishedNews();
    this.loadLatestNews();
  }

  // Thêm hàm để thay đổi view
  setView(view: 'grid' | 'table'): void {
    this.currentView = view;
  }

  loadPublishedNews(): void {
    this.isLoading = true;
    this.cdr.markForCheck();
    this.newsService.getPublishedNews(this.currentPage, this.pageSize).subscribe({
      next: (response) => {
        this.newsList = response.news_list;
        this.totalPages = response.total_pages;
        this.isLoading = false;
        this.cdr.markForCheck();
      },
      error: (error) => {
        console.error('Error loading news:', error);
        this.isLoading = false;
        this.cdr.markForCheck();
      }
    });
  }

  loadLatestNews(): void {
    this.newsService.getPublishedNews(0, 5).subscribe({
      next: (response) => {
        this.latestNews = response.news_list;
        this.cdr.markForCheck();
      },
      error: (error) => {
        console.error('Error loading latest news:', error);
        this.cdr.markForCheck();
      }
    });
  }

  searchNews(): void {
    // Clear previous timeout
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout);
    }

    // Debounce search
    this.searchTimeout = setTimeout(() => {
      if (this.searchKeyword.trim()) {
        this.isLoading = true;
        this.cdr.markForCheck();
        this.newsService.searchPublishedNews(this.searchKeyword, this.currentPage, this.pageSize).subscribe({
          next: (response) => {
            this.newsList = response.news_list;
            this.totalPages = response.total_pages;
            this.isLoading = false;
            this.cdr.markForCheck();
          },
          error: (error) => {
            console.error('Error searching news:', error);
            this.isLoading = false;
            this.cdr.markForCheck();
          }
        });
      } else {
        this.loadPublishedNews();
      }
    }, 300); // Debounce 300ms
  }

  viewNewsDetail(newsId: number): void {
    this.router.navigate(['/news', newsId]);
  }

  formatDate(dateString: string): { day: string, month: string, year: string, fullDate: string } {
    const date = new Date(dateString);
    return {
      day: date.getDate().toString().padStart(2, '0'),
      month: (date.getMonth() + 1).toString(),
      year: date.getFullYear().toString(),
      fullDate: `${date.getDate().toString().padStart(2, '0')}/${(date.getMonth() + 1).toString().padStart(2, '0')}/${date.getFullYear()}`
    };
  }

  getTruncatedSummary(summary: string, maxLength: number = 100): string {
    if (!summary) return '';
    return summary.length > maxLength ? summary.substring(0, maxLength) + '...' : summary;
  }

  getTruncatedTitle(title: string, maxLength: number = 50): string {
    if (!title) return '';
    return title.length > maxLength ? title.substring(0, maxLength) + '...' : title;
  }

  getImageUrl(featuredImage: string | undefined | null): string {
    const baseUrl = `${environment.apiUrl}/news/images`;
    const configuredFallback = environment.newsDefaultImage;

    const fallbackFromConfig = configuredFallback
      ? (configuredFallback.startsWith('http')
          ? configuredFallback
          : `${baseUrl}/${configuredFallback}`)
      : `${baseUrl}/default-lock-news.jpg`;

    if (!featuredImage) {
      return fallbackFromConfig;
    }

    if (featuredImage.startsWith('http')) {
      return featuredImage;
    }

    return `${baseUrl}/${featuredImage}`;
  }

  getNewsLinkPreview(news: NewsDto): LinkPreview {
    return {
      url: `${window.location.origin}/news/${news.id}`,
      title: news.title,
      description: news.summary || news.content?.substring(0, 100),
      image: this.getImageUrl(news.featured_image),
      siteName: 'Locker Korea News'
    };
  }

  nextPage(): void {
    if (this.currentPage < this.totalPages - 1) {
      this.currentPage++;
      this.loadPublishedNews();
    }
  }

  previousPage(): void {
    if (this.currentPage > 0) {
      this.currentPage--;
      this.loadPublishedNews();
    }
  }
}
