import { AfterViewInit, Component, OnInit } from '@angular/core';
import { BaseComponent } from '../../../core/commonComponent/base.component';
import { ProductService } from '../../../core/services/product.service';
import { catchError, filter, finalize, of, switchMap, takeUntil, tap } from 'rxjs';
import { ProductDto } from '../../../core/dtos/product.dto';
import { DataViewModule } from 'primeng/dataview';
import { DropdownModule } from 'primeng/dropdown';
import { MenuItem } from 'primeng/api';
import { FormsModule } from "@angular/forms";
import { DetailProductService } from '../../../core/services/detail-product.service';
import { Router, ActivatedRoute } from '@angular/router';
import { PaginatorModule } from 'primeng/paginator';
import { AllProductDto } from '../../../core/dtos/AllProduct.dto';
import { CurrencyPipe, CommonModule } from '@angular/common';
import { SliderModule } from 'primeng/slider';
import { environment } from '../../../../environments/environment.development';
import { BadgeModule } from 'primeng/badge';
import { CategoriesService } from '../../../core/services/categories.service';
import { CategoriesDto } from '../../../core/dtos/categories.dto';
import { UserService } from '../../../core/services/user.service';
import { UserDto } from '../../../core/dtos/user.dto';
import { LockFeatureService, LockFeature } from '../../../core/services/lock-feature.service';

@Component({
  selector: 'app-all-product',
  standalone: true,
  imports: [
    CommonModule,
    DataViewModule,
    DropdownModule,
    FormsModule,
    PaginatorModule,
    CurrencyPipe,
    SliderModule,
    BadgeModule
  ],
  templateUrl: './all-product.component.html',
  styleUrl: './all-product.component.scss'
})
export class AllProductComponent extends BaseComponent implements OnInit, AfterViewInit {
  private token: string | null = null;
  public roleId!: number;
  public products: ProductDto[] = [];
  public displayedProducts: ProductDto[] = []; // Products for current page
  public sortOptions: MenuItem[] = [
    { label: 'Giá từ thấp đến cao', value: 'price' },
    { label: 'Giá từ cao đến thấp', value: '!price' },
  ];
  public categoriesOptions: MenuItem[] = [];
  public productsHighlight: ProductDto[] = [];
  public sortOrder!: number;
  public sortField!: string;
  public priceFilterValue: number[] = [1, 100];
  public apiImage: string = environment.apiImage;
  public isLoading: boolean = false;
  public error: string | null = null;

  // Pagination properties
  public first: number = 0;
  public rows: number = 12;
  public totalRecords: number = 0;

  // Thêm các biến cho bộ lọc thương hiệu
  public brandOptions = [
    { label: 'Nike', value: 'nike' },
    { label: 'Adidas', value: 'adidas' },
    { label: 'Puma', value: 'puma' },
    { label: 'Converse', value: 'converse' },
    { label: 'Vans', value: 'vans' }
  ];
  public selectedBrands: string[] = [];
  private allProducts: ProductDto[] = []; // Lưu trữ tất cả sản phẩm trước khi lọc
  public selectedCategory: string = 'all'; // Category đang được chọn
  public selectedFeature: string = 'all'; // Feature đang được chọn (for mobile dropdown)
  public selectedFeatures: string[] = []; // Multiple features selected (for desktop)
  public featureOptions: MenuItem[] = [];
  public features: LockFeature[] = []; // Lưu trữ features từ database

  constructor(
    private productService: ProductService,
    private detailProductService: DetailProductService,
    private router: Router,
    private route: ActivatedRoute,
    private categoriesService: CategoriesService,
    private userService: UserService,
    private lockFeatureService: LockFeatureService
  ) {
    super();
    if (typeof localStorage !== 'undefined') {
      this.token = localStorage.getItem('token');
    }
  }

  ngAfterViewInit(): void {
    this.detailProductService.content.pipe(
      filter((searchContent) => !!searchContent),
      switchMap((searchContent) => {
        return this.productService.searchProduct(searchContent).pipe(
          filter((product : AllProductDto) => !!product),
          tap((product: AllProductDto) => {
            this.products = product.products;
            this.totalRecords = this.products.length;
            this.updateDisplayedProducts();
            this.productsHighlight = product.products.filter(p => p.quantity > 0).slice(0, 5);
          }),
        )
      }),
    ).subscribe();
  }

  ngOnInit(): void {
    // Xử lý query params từ route (category hoặc feature/features)
    this.route.queryParams.pipe(
      takeUntil(this.destroyed$),
      tap(params => {
        if (params['category']) {
          this.selectedCategory = params['category'];
          console.log('Filter by category:', this.selectedCategory);
        }
        // Handle single feature (from home page)
        if (params['feature']) {
          this.selectedFeature = params['feature'];
          // Also add to selectedFeatures for desktop display
          this.selectedFeatures = [params['feature']];
          console.log('Filter by feature:', this.selectedFeature);
        }
        // Handle multiple features (from checkboxes)
        if (params['features']) {
          this.selectedFeatures = params['features'].split(',');
          console.log('Filter by features:', this.selectedFeatures);
        }
        // Load data sau khi xử lý query params
        this.loadInitialData();
      })
    ).subscribe();
  }

  private loadInitialData(): void {
    // Kiểm tra role user
    if (this.token != null) {
      this.userService.getInforUser(this.token).pipe(
        filter((userInfor: UserDto) => !!userInfor),
        tap((userInfor: UserDto) => {
          this.roleId = userInfor.role.id;
        })
      ).subscribe();
    }

    // Tải danh mục sản phẩm
    this.categoriesService.getCategories().pipe(
      tap((categories) => {
        const categoryItems = categories.map((item: CategoriesDto) => ({
          label: item.name,
          value: item.id.toString()
        }));
        this.categoriesOptions = [
          { label: 'Tất cả', value: 'all' },
          ...categoryItems
        ];
      })
    ).subscribe();

    // Tải danh sách features
    this.loadFeatures();
  }

  private loadFeatures(): void {
    this.lockFeatureService.getActiveFeatures().pipe(
      takeUntil(this.destroyed$),
      tap((features: LockFeature[]) => {
        this.features = features;
        const featureItems = features.map((feature: LockFeature) => ({
          label: feature.name,
          value: feature.id?.toString() || ''
        }));
        this.featureOptions = [
          { label: 'Tất cả chức năng', value: 'all' },
          ...featureItems
        ];

        // Sau khi có features, load products theo selectedCategory
        this.loadProductsByCategory();
      }),
      catchError((error) => {
        console.error('Error loading features:', error);
        // Nếu lỗi, vẫn load products
        this.loadProductsByCategory();
        return of([]);
      })
    ).subscribe();
  }

  private loadProductsByCategory(): void {
    // Nếu có category được chọn (từ query param hoặc filter)
    if (this.selectedCategory && this.selectedCategory !== 'all') {
      this.isLoading = true;
      const categoryId = parseInt(this.selectedCategory, 10);
      this.categoriesService.getAllProductByCategory(categoryId).pipe(
        takeUntil(this.destroyed$),
        tap((productByCategory: AllProductDto) => {
          if (productByCategory && productByCategory.products) {
            this.allProducts = productByCategory.products;
            // Apply feature filter if selected
            this.applyFilters();
            this.error = null;
          } else {
            this.error = 'Không có sản phẩm nào trong danh mục này';
          }
        }),
        catchError((error) => {
          console.error('Error loading category products:', error);
          this.error = 'Có lỗi xảy ra khi tải sản phẩm theo danh mục';
          return of(null);
        }),
        finalize(() => {
          this.isLoading = false;
        })
      ).subscribe();
    } else {
      // Load tất cả sản phẩm theo khoảng giá mặc định
      this.filterPrice();
    }
  }

  private applyFilters(): void {
    let filteredProducts = [...this.allProducts];

    // Filter by multiple features if selected (desktop)
    if (this.selectedFeatures.length > 0) {
      filteredProducts = filteredProducts.filter(product => {
        // Product must match at least one selected feature
        return this.selectedFeatures.some(featureId => 
          this.productMatchesFeature(product, featureId)
        );
      });
    } 
    // Filter by single feature (mobile dropdown)
    else if (this.selectedFeature && this.selectedFeature !== 'all') {
      filteredProducts = this.filterByFeature(filteredProducts, this.selectedFeature);
    }

    // Filter by price
    filteredProducts = filteredProducts.filter(product => 
      product.price >= this.priceFilterValue[0] * 500000 &&
      product.price <= this.priceFilterValue[1] * 500000
    );

    // Filter by brand if selected
    if (this.selectedBrands.length > 0) {
      filteredProducts = filteredProducts.filter(product => 
        this.selectedBrands.some(brand => 
          product.name.toLowerCase().includes(brand.toLowerCase())
        )
      );
    }

    // Sort by availability
    this.products = this.sortByAvailability(filteredProducts);
    this.totalRecords = this.products.length;
    this.first = 0;
    this.updateDisplayedProducts();
    this.productsHighlight = filteredProducts.filter(p => p.quantity > 0).slice(0, 5);
  }

  private productMatchesFeature(product: ProductDto, featureId: string): boolean {
    const selectedFeature = this.features.find(f => f.id?.toString() === featureId);
    if (!selectedFeature) return false;

    const featureName = selectedFeature.name.toLowerCase();
    
    // Check in product name
    const nameMatch = product.name.toLowerCase().includes(featureName);
    
    // Check in product description
    const descMatch = !!(product.description && 
      product.description.toLowerCase().includes(featureName));
    
    // Check in product features array by ID
    const featuresMatchById = !!(product.features && product.features.some(feature => 
      feature.id?.toString() === featureId
    ));

    // Check in product features array by name
    const featuresMatchByName = !!(product.features && product.features.some(feature => 
      feature.name.toLowerCase().includes(featureName) ||
      (feature.description && feature.description.toLowerCase().includes(featureName))
    ));

    return nameMatch || descMatch || featuresMatchById || featuresMatchByName;
  }

  private filterByFeature(products: ProductDto[], featureId: string): ProductDto[] {
    // Tìm feature trong database
    const selectedFeature = this.features.find(f => f.id?.toString() === featureId);
    if (!selectedFeature) {
      return products;
    }

    const featureName = selectedFeature.name.toLowerCase();
    
    return products.filter(product => {
      // Check in product name
      const nameMatch = product.name.toLowerCase().includes(featureName);
      
      // Check in product description
      const descMatch = product.description && 
        product.description.toLowerCase().includes(featureName);
      
      // Check in product features array by ID
      const featuresMatchById = product.features && product.features.some(feature => 
        feature.id?.toString() === featureId
      );

      // Check in product features array by name
      const featuresMatchByName = product.features && product.features.some(feature => 
        feature.name.toLowerCase().includes(featureName) ||
        (feature.description && feature.description.toLowerCase().includes(featureName))
      );

      return nameMatch || descMatch || featuresMatchById || featuresMatchByName;
    });
  }

  onBrandChange(event: any, brandValue: string) {
    if (event.target.checked) {
      this.selectedBrands.push(brandValue);
    } else {
      this.selectedBrands = this.selectedBrands.filter(b => b !== brandValue);
    }
    this.filterProducts();
  }

  private sortByAvailability(products: ProductDto[]): ProductDto[] {
    return [...products].sort((a, b) => {
      // Ưu tiên sản phẩm còn hàng
      if (a.quantity > 0 && b.quantity === 0) return -1;
      if (a.quantity === 0 && b.quantity > 0) return 1;
      return 0;
    });
  }

  filterProducts() {
    // Use the unified applyFilters method
    this.applyFilters();
  }

  onSortChange(event: any) {
    let value = event.value;
    if (value.indexOf("!") === 0) {
      this.sortOrder = -1;
      this.sortField = value.substring(1, value.length);
    } else {
      this.sortOrder = 1;
      this.sortField = value;
    }
    
    // Sort products by price and availability
    this.products.sort((a, b) => {
      // First sort by availability
      const availabilitySort = this.sortByAvailability([a, b]);
      if (availabilitySort[0] === a) return -1;
      if (availabilitySort[0] === b) return 1;
      
      // Then sort by price
      const aValue = a[this.sortField as keyof ProductDto] ?? 0;
      const bValue = b[this.sortField as keyof ProductDto] ?? 0;
      return this.sortOrder * (aValue > bValue ? 1 : -1);
    });
    
    this.updateDisplayedProducts();
  }

  onCategoryChange(event: any){
    // Update selectedCategory
    this.selectedCategory = event.value;

    // Update URL query params
    this.router.navigate([], {
      relativeTo: this.route,
      queryParams: { category: this.selectedCategory === 'all' ? null : this.selectedCategory },
      queryParamsHandling: 'merge'
    });

    // Load products
    this.loadProductsByCategory();
  }

  onFeatureChange(event: any){
    // Update selectedFeature (mobile)
    this.selectedFeature = event.value;

    // Update URL query params
    this.router.navigate([], {
      relativeTo: this.route,
      queryParams: { feature: this.selectedFeature === 'all' ? null : this.selectedFeature },
      queryParamsHandling: 'merge'
    });

    // Apply filters to current products
    this.applyFilters();
  }

  onFeatureCheckboxChange(featureId: string, checked: boolean): void {
    if (checked) {
      // Add feature to selected list
      if (!this.selectedFeatures.includes(featureId)) {
        this.selectedFeatures.push(featureId);
      }
    } else {
      // Remove feature from selected list
      this.selectedFeatures = this.selectedFeatures.filter(id => id !== featureId);
    }

    // Update URL query params
    this.router.navigate([], {
      relativeTo: this.route,
      queryParams: { 
        features: this.selectedFeatures.length > 0 ? this.selectedFeatures.join(',') : null 
      },
      queryParamsHandling: 'merge'
    });

    // Apply filters
    this.applyFilters();
  }

  isFeatureSelected(featureId: string): boolean {
    return this.selectedFeatures.includes(featureId);
  }

  navigateToDetail(productId: number) {
    this.detailProductService.setId(productId);
    this.router.navigateByUrl(`/detailProduct/${productId}`);
  }

  filterPrice() {
    this.isLoading = true;
    this.productService.getProductViaPrice(this.priceFilterValue[0] * 500000, this.priceFilterValue[1] * 500000).pipe(
      takeUntil(this.destroyed$),
      tap((product: AllProductDto) => {
        if (product && product.products) {
          this.allProducts = product.products;
          // Apply all filters including feature filter
          this.applyFilters();
          this.error = null;
        } else {
          this.error = 'Không tìm thấy sản phẩm trong khoảng giá này';
        }
      }),
      catchError((error) => {
        console.error('Error filtering products by price:', error);
        this.error = 'Có lỗi xảy ra khi lọc sản phẩm theo giá';
        return of(null);
      }),
      finalize(() => {
        this.isLoading = false;
      })
    ).subscribe();
  }

  getProductImageUrl(product: ProductDto): string {
    // If product has a thumbnail, use it
    if (product.thumbnail && product.thumbnail.trim() !== '') {
      return this.apiImage + product.thumbnail;
    }
    
    // If no thumbnail but has product_images, use the first one
    if (product.product_images && product.product_images.length > 0) {
      return this.apiImage + product.product_images[0].image_url;
    }
    
    // Default image if no images available
    return this.apiImage + 'notfound.jpg';
  }

  // Pagination methods
  onPageChange(event: any) {
    this.first = event.first;
    this.rows = event.rows;
    this.updateDisplayedProducts();
  }

  private updateDisplayedProducts() {
    // Sắp xếp ưu tiên sản phẩm còn hàng
    const sortedProducts = this.sortByAvailability(this.products);
    
    const startIndex = this.first;
    const endIndex = startIndex + this.rows;
    this.displayedProducts = sortedProducts.slice(startIndex, endIndex);
  }
}
