import { Component, OnInit, ChangeDetectionStrategy, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { BannerService } from '../../../core/services/banner.service';
import { BannerDto } from '../../../core/dtos/banner.dto';
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
import { InputNumberModule } from 'primeng/inputnumber';
import { CalendarModule } from 'primeng/calendar';
import { TooltipModule } from 'primeng/tooltip';
import { environment } from '../../../../environments/environment.development';
import { CheckboxModule } from 'primeng/checkbox';

@Component({
  selector: 'app-banner-manage',
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
    InputNumberModule,
    CalendarModule,
    TooltipModule,
    CheckboxModule
  ],
  providers: [MessageService, ConfirmationService],
  templateUrl: './banner-manage.component.html',
  styleUrl: './banner-manage.component.scss'
  // Tạm thời tắt OnPush để icons hiển thị đúng ngay lần đầu
  // changeDetection: ChangeDetectionStrategy.OnPush
})
export class BannerManageComponent implements OnInit {
  banners: BannerDto[] = [];
  bannerForm!: FormGroup;
  displayDialog: boolean = false;
  isEditMode: boolean = false;
  selectedBannerId: number | null = null;
  selectedFile: File | null = null;
  imagePreview: string | null = null;
  isUploading: boolean = false;

  buttonStyleOptions = [
    { label: 'Primary (Xanh)', value: 'primary' },
    { label: 'Danger (Đỏ)', value: 'danger' },
    { label: 'Success (Xanh lá)', value: 'success' },
    { label: 'Warning (Vàng)', value: 'warning' },
    { label: 'Info (Xanh dương)', value: 'info' }
  ];

  constructor(
    private bannerService: BannerService,
    private fb: FormBuilder,
    private messageService: MessageService,
    private toastService: ToastService,
    private confirmationService: ConfirmationService,
    private cdr: ChangeDetectorRef
  ) {
    this.initForm();
  }

  ngOnInit(): void {
    this.loadBanners();
  }

  initForm(): void {
    this.bannerForm = this.fb.group({
      title: ['', [Validators.required]],
      description: [''],
      image_url: ['', [Validators.required]],
      button_text: [''],
      button_link: [''],
      button_style: ['primary'],
      display_order: [0],
      is_active: [true],
      start_date: [null],
      end_date: [null]
    });

    // Custom validator: image_url is required only when creating new banner
    // For edit mode, image_url can be empty if no new file is selected
    this.bannerForm.get('image_url')?.valueChanges.subscribe(() => {
      this.updateImageUrlValidator();
    });
  }

  private updateImageUrlValidator(): void {
    const imageUrlControl = this.bannerForm.get('image_url');
    if (!imageUrlControl) return;

    if (this.isEditMode) {
      // In edit mode, image_url is only required if no file is selected and no existing image
      const hasExistingImage = imageUrlControl.value && imageUrlControl.value !== '' && imageUrlControl.value !== 'temp_uploading';
      const hasSelectedFile = !!this.selectedFile;
      if (hasExistingImage || hasSelectedFile) {
        imageUrlControl.clearValidators();
      } else {
        imageUrlControl.setValidators([Validators.required]);
      }
    } else {
      // In create mode, image_url is required but we accept temp_uploading if file is selected
      if (this.selectedFile || (imageUrlControl.value && imageUrlControl.value !== '')) {
        imageUrlControl.clearValidators();
      } else {
        imageUrlControl.setValidators([Validators.required]);
      }
    }
    imageUrlControl.updateValueAndValidity({ emitEvent: false });
  }

  loadBanners(): void {
    this.bannerService.getAllBanners().subscribe({
      next: (response) => {
        this.banners = response.banners || [];
        this.cdr.detectChanges();
      },
      error: (error) => {
        console.error('Error loading banners:', error);
        this.toastService.showError('Lỗi', 'Không thể tải danh sách banner');
        this.banners = [];
      }
    });
  }

  openNewDialog(): void {
    this.isEditMode = false;
    this.selectedBannerId = null;
    this.selectedFile = null;
    this.imagePreview = null;
    this.bannerForm.reset({
      title: '',
      description: '',
      image_url: '',
      button_text: '',
      button_link: '',
      button_style: 'primary',
      display_order: 0,
      is_active: true,
      start_date: null,
      end_date: null
    });
    this.updateImageUrlValidator();
    this.displayDialog = true;
    this.cdr.markForCheck();
  }

  openEditDialog(banner: BannerDto): void {
    this.isEditMode = true;
    this.selectedBannerId = banner.id!;
    this.selectedFile = null;
    const cleanApiImage = environment.apiUrl.replace(/\/$/, '') + '/banners/images';
    const cleanImageUrl = banner.image_url ? banner.image_url.replace(/^\//, '') : '';
    this.imagePreview = banner.image_url ? `${cleanApiImage}/${cleanImageUrl}` : null;
    
    // Helper function to safely parse date
    const parseDateSafely = (dateString: string | null | undefined): Date | null => {
      if (!dateString) return null;
      const date = new Date(dateString);
      return isNaN(date.getTime()) ? null : date;
    };

    this.bannerForm.patchValue({
      title: banner.title,
      description: banner.description,
      image_url: banner.image_url,
      button_text: banner.button_text,
      button_link: banner.button_link,
      button_style: banner.button_style,
      display_order: banner.display_order,
      is_active: banner.is_active,
      start_date: parseDateSafely(banner.start_date),
      end_date: parseDateSafely(banner.end_date)
    });
    this.updateImageUrlValidator();
    this.displayDialog = true;
    this.cdr.markForCheck();
  }

  onFileSelect(event: any): void {
    const file = event.target.files[0];
    if (file) {
      this.selectedFile = file;
      // Set a temporary value to image_url so form validation passes
      // The actual file name will be set after upload
      this.bannerForm.patchValue({ image_url: 'temp_uploading' });
      this.updateImageUrlValidator();
      const reader = new FileReader();
      reader.onload = (e: any) => {
        this.imagePreview = e.target.result;
        this.cdr.markForCheck();
      };
      reader.readAsDataURL(file);
    } else {
      // If no file selected, clear the image_url if creating new banner
      if (!this.isEditMode) {
        this.bannerForm.patchValue({ image_url: '' });
        this.updateImageUrlValidator();
      }
      this.selectedFile = null;
      this.imagePreview = null;
    }
    this.cdr.markForCheck();
  }

  uploadImage(): Promise<string> {
    return new Promise((resolve, reject) => {
      if (!this.selectedFile) {
        reject(new Error('No file selected'));
        return;
      }

      this.isUploading = true;
      this.cdr.markForCheck();

      const formData = new FormData();
      formData.append('file', this.selectedFile);

      this.bannerService.uploadBannerImage(formData).subscribe({
        next: (response: any) => {
          this.isUploading = false;
          this.cdr.markForCheck();
          
          if (response && response.fileName) {
            resolve(response.fileName);
          } else if (response && response.error) {
            reject(new Error(response.error));
          } else {
            reject(new Error('No file name returned from server'));
          }
        },
        error: (error: any) => {
          console.error('Error uploading image:', error);
          this.isUploading = false;
          this.cdr.markForCheck();
          
          const errorMessage = error?.error?.error || error?.error?.message || 'Không thể upload ảnh';
          this.toastService.showError('Lỗi', errorMessage);
          reject(error);
        }
      });
    });
  }

  async saveBanner(): Promise<void> {
    // Validate form
    if (this.bannerForm.invalid) {
      this.markFormGroupTouched(this.bannerForm);
      this.toastService.showError('Lỗi', 'Vui lòng điền đầy đủ thông tin bắt buộc');
      return;
    }

    // Validate image requirement
    if (!this.isEditMode && !this.selectedFile) {
      this.toastService.showError('Lỗi', 'Vui lòng chọn hình ảnh cho banner');
      return;
    }

    // Check if image_url is empty (for new banner) or missing (for edit without new file)
    const currentImageUrl = this.bannerForm.value.image_url;
    if (!this.isEditMode && !currentImageUrl && !this.selectedFile) {
      this.toastService.showError('Lỗi', 'Vui lòng chọn hình ảnh cho banner');
      return;
    }

    try {
      let imageUrl = currentImageUrl;

      // Upload new image if selected
      if (this.selectedFile) {
        try {
          const fileName = await this.uploadImage();
          if (fileName) {
            imageUrl = fileName;
            this.bannerForm.patchValue({ image_url: fileName });
          } else {
            this.toastService.showError('Lỗi', 'Không thể upload ảnh. Vui lòng thử lại');
            return;
          }
        } catch (error) {
          console.error('Error uploading image:', error);
          this.toastService.showError('Lỗi', 'Không thể upload ảnh. Vui lòng thử lại');
          return;
        }
      }

      // Validate image_url after upload
      if (!imageUrl || imageUrl.trim() === '') {
        this.toastService.showError('Lỗi', 'Hình ảnh banner là bắt buộc');
        return;
      }

      // Format dates to LocalDateTime format (yyyy-MM-dd HH:mm:ss) without timezone
      const formatDateForBackend = (date: Date | null | undefined): string | null => {
        if (!date) return null;
        
        const d = new Date(date);
        
        // Check if date is valid
        if (isNaN(d.getTime())) {
          console.warn('Invalid date provided:', date);
          return null;
        }
        
        const year = d.getFullYear();
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        const hours = String(d.getHours()).padStart(2, '0');
        const minutes = String(d.getMinutes()).padStart(2, '0');
        const seconds = String(d.getSeconds()).padStart(2, '0');
        return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
      };

      const bannerData: BannerDto = {
        ...this.bannerForm.value,
        image_url: imageUrl,
        start_date: formatDateForBackend(this.bannerForm.value.start_date),
        end_date: formatDateForBackend(this.bannerForm.value.end_date),
        created_at: undefined, // Don't send to backend
        updated_at: undefined  // Don't send to backend
      };

      if (this.isEditMode && this.selectedBannerId) {
        this.bannerService.updateBanner(this.selectedBannerId, bannerData).subscribe({
          next: () => {
            this.toastService.showSuccess('Thành công', 'Cập nhật banner thành công');
            this.displayDialog = false;
            this.loadBanners();
          },
          error: (error) => {
            console.error('Error updating banner:', error);
            const errorMessage = error?.error?.message || error?.error?.error || 'Không thể cập nhật banner';
            this.toastService.showError('Lỗi', errorMessage);
          }
        });
      } else {
        this.bannerService.createBanner(bannerData).subscribe({
          next: () => {
            this.toastService.showSuccess('Thành công', 'Tạo banner thành công');
            this.displayDialog = false;
            this.loadBanners();
          },
          error: (error) => {
            console.error('Error creating banner:', error);
            const errorMessage = error?.error?.message || error?.error?.error || 'Không thể tạo banner';
            this.toastService.showError('Lỗi', errorMessage);
          }
        });
      }
    } catch (error) {
      console.error('Error in saveBanner:', error);
      this.toastService.showError('Lỗi', 'Đã xảy ra lỗi không mong muốn');
    }
  }

  private markFormGroupTouched(formGroup: FormGroup): void {
    Object.keys(formGroup.controls).forEach(key => {
      const control = formGroup.get(key);
      control?.markAsTouched();
      if (control instanceof FormGroup) {
        this.markFormGroupTouched(control);
      }
    });
  }

  toggleStatus(banner: BannerDto): void {
    this.confirmationService.confirm({
      message: `Bạn có chắc muốn ${banner.is_active ? 'vô hiệu hóa' : 'kích hoạt'} banner này?`,
      header: 'Xác nhận',
      icon: 'pi pi-exclamation-triangle',
      accept: () => {
        this.bannerService.toggleBannerStatus(banner.id!).subscribe({
          next: () => {
            this.toastService.showSuccess('Thành công', 'Cập nhật trạng thái thành công');
            this.loadBanners();
          },
          error: (error) => {
            console.error('Error toggling banner status:', error);
            this.toastService.showError('Lỗi', 'Không thể cập nhật trạng thái');
          }
        });
      }
    });
  }

  deleteBanner(id: number): void {
    this.confirmationService.confirm({
      message: 'Bạn có chắc muốn xóa banner này?',
      header: 'Xác nhận xóa',
      icon: 'pi pi-exclamation-triangle',
      accept: () => {
        this.bannerService.deleteBanner(id).subscribe({
          next: () => {
            this.toastService.showSuccess('Thành công', 'Xóa banner thành công');
            this.loadBanners();
          },
          error: (error) => {
            console.error('Error deleting banner:', error);
            this.toastService.showError('Lỗi', 'Không thể xóa banner');
          }
        });
      }
    });
  }

  getBannerImageUrl(imageUrl: string): string {
    if (!imageUrl) {
      return 'assets/images/no-image.png'; // Fallback image
    }
    const cleanApiUrl = environment.apiUrl.replace(/\/$/, '');
    const cleanImageUrl = imageUrl.replace(/^\//, '');
    return `${cleanApiUrl}/banners/images/${cleanImageUrl}`;
  }

  onImageError(event: any): void {
    event.target.src = 'assets/images/no-image.png'; // Fallback on error
  }
}

