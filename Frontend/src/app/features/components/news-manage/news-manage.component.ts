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
import { EditorModule, Editor } from 'primeng/editor';
import { environment } from '../../../../environments/environment.development';
import { AiService } from '../../../core/services/ai.service';
import { finalize } from 'rxjs/operators';

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
export class NewsManageComponent implements OnInit, AfterViewChecked {
  @ViewChild('editor') editor!: Editor;
  
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
    this.pendingContent = null;
    this.newsForm.reset({ status: 'DRAFT' });
    this.displayDialog = true;
    this.cdr.markForCheck();
  }

  openEditDialog(news: NewsDto): void {
    this.isEditMode = true;
    this.selectedNewsId = news.id;
    this.selectedFile = null;
    this.imagePreview = news.featured_image ? `${environment.apiUrl}/news/images/${news.featured_image}` : null;
    
    // Store content to set later after editor is ready
    this.pendingContent = news.content || '';
    
    this.newsForm.patchValue({
      title: news.title,
      content: '', // Set empty first, will set after editor ready
      summary: news.summary,
      author: news.author,
      category: news.category,
      status: news.status,
      featured_image: news.featured_image
    });
    
    this.displayDialog = true;
    this.cdr.markForCheck();
    
    // Wait for editor to initialize then set content
    if (this.isBrowser && this.pendingContent) {
      setTimeout(() => {
        if (this.pendingContent) {
          this.setEditorContent(this.pendingContent);
        }
      }, 100);
    }
  }
  
  ngAfterViewChecked(): void {
    // Set content when editor is ready (only once)
    if (this.pendingContent && this.editor && this.displayDialog && this.editor.quill) {
      const content = this.pendingContent;
      this.pendingContent = null; // Clear immediately to prevent multiple calls
      
      setTimeout(() => {
        this.setEditorContent(content);
      }, 50);
    }
  }
  
  private setEditorContentWithRetry(content: string, attempt: number, maxAttempts: number): void {
    if (!content) return;
    
    // Clean and validate HTML content
    let cleanedContent = content.trim();
    
    // Check if editor is ready
    if (this.editor && this.editor.quill && this.editor.quill.root) {
      try {
        console.log('Setting editor content, attempt:', attempt + 1, 'Content length:', cleanedContent.length);
        
        // Method 1: Set via formControl - PrimeNG Editor should sync automatically
        // Use emitEvent: true to trigger change detection
        this.newsForm.patchValue({ content: cleanedContent }, { emitEvent: true });
        this.cdr.detectChanges();
        
        // Method 2: Set directly to Quill root
        // Clear first, then set new content
        this.editor.quill.setText('');
        this.editor.quill.root.innerHTML = cleanedContent;
        
        // Method 3: Use Quill's clipboard to paste HTML (most reliable)
        try {
          const delta = this.editor.quill.clipboard.convert({ html: cleanedContent });
          this.editor.quill.setContents(delta, 'api');
        } catch (e) {
          console.log('Delta conversion failed, using innerHTML');
        }
        
        // Force update
        this.editor.quill.update();
        this.editor.quill.focus();
        
        // Verify content was set
        const formControlValue = this.newsForm.get('content')?.value || '';
        const quillContent = this.editor.quill.root.innerHTML || '';
        const quillText = this.editor.quill.getText() || '';
        
        console.log('After setting - Form control length:', formControlValue.length);
        console.log('After setting - Quill HTML length:', quillContent.length);
        console.log('After setting - Quill text length:', quillText.length);
        
        // If content is set in any form, consider it successful
        if ((formControlValue && formControlValue.trim().length > 0) || 
            (quillContent && quillContent.trim().length > 0) ||
            (quillText && quillText.trim().length > 10)) {
          console.log('✓ Content set successfully to editor');
          this.cdr.markForCheck();
          return;
        } else {
          console.warn('Content not visible in editor, will retry');
        }
      } catch (error) {
        console.error('Error setting editor content:', error);
      }
    } else {
      console.log('Editor not ready yet, editor:', !!this.editor, 'quill:', !!(this.editor?.quill), 'root:', !!(this.editor?.quill?.root));
    }
    
    // Retry if editor not ready and haven't exceeded max attempts
    if (attempt < maxAttempts) {
      setTimeout(() => {
        this.setEditorContentWithRetry(content, attempt + 1, maxAttempts);
      }, 300);
    } else {
      // Last resort: set form control and try to sync manually
      console.warn('Editor not ready after max attempts, setting form control only');
      this.newsForm.patchValue({ content: cleanedContent }, { emitEvent: true });
      
      // Try one more time to set to Quill if it's now available
      if (this.editor && this.editor.quill && this.editor.quill.root) {
        this.editor.quill.root.innerHTML = cleanedContent;
        this.editor.quill.update();
      }
      
      this.cdr.markForCheck();
    }
  }

  private setEditorContent(content: string): void {
    if (!content) return;
    
    // Clean and validate HTML content
    let cleanedContent = content.trim();
    
    // Set form control first (PrimeNG Editor binds to this)
    this.newsForm.patchValue({ content: cleanedContent }, { emitEvent: false });
    
    // Then set directly to Quill if available
    if (this.editor && this.editor.quill && this.editor.quill.root) {
      try {
        // Set HTML directly - PrimeNG Editor handles this well
        this.editor.quill.root.innerHTML = cleanedContent;
        // Trigger update to ensure UI refreshes
        this.editor.quill.update();
        console.log('Content set to editor via innerHTML');
      } catch (error) {
        console.error('Error setting editor content via innerHTML:', error);
        // Try alternative method
        try {
          const delta = this.editor.quill.clipboard.convert({ html: cleanedContent });
          this.editor.quill.setContents(delta, 'silent');
          console.log('Content set to editor via Delta');
        } catch (deltaError) {
          console.error('Error setting editor content via Delta:', deltaError);
        }
      }
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
            // Get word count from response or calculate it
            const wordCount = response.wordCount || content.trim().split(/\s+/).length;
            const minWords = 800; // Minimum words for news content
            
            // Show warning if content is too short or if backend sent warning
            if (response.warning || wordCount < minWords) {
              const warningMsg = response.warning || `Cảnh báo: Nội dung chỉ có ${wordCount} từ, có thể chưa đủ chi tiết (tối thiểu: ${minWords} từ).`;
              this.toastService.warn(warningMsg);
            }
            
            // Use setEditorContent to set both form control and Quill editor
            // Wait a bit for dialog to fully render, then set content
            setTimeout(() => {
              this.setEditorContentWithRetry(content, 0, 5);
              
              const successMsg = wordCount >= minWords 
                ? `Đã tạo nội dung bằng AI (${wordCount} từ)`
                : `Đã tạo nội dung bằng AI (${wordCount} từ - có thể cần mở rộng thêm)`;
              this.toastService.showSuccess('Thành công', successMsg);
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

