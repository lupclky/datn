import { Component, OnInit } from '@angular/core';
import { CarouselModule } from 'primeng/carousel';
import { BaseComponent } from '../../../core/commonComponent/base.component';
import { ProductService } from '../../../core/services/product.service';
import { ProductDto } from '../../../core/dtos/product.dto';
import { catchError, filter, tap, of, map, takeUntil } from 'rxjs';
import { AllProductDto } from '../../../core/dtos/AllProduct.dto';
import { environment } from '../../../../environments/environment.development';
import { CurrencyPipe } from '@angular/common';
import { BadgeModule } from 'primeng/badge';
import { Router, RouterModule } from '@angular/router';

import { RecommendationService } from '../../../core/services/recommendation.service';
import { CategoriesService } from '../../../core/services/categories.service';
import { CategoryDto } from '../../../core/dtos/Category.dto';
import { VoucherDisplayComponent } from '../voucher-display/voucher-display.component';

import { AiChatbotComponent } from '../../../core/components/ai-chatbot/ai-chatbot.component';
import { RatingModule } from 'primeng/rating';
import { FormsModule } from '@angular/forms';
import { BannerService } from '../../../core/services/banner.service';
import { BannerDto } from '../../../core/dtos/banner.dto';
import { CommonModule } from '@angular/common';
import { NewsService } from '../../../core/services/news.service';
import { NewsDto } from '../../../core/dtos/news.dto';
import { LockFeatureService, LockFeature } from '../../../core/services/lock-feature.service';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [
    CarouselModule,
    CurrencyPipe,
    BadgeModule,
    RouterModule,
    AiChatbotComponent,
    VoucherDisplayComponent,
    RatingModule,
    FormsModule,
    CommonModule
  ],
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss']
})
export class HomeComponent extends BaseComponent implements OnInit {
  public products: ProductDto[] = [];
  public productsHighlight: ProductDto[] = [];
  public productNewest: ProductDto[] = [];
  public productsDiscount: ProductDto[] = [];
  public recommendedProducts: ProductDto[] = [];
  public apiImage: string = environment.apiImage;
  public categories: CategoryDto[] = [];
  public banners: BannerDto[] = [];
  public isLoadingBanners: boolean = false;
  public latestNews: NewsDto[] = [];
  public isLoadingNews: boolean = false;
  public features: Array<{id?: number, name: string, icon: string}> = [];

  constructor(
    private productService: ProductService,
    private recommendationService: RecommendationService,
    private categoriesService: CategoriesService,
    private bannerService: BannerService,
    private newsService: NewsService,
    private lockFeatureService: LockFeatureService,
    private router: Router
  ) {
    super();
  }

  ngOnInit(): void {
    this.loadProducts();
    this.loadCategories();
    this.loadBanners();
    this.loadLatestNews();
    this.loadFeatures();
  }

  loadProducts(): void {
    this.productService.getAllProduct().pipe(
      catchError((error) => {
        console.error('Error loading products:', error);
        return of({ products: [], totalProducts: 0 } as AllProductDto);
      }),
      filter((product: AllProductDto) => !!product),
      tap((product: AllProductDto) => {
        this.products = product.products || [];
        this.productsHighlight = this.products.slice(0, 3);
        this.productNewest = this.products.slice(0, 4);
        this.productsDiscount = this.products.filter((product) => {
          return product.discount && product.discount > 0;
        });
        this.loadRecommendedProducts();
      })
    ).subscribe();
  }

  loadCategories(): void {
    this.categoriesService.getCategories().pipe(
      filter((categories: CategoryDto[]) => !!categories),
      tap((categories: CategoryDto[]) => {
        this.categories = categories;
      })
    ).subscribe();
  }

  loadRecommendedProducts(): void {
    if (!this.products.length) {
      return;
    }

    this.recommendationService.getRecommendations(this.products).pipe(
      filter((products: ProductDto[]) => !!products),
      tap((products: ProductDto[]) => {
        this.recommendedProducts = products;
      })
    ).subscribe();
  }

  navigateToDetail(id: number): void {
    this.router.navigate(['/detailProduct', id]);
  }

  getProductImageUrl(product: ProductDto): string {
    return `${this.apiImage}${product.thumbnail}`;
  }

  loadBanners(): void {
    this.isLoadingBanners = true;
    this.bannerService.getActiveBanners().pipe(
      catchError((error) => {
        console.error('Error loading banners:', error);
        return of({ banners: [], total: 0, message: '' });
      }),
      tap((response) => {
        this.banners = response.banners || [];
        this.isLoadingBanners = false;
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  getBannerImageUrl(banner: BannerDto): string {
    if (!banner.image_url) return '';
    const cleanApiUrl = environment.apiUrl.replace(/\/$/, '');
    const cleanImageUrl = banner.image_url.replace(/^\//, '');
    return `${cleanApiUrl}/banners/images/${cleanImageUrl}`;
  }

  loadLatestNews(): void {
    this.isLoadingNews = true;
    this.newsService.getPublishedNews(0, 3).pipe(
      catchError((error) => {
        console.error('Error loading latest news:', error);
        return of({ news_list: [], total_pages: 0, message: '' });
      }),
      tap((response) => {
        this.latestNews = response.news_list || [];
        this.isLoadingNews = false;
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  getNewsImageUrl(news: NewsDto): string {
    if (!news.featured_image) {
      return '../../../../assets/images/post1.jpg';
    }
    if (news.featured_image.startsWith('http')) {
      return news.featured_image;
    }
    return `${environment.apiUrl}/news/images/${news.featured_image}`;
  }

  formatDate(dateString: string): { day: string, month: string } {
    const date = new Date(dateString);
    return {
      day: date.getDate().toString().padStart(2, '0'),
      month: (date.getMonth() + 1).toString()
    };
  }

  getTruncatedTitle(title: string, maxLength: number = 50): string {
    if (!title) return '';
    return title.length > maxLength ? title.substring(0, maxLength) + '...' : title;
  }

  getTruncatedSummary(summary: string, maxLength: number = 100): string {
    if (!summary) return '';
    return summary.length > maxLength ? summary.substring(0, maxLength) + '...' : summary;
  }

  navigateToNews(newsId: number): void {
    this.router.navigate(['/news', newsId]);
  }

  navigateToCategory(categoryId: number): void {
    this.router.navigate(['/allProduct'], { 
      queryParams: { category: categoryId } 
    });
  }

  navigateToFeature(featureId: number | undefined): void {
    if (featureId) {
      this.router.navigate(['/allProduct'], { 
        queryParams: { feature: featureId } 
      });
    }
  }

  loadFeatures(): void {
    this.lockFeatureService.getActiveFeatures().pipe(
      catchError((error) => {
        console.error('Error loading features:', error);
        return of([]);
      }),
      tap((features: LockFeature[]) => {
        // Map features và add icon dựa trên tên
        this.features = features.map(feature => ({
          id: feature.id,
          name: feature.name,
          icon: this.getFeatureIcon(feature.name)
        }));
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  private getFeatureIcon(featureName: string): string {
    const name = featureName.toLowerCase();
    if (name.includes('vân tay') || name.includes('fingerprint')) return 'pi pi-fingerprint';
    if (name.includes('bluetooth')) return 'pi pi-wifi';
    if (name.includes('mã số') || name.includes('password')) return 'pi pi-lock';
    if (name.includes('thẻ') || name.includes('card')) return 'pi pi-credit-card';
    if (name.includes('điều khiển') || name.includes('remote')) return 'pi pi-mobile';
    if (name.includes('tự động') || name.includes('auto')) return 'pi pi-shield';
    if (name.includes('báo động') || name.includes('alarm')) return 'pi pi-bell';
    if (name.includes('pin') || name.includes('battery')) return 'pi pi-bolt';
    return 'pi pi-cog'; // Default icon
  }
}
