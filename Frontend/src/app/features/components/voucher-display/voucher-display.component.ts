import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule, CurrencyPipe } from '@angular/common';
import { VoucherService } from '../../../core/services/voucher.service';
import { VoucherDto } from '../../../core/dtos/voucher.dto';
import { HomepageVoucherDto } from '../../../core/dtos/homepageVoucher.dto';
import { catchError, of, tap, filter, takeUntil } from 'rxjs';
import { RouterModule } from '@angular/router';
import { ToastService } from '../../../core/services/toast.service';
import { ToastModule } from 'primeng/toast';
import { MessageService } from 'primeng/api';
import { TooltipModule } from 'primeng/tooltip';
import { Subject } from 'rxjs';

@Component({
  selector: 'app-voucher-display',
  standalone: true,
  imports: [CommonModule, RouterModule, ToastModule, CurrencyPipe, TooltipModule],
  templateUrl: './voucher-display.component.html',
  styleUrls: ['./voucher-display.component.scss'],
  providers: [ToastService, MessageService]
})
export class VoucherDisplayComponent implements OnInit, OnDestroy {
  vouchers: HomepageVoucherDto[] = [];
  isLoading = true;
  private destroyed$ = new Subject<void>();

  constructor(
    private voucherService: VoucherService,
    private toastService: ToastService
    ) {}

  ngOnInit(): void {
    this.loadVouchers();
    
    // Lắng nghe sự thay đổi voucher và tự động reload
    this.voucherService.voucherChanged$.pipe(
      filter((changed) => changed === true),
      tap(() => {
        console.log('Voucher changed, reloading...');
        this.loadVouchers();
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }
  
  ngOnDestroy(): void {
    this.destroyed$.next();
    this.destroyed$.complete();
  }
  
  private loadVouchers(): void {
    this.isLoading = true;
    this.voucherService.getHomepageVouchers(0, 5).pipe(
      tap(response => {
        if(response && response.vouchers) {
          this.vouchers = response.vouchers;
        }
        this.isLoading = false;
      }),
      catchError(error => {
        console.error('Error fetching homepage vouchers:', error);
        this.isLoading = false;
        return of(null);
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  copyCode(code: string) {
    navigator.clipboard.writeText(code).then(() => {
      this.toastService.success('Đã sao chép mã voucher!');
    }).catch(err => {
      this.toastService.fail('Không thể sao chép mã.');
      console.error('Could not copy text: ', err);
    });
  }

  getProgressPercentage(voucher: HomepageVoucherDto): number {
    const total = voucher.quantity || 0;
    const remaining = voucher.remaining_quantity || 0;
    
    if (total === 0) return 0;
    
    // Tính phần trăm: (remaining / total) * 100
    const percentage = (remaining / total) * 100;
    
    // Giới hạn từ 0 đến 100
    return Math.max(0, Math.min(100, percentage));
  }
} 