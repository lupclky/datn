import { Component, OnInit } from '@angular/core';
import { BaseComponent } from '../../../../core/commonComponent/base.component';
import { CommonService } from '../../../../core/services/common.service';
import { catchError, filter, of, tap } from 'rxjs';
import { OrderService } from '../../../../core/services/order.service';
import { InfoOrderDto } from '../../../../core/dtos/InfoOrder.dto';
import { OrderDetailDto } from '../../../../core/dtos/OrderDetail.dto';
import { CurrencyPipe, DatePipe, NgClass, NgIf } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { environment } from '../../../../../environments/environment.development';
import { ToastService } from '../../../../core/services/toast.service';
import { MessageService } from 'primeng/api';
import { ToastModule } from 'primeng/toast';
import { TimelineModule } from 'primeng/timeline';
import { CardModule } from 'primeng/card';
import { DropdownModule } from 'primeng/dropdown';
import { ButtonModule } from 'primeng/button';
import { FormsModule } from '@angular/forms';

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
    FormsModule
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
  public orderStatusOptions = [
    { label: 'Đang chờ', value: 'pending' },
    { label: 'Đang xử lý', value: 'processing' },
    { label: 'Đang giao hàng', value: 'shipped' },
    { label: 'Đã giao', value: 'delivered' },
    { label: 'Đã hủy', value: 'cancelled' },
    { label: 'Thanh toán thất bại', value: 'payment_failed' }
  ];
  public selectedStatus: string = '';

  constructor(
    private commonService: CommonService,
    private orderService: OrderService,
    private activatedRouter: ActivatedRoute,
    private router: Router,
    private toastService: ToastService
  ) {
    super();
  }

  ngOnInit(): void {
    const idFromUrl = this.activatedRouter.snapshot.paramMap.get('id');
    if (!idFromUrl) {
        this.toastService.fail('Không tìm thấy mã đơn hàng.');
        this.router.navigate(['/admin/orders']); // Navigate to admin orders list
        return;
    }
    this.id = idFromUrl;
    this.loadOrderDetail(this.id);
  }

  loadOrderDetail(orderId: string): void {
    this.orderService.getOrderInfor(parseInt(orderId)).pipe(
      filter((orderInfor: InfoOrderDto) => !!orderInfor),
      tap((orderInfor: InfoOrderDto) => {
        this.orderInfor = orderInfor;
        this.productOrderd = orderInfor.order_details;
        this.notion = orderInfor.note;
        this.selectedStatus = orderInfor.status;

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
            break;
        }
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
        } else {
          this.finalTotal = this.totalMoney - this.discountAmount + this.shipCost;
        }

        this.initializeTimeline(orderInfor);
      }),
      catchError((err) => {
        this.toastService.fail('Không thể tải thông tin đơn hàng.');
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

  printInvoice(): void {
    window.print();
  }
}
