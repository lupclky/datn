import { Component, OnInit, Inject, PLATFORM_ID } from '@angular/core';
import { RouterLink } from '@angular/router';
import { NgSwitch, NgSwitchCase, NgClass, CommonModule } from '@angular/common';
import { CurrencyPipe, DatePipe, isPlatformBrowser } from '@angular/common';
import { FormBuilder, FormGroup, FormsModule, ReactiveFormsModule, Validators } from '@angular/forms';
import { BaseComponent } from '../../../core/commonComponent/base.component';
import { HistoryOrderDto } from '../../../core/dtos/HistoryOrder.dto';
import { environment } from '../../../../environments/environment.development';
import { MenuItem } from 'primeng/api';
import { DropdownModule } from 'primeng/dropdown';
import { OrderService } from '../../../core/services/order.service';
import { catchError, of, tap, debounceTime, distinctUntilChanged, switchMap, finalize, Observable } from 'rxjs';
import { MessageService } from 'primeng/api';
import { ToastService } from '../../../core/services/toast.service';
import { ToastModule } from 'primeng/toast';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { TableModule } from 'primeng/table';
import { ButtonModule } from 'primeng/button';
import { TooltipModule } from 'primeng/tooltip';
import { CardModule } from 'primeng/card';
import { ConfirmationService } from 'primeng/api';
import { Router } from '@angular/router';
import { InputTextModule } from 'primeng/inputtext';
import { CalendarModule } from 'primeng/calendar';
import { OrderListResponse } from '../../../core/responses/order.list.response';
import { DialogModule } from 'primeng/dialog';
import { ProductService } from '../../../core/services/product.service';
import { ProductDto } from '../../../core/dtos/product.dto';
import { AutoCompleteModule } from 'primeng/autocomplete';
import { InputNumberModule } from 'primeng/inputnumber';
import { InputTextareaModule } from 'primeng/inputtextarea';
import { RadioButtonModule } from 'primeng/radiobutton';
import { ORDER_STATUS_OPTIONS, getOrderStatusLabel } from '../../../core/constants/order-status.constants';
import { VietnamAddressService, AddressDropdownOption } from '../../../core/services/vietnam-address.service';
import { forkJoin, map } from 'rxjs';

@Component({
  selector: 'app-order-manage',
  standalone: true,
  imports: [
    DatePipe,
    CurrencyPipe,
    NgSwitch,
    NgSwitchCase,
    RouterLink,
    DropdownModule,
    ToastModule,
    FormsModule,
    ConfirmDialogModule,
    TableModule,
    ButtonModule,
    TooltipModule,
    CardModule,
    ReactiveFormsModule,
    InputTextModule,
    CalendarModule,
    DialogModule,
    NgClass,
    AutoCompleteModule,
    InputNumberModule,
    InputTextareaModule,
    RadioButtonModule,
    CommonModule
  ],
  providers: [
    MessageService,
    ToastService,
    ConfirmationService
  ],
  templateUrl: './order-manage.component.html',
  styleUrl: './order-manage.component.scss'
})
export class OrderManageComponent extends BaseComponent implements OnInit {
  public allOrders: HistoryOrderDto[] = [];
  public loading: boolean = true;
  public apiImage: string = environment.apiImage;
  public orderStateOptions: MenuItem[] = ORDER_STATUS_OPTIONS.map(opt => ({
    label: opt.label,
    value: opt.value
  }));
  public searchForm: FormGroup;
  public totalRecords: number = 0;
  public pageSize: number = 15;
  public page: number = 0;
  public sortField: string = 'orderDate';
  public sortOrder: number = -1; // -1 for desc, 1 for asc
  public showSearchDialog: boolean = false;
  public isStaff: boolean = false; // Flag to check if user is STAFF
  
  // Create new order dialog
  public showCreateOrderDialog: boolean = false;
  public createOrderForm: FormGroup;
  public selectedProducts: Array<{product: ProductDto, quantity: number}> = [];
  public productSearchResults: ProductDto[] = [];
  public filteredProducts: ProductDto[] = [];
  public showQuantityDialog: boolean = false;
  public selectedProductForQuantity: ProductDto | null = null;
  public quantityToAdd: number = 1;
  public shippingMethods = [
    { name: 'Nhanh', price: 0 },
    { name: 'Hỏa tốc', price: 60000 }
  ];
  
  // Address properties
  public provinces: AddressDropdownOption[] = [];
  public districts: AddressDropdownOption[] = [];
  public wards: AddressDropdownOption[] = [];
  public selectedProvince: number | null = null;
  public selectedDistrict: number | null = null;
  public selectedWard: string | null = null;

  public paymentMethods = [
    { name: 'Thanh toán khi nhận hàng', key: 'Cash' },
    { name: 'Thanh toán bằng thẻ Visa/Mastercard', key: 'Stripe' },
    { name: 'Thanh toán qua VNPAY', key: 'VNPAY' }
  ];
    
  public isCreatingOrder: boolean = false;

  constructor(
    private orderService: OrderService,
    private toastService: ToastService,
    private router: Router,
    private fb: FormBuilder,
    private productService: ProductService,
    private vietnamAddressService: VietnamAddressService,
    @Inject(PLATFORM_ID) private platformId: Object
  ) {
    super();
    this.searchForm = this.fb.group({
      keyword: [''],
      status: [''],
      dateRange: [[]]
    });
    
    this.createOrderForm = this.fb.group({
      fullname: ['', [Validators.required]],
      ehone_number: ['', [Validators.required, Validators.minLength(5)]],
      province: [null, [Validators.required]],
      district: [{value: null, disabled: true}, [Validators.required]],
      ward: [{value: null, disabled: true}, [Validators.required]],
      streetmber: ['', [Validators.required, Validators.minLength(5)]],
      address: ['', [Validators.required]],
      note: [''],
      shipping_method: ['Nhanh', [Validators.required]],
      payment_method: ['Cash', [Validators.required]],
      productSearch: ['']
    });

  }

  private checkPermissions(): boolean {
    console.log('OrderManageComponent.checkPermissions() - Starting permission check');
    
    if (!isPlatformBrowser(this.platformId)) {
      console.log('OrderManageComponent.checkPermissions() - Not browser platform, returning false');
      return false;
    }
    
    const userInfo = localStorage.getItem('userInfor');
    console.log('OrderManageComponent.checkPermissions() - userInfo from localStorage:', userInfo ? 'exists' : 'null');
    
    if (!userInfo) {
      console.log('OrderManageComponent.checkPermissions() - No userInfo, redirecting to login');
      this.toastService.fail('Vui lòng đăng nhập để tiếp tục');
      this.router.navigate(['/auth-login']);
      return false;
    }
    
    const user = JSON.parse(userInfo);
    console.log('OrderManageComponent.checkPermissions() - User object:', {
      hasRole: !!user.role,
      roleId: user.role?.id,
      roleName: user.role?.name
    });
    
    // Allow both ADMIN (roleId = 2) and STAFF (roleId = 3)
    if (!user.role || (user.role.id !== 2 && user.role.id !== 3)) {
      console.log('OrderManageComponent.checkPermissions() - Access denied. User role:', user.role);
      console.log('OrderManageComponent.checkPermissions() - Expected roleId: 2 (ADMIN) or 3 (STAFF), got:', user.role?.id);
      this.toastService.fail('Bạn không có quyền truy cập trang này');
      this.router.navigate(['/']);
      return false;
    }
    
    // Set isStaff flag
    this.isStaff = user.role.id === 3;
    
    console.log('OrderManageComponent.checkPermissions() - Access granted for roleId:', user.role.id, 'isStaff:', this.isStaff);
    return true;
  }

  ngOnInit(): void {
    console.log('OrderManageComponent.ngOnInit() - Component initializing');
    if(!this.checkPermissions()) {
      console.log('OrderManageComponent.ngOnInit() - Permission check failed, exiting');
      return;
    }
    console.log('OrderManageComponent.ngOnInit() - Permission check passed, loading orders');
    this.loadOrders();

    this.searchForm.valueChanges.pipe(
      debounceTime(500),
      distinctUntilChanged()
    ).subscribe(() => {
      this.page = 0;
      this.loadOrders();
    });
  }

  loadOrders(event?: any) {
    console.log('OrderManageComponent.loadOrders() - Starting to load orders');
    
    if(!this.checkPermissions()) {
      console.log('OrderManageComponent.loadOrders() - Permission check failed, exiting');
      return;
    }

    // If user is STAFF, use getAllOrders API which filters by assigned staff
    if (this.isStaff) {
      this.loading = true;
      this.orderService.getAllOrders().pipe(
        tap((orders: HistoryOrderDto[]) => {
          // Apply client-side filtering if needed
          let filteredOrders = orders;
          const { keyword, status, dateRange } = this.searchForm.value;
          
          if (keyword) {
            const searchLower = keyword.toLowerCase();
            filteredOrders = filteredOrders.filter(order => 
              order.fullname?.toLowerCase().includes(searchLower) ||
              order.email?.toLowerCase().includes(searchLower) ||
              order.phone_number?.includes(keyword) ||
              order.id?.toString().includes(keyword)
            );
          }
          
          if (status) {
            filteredOrders = filteredOrders.filter(order => order.status === status);
          }
          
          if (dateRange && dateRange[0] && dateRange[1]) {
            const startDate = new Date(dateRange[0]);
            const endDate = new Date(dateRange[1]);
            endDate.setHours(23, 59, 59, 999);
            
            filteredOrders = filteredOrders.filter(order => {
              const orderDate = new Date(order.order_date);
              return orderDate >= startDate && orderDate <= endDate;
            });
          }
          
          // Sort orders
          filteredOrders.sort((a, b) => {
            let field = this.sortField;
            if (field === 'orderDate') {
              field = 'order_date';
            }
            
            const aValue = a[field as keyof HistoryOrderDto];
            const bValue = b[field as keyof HistoryOrderDto];
            
            // Handle undefined/null values
            if (aValue === undefined || aValue === null) {
              return 1; // Put undefined values at the end
            }
            if (bValue === undefined || bValue === null) {
              return -1; // Put undefined values at the end
            }
            
            // Compare values
            if (this.sortOrder === -1) {
              return aValue > bValue ? -1 : aValue < bValue ? 1 : 0;
            } else {
              return aValue < bValue ? -1 : aValue > bValue ? 1 : 0;
            }
          });
          
          // Apply pagination
          const startIndex = this.page * this.pageSize;
          const endIndex = startIndex + this.pageSize;
          this.allOrders = filteredOrders.slice(startIndex, endIndex);
          this.totalRecords = filteredOrders.length;
          this.loading = false;
        }),
        catchError(err => {
          const errorMessage = err?.error?.message || 'Không thể tải danh sách đơn hàng';
          this.toastService.fail(errorMessage);
          this.loading = false;
          return of(err);
        })
      ).subscribe();
      return;
    }

    // For ADMIN, use the existing keyword search API
    let sortField = this.sortField;
    let sortOrder = this.sortOrder;

    if (event) {
      console.log('OrderManageComponent.loadOrders() - Event received:', event);
      if (event.first != null && event.rows != null) {
        this.page = event.first / event.rows;
        this.pageSize = event.rows;
      }
      if (event.sortField) {
        sortField = event.sortField;
        this.sortField = sortField;
      }
      if (event.sortOrder) {
        sortOrder = event.sortOrder;
        this.sortOrder = sortOrder;
      }
    }
    
    this.loading = true;
    const { keyword, status, dateRange } = this.searchForm.value;
    const startDate = dateRange && dateRange[0] ? this.formatDate(dateRange[0]) : null;
    const endDate = dateRange && dateRange[1] ? this.formatDate(dateRange[1]) : null;
    
    const safePage = this.page != null ? this.page : 0;
    const safePageSize = this.pageSize != null ? this.pageSize : 15;
    
    console.log('OrderManageComponent.loadOrders() - Loading orders with params:', {
      keyword,
      status,
      startDate,
      endDate,
      page: safePage,
      pageSize: safePageSize,
      sortField,
      sortOrder
    });
    const sortDir = sortOrder === -1 ? 'desc' : 'asc';

    this.orderService.getOrdersByKeyword(
      keyword || '', status, startDate, endDate, 
      safePage, safePageSize, 
      sortField, sortDir
    ).pipe(
        tap((response: OrderListResponse) => {
          this.allOrders = response.orders;
          this.totalRecords = response.totalPages * safePageSize;
          this.loading = false;
        }),
        catchError(err => {
          const errorMessage = err?.error?.message || 'Không thể tải danh sách đơn hàng';
          this.toastService.fail(errorMessage);
          this.loading = false;
          return of(err);
        })
      ).subscribe();
  }

  private mapSortField(frontendField: string): string {
    // Không cần thiết nữa, nhưng giữ lại để tránh lỗi nếu có tham chiếu ở đâu đó
    return 'orderDate';
  }

  resetSearch() {
    this.searchForm.reset({
      keyword: '',
      status: '',
      dateRange: []
    });
    this.page = 0;
    this.sortField = 'id';
    this.sortOrder = -1;
    this.loadOrders();
  }

  private formatDate(date: Date): string {
    const d = new Date(date);
    let month = '' + (d.getMonth() + 1);
    let day = '' + d.getDate();
    const year = d.getFullYear();
    if (month.length < 2) month = '0' + month;
    if (day.length < 2) day = '0' + day;
    return [year, month, day].join('-');
  }

  getPaymentMethodClass(paymentMethod: string): string {
    if (paymentMethod === 'Stripe Card Payment' || paymentMethod === 'Stripe (visa/mastercard)' || paymentMethod === 'Thanh toán thẻ thành công' || paymentMethod === 'Stripe') {
      return 'payment-stripe';
    }
    if (paymentMethod === 'Pending Stripe Payment') {
      return 'payment-pending';
    }
    if (paymentMethod === 'VNPAY' || paymentMethod === 'VnPay' || paymentMethod?.toLowerCase() === 'vnpay') {
      return 'payment-vnpay';
    }
    if (paymentMethod === 'Thanh toán khi nhận hàng' || paymentMethod === 'Cash' || paymentMethod === 'Tiền mặt') {
      return 'payment-cod';
    }
    return 'payment-default';
  }

  getPaymentMethodIcon(paymentMethod: string): string {
    if (paymentMethod === 'Stripe Card Payment' || paymentMethod === 'Stripe (visa/mastercard)' || paymentMethod === 'Thanh toán thẻ thành công' || paymentMethod === 'Stripe') {
      return 'pi-credit-card';
    }
    if (paymentMethod === 'VNPAY' || paymentMethod === 'VnPay' || paymentMethod?.toLowerCase() === 'vnpay') {
      return 'pi-wallet';
    }
    if (paymentMethod === 'Thanh toán khi nhận hàng' || paymentMethod === 'Cash' || paymentMethod === 'Tiền mặt') {
      return 'pi-money-bill';
    }
    return 'pi-info-circle';
  }

  getStatusIcon(status: string): string {
    switch (status) {
      case 'pending': return 'pi-clock';
      case 'processing': return 'pi-cog';
      case 'shipped': return 'pi-truck';
      case 'delivered': return 'pi-check-circle';
      case 'cancelled': return 'pi-times-circle';
      default: return 'pi-info-circle';
    }
  }

  getPaymentMethodLabel(paymentMethod?: string): string {
    if (!paymentMethod) return 'N/A';
    const methodMap: { [key: string]: string } = {
      'Cash': 'Tiền mặt',
      'Banking': 'Chuyển khoản',
      'Stripe': 'Stripe (visa/mastercard)',
      'VNPAY': 'VNPay',
      'Stripe Card Payment': 'Stripe (visa/mastercard)',
      'Stripe (visa/mastercard)': 'Stripe (visa/mastercard)',
      'Thanh toán thẻ thành công': 'Stripe (visa/mastercard)',
      'Pending Stripe Payment': 'Chờ thanh toán thẻ',
      'Thanh toán khi nhận hàng': 'Tiền mặt'
    };
    return methodMap[paymentMethod] || paymentMethod;
  }

  getShippingMethodLabel(shippingMethod?: string): string {
    if (!shippingMethod) return 'N/A';
    const methodMap: { [key: string]: string } = {
      'Tiêu chuẩn': 'Tiêu chuẩn',
      'Nhanh': 'Nhanh',
      'Hỏa tốc': 'Hỏa tốc',
      'Standard': 'Tiêu chuẩn',
      'Fast': 'Nhanh',
      'Express': 'Hỏa tốc'
    };
    return methodMap[shippingMethod] || shippingMethod;
  }

  onOrderStateChange(event: any, orderId: number) {
    if(!this.checkPermissions()) {
      return;
    }
    
    this.orderService.changeOrderState(event.value, orderId).pipe(
      tap((res: {message: string}) => {
        this.toastService.success(res.message);
        this.loadOrders();
      }),
      catchError((err) => {
        if (err.status === 403) {
          this.toastService.fail('Bạn không có quyền thực hiện thao tác này');
          this.router.navigate(['/']);
        } else {
          const errorMessage = err?.error?.message || 'Không thể cập nhật trạng thái đơn hàng';
          this.toastService.fail(errorMessage);
        }
        return of(err);
      })
    ).subscribe();
  }

  getPlaceholderByOrderStatus(status: string): string {
    return getOrderStatusLabel(status);
  }

  // Create new order methods
  openCreateOrderDialog() {
    this.showCreateOrderDialog = true;
    this.selectedProducts = [];
    this.createOrderForm.reset({
      shipping_method: 'Nhanh',
      payment_method: 'Cash',
      productSearch: ''
    });
    this.selectedProductForQuantity = null;
    this.quantityToAdd = 1;
    this.showQuantityDialog = false;
    this.loadAllProducts();
    this.loadProvinces();
  }

  // Address methods
  loadProvinces() {
    this.vietnamAddressService.getProvinces().subscribe({
      next: (provinces) => {
        this.provinces = provinces;
      },
      error: (err) => {
        console.error('Error loading provinces:', err);
        this.toastService.fail('Không thể tải danh sách tỉnh/thành phố');
      }
    });
  }

  onProvinceChange(event: any) {
    const provinceId = event.value;
    this.selectedProvince = provinceId;
    this.selectedDistrict = null;
    this.selectedWard = null;
    this.districts = [];
    this.wards = [];
    
    this.createOrderForm.patchValue({
      district: null,
      ward: null
    });
    this.createOrderForm.get('district')?.disable();
    this.createOrderForm.get('ward')?.disable();

    if (provinceId) {
      this.createOrderForm.get('district')?.enable();
      this.vietnamAddressService.getDistricts(provinceId).subscribe({
        next: (districts) => {
          this.districts = districts;
        },
        error: (err) => {
          console.error('Error loading districts:', err);
          this.toastService.fail('Không thể tải danh sách quận/huyện');
        }
      });
    }
  }

  onDistrictChange(event: any) {
    const districtId = event.value;
    this.selectedDistrict = districtId;
    this.selectedWard = null;
    this.wards = [];
    
    this.createOrderForm.patchValue({
      ward: null
    });
    this.createOrderForm.get('ward')?.disable();

    if (districtId) {
      this.createOrderForm.get('ward')?.enable();
      this.vietnamAddressService.getWards(districtId).subscribe({
        next: (wards) => {
          this.wards = wards;
        },
        error: (err) => {
          console.error('Error loading wards:', err);
          this.toastService.fail('Không thể tải danh sách phường/xã');
        }
      });
    }
  }

  onWardChange(event: any) {
    this.selectedWard = event.value;
  }

  private buildCompleteAddress(): Observable<string> {
    const street = this.createOrderForm.value.street || '';
    const wardCode = this.createOrderForm.value.ward;
    const districtId = this.createOrderForm.value.district;
    const provinceId = this.createOrderForm.value.province;

    if (!wardCode || !districtId || !provinceId) {
      return of(street);
    }

    return forkJoin({
      ward: this.vietnamAddressService.getWardName(wardCode),
      district: this.vietnamAddressService.getDistrictName(districtId),
      province: this.vietnamAddressService.getProvinceName(provinceId)
    }).pipe(
      map(({ ward, district, province }) => {
        const parts = [street, ward, district, province].filter(part => part && part.trim());
        return parts.join(', ');
      }),
      catchError(() => {
        return of(street);
      })
    );
  }

  loadAllProducts() {
    this.productService.getAllProduct().pipe(
      tap((response) => {
        this.productSearchResults = response.products || [];
        this.filteredProducts = this.productSearchResults;
      }),
      catchError((err) => {
        console.error('Error loading products:', err);
        return of({ products: [] });
      })
    ).subscribe();
  }

  searchProducts(event: any) {
    const query = event.query?.toLowerCase() || '';
    if (!query) {
      this.filteredProducts = this.productSearchResults;
      return;
    }
    
    this.filteredProducts = this.productSearchResults.filter(product =>
      product.name.toLowerCase().includes(query) ||
      product.id.toString().includes(query)
    );
  }

  onProductSelect(event: any) {
    // When user selects a product from autocomplete
    if (event && event.id) {
      this.addProductToOrder(event);
    }
  }

  addProductToOrder(product: ProductDto, quantity: number = 1) {
    // Check stock
    if (product.quantity <= 0) {
      this.toastService.fail('Sản phẩm đã hết hàng');
      return;
    }

    // Check if product already added - if yes, increase quantity
    const existingIndex = this.selectedProducts.findIndex(p => p.product.id === product.id);
    if (existingIndex >= 0) {
      const currentQuantity = this.selectedProducts[existingIndex].quantity;
      const newQuantity = currentQuantity + quantity;
      
      if (newQuantity > product.quantity) {
        this.toastService.fail(`Số lượng vượt quá tồn kho (${product.quantity}). Hiện tại đã có ${currentQuantity} sản phẩm`);
        return;
      }
      
      this.selectedProducts[existingIndex].quantity = newQuantity;
      this.toastService.success(`Đã tăng số lượng ${product.name} lên ${newQuantity}`);
    } else {
      // Add new product
      if (quantity > product.quantity) {
        this.toastService.fail(`Số lượng vượt quá tồn kho (${product.quantity})`);
        quantity = product.quantity;
      }
      
      this.selectedProducts.push({
        product: product,
        quantity: quantity
      });
      this.toastService.success(`Đã thêm ${product.name} vào đơn hàng`);
    }

    // Clear search
    this.createOrderForm.patchValue({ productSearch: null });
    this.filteredProducts = this.productSearchResults;
  }

  addProductWithQuantity(product: ProductDto) {
    // Open dialog to select quantity
    this.selectedProductForQuantity = product;
    this.showQuantityDialog = true;
    this.quantityToAdd = 1;
  }

  confirmAddProductWithQuantity() {
    if (this.selectedProductForQuantity && this.quantityToAdd > 0) {
      this.addProductToOrder(this.selectedProductForQuantity, this.quantityToAdd);
      this.showQuantityDialog = false;
      this.selectedProductForQuantity = null;
      this.quantityToAdd = 1;
    }
  }

  removeProductFromOrder(index: number) {
    this.selectedProducts.splice(index, 1);
  }

  updateProductQuantity(index: number, quantity: number | string | null) {
    const numQuantity = typeof quantity === 'number' ? quantity : (quantity ? Number(quantity) : 1);
    
    if (isNaN(numQuantity) || numQuantity <= 0) {
      this.toastService.fail('Số lượng phải lớn hơn 0');
      return;
    }
    
    const product = this.selectedProducts[index].product;
    if (numQuantity > product.quantity) {
      this.toastService.fail(`Số lượng vượt quá tồn kho (${product.quantity})`);
      this.selectedProducts[index].quantity = product.quantity;
      return;
    }
    
    this.selectedProducts[index].quantity = numQuantity;
  }

  calculateSubTotal(): number {
    return this.selectedProducts.reduce((total, item) => {
      return total + (item.product.price * item.quantity);
    }, 0);
  }

  getShippingCost(): number {
    const selectedShipping = this.shippingMethods.find(
      m => m.name === this.createOrderForm.get('shipping_method')?.value
    );
    return selectedShipping?.price || 0;
  }

  calculateTotal(): number {
    return this.calculateSubTotal() + this.getShippingCost();
  }

  getProductImageUrl(product: ProductDto): string {
    if (product.thumbnail && product.thumbnail.trim() !== '' && product.thumbnail !== 'null') {
      return this.apiImage + product.thumbnail;
    }
    if (product.product_images && product.product_images.length > 0 && product.product_images[0]?.image_url) {
      return this.apiImage + product.product_images[0].image_url;
    }
    return 'assets/images/no-image.png';
  }

  createOrder() {
    if (this.createOrderForm.invalid) {
      this.toastService.fail('Vui lòng điền đầy đủ thông tin');
      return;
    }

    if (this.selectedProducts.length === 0) {
      this.toastService.fail('Vui lòng chọn ít nhất một sản phẩm');
      return;
    }

    this.isCreatingOrder = true;
    const formValue = this.createOrderForm.value;
    
    this.buildCompleteAddress().subscribe(fullAddress => {
        const orderData = {
          fullname: formValue.fullname,
          email: formValue.email,
          phone_number: formValue.phone_number,
          address: fullAddress,
          district_id: formValue.district,
          ward_code: formValue.ward,
          note: formValue.note || '',
          shipping_method: formValue.shipping_method,
          payment_method: formValue.payment_method,
          cart_items: this.selectedProducts.map(item => ({
            product_id: item.product.id,
            quantity: item.quantity,
            size: 0 // Khóa điện tử không có size
          })),
          sub_total: this.calculateSubTotal(),
          total_money: this.calculateTotal()
        };

        this.orderService.postOrder(orderData).pipe(
          tap(() => {
            this.toastService.success('Tạo đơn hàng thành công!');
            this.showCreateOrderDialog = false;
            this.loadOrders(); // Reload orders list
          }),
          catchError((err) => {
            const errorMessage = err?.error?.message || err?.error || 'Không thể tạo đơn hàng';
            this.toastService.fail(errorMessage);
            return of(err);
          }),
          finalize(() => {
            this.isCreatingOrder = false;
          })
        ).subscribe();
    });
  }

}
