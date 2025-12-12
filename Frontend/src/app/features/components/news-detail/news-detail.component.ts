import { Component, OnInit, ChangeDetectionStrategy, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { NewsService } from '../../../core/services/news.service';
import { NewsDto } from '../../../core/dtos/news.dto';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { environment } from '../../../../environments/environment.development';
import { LinkPreviewCardComponent, LinkPreview } from '../../../shared/components/link-preview-card/link-preview-card.component';

@Component({
  selector: 'app-news-detail',
  standalone: true,
  imports: [CommonModule, RouterLink, LinkPreviewCardComponent],
  templateUrl: './news-detail.component.html',
  styleUrl: './news-detail.component.scss'
  // Tạm thời tắt OnPush để đảm bảo trang load được  
  // changeDetection: ChangeDetectionStrategy.OnPush
})
export class NewsDetailComponent implements OnInit {
  news: NewsDto | null = null;
  isLoading: boolean = false;
  relatedNews: NewsDto[] = [];

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private newsService: NewsService,
    private sanitizer: DomSanitizer,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.route.params.subscribe(params => {
      const id = +params['id'];
      if (id) {
        this.loadNewsDetail(id);
      }
    });
  }

  loadNewsDetail(id: number): void {
    this.isLoading = true;
    this.cdr.markForCheck();
    this.newsService.getPublishedNewsById(id).subscribe({
      next: (news) => {
        this.news = news;
        this.isLoading = false;
        this.cdr.markForCheck();
        // Load related news
        this.loadSidebarNews(news.category || null, id);
      },
      error: (error) => {
        console.error('Error loading news detail:', error);
        this.isLoading = false;
        this.cdr.markForCheck();
        this.router.navigate(['/news']);
      }
    });
  }

  loadSidebarNews(category: string | null, excludeId: number, isFallback = false): void {
    const source$ = category 
      ? this.newsService.getNewsByCategory(category, 0, 5)
      : this.newsService.getPublishedNews(0, 5);

    source$.subscribe({
      next: (response) => {
        const filtered = response.news_list.filter(n => n.id !== excludeId);

        if (filtered.length === 0 && category) {
          // Fallback to latest published news when no related items in category
          this.loadSidebarNews(null, excludeId, true);
          return;
        }

        // If still empty after fallback, keep empty array to show placeholder
        this.relatedNews = filtered;
        this.cdr.markForCheck();
      },
      error: (error) => {
        console.error('Error loading sidebar news:', error);
        if (category && !isFallback) {
          // fallback to general news on error
          this.loadSidebarNews(null, excludeId, true);
        } else {
          this.relatedNews = [];
          this.cdr.markForCheck();
        }
      }
    });
  }

  getSafeHtml(content: string): SafeHtml {
    return this.sanitizer.bypassSecurityTrustHtml(content);
  }

  formatDate(dateString: string): string {
    const date = new Date(dateString);
    return date.toLocaleDateString('vi-VN', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  }

  goBack(): void {
    this.router.navigate(['/news']);
  }

  viewRelatedNews(newsId: number): void {
    this.router.navigate(['/news', newsId]);
    // Reload the component
    this.loadNewsDetail(newsId);
    // Scroll to top
    window.scrollTo(0, 0);
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

  getNewsLinkPreview(): LinkPreview | null {
    if (!this.news) return null;
    
    return {
      url: `${window.location.origin}/news/${this.news.id}`,
      title: this.news.title,
      description: this.news.summary || this.news.content?.substring(0, 150),
      image: this.getImageUrl(this.news.featured_image),
      siteName: 'Locker Korea News',
      favicon: 'favicon.ico'
    };
  }

  copyLinkToClipboard(): void {
    if (this.news) {
      const url = `${window.location.origin}/news/${this.news.id}`;
      navigator.clipboard.writeText(url).then(() => {
        alert('Đã sao chép link vào clipboard!');
      }).catch(err => {
        console.error('Failed to copy:', err);
      });
    }
  }
}

