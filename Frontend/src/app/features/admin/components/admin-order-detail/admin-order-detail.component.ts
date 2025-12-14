import { Component, OnInit } from '@angular/core';
import { BaseComponent } from '../../../../core/commonComponent/base.component';
import { CommonService } from '../../../../core/services/common.service';
import { catchError, filter, of, tap, finalize } from 'rxjs';
import { OrderService } from '../../../../core/services/order.service';
import { InfoOrderDto } from '../../../../core/dtos/InfoOrder.dto';
import { OrderDetailDto } from '../../../../core/dtos/OrderDetail.dto';
import { CurrencyPipe, DatePipe, NgClass, NgIf } from '@angular/common';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { environment } from '../../../../../environments/environment.development';
import { ToastService } from '../../../../core/services/toast.service';
import { MessageService } from 'primeng/api';
import { ToastModule } from 'primeng/toast';
import { InvoicePdfService } from '../../../../core/services/invoice-pdf.service';
import { TimelineModule } from 'primeng/timeline';
import { CardModule } from 'primeng/card';
import { DropdownModule } from 'primeng/dropdown';
import { ButtonModule } from 'primeng/button';
import { FormsModule, ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { TableModule } from 'primeng/table';
import { DialogModule } from 'primeng/dialog';
import { InputNumberModule } from 'primeng/inputnumber';
import { InputTextModule } from 'primeng/inputtext';
import { TooltipModule } from 'primeng/tooltip';
import { TagModule } from 'primeng/tag';

import { UserService } from '../../../../core/services/user.service';
import { ORDER_STATUS_UPDATE_OPTIONS, getOrderStatusLabel } from '../../../../core/constants/order-status.constants';

@Component({
  selector: 'app-admin-order-detail',
  standalone: true,
  imports: [
    CurrencyPipe,
    DatePipe,
    NgClass,
    NgIf,
    ToastModule,
    TimelineModule,
    CardModule,
    DropdownModule,
    ButtonModule,
    FormsModule,
    ReactiveFormsModule,
    TableModule,
    DialogModule,
    InputNumberModule,
    InputTextModule,
    TooltipModule,
    TagModule,
    RouterModule
  ],
  providers: [ToastService, MessageService],
  templateUrl: './admin-order-detail.component.html',
  styleUrl: './admin-order-detail.component.scss'
})
export class AdminOrderDetailComponent extends BaseComponent implements OnInit {
  public orderInfor!: InfoOrderDto;
  public productOrderd!: OrderDetailDto[];
  public totalMoney: number = 0;
  public shipCost: number = 0;
  public notion!: string;
  public id!: string;
  public apiImage: string = environment.apiImage;
  public discountAmount: number = 0;
  public voucherInfo: { code: string, name: string, percentage: number } | null = null;
  public finalTotal: number = 0;
  
  public orderEvents: any[] = [];
  public currentStatusIndex: number = 0;

  // Admin specific properties
  public orderStatusOptions = ORDER_STATUS_UPDATE_OPTIONS;
  public selectedStatus: string = '';

  // Waybill creation
  public showWaybillDialog: boolean = false;
  public waybillForm!: FormGroup;
  public isCreatingWaybill: boolean = false;
  public isGeneratingPDF: boolean = false;

  // Staff assignment
  public staffList: any[] = [];
  public selectedStaff: any = null;
  public showAssignStaffDialog: boolean = false;
  public isAdmin: boolean = false;

  constructor(
    private commonService: CommonService,
    private orderService: OrderService,
    private activatedRouter: ActivatedRoute,
    private router: Router,
    private toastService: ToastService,
    private fb: FormBuilder,
    private invoicePdfService: InvoicePdfService,
    private userService: UserService
  ) {
    super();
    this.waybillForm = this.fb.group({
      district_id: [null, Validators.required],
      ward_code: ['', Validators.required],
      length: [20, Validators.min(1)],
      width: [20, Validators.min(1)],
      height: [10, Validators.min(1)],
      weight: [200, Validators.min(1)]
    });
  }

  ngOnInit(): void {
    const idFromUrl = this.activatedRouter.snapshot.paramMap.get('id');
    if (!idFromUrl) {
        this.toastService.fail('Không tìm thấy mã đơn hàng.');
        this.router.navigate(['/orderManage']);
        return;
    }
    this.id = idFromUrl;
    
    // Check if user is ADMIN
    const userInfo = localStorage.getItem('userInfor');
    if (userInfo) {
      const user = JSON.parse(userInfo);
      this.isAdmin = user.role && user.role.id === 2; // 2 = ADMIN
    }
    
    this.loadOrderDetail(this.id);
    
    // Only load staff list if user is ADMIN
    if (this.isAdmin) {
      this.getStaffList();
    }
  }

  getStaffList() {
    this.userService.getAllUser().subscribe({
      next: (users: any[]) => {
        this.staffList = users.filter(u => u.role && u.role.name === 'STAFF');
      },
      error: (err) => console.error(err)
    });
  }

  openAssignStaffDialog() {
    this.showAssignStaffDialog = true;
  }

  assignStaff() {
    if (!this.selectedStaff) return;
    this.orderService.assignStaff(parseInt(this.id), this.selectedStaff.id).subscribe({
      next: () => {
        this.toastService.showSuccess('Thành công', 'Đã phân công nhân viên');
        this.showAssignStaffDialog = false;
        this.loadOrderDetail(this.id); // Refresh order
      },
      error: (err) => this.toastService.showError('Lỗi', err.error || 'Không thể phân công')
    });
  }

  loadOrderDetail(orderId: string): void {
    this.orderService.getOrderInfor(parseInt(orderId)).pipe(
      filter((orderInfor: InfoOrderDto) => !!orderInfor),
      tap((orderInfor: InfoOrderDto) => {
        this.orderInfor = orderInfor;
        this.productOrderd = orderInfor.order_details;
        this.notion = orderInfor.note;
        // Normalize status: handle 'success' as 'delivered' for backward compatibility
        this.selectedStatus = orderInfor.status === 'success' ? 'delivered' : orderInfor.status;

        this.totalMoney = 0;
        this.productOrderd.forEach((item) => {
          this.totalMoney += item.total_money;
        });
        
        if (orderInfor.discount_amount) {
          this.discountAmount = orderInfor.discount_amount;
        }
        
        if (orderInfor.voucher) {
          this.voucherInfo = {
            code: orderInfor.voucher.code,
            name: orderInfor.voucher.name,
            percentage: orderInfor.voucher.discount_percentage
          };
        }

        if (orderInfor.total_money) {
          this.finalTotal = orderInfor.total_money;
          // Calculate actual shipping cost from total
          this.shipCost = this.finalTotal - (this.totalMoney - this.discountAmount);
          if (this.shipCost < 0) this.shipCost = 0;
        } else {
            // Fallback for legacy orders without total_money
            switch (orderInfor.shipping_method) {
                case "Tiêu chuẩn":
                  this.shipCost = 30000;
                  break;
                case "Nhanh":
                  this.shipCost = 40000;
                  break;
                case "Hỏa tốc":
                  this.shipCost = 60000;
                  break;
                default:
                  this.shipCost = 0;
                  break;
            }
            this.finalTotal = this.totalMoney - this.discountAmount + this.shipCost;
        }

        this.initializeTimeline(orderInfor);
      }),
      catchError((err) => {
        const errorMessage = err?.error?.message || err?.error || 'Không thể tải thông tin đơn hàng.';
        this.toastService.fail(errorMessage);
        // Navigate back to order list if access denied
        if (errorMessage.includes('assigned') || errorMessage.includes('Cannot get order')) {
          setTimeout(() => {
            this.router.navigate(['/orderManage']);
          }, 2000);
        }
        return of(err)
      }),
    ).subscribe();
  }

  updateOrderStatus(): void {
    if (!this.selectedStatus) return;
    
    this.orderService.updateOrderStatus(parseInt(this.id), this.selectedStatus).pipe(
        tap(() => {
            this.toastService.success('Cập nhật trạng thái đơn hàng thành công');
            this.loadOrderDetail(this.id); // Reload to refresh timeline
        }),
        catchError((err) => {
            this.toastService.fail('Cập nhật trạng thái thất bại: ' + err.message);
            return of(err);
        })
    ).subscribe();
  }

  initializeTimeline(order: InfoOrderDto) {
    this.orderEvents = [
      { status: 'Đặt hàng thành công', date: order.order_date, icon: 'pi pi-shopping-cart', color: '#9C27B0' },
      { status: 'Đã xác nhận', date: null, icon: 'pi pi-check', color: '#607D8B' },
      { status: 'Chờ lấy hàng', date: null, icon: 'pi pi-box', color: '#607D8B' },
      { status: 'Đang vận chuyển', date: null, icon: 'pi pi-truck', color: '#607D8B' },
      { status: 'Đang giao hàng', date: null, icon: 'pi pi-map-marker', color: '#607D8B' },
      { status: 'Giao hàng thành công', date: null, icon: 'pi pi-check-circle', color: '#607D8B' }
    ];

    let ghnStatus = '';
    if (order.tracking_info && order.tracking_info.status) {
        ghnStatus = order.tracking_info.status.toLowerCase();
    }

    this.markActive(0);

    if (order.status !== 'pending' && order.status !== 'cancelled' && order.status !== 'payment_failed') {
        this.markActive(1);
    }

    if (ghnStatus || order.tracking_number) {
        this.markActive(2);
        if (ghnStatus === 'ready_to_pick') {
             this.orderEvents[2].status = 'Chờ lấy hàng (GHN)';
        }
    }

    const shippingStatuses = ['picking', 'storing', 'transporting', 'sorting', 'picked'];
    if (shippingStatuses.includes(ghnStatus) || ghnStatus === 'delivering' || ghnStatus === 'delivered') {
        this.markActive(3);
        if (ghnStatus === 'picking') this.orderEvents[3].status = 'Đang lấy hàng';
        if (ghnStatus === 'picked') this.orderEvents[3].status = 'Đã lấy hàng';
        if (ghnStatus === 'storing') this.orderEvents[3].status = 'Đang lưu kho';
        if (ghnStatus === 'transporting') this.orderEvents[3].status = 'Đang luân chuyển';
        if (ghnStatus === 'sorting') this.orderEvents[3].status = 'Đang phân loại';
    }

    if (ghnStatus === 'delivering' || ghnStatus === 'delivered') {
        this.markActive(4);
    }

    if (ghnStatus === 'delivered' || order.status === 'delivered') {
        this.markActive(5);
    }
  }

  markActive(index: number) {
      this.orderEvents[index].color = '#673AB7';
  }

  getGhnStatusText(status: string): string {
    if (!status) return '';
    const statusMap: {[key: string]: string} = {
        'ready_to_pick': 'Mới tạo, chờ lấy hàng',
        'picking': 'Nhân viên đang lấy hàng',
        'cancel': 'Đã hủy',
        'picked': 'Đã lấy hàng',
        'storing': 'Hàng đang nằm ở kho',
        'transporting': 'Đang luân chuyển hàng',
        'sorting': 'Đang phân loại',
        'delivering': 'Nhân viên đang đi giao hàng',
        'money_collect_picking': 'Đang thu tiền người gửi',
        'tally_picking': 'Đang kiểm đếm',
        'delivery_fail': 'Giao hàng thất bại',
        'waiting_to_return': 'Chờ trả hàng',
        'return': 'Đang trả hàng',
        'return_fail': 'Trả hàng thất bại',
        'returned': 'Đã trả hàng',
        'exception': 'Hàng ngoại lệ',
        'damage': 'Hàng bị hư hỏng',
        'lost': 'Hàng bị thất lạc'
    };
    return statusMap[status.toLowerCase()] || status;
  }


  async downloadInvoicePDF(): Promise<void> {
    if (!this.orderInfor || !this.productOrderd) {
      this.toastService.fail('Không thể tải hóa đơn. Vui lòng thử lại sau.');
      return;
    }

    this.isGeneratingPDF = true;
    try {
      await this.invoicePdfService.generateInvoicePDF(
        this.orderInfor,
        this.productOrderd,
        this.totalMoney,
        this.shipCost,
        this.discountAmount,
        this.finalTotal,
        this.voucherInfo,
        this.apiImage
      );
      this.toastService.success('Đã tải hóa đơn thành công!');
    } catch (error: any) {
      console.error('Error generating PDF:', error);
      this.toastService.fail(error.message || 'Không thể tạo file PDF. Vui lòng thử lại.');
    } finally {
      this.isGeneratingPDF = false;
    }
  }

  openWaybillDialog(): void {
    if (this.orderInfor.tracking_number) {
      this.toastService.warn('Đơn hàng đã có vận đơn: ' + this.orderInfor.tracking_number);
      return;
    }
    this.showWaybillDialog = true;
    this.waybillForm.patchValue({
      district_id: this.orderInfor.district_id || null,
      ward_code: this.orderInfor.ward_code || '',
      length: 20,
      width: 20,
      height: 10,
      weight: 200
    });
  }

  createWaybill(): void {
    if (this.waybillForm.invalid) {
      this.toastService.fail('Vui lòng nhập đầy đủ thông tin bắt buộc');
      return;
    }

    this.isCreatingWaybill = true;
    const formValue = this.waybillForm.value;

    this.orderService.createWaybill(
      parseInt(this.id),
      formValue.district_id,
      formValue.ward_code,
      formValue.length,
      formValue.width,
      formValue.height,
      formValue.weight
    ).pipe(
      tap(() => {
        this.toastService.success('Tạo vận đơn thành công! Email đã được gửi cho khách hàng.');
        this.showWaybillDialog = false;
        this.loadOrderDetail(this.id); // Reload to get tracking number
      }),
      catchError((err) => {
        const errorMessage = err?.error?.message || err?.error || 'Không thể tạo vận đơn';
        this.toastService.fail(errorMessage);
        return of(err);
      }),
      finalize(() => {
        this.isCreatingWaybill = false;
      })
    ).subscribe();
  }

  getStatusSeverity(status: string): string {
    switch(status) {
      case 'pending': return 'warning';
      case 'processing': return 'info';
      case 'shipped': return 'primary';
      case 'delivered': return 'success';
      case 'cancelled': return 'danger';
      case 'payment_failed': return 'danger';
      default: return 'secondary';
    }
  }

  getStatusLabel(status: string): string {
    const option = this.orderStatusOptions.find(opt => opt.value === status);
    return option ? option.label : status;
  }

  getPaymentMethodSeverity(method: string): string {
    switch(method?.toUpperCase()) {
      case 'CASH': return 'warning';
      case 'STRIPE': return 'success';
      case 'VNPAY': return 'info';
      case 'BANKING': return 'primary';
      default: return 'secondary';
    }
  }

  getPaymentMethodLabel(method?: string): string {
    if (!method) return 'N/A';
    
    // Map payment method to display label
    const methodMap: { [key: string]: string } = {
      'Thanh toán thẻ thành công': 'Stripe (VISA / MasterCard)',
      'Stripe (visa/mastercard)': 'Stripe (VISA / MasterCard)',
      'Stripe Card Payment': 'Stripe (VISA / MasterCard)',
      'Pending Stripe Payment': 'Stripe (VISA / MasterCard) - Đang chờ',
      'VNPAY': 'VNPay',
      'VnPay': 'VNPay',
      'Thanh toán khi nhận hàng': 'Thanh toán khi nhận hàng (COD)',
      'Cash': 'Thanh toán khi nhận hàng (COD)'
    };
    
    return methodMap[method] || method;
  }
}
