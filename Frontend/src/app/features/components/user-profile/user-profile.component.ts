import { Component, OnInit, Inject, PLATFORM_ID } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators, ValidationErrors, AbstractControl } from '@angular/forms';
import { UserService } from '../../../core/services/user.service';
import { UserDto } from '../../../core/dtos/user.dto';
import { CommonModule, CurrencyPipe, DatePipe, isPlatformBrowser } from '@angular/common';
import { Router } from '@angular/router';
import { ToastService } from '../../../core/services/toast.service';
import { MessageService } from 'primeng/api';
import { catchError, of, takeUntil } from 'rxjs';
import { BaseComponent } from '../../../core/commonComponent/base.component';
import { ReturnService, ReturnRequestResponse } from '../../../core/services/return.service';
import { OrderService } from '../../../core/services/order.service';
import { OrderHistoryResponse } from '../../../core/responses/order-history.response';
import { environment } from '../../../../environments/environment';
import { DialogService } from 'primeng/dynamicdialog';
import { VnpayService } from '../../../core/services/vnpay.service';
import { ORDER_STATUS_OPTIONS, getOrderStatusLabel, getOrderStatusSeverity } from '../../../core/constants/order-status.constants';

// PrimeNG Modules
import { TabViewModule } from 'primeng/tabview';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { ToastModule } from 'primeng/toast';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { TagModule } from 'primeng/tag';
import { PaginatorModule, PaginatorState } from 'primeng/paginator';
import { DropdownModule } from 'primeng/dropdown';
import { FormsModule } from '@angular/forms';
import { TooltipModule } from 'primeng/tooltip';
import { DialogModule } from 'primeng/dialog';
import { StripePaymentComponent } from '../stripe-payment/stripe-payment.component';

@Component({
  selector: 'app-user-profile',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    TabViewModule,
    ButtonModule,
    InputTextModule,
    ToastModule,
    ProgressSpinnerModule,
    TagModule,
    PaginatorModule,
    DropdownModule,
    FormsModule,
    TooltipModule,
    DialogModule,
    CurrencyPipe,
    DatePipe,
    StripePaymentComponent
  ],
  providers: [
    MessageService,
    ToastService,
    DialogService
  ],
  templateUrl: './user-profile.component.html',
  styleUrls: ['./user-profile.component.scss']
})
export class UserProfileComponent extends BaseComponent implements OnInit {
  // Profile Form
  profileForm: FormGroup;
  user: UserDto | null = null;
  isEditMode = false;

  // Change Password Form
  changePasswordForm: FormGroup;
  isPasswordLoading = false;
  showCurrentPassword = false;
  showNewPassword = false;
  showConfirmPassword = false;

  // Order History
  historyOrder: OrderHistoryResponse[] = [];
  filteredOrders: OrderHistoryResponse[] = [];
  pagedOrders: OrderHistoryResponse[] = [];
  orderLoading = true;
  apiImage = environment.apiImage;
  searchTerm: string = '';
  statusOptions = ORDER_STATUS_OPTIONS;
  selectedStatus: string = '';
  rows: number = 8;
  currentPage: number = 0;
  showStripeDialog: boolean = false;
  selectedOrderForPayment: OrderHistoryResponse | null = null;

  // Returns
  myRequests: ReturnRequestResponse[] = [];
  returnsLoading = true;

  private readonly isBrowser: boolean;

  onTabChange(event: any) {
    // Index 3 corresponds to the Logout tab (after merging Profile and Password tabs)
    if (event.index === 3) {
      this.signOut();
    }
  }

  constructor(
    private fb: FormBuilder,
    private userService: UserService,
    private toastService: ToastService,
    private router: Router,
    private returnService: ReturnService,
    private orderService: OrderService,
    private dialogService: DialogService,
    private vnpayService: VnpayService,
    @Inject(PLATFORM_ID) private platformId: Object
  ) {
    super();
    this.isBrowser = isPlatformBrowser(this.platformId);
    
    // Profile Form
    this.profileForm = this.fb.group({
      fullname: [{ value: '', disabled: true }, Validators.required],
      email: [{ value: '', disabled: true }, [Validators.required, Validators.email]],
      phone_number: [{ value: '', disabled: true }, Validators.required],
      address: [{ value: '', disabled: true }, Validators.required],
    });

    // Change Password Form
    this.changePasswordForm = this.fb.group({
      currentPassword: ['', [Validators.required]],
      newPassword: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', [Validators.required]]
    }, {
      validators: this.passwordMatchValidator
    });
  }

  ngOnInit(): void {
    if (!this.isBrowser) return;
    this.loadUserProfile();
    this.loadOrderHistory();
    this.loadMyReturns();
  }

  // ========== Profile Methods ==========
  loadUserProfile(): void {
    this.userService.getInforUser().subscribe(
      (response: UserDto) => {
        this.user = response;
        if (this.user) {
          this.profileForm.patchValue({
            fullname: this.user.fullname,
            email: this.user.email,
            phone_number: this.user.phone_number,
            address: this.user.address,
          });
        }
      }
    );
  }

  enableEditMode(): void {
    this.isEditMode = true;
    this.profileForm.get('fullname')?.enable();
    this.profileForm.get('email')?.enable();
    this.profileForm.get('address')?.enable();
  }

  cancelEdit(): void {
    this.isEditMode = false;
    if (this.user) {
      this.profileForm.patchValue({
        fullname: this.user.fullname,
        email: this.user.email,
        phone_number: this.user.phone_number,
        address: this.user.address,
      });
    }
    this.profileForm.get('fullname')?.disable();
    this.profileForm.get('email')?.disable();
    this.profileForm.get('phone_number')?.disable();
    this.profileForm.get('address')?.disable();
  }

  onSubmitProfile(): void {
    if (this.profileForm.valid && this.user) {
      const updatedData = {
        ...this.profileForm.getRawValue(),
        id: this.user.id
      };
      this.userService.updateUser(updatedData).subscribe(
        (response: any) => {
          this.toastService.success('Cập nhật thông tin thành công');
          this.user = { ...this.user, ...this.profileForm.getRawValue() } as UserDto;
          this.isEditMode = false;
          this.profileForm.get('fullname')?.disable();
          this.profileForm.get('email')?.disable();
          this.profileForm.get('phone_number')?.disable();
          this.profileForm.get('address')?.disable();
        },
        (error: any) => {
          this.toastService.fail('Cập nhật thông tin thất bại');
        }
      );
    }
  }

  // ========== Change Password Methods ==========
  toggleCurrentPassword(): void {
    this.showCurrentPassword = !this.showCurrentPassword;
  }

  toggleNewPassword(): void {
    this.showNewPassword = !this.showNewPassword;
  }

  toggleConfirmPassword(): void {
    this.showConfirmPassword = !this.showConfirmPassword;
  }

  private passwordMatchValidator(group: AbstractControl): ValidationErrors | null {
    const newPassword = group.get('newPassword');
    const confirmPassword = group.get('confirmPassword');
    
    if (!newPassword || !confirmPassword) {
      return null;
    }
    
    if (newPassword.value !== confirmPassword.value) {
      confirmPassword.setErrors({ passwordMismatch: true });
      return { passwordMismatch: true };
    } else {
      if (confirmPassword.hasError('passwordMismatch')) {
        confirmPassword.setErrors(null);
      }
    }
    return null;
  }

  onSubmitPassword(): void {
    if (this.changePasswordForm.invalid) {
      this.changePasswordForm.markAllAsTouched();
      this.toastService.fail('Vui lòng kiểm tra lại thông tin.');
      return;
    }

    const currentPassword = this.changePasswordForm.value.currentPassword;
    const newPassword = this.changePasswordForm.value.newPassword;
    const confirmPassword = this.changePasswordForm.value.confirmPassword;

    if (newPassword !== confirmPassword) {
      this.toastService.fail('Mật khẩu mới và xác nhận mật khẩu không khớp.');
      return;
    }

    if (currentPassword === newPassword) {
      this.toastService.fail('Mật khẩu mới phải khác với mật khẩu hiện tại.');
      return;
    }

    this.isPasswordLoading = true;
    this.userService.changePassword(currentPassword, newPassword).pipe(
      catchError((error) => {
        this.isPasswordLoading = false;
        if (error.status === 400) {
          this.toastService.fail('Mật khẩu hiện tại không chính xác.');
        } else {
          this.toastService.fail(error.error?.message || 'Đã xảy ra lỗi. Vui lòng thử lại.');
        }
        return of();
      }),
      takeUntil(this.destroyed$)
    ).subscribe((response) => {
      if (response) {
        this.isPasswordLoading = false;
        this.toastService.success(response.message || 'Đổi mật khẩu thành công.');
        this.changePasswordForm.reset();
      }
    });
  }

  // ========== Order History Methods ==========
  loadOrderHistory(): void {
    this.orderLoading = true;
    const token = localStorage.getItem('token') as string;
    this.orderService.findByUserId(token).subscribe({
      next: (data: any) => {
        this.historyOrder = data.sort((a: OrderHistoryResponse, b: OrderHistoryResponse) => b.id - a.id);
        this.applyFilters();
        this.orderLoading = false;
      },
      error: (err: any) => {
        console.error('Failed to load order history', err);
        this.toastService.fail('Không thể tải lịch sử đơn hàng.');
        this.orderLoading = false;
      }
    });
  }

  applyFilters(): void {
    let orders = [...this.historyOrder];

    if (this.selectedStatus) {
      orders = orders.filter(order => order.status === this.selectedStatus);
    }

    if (this.searchTerm.trim()) {
      const lowercasedTerm = this.searchTerm.toLowerCase();
      orders = orders.filter(order =>
        order.id.toString().includes(lowercasedTerm) ||
        order.product_name.toLowerCase().includes(lowercasedTerm) ||
        order.fullname.toLowerCase().includes(lowercasedTerm)
      );
    }

    this.filteredOrders = orders;
    this.paginate({ first: 0, rows: this.rows });
  }

  onSearchChange(): void {
    this.applyFilters();
  }

  onStatusChange(): void {
    this.applyFilters();
  }

  clearFilters(): void {
    this.searchTerm = '';
    this.selectedStatus = '';
    this.applyFilters();
  }

  paginate(event: PaginatorState | { first: number, rows: number }): void {
    const first = event.first ?? 0;
    const rows = event.rows ?? this.rows;
    this.pagedOrders = this.filteredOrders.slice(first, first + rows);
  }

  getStatusLabel(status: string): string {
    return getOrderStatusLabel(status);
  }

  getStatusSeverity(status: string): 'info' | 'warning' | 'success' | 'danger' | 'primary' {
    return getOrderStatusSeverity(status);
  }

  viewOrderDetail(orderId: number): void {
    this.router.navigate(['/order-detail', orderId]);
  }

  canReturnOrder(order: OrderHistoryResponse): boolean {
    if (order.status !== 'delivered') return false;
    const deliveryDate = new Date(order.order_date);
    const today = new Date();
    const diffTime = Math.abs(today.getTime() - deliveryDate.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays <= 7;
  }

  requestReturn(orderId: number): void {
    this.router.navigate(['/return-request', orderId]);
  }

  getRoundedAmount(amount: number): number {
    return Math.round(amount);
  }

  retryPayment(order: OrderHistoryResponse): void {
    this.selectedOrderForPayment = order;
    this.showStripeDialog = true;
  }

  onStripePaymentSuccess(paymentIntent: any): void {
    this.showStripeDialog = false;
    this.toastService.success('Thanh toán lại thành công!');
    this.loadOrderHistory();
  }

  onStripePaymentError(error: string): void {
    this.showStripeDialog = false;
    this.toastService.fail(`Thanh toán lại thất bại: ${error}`);
  }

  onStripePaymentCancel(): void {
    this.showStripeDialog = false;
    this.toastService.fail('Bạn đã hủy phiên thanh toán.');
  }

  retryVnpayPayment(order: OrderHistoryResponse): void {
    const paymentData = {
      amount: Math.round(order.total_money),
      order_info: `Thanh toan lai don hang ${order.id}`,
      order_id: order.id
    };

    this.vnpayService.createVnpayPayment(paymentData).subscribe({
      next: (response) => {
        if (response.url) {
          window.location.href = response.url;
        } else {
          this.toastService.fail('Không thể tạo link thanh toán VNPAY.');
        }
      },
      error: (err) => {
        this.toastService.fail(`Lỗi khi tạo thanh toán VNPAY: ${err.error?.message || 'Lỗi không xác định'}`);
      }
    });
  }

  // ========== Returns Methods ==========
  loadMyReturns(): void {
    this.returnsLoading = true;
    this.returnService.getMyReturnRequests().subscribe({
      next: (data) => {
        this.myRequests = data.sort((a, b) => new Date(b.requested_at).getTime() - new Date(a.requested_at).getTime());
        this.returnsLoading = false;
      },
      error: (err) => {
        this.returnsLoading = false;
        this.toastService.fail('Không thể tải danh sách trả hàng. ' + (err.error?.message || ''));
      }
    });
  }

  getStatusClass(status: string): string {
    return `status-${status.toLowerCase()}`;
  }

  getStatusText(status: string): string {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Đang chờ xử lý';
      case 'approved':
        return 'Đã chấp nhận';
      case 'rejected':
        return 'Đã từ chối';
      case 'refunded':
        return 'Đã hoàn tiền';
      case 'awaiting_refund':
        return 'Chờ hoàn tiền';
      default:
        return status;
    }
  }

  getReturnStatusSeverity(status: string): 'info' | 'warning' | 'success' | 'danger' | 'primary' {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'warning';
      case 'approved':
        return 'success';
      case 'rejected':
        return 'danger';
      case 'refunded':
        return 'success';
      case 'awaiting_refund':
        return 'info';
      default:
        return 'info';
    }
  }

  viewReturnOrderDetail(orderId: number): void {
    this.router.navigate([`/order-detail/${orderId}`]);
  }

  navigateToChangePassword(): void {
    this.router.navigate(['/change-password']);
  }

  // ========== Sign Out ==========
  signOut(): void {
    if (this.isBrowser) {
      localStorage.removeItem("token");
      localStorage.removeItem("roleId");
      localStorage.removeItem("userInfor");
      localStorage.removeItem("productOrder");
      this.toastService.success('Đăng xuất thành công');
      setTimeout(() => {
        window.location.href = "/Home";
      }, 500);
    }
  }
}
