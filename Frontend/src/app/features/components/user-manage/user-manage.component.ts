import { Component, Inject, OnInit, PLATFORM_ID } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { CommonModule, DatePipe, isPlatformBrowser } from '@angular/common';
import { BaseComponent } from '../../../core/commonComponent/base.component';
import { UserService } from '../../../core/services/user.service';
import { catchError, filter, forkJoin, of, takeUntil, tap } from 'rxjs';
import { UserDto } from '../../../core/dtos/user.dto';
import { registerReq } from '../../../core/types/registerReq';

// PrimeNG imports
import { TableModule } from 'primeng/table';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { DropdownModule } from 'primeng/dropdown';
import { DialogModule } from 'primeng/dialog';
import { ToastModule } from 'primeng/toast';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { CardModule } from 'primeng/card';
import { TagModule } from 'primeng/tag';
import { TooltipModule } from 'primeng/tooltip';
import { CalendarModule } from 'primeng/calendar';
import { InputTextareaModule } from 'primeng/inputtextarea';
import { RatingModule } from 'primeng/rating';
import { MessageService, ConfirmationService } from 'primeng/api';
import { OrderService } from '../../../core/services/order.service';
import { ReviewService, Review } from '../../../core/services/review.service';
import { ProductService } from '../../../core/services/product.service';
import { HistoryOrderDto } from '../../../core/dtos/HistoryOrder.dto';
import { ProductDto } from '../../../core/dtos/product.dto';
import { AllProductDto } from '../../../core/dtos/AllProduct.dto';
import { switchMap } from 'rxjs';
import { Observable } from 'rxjs';

export interface UserOption {
  label: string;
  value: any;
}

@Component({
  selector: 'app-user-manage',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    DatePipe,
    TableModule,
    ButtonModule,
    InputTextModule,
    DropdownModule,
    DialogModule,
    ToastModule,
    ConfirmDialogModule,
    CardModule,
    TagModule,
    TooltipModule,
    CalendarModule,
    InputTextareaModule,
    RatingModule
  ],
  providers: [MessageService, ConfirmationService],
  templateUrl: './user-manage.component.html',
  styleUrls: ['./user-manage.component.scss']
})
export class UserManageComponent extends BaseComponent implements OnInit {
  public userOptions: UserOption[] = [
    { label: 'Người dùng', value: 1 },
    { label: 'Quản trị viên', value: 2 },
    { label: 'Nhân viên', value: 3 },
  ];

  public statusOptions = [
    { label: 'Hoạt động', value: true },
    { label: 'Vô hiệu', value: false }
  ];

  searchTerm: string = '';
  filterLsedUsers: any[] = [];
  loading: boolean = false;
  showSearchDialog: boolean = false;
  selectedRole: any = null;
  selectedStatus: any = null;

  public roleMap = [
    'Người dùng',
    'Quản trị viên',
    'Nhân viên',
  ];

  public userId!: number;
  public users: UserDto[] = [];

  // Properties for edit functionality
  public showEditDialog = false;
  public showAddDialog = false;
  public editingUser: UserDto = {} as UserDto;
  public originalUser: UserDto = {} as UserDto;
  public addUser: registerReq & { role_id?: number } = {} as registerReq & { role_id?: number };

  // Order and Comment History
  public showOrderHistoryDialog = false;
  public showCommentHistoryDialog = false;
  public selectedUser: UserDto | null = null;
  public userOrderHistory: HistoryOrderDto[] = [];
  public userComments: any[] = [];
  public loadingOrderHistory = false;
  public loadingCommentHistory = false;

  displayedColumns: string[] = [
    'fullname',
    'phone',
    'email',
    'address',
    'dateOfBirth',
    'status',
    'role',
    'actions'
  ];

  get filteredUsers(): UserDto[] {
    if (!this.users) return [];
    
    let filtered = this.users.filter(user => {
      // Filter out current user if userId is set
      if (this.userId && user?.id === this.userId) {
        return false;
      }
      return user?.id != null;
    });
    
    // Apply search filter
    if (this.searchTerm && this.searchTerm.trim()) {
      const searchLower = this.searchTerm.toLowerCase().trim();
      filtered = filtered.filter(user => 
        user.fullname?.toLowerCase().includes(searchLower) ||
        user.phone_number?.toLowerCase().includes(searchLower) ||
        user.email?.toLowerCase().includes(searchLower) ||
        user.address?.toLowerCase().includes(searchLower)
      );
    }
    
    // Apply role filter
    if (this.selectedRole !== null && this.selectedRole !== undefined) {
      filtered = filtered.filter(user => user.role?.id === this.selectedRole);
    }
    
    // Apply status filter
    if (this.selectedStatus !== null && this.selectedStatus !== undefined) {
      filtered = filtered.filter(user => user.is_active === this.selectedStatus);
    }
    
    return filtered;
  }

  get totalRecords(): number {
    return this.filteredUsers.length;
  }

  constructor(
    private userService: UserService,
    private orderService: OrderService,
    private reviewService: ReviewService,
    private productService: ProductService,
    private messageService: MessageService,
    private confirmationService: ConfirmationService,
    @Inject(PLATFORM_ID) private platformId: Object
  ) {
    super();
    if (typeof localStorage !== 'undefined') {
      this.userId = parseInt(JSON.parse(localStorage.getItem("userInfor") || '{}').id);
    }
  }

  ngOnInit(): void {
    if (isPlatformBrowser(this.platformId)) {
      this.getUsers();
    }
  }

  private getUsers(): void {
    this.loading = true;
    this.userService.getAllUser().pipe(
      filter((users: UserDto[]) => !!users),
      tap((users: UserDto[]) => {
        this.users = users;
        this.filterLsedUsers = this.users;
        this.loading = false;
      }),
      catchError(err => {
        this.loading = false;
        this.showErrorMessage('Không thể tải danh sách người dùng');
        return of([]);
      })
    ).subscribe();
  }

  // Search and filter methods
  resetSearch(): void {
    this.searchTerm = '';
    this.selectedRole = null;
    this.selectedStatus = null;
  }

  applyFilter(): void {
    // The filtering is automatically applied via the getter
    // This method can be used for additional logic if needed
  }

  filterUsers(): void {
    // This method is called when searchTerm changes
    // The actual filtering is done in the filteredUsers getter
  }

  // Edit user functionality
  editUser(user: UserDto): void {
    this.editingUser = {
      ...user,
      date_of_birth: user.date_of_birth ? new Date(user.date_of_birth) : new Date()
    };
    this.originalUser = { ...user };
    this.showEditDialog = true;
  }

  closeEditDialog(): void {
    this.showEditDialog = false;
    this.editingUser = {} as UserDto;
    this.originalUser = {} as UserDto;
  }

  closeAddDialog(): void {
    this.showAddDialog = false;
    this.addUser = {} as registerReq;
  }

  saveUser(): void {
    if (!this.validateUserData()) {
      return;
    }

    // Prepare data for API
    const updateData = {
      id: this.editingUser.id,
      fullname: this.editingUser.fullname?.trim(),
      phone_number: this.editingUser.phone_number?.trim(),
      address: this.editingUser.address?.trim(),
      date_of_birth: this.editingUser.date_of_birth,
      role_id: this.editingUser.role?.id,
      is_active: this.editingUser.is_active,
      email: this.editingUser.email
    };


    this.userService.updateUser(updateData).pipe(
      tap((res: { users: UserDto[], message: string } | UserDto) => {
        // Handle different response formats
        if ('users' in res) {
          // Nếu response có users array
          // Reload lại danh sách
          this.getUsers();
          this.showSuccessMessage(res.message || 'Cập nhật thông tin người dùng thành công!');
        } else {
          // Nếu response là user đơn lẻ
          // Reload lại danh sách
          this.getUsers();
          this.showSuccessMessage('Cập nhật thông tin người dùng thành công!');
        }
        this.closeEditDialog();
      }),
      catchError((err) => {
        console.error('Error updating user:', err);
        this.showErrorMessage(err.error?.message || 'Có lỗi xảy ra khi cập nhật thông tin người dùng!');
        return of(err);
      })
    ).subscribe();
  }

  addUserF(): void {
    this.addUser.retype_password = this.addUser.password;
    const errors = this.validateAddUser();
    if (errors.length > 0) {
      this.showErrorMessage(errors.join(', '));
      return;
    }

    this.userService.register(this.addUser).subscribe({
      next: (res: any) => {
        this.showSuccessMessage('Thêm thành công!');
        this.getUsers();
        this.closeAddDialog();
      },
      error: (err) => {
        this.showErrorMessage(err.error?.message || 'Thêm không thành công!');
      }
    });
  }

  private validateUserData(): boolean {
    if (!this.editingUser.fullname?.trim()) {
      this.showErrorMessage('Vui lòng nhập họ tên!');
      return false;
    }

    if (!this.editingUser.phone_number?.trim()) {
      this.showErrorMessage('Vui lòng nhập số điện thoại!');
      return false;
    }

    // Validate phone number format
    const phoneRegex = /^[0-9]{10,11}$/;
    if (!phoneRegex.test(this.editingUser.phone_number.replace(/\s/g, ''))) {
      this.showErrorMessage('Số điện thoại không hợp lệ! Vui lòng nhập 10-11 chữ số.');
      return false;
    }

    if (!this.editingUser.address?.trim()) {
      this.showErrorMessage('Vui lòng nhập địa chỉ!');
      return false;
    }

    if (!this.editingUser.date_of_birth) {
      this.showErrorMessage('Vui lòng chọn ngày sinh!');
      return false;
    }

    if (!this.editingUser.role?.id) {
      this.showErrorMessage('Vui lòng chọn vai trò!');
      return false;
    }

    return true;
  }

  private showSuccessMessage(message: string): void {
    this.messageService.add({severity: 'success', summary: 'Thành công', detail: message});
  }

  private showErrorMessage(message: string): void {
    this.messageService.add({severity: 'error', summary: 'Lỗi', detail: message});
  }

  confirmDelete(id: number) {
    this.confirmationService.confirm({
      message: 'Xóa người dùng đồng nghĩa xóa tất cả đơn hàng, thông tin của người dùng. Bạn có chắc muốn xóa người dùng này?',
      header: 'Xác nhận xóa',
      icon: 'pi pi-exclamation-triangle',
      accept: () => {
        this.userService.deleteUser(id).pipe(
          tap((res: { users: UserDto[], message: string }) => {
            this.getUsers();
            this.messageService.add({severity: 'success', summary: 'Thành công', detail: res.message});
          }),
          catchError((err) => {
            this.messageService.add({severity: 'error', summary: 'Lỗi', detail: err.error.message});
            return of(err);
          })
        ).subscribe();
      }
    });
  }

  getRoleName(user: any): string {
    const roleId = user?.role?.id;
    return roleId != null ? this.roleMap[roleId - 1] : 'Không xác định';
  }

  onCategoryChange(userId: number, event: any) {
    this.userService.changeRoleUser(event.value, userId).pipe(
      tap((res: { users: UserDto[], message: string }) => {
        this.getUsers();
        this.messageService.add({severity: 'success', summary: 'Thành công', detail: res.message});
      }),
      catchError((err) => {
        this.messageService.add({severity: 'error', summary: 'Lỗi', detail: err.error.message});
        return of(err);
      })
    ).subscribe();
  }

  onRoleChange(event: any, userId: number) {
    this.onCategoryChange(userId, event);
  }

  onEditRoleChange(roleId: number): void {
    const selectedOption = this.userOptions.find(o => o.value === roleId);
    if (selectedOption) {
      this.editingUser.role = {
        id: roleId,
        name: selectedOption.label
      };
    }
  }

  changeActiveStatus(user: UserDto) {
    const newStatus = !user.is_active;

    if (user.id == null) {
      this.showErrorMessage('Không xác định được ID người dùng.');
      return;
    }
    this.userService.changeActive(user.id, newStatus).pipe(
      tap((res: UserDto) => {
        this.getUsers();
        this.messageService.add({severity: 'success', summary: 'Thành công', detail: 'Cập nhật trạng thái người dùng thành công'});
      }),
      catchError(err => {
        this.messageService.add({severity: 'error', summary: 'Lỗi', detail: err.error.message || 'Cập nhật trạng thái thất bại'});
        return of(err);
      })
    ).subscribe();
  }

  openAddUserDialog(): void {
    this.addUser = {
      fullname: '',
      phone_number: '',
      password: '',
      email: '',
      retype_password: '',
      address: '',
      date_of_birth: new Date(),
    };
    this.originalUser = {} as UserDto;
    this.showAddDialog = true;
  }

  validateAddUser(): string[] {
    const errors: string[] = [];

    const user = this.addUser;

    if (!user.fullname || !user.fullname.trim()) {
      errors.push('Họ tên không được để trống.');
    }

    if (!user.phone_number || !user.phone_number.trim()) {
      errors.push('Số điện thoại không được để trống.');
    } else if (!/^(0|\+84)[0-9]{9,10}$/.test(user.phone_number)) {
      errors.push('Số điện thoại không hợp lệ.');
    }

    if (!user.password || user.password.length < 6) {
      errors.push('Mật khẩu phải có ít nhất 6 ký tự.');
    }

    if (user.password !== user.retype_password) {
      errors.push('Mật khẩu nhập lại không khớp.');
    }

    if (!user.date_of_birth) {
      errors.push('Ngày sinh không được để trống.');
    }

    return errors;
  }

  // View Order History
  viewOrderHistory(user: UserDto): void {
    this.selectedUser = user;
    this.showOrderHistoryDialog = true;
    this.loadingOrderHistory = true;
    this.userOrderHistory = [];

    // Get all orders and filter by matching email or phone
    this.orderService.getAllOrders().pipe(
      tap((orders: HistoryOrderDto[]) => {
        // Filter orders by matching email or phone_number
        this.userOrderHistory = orders.filter(order => 
          (order.email && user.email && order.email.toLowerCase() === user.email.toLowerCase()) ||
          (order.phone_number && user.phone_number && order.phone_number === user.phone_number)
        );
        this.loadingOrderHistory = false;
      }),
      catchError(err => {
        this.loadingOrderHistory = false;
        this.showErrorMessage('Không thể tải lịch sử đơn hàng');
        return of([]);
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  // View Comment History
  viewCommentHistory(user: UserDto): void {
    if (!user.id) {
      this.showErrorMessage('Không xác định được ID người dùng');
      return;
    }

    const userId: number = user.id; // Type guard: ensure userId is number

    this.selectedUser = user;
    this.showCommentHistoryDialog = true;
    this.loadingCommentHistory = true;
    this.userComments = [];

    // Get user's orders first to get product names
    this.orderService.getAllOrders().pipe(
      switchMap((orders: HistoryOrderDto[]) => {
        // Get user's orders to map product names
        const userOrders = orders.filter(order => 
          (order.email && user.email && order.email.toLowerCase() === user.email.toLowerCase()) ||
          (order.phone_number && user.phone_number && order.phone_number === user.phone_number)
        );
        
        // Extract product names from orders (simplified - HistoryOrderDto has product_name)
        const productNameMap = new Map<string, string>();
        userOrders.forEach(order => {
          if (order.product_name) {
            productNameMap.set(order.product_name, order.product_name);
          }
        });

        // Get all products to get their IDs for reviews
        // Since we don't have product IDs in HistoryOrderDto, we need to get all reviews
        // and filter by userId. This is not efficient but works with current API structure.
        
        // For now, we'll need to get reviews from all products
        // This is a simplified approach - ideally should have an API endpoint to get reviews by userId
        return this.getAllReviewsForUser(userId, productNameMap);
      }),
      tap((reviews: any[]) => {
        this.userComments = reviews;
        this.loadingCommentHistory = false;
      }),
      catchError(err => {
        this.loadingCommentHistory = false;
        this.showErrorMessage('Không thể tải lịch sử bình luận. Vui lòng thử lại sau.');
        return of([]);
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  // Helper method to get all reviews for a user
  // Note: This is not efficient - ideally should have an API endpoint for this
  private getAllReviewsForUser(userId: number, productNameMap: Map<string, string>): Observable<any[]> {
    // Get all products first
    return this.productService.getAllProduct().pipe(
      switchMap((productResponse: AllProductDto) => {
        const products = productResponse.products || [];
        
        if (products.length === 0) {
          return of([]);
        }

        // Get reviews for all products
        const reviewObservables = products.map((product: ProductDto) =>
          this.reviewService.getReviewsByProduct(product.id).pipe(
            catchError(() => of([])),
            tap((reviews: Review[]) => {
              // Map product name to reviews
              reviews.forEach((review: any) => {
                review.productName = product.name;
              });
            })
          )
        );

        return forkJoin(reviewObservables);
      }),
      switchMap((reviewArrays: Review[][]) => {
        // Flatten and filter by userId
        const allReviews = reviewArrays.flat();
        const userReviews = allReviews
          .filter((review: any) => review.userId === userId)
          .map((review: any) => ({
            ...review,
            productName: review.productName || 'N/A',
            createdAt: review.createdAt ? new Date(review.createdAt) : new Date()
          }))
          .sort((a, b) => (b.createdAt as Date).getTime() - (a.createdAt as Date).getTime());
        
        return of(userReviews);
      }),
      catchError(() => {
        return of([]);
      })
    );
  }

  getOrderStatusSeverity(status: string): string {
    switch (status?.toLowerCase()) {
      case 'pending':
      case 'chờ xử lý':
        return 'warning';
      case 'processing':
      case 'đang xử lý':
        return 'info';
      case 'completed':
      case 'hoàn thành':
        return 'success';
      case 'cancelled':
      case 'đã hủy':
        return 'danger';
      default:
        return '';
    }
  }

  viewOrderDetails(order: HistoryOrderDto): void {
    // Navigate to order detail page or show in dialog
    this.showSuccessMessage(`Chi tiết đơn hàng #${order.id}`);
    // You can implement detailed view here
  }
}
