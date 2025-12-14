import { Component, OnInit, ChangeDetectionStrategy, ChangeDetectorRef, PLATFORM_ID, Inject, ViewChild, AfterViewChecked } from '@angular/core';
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
import { CKEditorModule } from '@ckeditor/ckeditor5-angular';
import { environment } from '../../../../environments/environment.development';
import { AiService } from '../../../core/services/ai.service';
import { finalize } from 'rxjs/operators';

import { CalendarModule } from 'primeng/calendar';
import { CheckboxModule } from 'primeng/checkbox';

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
    CKEditorModule,
    CalendarModule,
    CheckboxModule
  ],
  providers: [MessageService, ToastService, ConfirmationService],
  templateUrl: './news-manage.component.html',
  styleUrl: './news-manage.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class NewsManageComponent implements OnInit {
  public Editor: any;
  private editorInstance: any;

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
  isGenerating: boolean = false;
  pendingContent: string | null = null;
  
  // Facebook Share
  displayShareDialog: boolean = false;
  shareNewsId: number | null = null;
  scheduledDate: Date | null = null;
  minDate: Date = new Date();

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
    private aiService: AiService,
    @Inject(PLATFORM_ID) private platformId: Object
  ) {
    this.isBrowser = isPlatformBrowser(this.platformId);
    console.log(`isBrowser: ${this.isBrowser}`);
    this.initForm();
  }

  ngOnInit(): void {
    if (this.isBrowser) {
      console.log('Attempting to import CKEditor...');
      import('@ckeditor/ckeditor5-build-classic').then(editor => {
        console.log('CKEditor imported successfully.');
        this.Editor = editor.default;
        this.cdr.markForCheck();
      }).catch(error => {
        console.error('Error importing CKEditor:', error);
      });
      
      // Auto-sync Facebook status on load
      this.syncFacebookStatus();
    }
    this.loadNews();
  }

  syncFacebookStatus(): void {
    this.newsService.syncFacebookPosts().subscribe({
      next: () => {
        console.log('Facebook status synced');
        // Always reload to get the latest status
        this.loadNews();
      },
      error: (error) => {
        console.error('Failed to sync Facebook status:', error);
      }
    });
  }

  manualSyncFacebook(): void {
    this.isLoading = true;
    this.cdr.markForCheck();
    this.newsService.syncFacebookPosts().subscribe({
      next: () => {
        this.toastService.showSuccess('Thành công', 'Đã cập nhật trạng thái từ Facebook');
        this.loadNews();
      },
      error: (error) => {
        console.error('Failed to sync Facebook status:', error);
        this.toastService.showError('Lỗi', 'Không thể cập nhật trạng thái từ Facebook');
        this.isLoading = false;
        this.cdr.markForCheck();
      }
    });
  }

  initForm(): void {
    this.newsForm = this.fb.group({
      title: ['', [Validators.required, Validators.maxLength(500)]],
      content: [''],
      summary: ['', Validators.maxLength(1000)],
      author: [''],
      category: [''],
      status: ['DRAFT', Validators.required],
      featured_image: [''],
      share_to_facebook: [false]
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
    this.pendingContent = null;
    this.scheduledDate = null;
    this.newsForm.reset({ status: 'DRAFT', share_to_facebook: false });
    this.displayDialog = true;
    this.cdr.markForCheck();
  }

  openEditDialog(news: NewsDto): void {
    this.isEditMode = true;
    this.selectedNewsId = news.id;
    this.selectedFile = null;
    this.imagePreview = news.featured_image ? `${environment.apiUrl}/news/images/${news.featured_image}` : null;
    this.scheduledDate = null;
    
    // Store content to set later after editor is ready
    this.pendingContent = news.content || '';
    
    this.newsForm.patchValue({
      title: news.title,
      content: '', // Set empty first, will set after editor ready
      summary: news.summary,
      author: news.author,
      category: news.category,
      status: news.status,
      featured_image: news.featured_image,
      share_to_facebook: false
    });
    
    this.displayDialog = true;
    this.cdr.markForCheck();
    
    // Wait for editor to initialize then set content
    if (this.isBrowser && this.pendingContent) {
      this.newsForm.patchValue({ content: this.pendingContent });
      // The onEditorReady method will handle setting the data if the editor is already initialized.
    }
  }

  onEditorReady(editor: any) {
    console.log('CKEditor is ready.');
    this.editorInstance = editor;
    // If there is pending content, set it now that the editor is ready.
    if (this.pendingContent) {
      this.editorInstance.setData(this.pendingContent);
      this.pendingContent = null; // Clear the pending content
    }
  }

  private setEditorContent(content: string): void {
    // If the editor instance is ready, set the data directly.
    if (this.editorInstance) {
      this.editorInstance.setData(content);
    } else {
      // If the editor is not yet ready, store the content to be set in onEditorReady.
      this.pendingContent = content;
      // Also update the form control so the data isn't lost.
      this.newsForm.patchValue({ content: content });
    }
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

    if (this.editorInstance) {
      const editorData = this.editorInstance.getData();
      this.newsForm.patchValue({ content: editorData });
    }

    try {
      // Upload image first if there's a new file
      if (this.selectedFile) {
        const fileName = await this.uploadImage();
        this.newsForm.patchValue({ featured_image: fileName });
      }

      const newsData: NewsCreateRequest = this.newsForm.value;
      
      // Add scheduling info
      if (this.newsForm.get('share_to_facebook')?.value && this.scheduledDate) {
        newsData.facebook_scheduled_time = Math.floor(this.scheduledDate.getTime() / 1000);
      }

      if (this.isEditMode && this.selectedNewsId) {
        this.newsService.updateNews(this.selectedNewsId, newsData).subscribe({
          next: () => {
            this.toastService.showSuccess('Thành công', 'Cập nhật tin tức thành công');
            if (newsData.share_to_facebook) {
                 this.toastService.showInfo('Facebook', 'Đang xử lý đăng bài lên Facebook...');
            }
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
            if (newsData.share_to_facebook) {
                 this.toastService.showInfo('Facebook', 'Đang xử lý đăng bài lên Facebook...');
            }
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

  shareToFacebook(id: number): void {
    this.shareNewsId = id;
    this.scheduledDate = null;
    this.minDate = new Date();
    this.minDate.setMinutes(this.minDate.getMinutes() + 10); // Min 10 mins from now
    this.displayShareDialog = true;
    this.cdr.markForCheck();
  }

  confirmShare(): void {
    if (!this.shareNewsId) return;

    let scheduledTime: number | undefined;
    if (this.scheduledDate) {
      // Convert to Unix timestamp (seconds)
      scheduledTime = Math.floor(this.scheduledDate.getTime() / 1000);
    }

    this.newsService.shareToFacebook(this.shareNewsId, scheduledTime).subscribe({
      next: () => {
        const msg = scheduledTime 
          ? 'Đã lên lịch đăng bài lên Facebook thành công' 
          : 'Đã chia sẻ lên Facebook thành công';
        this.toastService.showSuccess('Thành công', msg);
        this.displayShareDialog = false;
        this.loadNews(); // Reload to show updated Facebook status
        this.cdr.markForCheck();
      },
      error: (error) => {
        console.error('Error sharing to Facebook:', error);
        let errorMsg = 'Không thể chia sẻ lên Facebook.';
        if (error.error) {
             errorMsg += ' ' + error.error;
        }
        this.toastService.showError('Lỗi', errorMsg);
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

  generateContent(): void {
    const title = this.newsForm.get('title')?.value;
    
    if (!title || title.trim() === '') {
      this.toastService.warn('Vui lòng nhập tiêu đề trước khi tạo nội dung');
      return;
    }

    // Get optional fields
    const category = this.newsForm.get('category')?.value;
    const summary = this.newsForm.get('summary')?.value;

    this.isGenerating = true;
    this.cdr.markForCheck();

    this.aiService.generateNewsContent(title, category, summary)
      .pipe(finalize(() => {
        this.isGenerating = false;
        this.cdr.markForCheck();
      }))
      .subscribe({
        next: (response) => {
          console.log('AI Response:', response);
          
          // Check if response has content
          const content = response?.content || '';
          
          if (response && response.success && content && content.trim() !== '') {
            // Use setEditorContent to set both form control and Quill editor
            // Wait a bit for dialog to fully render, then set content
            setTimeout(() => {
              this.setEditorContent(content);
              this.toastService.showSuccess('Thành công', 'Đã tạo nội dung bằng AI thành công!');
              this.cdr.markForCheck();
            }, 300);
          } else {
            console.error('Invalid response or empty content:', response);
            const errorMsg = response?.error || 'Không thể tạo nội dung hoặc nội dung trống';
            this.toastService.showError('Lỗi', errorMsg);
          }
        },
        error: (error) => {
          console.error('Error generating content:', error);
          let errorMessage = 'Không thể tạo nội dung. Vui lòng thử lại.';
          
          if (error.status === 0) {
            errorMessage = 'Không thể kết nối đến server AI.';
          } else if (error.status === 500) {
            errorMessage = 'Lỗi server khi tạo nội dung. Kiểm tra Google Cloud credentials.';
          } else if (error.error?.error) {
            errorMessage = error.error.error;
          }
          
          this.toastService.showError('Lỗi', errorMessage);
        }
      });
  }
}

