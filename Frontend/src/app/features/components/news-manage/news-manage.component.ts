import { Component, OnInit, ChangeDetectionStrategy, ChangeDetectorRef, PLATFORM_ID, Inject } from '@angular/core';
import { CommonModule, isPlatformBrowser } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { NewsService } from '../../../core/services/news.service';
import { NewsDto, NewsCreateRequest } from '../../../core/dtos/news.dto';
import { TableModule } from 'primeng/table';
import { ButtonModule } from 'primeng/button';
import { DialogModule } from 'primeng/dialog';
import { InputTextModule } from 'primeng/inputtext';
import { InputTextareaModule } from 'primeng/inputtextarea';
import { DropdownModule } from 'primeng/dropdown';
import { ToastModule } from 'primeng/toast';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { MessageService, ConfirmationService } from 'primeng/api';
import { ToastService } from '../../../core/services/toast.service';
import { EditorModule } from 'primeng/editor';
import { environment } from '../../../../environments/environment.development';

@Component({
  selector: 'app-news-manage',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    TableModule,
    ButtonModule,
    DialogModule,
    InputTextModule,
    InputTextareaModule,
    DropdownModule,
    ToastModule,
    ConfirmDialogModule,
    EditorModule
  ],
  providers: [MessageService, ToastService, ConfirmationService],
  templateUrl: './news-manage.component.html',
  styleUrl: './news-manage.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class NewsManageComponent implements OnInit {
  newsList: NewsDto[] = [];
  displayDialog: boolean = false;
  newsForm!: FormGroup;
  isEditMode: boolean = false;
  selectedNewsId: number | null = null;
  currentPage: number = 0;
  totalPages: number = 0;
  pageSize: number = 10;
  isLoading: boolean = false;
  isBrowser: boolean = false;
  selectedFile: File | null = null;
  imagePreview: string | null = null;
  isUploading: boolean = false;

  statusOptions = [
    { label: 'Nháp', value: 'DRAFT' },
    { label: 'Đã xuất bản', value: 'PUBLISHED' },
    { label: 'Đã lưu trữ', value: 'ARCHIVED' }
  ];

  constructor(
    private newsService: NewsService,
    private fb: FormBuilder,
    private messageService: MessageService,
    private toastService: ToastService,
    private confirmationService: ConfirmationService,
    private cdr: ChangeDetectorRef,
    @Inject(PLATFORM_ID) private platformId: Object
  ) {
    this.isBrowser = isPlatformBrowser(this.platformId);
    this.initForm();
  }

  ngOnInit(): void {
    this.loadNews();
  }

  initForm(): void {
    this.newsForm = this.fb.group({
      title: ['', [Validators.required, Validators.maxLength(500)]],
      content: [''],
      summary: ['', Validators.maxLength(1000)],
      author: [''],
      category: [''],
      status: ['DRAFT', Validators.required],
      featured_image: ['']
    });
  }

  loadNews(): void {
    this.isLoading = true;
    this.cdr.markForCheck();
    this.newsService.getAllNewsForAdmin(this.currentPage, this.pageSize).subscribe({
      next: (response) => {
        this.newsList = response.news_list;
        this.totalPages = response.total_pages;
        this.isLoading = false;
        this.cdr.markForCheck();
      },
      error: (error) => {
        console.error('Error loading news:', error);
        this.toastService.showError('Lỗi', 'Không thể tải danh sách tin tức');
        this.isLoading = false;
        this.cdr.markForCheck();
      }
    });
  }

  openNewDialog(): void {
    this.isEditMode = false;
    this.selectedNewsId = null;
    this.selectedFile = null;
    this.imagePreview = null;
    this.newsForm.reset({ status: 'DRAFT' });
    this.displayDialog = true;
    this.cdr.markForCheck();
  }

  openEditDialog(news: NewsDto): void {
    this.isEditMode = true;
    this.selectedNewsId = news.id;
    this.selectedFile = null;
    this.imagePreview = news.featured_image ? `${environment.apiUrl}/news/images/${news.featured_image}` : null;
    this.newsForm.patchValue({
      title: news.title,
      content: news.content,
      summary: news.summary,
      author: news.author,
      category: news.category,
      status: news.status,
      featured_image: news.featured_image
    });
    this.displayDialog = true;
    this.cdr.markForCheck();
  }

  onFileSelected(event: any): void {
    const file = event.target.files[0];
    if (file) {
      // Validate file type
      if (!file.type.startsWith('image/')) {
        this.toastService.showError('Lỗi', 'Vui lòng chọn file ảnh');
        return;
      }

      // Validate file size (max 5MB)
      if (file.size > 5 * 1024 * 1024) {
        this.toastService.showError('Lỗi', 'Kích thước file không được vượt quá 5MB');
        return;
      }

      this.selectedFile = file;

      // Preview image
      const reader = new FileReader();
      reader.onload = (e: any) => {
        this.imagePreview = e.target.result;
        this.cdr.markForCheck();
      };
      reader.readAsDataURL(file);
    }
  }

  uploadImage(): Promise<string> {
    return new Promise((resolve, reject) => {
      if (!this.selectedFile) {
        resolve('');
        return;
      }

      this.isUploading = true;
      this.cdr.markForCheck();

      this.newsService.uploadFeaturedImage(this.selectedFile).subscribe({
        next: (response) => {
          this.isUploading = false;
          this.cdr.markForCheck();
          resolve(response.fileName);
        },
        error: (error) => {
          console.error('Error uploading image:', error);
          this.isUploading = false;
          this.cdr.markForCheck();
          this.toastService.showError('Lỗi', 'Không thể upload ảnh');
          reject(error);
        }
      });
    });
  }

  async saveNews(): Promise<void> {
    if (this.newsForm.invalid) {
      this.toastService.showError('Lỗi', 'Vui lòng điền đầy đủ thông tin');
      return;
    }

    try {
      // Upload image first if there's a new file
      if (this.selectedFile) {
        const fileName = await this.uploadImage();
        this.newsForm.patchValue({ featured_image: fileName });
      }

      const newsData: NewsCreateRequest = this.newsForm.value;

      if (this.isEditMode && this.selectedNewsId) {
        this.newsService.updateNews(this.selectedNewsId, newsData).subscribe({
          next: () => {
            this.toastService.showSuccess('Thành công', 'Cập nhật tin tức thành công');
            this.displayDialog = false;
            this.loadNews();
          },
          error: (error) => {
            console.error('Error updating news:', error);
            this.toastService.showError('Lỗi', 'Không thể cập nhật tin tức');
          }
        });
      } else {
        this.newsService.createNews(newsData).subscribe({
          next: () => {
            this.toastService.showSuccess('Thành công', 'Tạo tin tức thành công');
            this.displayDialog = false;
            this.loadNews();
          },
          error: (error) => {
            console.error('Error creating news:', error);
            this.toastService.showError('Lỗi', 'Không thể tạo tin tức');
          }
        });
      }
    } catch (error) {
      console.error('Error in saveNews:', error);
    }
  }

  deleteNews(id: number): void {
    this.confirmationService.confirm({
      message: 'Bạn có chắc chắn muốn xóa tin tức này?',
      header: 'Xác nhận xóa',
      icon: 'pi pi-exclamation-triangle',
      acceptLabel: 'Xóa',
      rejectLabel: 'Hủy',
      accept: () => {
        this.newsService.deleteNews(id).subscribe({
          next: () => {
            this.toastService.showSuccess('Thành công', 'Xóa tin tức thành công');
            this.loadNews();
          },
          error: (error) => {
            console.error('Error deleting news:', error);
            this.toastService.showError('Lỗi', 'Không thể xóa tin tức');
          }
        });
      }
    });
  }

  publishNews(id: number): void {
    this.newsService.publishNews(id).subscribe({
      next: () => {
        this.toastService.showSuccess('Thành công', 'Xuất bản tin tức thành công');
        this.loadNews();
      },
      error: (error) => {
        console.error('Error publishing news:', error);
        this.toastService.showError('Lỗi', 'Không thể xuất bản tin tức');
      }
    });
  }

  archiveNews(id: number): void {
    this.newsService.archiveNews(id).subscribe({
      next: () => {
        this.toastService.showSuccess('Thành công', 'Lưu trữ tin tức thành công');
        this.loadNews();
      },
      error: (error) => {
        console.error('Error archiving news:', error);
        this.toastService.showError('Lỗi', 'Không thể lưu trữ tin tức');
      }
    });
  }

  getStatusLabel(status: string): string {
    const option = this.statusOptions.find(opt => opt.value === status);
    return option ? option.label : status;
  }

  getStatusClass(status: string): string {
    switch (status) {
      case 'PUBLISHED':
        return 'badge bg-success';
      case 'DRAFT':
        return 'badge bg-warning';
      case 'ARCHIVED':
        return 'badge bg-secondary';
      default:
        return 'badge bg-light';
    }
  }

  formatDate(dateString: string): string {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleDateString('vi-VN');
  }

  nextPage(): void {
    if (this.currentPage < this.totalPages - 1) {
      this.currentPage++;
      this.loadNews();
    }
  }

  previousPage(): void {
    if (this.currentPage > 0) {
      this.currentPage--;
      this.loadNews();
    }
  }

  onPageChange(event: any): void {
    this.currentPage = event.page;
    this.pageSize = event.rows;
    this.loadNews();
  }
}

