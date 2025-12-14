import { Component, OnInit, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ChartModule } from 'primeng/chart';
import { CardModule } from 'primeng/card';
import { TabViewModule } from 'primeng/tabview';
import { CalendarModule } from 'primeng/calendar';
import { FormsModule } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { TableModule } from 'primeng/table';
import { StatisticsService, DailyRevenue, MonthlyRevenue, YearlyRevenue, ProductStatistics, TopStockProduct } from '../../../core/services/statistics.service';
import { Chart, registerables } from 'chart.js';
import { BestSellingStatisticsComponent } from '../../../best-selling-statistics/best-selling-statistics.component';
import { OrderService } from '../../../core/services/order.service';
import { PrimeNGConfig } from 'primeng/api';

// Register Chart.js components
Chart.register(...registerables);

import { AiService } from '../../../core/services/ai.service';
import { ToastService } from '../../../core/services/toast.service';
import { environment } from '../../../../environments/environment.development';

@Component({
  selector: 'app-admin-dashboard',
  standalone: true,
  imports: [
    CommonModule,
    ChartModule,
    CardModule,
    TabViewModule,
    CalendarModule,
    FormsModule,
    ButtonModule,
    TableModule,
    BestSellingStatisticsComponent
  ],
  templateUrl: './admin-dashboard.component.html',
  styleUrl: './admin-dashboard.component.scss'
})
export class AdminDashboardComponent implements OnInit {
  @ViewChild('dailyRevenueChart') dailyRevenueChartRef!: ElementRef;
  @ViewChild('monthlyRevenueChart') monthlyRevenueChartRef!: ElementRef;
  @ViewChild('yearlyRevenueChart') yearlyRevenueChartRef!: ElementRef;

  // Dashboard statistics
  totalRevenue: number = 0;
  dailyRevenue: number = 0;
  ordersToday: number = 0;
  totalProducts: number = 0;
  soldProducts: number = 0;
  availableProducts: number = 0;

  // Chart date ranges with default values
  dateRange: Date[] = [new Date(), new Date()];
  monthRange: Date[] = [new Date(), new Date()];
  yearRange: Date[] = [new Date(), new Date()];

  // Calendar configuration
  calendarConfig = {
    firstDayOfWeek: 1,
    dayNames: ['Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'],
    dayNamesShort: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'],
    dayNamesMin: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'],
    monthNames: ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'],
    monthNamesShort: ['Th1', 'Th2', 'Th3', 'Th4', 'Th5', 'Th6', 'Th7', 'Th8', 'Th9', 'Th10', 'Th11', 'Th12'],
    today: 'Hôm nay',
    clear: 'Xóa',
    dateFormat: 'dd/mm/yy',
    weekHeader: 'Tuần'
  };

  // Chart instances
  private dailyChart: Chart | null = null;
  private monthlyChart: Chart | null = null;
  private yearlyChart: Chart | null = null;

  // AI Insights
  aiInsights: string | null = null;
  isAnalyzing: boolean = false;

  // Top Stock Products
  topStockProducts: TopStockProduct[] = [];
  apiImage: string = '';

  constructor(
    private statisticsService: StatisticsService,
    private orderService: OrderService,
    private primeNGConfig: PrimeNGConfig,
    private aiService: AiService,
    private toastService: ToastService
  ) {}

  ngOnInit() {
    this.primeNGConfig.setTranslation(this.calendarConfig);
    this.apiImage = environment.apiImage;
    this.loadDashboardData();
  }

  generateInsights() {
    this.isAnalyzing = true;
    this.aiService.generateDashboardInsights().subscribe({
      next: (response: any) => {
        if (response && response.success) {
          this.aiInsights = response.insights;
        } else {
          this.toastService.showError('Lỗi', 'Không thể tạo đề xuất AI');
        }
        this.isAnalyzing = false;
      },
      error: (error) => {
        console.error('Error generating insights:', error);
        this.toastService.showError('Lỗi', 'Có lỗi xảy ra khi kết nối với AI');
        this.isAnalyzing = false;
      }
    });
  }

  formatInsights(text: string): string {
    if (!text) return '';
    // Simple markdown to HTML conversion for basic formatting
    return text
      .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
      .replace(/\n/g, '<br>');
  }

  private loadDashboardData() {
    // Fetch today's overview stats in one call
    this.statisticsService.getTodayOverview().subscribe(overview => {
      this.ordersToday = overview.ordersToday;
      this.dailyRevenue = overview.revenueToday;
    });

    // Load dashboard stats
    this.orderService.getDashboardStats().subscribe({
      next: (stats) => {
        this.totalRevenue = stats.totalRevenue;
        this.soldProducts = stats.totalProductsSold;
      },
      error: (error) => {
        console.error('Error loading dashboard stats:', error);
        this.totalRevenue = 0;
        this.soldProducts = 0;
      }
    });

    // Load product statistics
    this.statisticsService.getProductStatistics().subscribe({
      next: (stats) => {
        this.totalProducts = stats.totalProducts;
        this.availableProducts = stats.availableProducts;
      },
      error: (error) => {
        console.error('Error loading product statistics:', error);
        this.totalProducts = 0;
        this.availableProducts = 0;
      }
    });

    // Initialize date ranges
    const today = new Date();
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(today.getDate() - 30);
    
    this.dateRange = [thirtyDaysAgo, today];
    this.monthRange = [new Date(today.getFullYear(), 0, 1), today];
    this.yearRange = [new Date(today.getFullYear() - 5, 0, 1), today];

    // Load initial data
    this.onDateRangeSelect();
    this.onMonthRangeSelect();
    this.onYearRangeSelect();

    // Load top stock products
    this.statisticsService.getTopStockProducts(10).subscribe({
      next: (products) => {
        this.topStockProducts = products;
      },
      error: (error) => {
        console.error('Error loading top stock products:', error);
        this.topStockProducts = [];
      }
    });
  }

  onDateRangeSelect() {
    if (this.dateRange.length === 2) {
      const startDate = this.dateRange[0].toISOString().split('T')[0];
      const endDate = this.dateRange[1].toISOString().split('T')[0];
      
      this.statisticsService.getRevenueByDateRange(startDate, endDate).subscribe(
        data => this.updateDailyChart(data)
      );
    }
  }

  onMonthRangeSelect() {
    if (this.monthRange.length === 2) {
      const startMonth = this.monthRange[0].toISOString().slice(0, 7);
      const endMonth = this.monthRange[1].toISOString().slice(0, 7);
      
      this.statisticsService.getRevenueByMonthRange(startMonth, endMonth).subscribe(
        data => this.updateMonthlyChart(data)
      );
    }
  }

  onYearRangeSelect() {
    if (this.yearRange.length === 2) {
      const startYear = this.yearRange[0].getFullYear().toString();
      const endYear = this.yearRange[1].getFullYear().toString();
      
      this.statisticsService.getRevenueByYearRange(startYear, endYear).subscribe(
        data => this.updateYearlyChart(data)
      );
    }
  }

  private updateDailyChart(data: DailyRevenue[]) {
    if (typeof window === 'undefined') return; // Skip on server-side

    const ctx = this.dailyRevenueChartRef.nativeElement.getContext('2d');
    if (this.dailyChart) {
      this.dailyChart.destroy();
    }
    
    this.dailyChart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: data.map(item => item.date),
        datasets: [{
          label: 'Doanh thu theo ngày',
          data: data.map(item => item.revenue),
          borderColor: 'rgb(75, 192, 192)',
          backgroundColor: 'rgba(75, 192, 192, 0.1)',
          tension: 0.4,
          fill: true
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'top',
          },
          title: {
            display: true,
            text: 'Biểu đồ doanh thu theo ngày'
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: function(value) {
                return value.toLocaleString('vi-VN') + ' VND';
              }
            }
          }
        }
      }
    });
  }

  private updateMonthlyChart(data: MonthlyRevenue[]) {
    if (typeof window === 'undefined') return; // Skip on server-side

    const ctx = this.monthlyRevenueChartRef.nativeElement.getContext('2d');
    if (this.monthlyChart) {
      this.monthlyChart.destroy();
    }
    
    this.monthlyChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: data.map(item => item.month),
        datasets: [{
          label: 'Doanh thu theo tháng',
          data: data.map(item => item.revenue),
          backgroundColor: 'rgba(54, 162, 235, 0.5)',
          borderColor: 'rgb(54, 162, 235)',
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'top',
          },
          title: {
            display: true,
            text: 'Biểu đồ doanh thu theo tháng'
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: function(value) {
                return value.toLocaleString('vi-VN') + ' VND';
              }
            }
          }
        }
      }
    });
  }

  private updateYearlyChart(data: YearlyRevenue[]) {
    if (typeof window === 'undefined') return; // Skip on server-side

    const ctx = this.yearlyRevenueChartRef.nativeElement.getContext('2d');
    if (this.yearlyChart) {
      this.yearlyChart.destroy();
    }
    
    this.yearlyChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: data.map(item => item.year),
        datasets: [{
          label: 'Doanh thu theo năm',
          data: data.map(item => item.revenue),
          backgroundColor: 'rgba(153, 102, 255, 0.5)',
          borderColor: 'rgb(153, 102, 255)',
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'top',
          },
          title: {
            display: true,
            text: 'Biểu đồ doanh thu theo năm'
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: function(value) {
                return value.toLocaleString('vi-VN') + ' VND';
              }
            }
          }
        }
      }
    });
  }
} 