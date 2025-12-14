import { Component, OnInit } from '@angular/core';
import { BaseComponent } from '../../../core/commonComponent/base.component';
import { CommonService } from '../../../core/services/common.service';
import { catchError, filter, of, switchMap, tap } from 'rxjs';
import { OrderService } from '../../../core/services/order.service';
import { InfoOrderDto } from '../../../core/dtos/InfoOrder.dto';
import { OrderDetailDto } from '../../../core/dtos/OrderDetail.dto';
import { CurrencyPipe,DatePipe,NgClass } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { environment } from '../../../../environments/environment.development';
import { ToastService } from '../../../core/services/toast.service';
import { MessageService } from 'primeng/api';
import { ToastModule } from 'primeng/toast';
import { ProductService } from '../../../core/services/product.service';
import { InvoicePdfService } from '../../../core/services/invoice-pdf.service';
import { ButtonModule } from 'primeng/button';
import { Observable } from 'rxjs';
import { TimelineModule } from 'primeng/timeline';
import { CardModule } from 'primeng/card';
import { getOrderStatusLabel } from '../../../core/constants/order-status.constants';

@Component({
  selector: 'app-order-detail',
  standalone: true,
  imports: [
    CurrencyPipe,
    DatePipe,
    NgClass,
    ToastModule,
    TimelineModule,
    CardModule,
    ButtonModule
  ],
  providers: [ToastService, MessageService],
  templateUrl: './order-detail.component.html',
  styleUrl: './order-detail.component.scss'
})
export class OrderDetailComponent extends BaseComponent implements OnInit {
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

  public isGeneratingPDF: boolean = false;

  constructor(
    private commonService: CommonService,
    private orderService: OrderService,
    private activatedRouter: ActivatedRoute,
    private router: Router,
    private toastService: ToastService,
    private productService: ProductService,
    private invoicePdfService: InvoicePdfService
  ) {
    super();
  }

  ngOnInit(): void {
    const idFromUrl = this.activatedRouter.snapshot.paramMap.get('id');
    if (!idFromUrl) {
        // Handle case where ID is missing from URL
        this.toastService.fail('Không tìm thấy mã đơn hàng.');
        this.router.navigate(['/history']);
        return;
    }
    this.id = idFromUrl;
    
    // Handle VNPAY return first
    this.activatedRouter.queryParams.subscribe(params => {
      const paymentStatus = params['vnp_ResponseCode'];
      if (paymentStatus) {
        this.handleVnpayReturn(paymentStatus, this.id);
      } else {
        // Normal page load
        this.loadOrderDetail(this.id);
      }
    });
  }

  handleVnpayReturn(status: string, orderId: string): void {
    const orderIdNum = parseInt(orderId, 10);
    
    // Clean URL query params immediately to prevent re-triggering
    this.router.navigate([], {
      relativeTo: this.activatedRouter,
      queryParams: {},
      replaceUrl: true
    });
    
    if (status === '00') {
      this.orderService.updateOrderStatus(orderIdNum, 'paid').pipe(
        switchMap(() => this.productService.deleteAllProductsFromCart())
      ).subscribe({
        next: () => {
          this.toastService.success('Thanh toán thành công! Giỏ hàng đã được xóa.');
          localStorage.removeItem('productOrder');
          this.commonService.intermediateObservable.next(true);

          // Force reload after a short delay to ensure state is fresh
          setTimeout(() => {
            window.location.reload();
          }, 1000);
        },
        error: (err) => {
          this.toastService.fail('Có lỗi xảy ra khi hoàn tất đơn hàng. Vui lòng liên hệ hỗ trợ.');
          this.loadOrderDetail(orderId);
        }
      });
    } else {
      this.orderService.updateOrderStatus(orderIdNum, 'payment_failed').subscribe({
        next: () => {
          this.toastService.fail('Thanh toán VNPAY thất bại hoặc đã bị hủy.');
          this.loadOrderDetail(orderId);
        },
        error: (err) => {
          this.toastService.fail('Có lỗi xảy ra khi cập nhật trạng thái đơn hàng.');
          this.loadOrderDetail(orderId);
        }
      });
    }
  }

  loadOrderDetail(orderId: string): void {
    this.orderService.getOrderInfor(parseInt(orderId)).pipe(
      filter((orderInfor: InfoOrderDto) => !!orderInfor),
      tap((orderInfor: InfoOrderDto) => {
        this.orderInfor = orderInfor;
        this.productOrderd = orderInfor.order_details;
        this.notion = orderInfor.note;
        
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
          // Fallback for legacy orders
          switch (orderInfor.shipping_method) {
            case "Tiêu chuẩn":
              this.shipCost = 30000;
              break;
            case "Nhanh":
              this.shipCost = 0;
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

        // Initialize Timeline Events
        this.initializeTimeline(orderInfor);
      }),
      catchError((err) => {
        this.toastService.fail('Không thể tải thông tin đơn hàng.');
        return of(err)
      }),
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

    // Update colors based on progress
    // Step 1: Placed (Always active)
    this.markActive(0);

    // Step 2: Confirmed (Active if not pending/cancelled/payment_failed)
    if (order.status !== 'pending' && order.status !== 'cancelled' && order.status !== 'payment_failed') {
        this.markActive(1);
    }

    // Step 3: Ready to pick (GHN status exists)
    if (ghnStatus || order.tracking_number) {
        this.markActive(2);
        if (ghnStatus === 'ready_to_pick') {
             this.orderEvents[2].status = 'Chờ lấy hàng (GHN)';
        }
    }

    // Step 4: Shipping
    const shippingStatuses = ['picking', 'storing', 'transporting', 'sorting', 'picked'];
    if (shippingStatuses.includes(ghnStatus) || ghnStatus === 'delivering' || ghnStatus === 'delivered') {
        this.markActive(3);
        if (ghnStatus === 'picking') this.orderEvents[3].status = 'Đang lấy hàng';
        if (ghnStatus === 'picked') this.orderEvents[3].status = 'Đã lấy hàng';
        if (ghnStatus === 'storing') this.orderEvents[3].status = 'Đang lưu kho';
        if (ghnStatus === 'transporting') this.orderEvents[3].status = 'Đang luân chuyển';
        if (ghnStatus === 'sorting') this.orderEvents[3].status = 'Đang phân loại';
    }

    // Step 5: Delivering
    if (ghnStatus === 'delivering' || ghnStatus === 'delivered') {
        this.markActive(4);
    }

    // Step 6: Delivered
    if (ghnStatus === 'delivered' || order.status === 'delivered') {
        this.markActive(5);
    }
  }

  markActive(index: number) {
      this.orderEvents[index].color = '#673AB7'; // Active color
  }

  getOrderStatusLabel(status: string): string {
    return getOrderStatusLabel(status === 'success' ? 'delivered' : status);
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
}
