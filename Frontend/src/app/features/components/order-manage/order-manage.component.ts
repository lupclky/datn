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
import { catchError, of, tap, debounceTime, distinctUntilChanged, switchMap, finalize } from 'rxjs';
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
  public orderStateOptions: MenuItem[] = [
    { label: 'Tất cả', value: '' },
    { label: 'Đang chờ', value: 'pending' },
    { label: 'Đang xử lý', value: 'processing' },
    { label: 'Đang được giao', value: 'shipped' },
    { label: 'Đã được giao', value: 'delivered' },
    { label: 'Đã hủy', value: 'canceled' },
    { label: 'Thanh toán thành công', value: 'paid' },
    { label: 'Thanh toán thất bại', value: 'payment_failed' }
  ];
  public searchForm: FormGroup;
  public totalRecords: number = 0;
  public pageSize: number = 15;
  public page: number = 0;
  public sortField: string = 'id';
  public sortOrder: number = -1; // -1 for desc, 1 for asc
  public showSearchDialog: boolean = false;
  
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
    { name: 'Tiêu chuẩn', price: 30000 },
    { name: 'Nhanh', price: 40000 },
    { name: 'Hỏa tốc', price: 60000 }
  ];
  public paymentMethods = [
    { name: 'Thanh toán khi nhận hàng', key: 'Cash' },
    { name: 'Chuyển khoản ngân hàng', key: 'Banking' },
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
      email: ['', [Validators.required, Validators.email]],
      phone_number: ['', [Validators.required, Validators.minLength(5)]],
      address: ['', [Validators.required]],
      note: [''],
      shipping_method: ['Tiêu chuẩn', [Validators.required]],
      payment_method: ['Cash', [Validators.required]],
      productSearch: ['']
    });
  }

  private checkPermissions(): boolean {
    if (!isPlatformBrowser(this.platformId)) {
      return false;
    }
    const userInfo = localStorage.getItem('userInfor');
    if (!userInfo) {
      this.toastService.fail('Vui lòng đăng nhập để tiếp tục');
      this.router.navigate(['/auth-login']);
      return false;
    }
    const user = JSON.parse(userInfo);
    if (!user.role || user.role.id !== 2) { // 2 is admin role
      this.toastService.fail('Bạn không có quyền truy cập trang này');
      this.router.navigate(['/']);
      return false;
    }
    return true;
  }

  ngOnInit(): void {
    if(!this.checkPermissions()) {
      return;
    }

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
    if(!this.checkPermissions()) {
      return;
    }

    let sortField = this.sortField;
    let sortOrder = this.sortOrder;

    if (event) {
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
    if (paymentMethod === 'Stripe Card Payment') {
      return 'payment-method-stripe-success';
    }
    if (paymentMethod === 'Pending Stripe Payment') {
      return 'payment-method-stripe-pending';
    }
    if (paymentMethod === 'Thanh toán khi nhận hàng') {
      return 'payment-method-cod';
    }
    return 'payment-method-default';
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
    const selectedStatus = this.orderStateOptions.find(opt => opt['value'] === status);
    return selectedStatus ? selectedStatus.label as string : 'Trạng thái';
  }

  // Create new order methods
  openCreateOrderDialog() {
    this.showCreateOrderDialog = true;
    this.selectedProducts = [];
    this.createOrderForm.reset({
      shipping_method: 'Tiêu chuẩn',
      payment_method: 'Cash',
      productSearch: ''
    });
    this.selectedProductForQuantity = null;
    this.quantityToAdd = 1;
    this.showQuantityDialog = false;
    this.loadAllProducts();
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
    
    const orderData = {
      fullname: formValue.fullname,
      email: formValue.email,
      phone_number: formValue.phone_number,
      address: formValue.address,
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
  }
}
