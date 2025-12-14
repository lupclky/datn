import { Component, OnInit, ViewChild, ElementRef, OnDestroy } from '@angular/core';
import { CommonModule, CurrencyPipe } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { DetailProductService } from '../../services/detail-product.service';
import { ProductService } from '../../services/product.service';
import { ProductFromCartDto } from '../../dtos/ProductFromCart.dto';
import { ProductDto } from '../../dtos/product.dto';
import { filter, tap, debounceTime, distinctUntilChanged, switchMap, catchError, takeUntil } from 'rxjs/operators';
import { Subject, of } from 'rxjs';
import { environment } from '../../../../environments/environment.development';

@Component({
  selector: 'app-bottom-nav',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule, CurrencyPipe],
  templateUrl: './app-bottom-nav.component.html',
  styleUrls: ['./app-bottom-nav.component.scss']
})
export class AppBottomNavComponent implements OnInit, OnDestroy {
  isSearchOpen: boolean = false;
  searchKeyword: string = '';
  cartCount: number = 0;
  searchSuggestions: ProductDto[] = [];
  showSuggestions: boolean = false;
  private searchSubject = new Subject<string>();
  private destroyed$ = new Subject<void>();
  private apiImage: string = environment.apiImage;
  
  @ViewChild('searchInput') searchInput!: ElementRef;

  constructor(
    private router: Router,
    private detailProductService: DetailProductService,
    private productService: ProductService
  ) {
    // Setup search suggestions with debounce
    this.searchSubject.pipe(
      debounceTime(300),
      distinctUntilChanged(),
      switchMap(searchTerm => {
        if (searchTerm.trim().length >= 2) {
          return this.productService.searchProduct(searchTerm).pipe(
            tap(result => {
              // Extract products array from AllProductDto
              this.searchSuggestions = result.products ? result.products.slice(0, 5) : [];
              this.showSuggestions = true;
            }),
            switchMap(() => of(this.searchSuggestions)),
            catchError(() => {
              this.searchSuggestions = [];
              return of([]);
            })
          );
        }
        this.searchSuggestions = [];
        this.showSuggestions = false;
        return of([]);
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  ngOnInit(): void {
    // Sync cart count
    this.detailProductService.quantityProductsInCart.pipe(
      filter((quantity: number) => quantity !== null && quantity !== undefined),
      tap((quantity: number) => {
        this.cartCount = quantity;
      })
    ).subscribe();

    // Initial cart load if token exists
    if (localStorage.getItem('token')) {
      this.productService.getProductFromCart().pipe(
        filter((product: ProductFromCartDto) => !!product),
        tap((product: ProductFromCartDto) => {
          this.cartCount = product.totalCartItems;
        })
      ).subscribe();
    }
  }

  toggleSearch() {
    this.isSearchOpen = !this.isSearchOpen;
    if (this.isSearchOpen) {
      setTimeout(() => {
        this.searchInput?.nativeElement.focus();
      }, 100);
    }
  }

  onSearchInput(event: Event): void {
    const target = event.target as HTMLInputElement;
    const value = target.value;
    this.searchKeyword = value;
    
    if (value.trim().length >= 2) {
      this.searchSubject.next(value);
    } else {
      this.searchSuggestions = [];
      this.showSuggestions = false;
    }
  }

  onSearch() {
    if (this.searchKeyword.trim()) {
      this.router.navigate(['/allProduct'], { 
        queryParams: { 
          keyword: this.searchKeyword.trim() 
        } 
      });
      this.toggleSearch();
      this.searchKeyword = '';
      this.searchSuggestions = [];
      this.showSuggestions = false;
    }
  }

  selectProduct(product: ProductDto): void {
    this.router.navigate(['/detailProduct', product.id]);
    this.searchKeyword = '';
    this.searchSuggestions = [];
    this.showSuggestions = false;
    this.toggleSearch();
  }

  getProductImageUrl(product: ProductDto): string {
    // If product has a thumbnail, use it
    if (product.thumbnail && product.thumbnail.trim() !== '') {
      if (product.thumbnail.startsWith('http://') || product.thumbnail.startsWith('https://')) {
        return product.thumbnail;
      }
      return `${this.apiImage}${product.thumbnail}`;
    }
    
    // If no thumbnail but has product_images, use the first one
    if (product.product_images && product.product_images.length > 0) {
      const firstImage = product.product_images[0].image_url;
      if (firstImage.startsWith('http://') || firstImage.startsWith('https://')) {
        return firstImage;
      }
      return `${this.apiImage}${firstImage}`;
    }
    
    return 'assets/images/no-image.png';
  }

  ngOnDestroy(): void {
    this.destroyed$.next();
    this.destroyed$.complete();
  }
}



