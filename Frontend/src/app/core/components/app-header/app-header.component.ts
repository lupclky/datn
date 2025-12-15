import { AfterViewInit, Component, OnInit, Output, EventEmitter } from '@angular/core';
import { InputTextModule } from 'primeng/inputtext';
import { Router, RouterModule } from '@angular/router';
import { OverlayPanelModule } from 'primeng/overlaypanel';
import { BaseComponent } from '../../commonComponent/base.component';
import { AvatarModule } from 'primeng/avatar';
import { MenuItem } from 'primeng/api';
import { MenuModule } from 'primeng/menu';
import { UserService } from '../../services/user.service';
import { catchError, debounceTime, distinctUntilChanged, filter, of, switchMap, takeUntil, tap } from 'rxjs';
import { MessageService } from 'primeng/api';
import { ToastService } from '../../services/toast.service';
import { DetailProductService } from '../../services/detail-product.service';
import { FormsModule } from "@angular/forms";
import { ProductService } from '../../services/product.service';
import { ProductFromCartDto } from '../../dtos/ProductFromCart.dto';
import { BadgeModule } from 'primeng/badge';
import { ProductsInCartDto } from '../../dtos/productsInCart.dto';
import { CurrencyPipe } from '@angular/common';
import { ButtonModule } from 'primeng/button';
import { CommonModule } from '@angular/common';
import { DataViewModule } from 'primeng/dataview';
import { ToastModule } from 'primeng/toast';
import { CommonService } from '../../services/common.service';
import { environment } from '../../../../environments/environment.development';
import { UserDto } from '../../dtos/user.dto';
import { Subject } from 'rxjs';
import { ProductDto } from '../../dtos/product.dto';
import { CategoriesService } from '../../services/categories.service';
import { CategoriesDto } from '../../dtos/categories.dto';
import { LockFeatureService, LockFeature } from '../../services/lock-feature.service';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [
    InputTextModule,
    RouterModule,
    OverlayPanelModule,
    AvatarModule,
    MenuModule,
    FormsModule,
    BadgeModule,
    CurrencyPipe,
    ButtonModule,
    CommonModule,
    DataViewModule,
    ToastModule
  ],
  providers: [
    MessageService,
    ToastService
  ],
  templateUrl: './app-header.component.html',
  styleUrl: './app-header.component.scss'
})
export class AppHeaderComponent extends BaseComponent implements AfterViewInit,OnInit{
  @Output() sidebarToggled = new EventEmitter<boolean>();
  public token: string | null = null;
  public roleId: number = 100;
  public itemsMenuAvatar: MenuItem[] | undefined;
  public userName : string | undefined;
  public searchValue : string = "";
  public quantityInCart: number = 0;
  public products: ProductsInCartDto[] = [];
  public showPreview: boolean = false;
  public showCartPreview: boolean = false;
  public apiImage: string = environment.apiImage;

  // Search suggestions properties
  public searchSuggestions: ProductDto[] = [];
  public showSuggestions: boolean = false;
  private searchSubject = new Subject<string>();
  public isMenuOpen = false;
  public isMobileSearchActive = false;
  public isSidebarOpen = true; // Sidebar defaults to open on desktop
  
  // Category Menu Properties
  public isCategoryMenuOpen = false;
  public activeMobileSubmenu: string | null = null; // 'features' or null
  public categories: CategoriesDto[] = [];
  public features: LockFeature[] = [];
  public brandOptions = [
    { label: 'Samsung', value: 'samsung' },
    { label: 'Kaadas', value: 'kaadas' },
    { label: 'Xiaomi', value: 'xiaomi' },
    { label: 'Dessmann', value: 'dessmann' },
    { label: 'Unicor', value: 'unicor' },
    { label: 'Hafele', value: 'hafele' },
    { label: 'Yale', value: 'yale' },
    { label: 'Epic', value: 'epic' }
  ];

  constructor(
    private userService : UserService,
    private router : Router,
    private readonly messageService: MessageService,
    private toastService: ToastService,
    private detailProductService : DetailProductService,
    private productService: ProductService,
    private commonService: CommonService,
    private categoriesService: CategoriesService,
    private lockFeatureService: LockFeatureService
  ) {
    super();
    if (typeof localStorage !== 'undefined') {
      this.token = localStorage.getItem('token');
      this.roleId = parseInt(JSON.parse(localStorage.getItem("userInfor") || '{"role_id": "0"}').role_id || '0');
    }

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
            }),
            switchMap(() => of(this.searchSuggestions)),
            catchError(() => of([]))
          );
        }
        return of([]);
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  ngOnInit(): void {
    // Load menu data
    this.loadMenuData();

    // Emit initial state
    this.sidebarToggled.emit(this.isSidebarOpen);

    this.detailProductService.quantityProductsInCart.pipe(
      filter((quantity : number) => !!quantity),
      tap((quantity : number) => {
        this.quantityInCart = quantity;
      }),
      takeUntil(this.destroyed$)
    ).subscribe();

    if (this.token != null){
      this.userService.getInforUser(this.token).pipe(
        filter((userInfo: UserDto) => !!userInfo),
        tap((userInfo: UserDto) => {
          this.userName = userInfo.fullname;
          this.roleId = userInfo.role.id;
        }),
        takeUntil(this.destroyed$),
        catchError((err) => of(err))
      ).subscribe()

      this.getCart().subscribe();
    }

    this.itemsMenuAvatar = [
      {
        label: 'Hồ sơ',
        icon: 'pi pi-fw pi-user',
        command: () => {
          this.router.navigate(['/user-profile']);
        }
      },
      {
        label: 'Đăng xuất',
        icon: 'pi pi-power-off',
        command: () => {
          this.signOut();
        }
      }
    ]   
  }

  ngAfterViewInit(): void {
    this.commonService.intermediateObservable.pipe(
      tap(() => {
        // Reload user info and token from localStorage
        if (typeof localStorage !== 'undefined') {
          this.token = localStorage.getItem('token');
          const userInforStr = localStorage.getItem("userInfor");
          if (userInforStr) {
            const userInfor = JSON.parse(userInforStr);
            this.roleId = parseInt(userInfor.role_id || '0');
            this.userName = userInfor.fullname;
          } else if (this.token) {
             // If token exists but no user info, try to fetch it
             this.fetchUserInfo();
          } else {
            // Logout state
            this.token = null;
            this.userName = undefined;
            this.roleId = 0;
            this.quantityInCart = 0;
            this.products = [];
          }
        }
      }),
      switchMap(() => {
        if (this.token) {
            return this.getCart();
        }
        return of(null);
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  fetchUserInfo() {
    if (this.token != null) {
      this.userService.getInforUser(this.token).pipe(
        filter((userInfo: UserDto) => !!userInfo),
        tap((userInfo: UserDto) => {
          this.userName = userInfo.fullname;
          this.roleId = userInfo.role.id;
          localStorage.setItem("userInfor", JSON.stringify(userInfo));
        }),
        takeUntil(this.destroyed$),
        catchError((err) => of(err))
      ).subscribe();
    }
  }
  
  signOut(){
    localStorage.removeItem("token");
    localStorage.removeItem("roleId");
    localStorage.removeItem("userInfor");
    localStorage.removeItem("productOrder");
    window.location.href = "/Home";
  }

  sendContentSearch(){
    if (this.searchValue.trim()) {
      this.router.navigate(['/allProduct'], { 
        queryParams: { 
          keyword: this.searchValue.trim() 
        } 
      });
      this.hideSuggestions();
      this.isMobileSearchActive = false; // Close mobile search after search
    }
  }

  // Search suggestions methods
  onSearchInput(event: Event): void {
    const target = event.target as HTMLInputElement;
    const value = target.value;
    this.searchValue = value;
    
    if (value.trim().length >= 2) {
      this.searchSubject.next(value);
      this.showSuggestions = true;
    } else {
      this.searchSuggestions = [];
      this.showSuggestions = false;
    }
  }

  selectProduct(product: ProductDto): void {
    this.router.navigate(['/detailProduct', product.id]);
    this.searchValue = '';
    this.hideSuggestions();
  }

  hideSuggestions(): void {
    setTimeout(() => {
      this.showSuggestions = false;
      this.searchSuggestions = [];
    }, 150);
  }

  deleteProduct(event: any, id: number){
    event.stopPropagation();
    this.productService.deleteProductFromCart(id).pipe(
      switchMap(() => {
        this.commonService.intermediateObservable.next(true);
        return this.getCart();
      }),
      takeUntil(this.destroyed$),
      catchError((err) => {
        this.toastService.fail("Xóa sản phẩm thất bại");
        return of(err);
      })
    ).subscribe();
  }

  getCart(){
    return this.productService.getProductFromCart().pipe(
      filter((product : ProductFromCartDto) => !!product),
      tap((product : ProductFromCartDto) => {
        this.quantityInCart = product.totalCartItems;
        this.products = product.carts;
      }),
      takeUntil(this.destroyed$),
      catchError((err) => of(err))
    )
  }

  goToHistory(){
    this.router.navigate(['/history']);
  }

  goToMyReturns(){
    this.router.navigate(['/my-returns']);
  }

  goToChangePassword() {
    this.router.navigate(['/change-password']);
  }

  toggleMenu() {
    this.isMenuOpen = !this.isMenuOpen;
  }

  closeSidebarMobile() {
    // Only auto-close on mobile devices (width < 768px)
    if (window.innerWidth < 768) {
      this.isSidebarOpen = false;
      this.sidebarToggled.emit(this.isSidebarOpen);
    }
  }

  toggleSidebar() {
    this.isSidebarOpen = !this.isSidebarOpen;
    this.sidebarToggled.emit(this.isSidebarOpen);
  }

  initMenu() {
    this.itemsMenuAvatar = [
      {
        label: 'Hồ sơ',
        icon: 'pi pi-fw pi-user',
        command: () => {
          this.router.navigate(['/user-profile']);
        }
      },
      {
        label: 'Lịch sử mua',
        icon: 'pi pi-history',
        command: () => {
          this.goToHistory();
        }
      },
      {
        label: 'Trả hàng & Hoàn tiền',
        icon: 'pi pi-replay',
        command: () => {
          this.goToMyReturns();
        }
      },
      {
        label: 'Đổi mật khẩu',
        icon: 'pi pi-key',
        command: () => {
          this.goToChangePassword();
        }
      },
      {
        label: 'Đăng xuất',
        icon: 'pi pi-power-off',
        command: () => {
          this.signOut();
        }
      }
    ]   
  }

  getProductImageUrl(product: ProductDto): string {
    // If product has a thumbnail, use it
    if (product.thumbnail && product.thumbnail.trim() !== '') {
      return `${this.apiImage}${product.thumbnail}`;
    }
    
    // If no thumbnail but has product_images, use the first one
    if (product.product_images && product.product_images.length > 0) {
      return `${this.apiImage}${product.product_images[0].image_url}`;
    }
    
    // Default image if no images available
    return 'assets/images/no-image.png';
  }

  loadMenuData() {
    // Load Categories
    this.categoriesService.getCategories().pipe(
      takeUntil(this.destroyed$),
      tap(cats => this.categories = cats)
    ).subscribe();

    // Load Features
    this.lockFeatureService.getActiveFeatures().pipe(
      takeUntil(this.destroyed$),
      tap(feats => this.features = feats)
    ).subscribe();
  }

  toggleCategoryMenu() {
    this.isCategoryMenuOpen = !this.isCategoryMenuOpen;
    if (!this.isCategoryMenuOpen) {
      this.activeMobileSubmenu = null; // Reset submenu when closing
    }
  }

  openMobileSubmenu(menuName: string, event: Event) {
    if (window.innerWidth <= 768) {
      event.stopPropagation(); // Prevent closing or other actions
      this.activeMobileSubmenu = menuName;
    }
  }

  closeMobileSubmenu(event: Event) {
    event.stopPropagation();
    this.activeMobileSubmenu = null;
  }

  onCategorySelect(categoryId: string) {
    this.isCategoryMenuOpen = false;
    // Use setTimeout to ensure the menu closes visually before navigation or on mobile touch
    setTimeout(() => {
        this.router.navigate(['/allProduct'], { queryParams: { category: categoryId } });
    }, 50);
  }

  onFeatureSelect(featureId: string) {
    this.isCategoryMenuOpen = false;
    setTimeout(() => {
        this.router.navigate(['/allProduct'], { queryParams: { feature: featureId } });
    }, 50);
  }

  onBrandSelect(brand: string) {
    this.isCategoryMenuOpen = false;
    setTimeout(() => {
        this.router.navigate(['/allProduct'], { queryParams: { keyword: brand } });
    }, 50);
  }

  navigateAndClose(path: string[]) {
    this.isCategoryMenuOpen = false;
    setTimeout(() => {
        this.router.navigate(path);
    }, 50);
  }

  private menuCloseTimeout: any = null;

  // Hover handlers that only work on desktop to prevent mobile ghost clicks
  onMenuMouseEnter() {
    if (window.innerWidth > 768) {
      // Clear any pending close timeout
      if (this.menuCloseTimeout) {
        clearTimeout(this.menuCloseTimeout);
        this.menuCloseTimeout = null;
      }
      this.isCategoryMenuOpen = true;
    }
  }

  onMenuMouseLeave() {
    if (window.innerWidth > 768) {
      // Add delay before closing to allow mouse to move to dropdown
      this.menuCloseTimeout = setTimeout(() => {
        this.isCategoryMenuOpen = false;
        this.menuCloseTimeout = null;
      }, 200); // 200ms delay
    }
  }
}
