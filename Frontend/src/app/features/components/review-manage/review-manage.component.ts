import { Component, OnInit, Inject, PLATFORM_ID } from '@angular/core';
import { RouterLink } from '@angular/router';
import { CommonModule, DatePipe, isPlatformBrowser } from '@angular/common';
import { FormBuilder, FormGroup, FormsModule, ReactiveFormsModule, Validators } from '@angular/forms';
import { BaseComponent } from '../../../core/commonComponent/base.component';
import { ReviewService, Review, ReviewReplyRequest } from '../../../core/services/review.service';
import { ToastService } from '../../../core/services/toast.service';
import { ToastModule } from 'primeng/toast';
import { TableModule } from 'primeng/table';
import { ButtonModule } from 'primeng/button';
import { TooltipModule } from 'primeng/tooltip';
import { CardModule } from 'primeng/card';
import { InputTextModule } from 'primeng/inputtext';
import { DialogModule } from 'primeng/dialog';
import { InputTextareaModule } from 'primeng/inputtextarea';
import { RatingModule } from 'primeng/rating';
import { catchError, of, tap, debounceTime, distinctUntilChanged } from 'rxjs';
import { Router } from '@angular/router';

@Component({
  selector: 'app-review-manage',
  standalone: true,
  imports: [
    DatePipe,
    RouterLink,
    ToastModule,
    FormsModule,
    TableModule,
    ButtonModule,
    TooltipModule,
    CardModule,
    ReactiveFormsModule,
    InputTextModule,
    DialogModule,
    InputTextareaModule,
    RatingModule,
    CommonModule
  ],
  providers: [
    ToastService
  ],
  templateUrl: './review-manage.component.html',
  styleUrl: './review-manage.component.scss'
})
export class ReviewManageComponent extends BaseComponent implements OnInit {
  public allReviews: Review[] = [];
  public loading: boolean = true;
  public searchForm: FormGroup;
  public totalRecords: number = 0;
  public pageSize: number = 15;
  public page: number = 0;
  public sortField: string = 'id';
  public sortOrder: number = -1; // -1 for desc, 1 for asc
  
  // Reply dialog
  public showReplyDialog: boolean = false;
  public replyForm: FormGroup;
  public selectedReview: Review | null = null;
  public isSubmittingReply: boolean = false;

  constructor(
    private reviewService: ReviewService,
    private toastService: ToastService,
    private router: Router,
    private fb: FormBuilder,
    @Inject(PLATFORM_ID) private platformId: Object
  ) {
    super();
    this.searchForm = this.fb.group({
      keyword: [''],
      productId: [null]
    });

    this.replyForm = this.fb.group({
      reply: ['', [Validators.required, Validators.minLength(1)]]
    });
  }

  private checkPermissions(): boolean {
    console.log('ReviewManageComponent.checkPermissions() - Starting permission check');
    
    if (!isPlatformBrowser(this.platformId)) {
      console.log('ReviewManageComponent.checkPermissions() - Not browser platform, returning false');
      return false;
    }
    
    const userInfo = localStorage.getItem('userInfor');
    console.log('ReviewManageComponent.checkPermissions() - userInfo from localStorage:', userInfo ? 'exists' : 'null');
    
    if (!userInfo) {
      console.log('ReviewManageComponent.checkPermissions() - No userInfo, redirecting to login');
      this.toastService.fail('Vui lòng đăng nhập để tiếp tục');
      this.router.navigate(['/auth-login']);
      return false;
    }
    
    const user = JSON.parse(userInfo);
    console.log('ReviewManageComponent.checkPermissions() - User object:', {
      hasRole: !!user.role,
      roleId: user.role?.id,
      roleName: user.role?.name
    });
    
    // Allow both ADMIN (roleId = 2) and STAFF (roleId = 3)
    if (!user.role || (user.role.id !== 2 && user.role.id !== 3)) {
      console.log('ReviewManageComponent.checkPermissions() - Access denied. User role:', user.role);
      console.log('ReviewManageComponent.checkPermissions() - Expected roleId: 2 (ADMIN) or 3 (STAFF), got:', user.role?.id);
      this.toastService.fail('Bạn không có quyền truy cập trang này');
      this.router.navigate(['/']);
      return false;
    }
    
    console.log('ReviewManageComponent.checkPermissions() - Access granted for roleId:', user.role.id);
    return true;
  }

  ngOnInit(): void {
    console.log('ReviewManageComponent.ngOnInit() - Component initializing');
    if(!this.checkPermissions()) {
      console.log('ReviewManageComponent.ngOnInit() - Permission check failed, exiting');
      return;
    }
    console.log('ReviewManageComponent.ngOnInit() - Permission check passed, loading reviews');
    this.loadReviews();

    this.searchForm.valueChanges.pipe(
      debounceTime(500),
      distinctUntilChanged()
    ).subscribe(() => {
      this.page = 0;
      this.loadReviews();
    });
  }

  loadReviews(event?: any): void {
    console.log('ReviewManageComponent.loadReviews() - Starting to load reviews');
    
    if(!this.checkPermissions()) {
      console.log('ReviewManageComponent.loadReviews() - Permission check failed, exiting');
      return;
    }

    if (event) {
      console.log('ReviewManageComponent.loadReviews() - Event received:', event);
      if (event.first != null && event.rows != null) {
        this.page = event.first / event.rows;
        this.pageSize = event.rows;
      }
      if (event.sortField) {
        this.sortField = event.sortField;
      }
      if (event.sortOrder) {
        this.sortOrder = event.sortOrder;
      }
    }
    
    this.loading = true;
    const { keyword, productId } = this.searchForm.value;
    
    const safePage = this.page != null ? this.page : 0;
    const safePageSize = this.pageSize != null ? this.pageSize : 15;
    
    console.log('ReviewManageComponent.loadReviews() - Loading reviews with params:', {
      keyword,
      productId,
      page: safePage,
      pageSize: safePageSize
    });

    this.reviewService.getAllReviews(safePage, safePageSize, keyword || undefined, productId || undefined).pipe(
      tap((response: any) => {
        console.log('ReviewManageComponent.loadReviews() - Response received:', response);
        this.allReviews = response.content || response.orders || [];
        this.totalRecords = response.totalElements || response.totalPages * safePageSize || 0;
        this.loading = false;
        console.log('ReviewManageComponent.loadReviews() - Loaded', this.allReviews.length, 'reviews');
      }),
      catchError(err => {
        console.error('ReviewManageComponent.loadReviews() - Error loading reviews:', err);
        const errorMessage = err?.error?.message || 'Không thể tải danh sách đánh giá';
        this.toastService.fail(errorMessage);
        this.loading = false;
        return of(err);
      })
    ).subscribe();
  }

  openReplyDialog(review: Review): void {
    console.log('ReviewManageComponent.openReplyDialog() - Opening reply dialog for review:', review.id);
    this.selectedReview = review;
    this.replyForm.patchValue({
      reply: review.staffReply || ''
    });
    this.showReplyDialog = true;
  }

  closeReplyDialog(): void {
    this.showReplyDialog = false;
    this.selectedReview = null;
    this.replyForm.reset();
  }

  submitReply(): void {
    if (!this.selectedReview || !this.replyForm.valid) {
      return;
    }

    this.isSubmittingReply = true;
    const replyText = this.replyForm.value.reply.trim();

    if (!replyText) {
      this.toastService.fail('Vui lòng nhập nội dung phản hồi');
      this.isSubmittingReply = false;
      return;
    }

    const replyRequest: ReviewReplyRequest = {
      reviewId: this.selectedReview.id!,
      reply: replyText
    };

    console.log('ReviewManageComponent.submitReply() - Submitting reply:', replyRequest);

    this.reviewService.replyToReview(replyRequest).pipe(
      tap((updatedReview: Review) => {
        console.log('ReviewManageComponent.submitReply() - Reply submitted successfully');
        // Update the review in the list
        const index = this.allReviews.findIndex(r => r.id === updatedReview.id);
        if (index !== -1) {
          this.allReviews[index] = updatedReview;
        }
        this.toastService.success('Phản hồi đánh giá thành công!');
        this.closeReplyDialog();
        this.isSubmittingReply = false;
      }),
      catchError(err => {
        console.error('ReviewManageComponent.submitReply() - Error submitting reply:', err);
        const errorMessage = err?.error?.error || err?.error?.message || 'Không thể gửi phản hồi';
        this.toastService.fail(errorMessage);
        this.isSubmittingReply = false;
        return of(null);
      })
    ).subscribe();
  }

  getStars(rating: number): number[] {
    return Array(rating).fill(0);
  }

  formatDate(date: Date | string | undefined): string {
    if (!date) return '';
    const d = new Date(date);
    return d.toLocaleDateString('vi-VN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    });
  }
}

