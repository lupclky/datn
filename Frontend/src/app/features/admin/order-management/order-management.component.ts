import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { OrderService } from '../../../core/services/order.service';
import { ToastService } from '../../../core/services/toast.service';

@Component({
  selector: 'app-order-management',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './order-management.component.html',
  styleUrls: ['./order-management.component.scss']
})
export class OrderManagementComponent implements OnInit {
  orders: any[] = [];
  
  constructor(
    private orderService: OrderService,
    private toastService: ToastService
  ) {}

  ngOnInit(): void {
    this.loadOrders();
  }

  loadOrders(): void {
    this.orderService.getAllOrders().subscribe({
      next: (response: any) => {
        this.orders = response || [];
      },
      error: (error) => {
        console.error('Error loading orders:', error);
        this.toastService.showError('Không thể tải đơn hàng');
      }
    });
  }

  updateOrderStatus(order: any, status: string): void {
    if (!status || !confirm(`Bạn có chắc chắn muốn cập nhật trạng thái đơn hàng?`)) {
      return;
    }

    this.orderService.updateOrderStatus(order.id, status).subscribe({
      next: (response) => {
        this.toastService.showSuccess('Cập nhật trạng thái thành công');
        this.loadOrders();
      },
      error: (error) => {
        console.error('Error updating order:', error);
        this.toastService.showError('Không thể cập nhật đơn hàng');
      }
    });
  }

  formatPrice(price: number): string {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND'
    }).format(price);
  }

  formatDate(dateString: string): string {
    const date = new Date(dateString);
    return date.toLocaleDateString('vi-VN');
  }
}

