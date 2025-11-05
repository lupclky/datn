import { Component, OnInit, ChangeDetectorRef, ChangeDetectionStrategy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { MessageService, ConfirmationService } from 'primeng/api';
import { TableModule } from 'primeng/table';
import { ButtonModule } from 'primeng/button';
import { DialogModule } from 'primeng/dialog';
import { InputTextModule } from 'primeng/inputtext';
import { InputTextareaModule } from 'primeng/inputtextarea';
import { InputNumberModule } from 'primeng/inputnumber';
import { DropdownModule } from 'primeng/dropdown';
import { ToastModule } from 'primeng/toast';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { ImageModule } from 'primeng/image';
import { TagModule } from 'primeng/tag';
import { MultiSelectModule } from 'primeng/multiselect';
import { FileUploadModule } from 'primeng/fileupload';
import { TooltipModule } from 'primeng/tooltip';
import { QuillModule } from 'ngx-quill';
import { ProductService } from '../../../core/services/product.service';
import { CategoriesService } from '../../../core/services/categories.service';
import { LockFeatureService, LockFeature } from '../../../core/services/lock-feature.service';
import { ToastService } from '../../../core/services/toast.service';
import { AiService } from '../../../core/services/ai.service';
import { ProductDto } from '../../../core/dtos/product.dto';
import { AllProductDto } from '../../../core/dtos/AllProduct.dto';
import { environment } from '../../../../environments/environment.development';
import { finalize } from 'rxjs';

interface ProductUploadReq {
  name: string;
  price: number;
  description: string;
  category_id: number;
  discount: number;
  quantity: number;
  featureIds: number[];
}

@Component({
  selector: 'app-product-manage',
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
    InputNumberModule,
    DropdownModule,
    ToastModule,
    ConfirmDialogModule,
    ImageModule,
    TagModule,
    MultiSelectModule,
    FileUploadModule,
    TooltipModule,
    QuillModule
  ],
  providers: [MessageService, ToastService, ConfirmationService],
  templateUrl: './product-manage.component.html',
  styleUrl: './product-manage.component.scss'
  // Tạm tắt OnPush để debug
  // changeDetection: ChangeDetectionStrategy.OnPush
})
export class ProductManageComponent implements OnInit {
  products: ProductDto[] = [];
  allProducts: ProductDto[] = []; // Store all products
  filteredProducts: ProductDto[] = []; // Filtered products for display
  displayDialog: boolean = false;
  productForm!: FormGroup;
  isEditMode: boolean = false;
  selectedProductId: number | null = null;
  currentPage: number = 0;
  totalPages: number = 0;
  pageSize: number = 10;
  totalRecords: number = 0;
  first: number = 0; // For paginator
  isLoading: boolean = false;
  searchKeyword: string = '';
  selectedFiles: File[] = [];
  imagePreviews: string[] = [];
  isUploading: boolean = false;
  apiImage: string = environment.apiImage;
  isGeneratingDescription: boolean = false;

  // Quill editor configuration
  quillModules = {
    toolbar: [
      [{ 'header': [1, 2, 3, 4, 5, 6, false] }],
      ['bold', 'italic', 'underline', 'strike'],
      [{ 'color': [] }, { 'background': [] }],
      [{ 'list': 'ordered'}, { 'list': 'bullet' }],
      [{ 'align': [] }],
      ['link', 'image', 'video'],
      ['clean']
    ]
  };

  categoriesOptions: any[] = [];
  featuresOptions: any[] = [];
  selectedFeatures: number[] = [];
  
  // Filter properties
  filterCategory: number | null = null;
  filterStockStatus: string | null = null;
  filterFeatures: number[] = [];
  filterMinPrice: number | null = null;
  filterMaxPrice: number | null = null;
  showFilters: boolean = false;
  
  // Stock status options
  stockStatusOptions = [
    { label: 'Tất cả', value: null },
    { label: 'Còn hàng', value: 'available' },
    { label: 'Sắp hết', value: 'low' },
    { label: 'Hết hàng', value: 'out' }
  ];

  constructor(
    private productService: ProductService,
    private categoriesService: CategoriesService,
    private lockFeatureService: LockFeatureService,
    private fb: FormBuilder,
    private messageService: MessageService,
    private toastService: ToastService,
    private confirmationService: ConfirmationService,
    private cdr: ChangeDetectorRef,
    private router: Router,
    private aiService: AiService
  ) {
    this.initForm();
  }

  ngOnInit(): void {
    this.loadProducts();
    this.loadCategories();
    this.loadFeatures();
  }

  initForm(): void {
    this.productForm = this.fb.group({
      name: ['', Validators.required],
      price: [0, [Validators.required, Validators.min(0)]],
      description: [''],
      category_id: [null, Validators.required],
      discount: [0, [Validators.min(0), Validators.max(100)]],
      quantity: [0, [Validators.required, Validators.min(0)]],
      featureIds: [[]]
    });
  }

  loadProducts(): void {
    this.isLoading = true;
    
    this.productService.getAllProduct().subscribe({
      next: (response: AllProductDto) => {
        this.allProducts = response.products;
        this.applyFilters();
        
        console.log('=== LOAD PRODUCTS ===');
        console.log('Total products:', this.allProducts.length);
        console.log('All products loaded, PrimeNG will handle pagination automatically');
        
        this.isLoading = false;
      },
      error: (error: any) => {
        console.error('Error loading products:', error);
        this.toastService.showError('Lỗi', 'Không thể tải danh sách sản phẩm');
        this.isLoading = false;
      }
    });
  }

  loadCategories(): void {
    this.categoriesService.getCategories().subscribe({
      next: (response: any) => {
        this.categoriesOptions = [
          { label: 'Tất cả danh mục', value: null },
          ...response.map((cat: any) => ({
            label: cat.name,
            value: cat.id
          }))
        ];
        this.cdr.markForCheck();
      },
      error: (error: any) => {
        console.error('Error loading categories:', error);
      }
    });
  }

  loadFeatures(): void {
    this.lockFeatureService.getAllFeatures().subscribe({
      next: (response: LockFeature[]) => {
        this.featuresOptions = response.map((feature: LockFeature) => ({
          label: feature.name,
          value: feature.id
        }));
        this.cdr.markForCheck();
      },
      error: (error: any) => {
        console.error('Error loading features:', error);
      }
    });
  }

  searchProducts(): void {
    if (this.searchKeyword.trim()) {
      this.isLoading = true;
      this.productService.searchProduct(this.searchKeyword).subscribe({
        next: (response: AllProductDto) => {
          this.allProducts = response.products;
          this.applyFilters();
          this.isLoading = false;
        },
        error: (error: any) => {
          console.error('Error searching products:', error);
          this.isLoading = false;
        }
      });
    } else {
      this.loadProducts();
    }
  }

  applyFilters(): void {
    let filtered = [...this.allProducts];

    // Filter by category
    if (this.filterCategory !== null) {
      filtered = filtered.filter(p => p.category_id === this.filterCategory);
    }

    // Filter by stock status
    if (this.filterStockStatus) {
      filtered = filtered.filter(p => {
        if (this.filterStockStatus === 'available') {
          return p.quantity >= 10;
        } else if (this.filterStockStatus === 'low') {
          return p.quantity > 0 && p.quantity < 10;
        } else if (this.filterStockStatus === 'out') {
          return p.quantity === 0;
        }
        return true;
      });
    }

    // Filter by features
    if (this.filterFeatures.length > 0) {
      filtered = filtered.filter(p => {
        if (!p.features || p.features.length === 0) return false;
        return this.filterFeatures.some(featureId => 
          p.features!.some(f => f.id === featureId)
        );
      });
    }

    // Filter by price range
    if (this.filterMinPrice !== null && this.filterMinPrice > 0) {
      filtered = filtered.filter(p => p.price >= this.filterMinPrice!);
    }
    if (this.filterMaxPrice !== null && this.filterMaxPrice > 0) {
      filtered = filtered.filter(p => p.price <= this.filterMaxPrice!);
    }

    this.filteredProducts = filtered;
    this.totalRecords = this.filteredProducts.length;
    this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
    this.cdr.markForCheck();
  }

  clearFilters(): void {
    this.filterCategory = null;
    this.filterStockStatus = null;
    this.filterFeatures = [];
    this.filterMinPrice = null;
    this.filterMaxPrice = null;
    this.applyFilters();
  }

  toggleFilters(): void {
    this.showFilters = !this.showFilters;
  }

  openNewDialog(): void {
    this.isEditMode = false;
    this.selectedProductId = null;
    this.selectedFiles = [];
    this.imagePreviews = [];
    this.selectedFeatures = [];
    this.productForm.reset({ discount: 0, quantity: 0, price: 0 });
    this.displayDialog = true;
    this.cdr.markForCheck();
  }

  openEditDialog(product: ProductDto): void {
    this.router.navigate(['/detailProduct', product.id]);
  }

  viewProduct(product: ProductDto): void {
    this.router.navigate(['/detailProduct', product.id]);
  }

  onFilesSelected(event: any): void {
    const files = event.currentFiles || event.files;
    if (files && files.length > 0) {
      // Validate max 5 images
      if (files.length > 5) {
        this.toastService.showError('Lỗi', 'Chỉ được chọn tối đa 5 ảnh');
        return;
      }

      this.selectedFiles = Array.from(files);
      this.imagePreviews = [];

      // Create previews
      this.selectedFiles.forEach(file => {
        const reader = new FileReader();
        reader.onload = (e: any) => {
          this.imagePreviews.push(e.target.result);
          this.cdr.markForCheck();
        };
        reader.readAsDataURL(file);
      });
    }
  }

  async saveProduct(): Promise<void> {
    if (this.productForm.invalid) {
      this.toastService.showError('Lỗi', 'Vui lòng điền đầy đủ thông tin');
      return;
    }

    try {
      const productData: ProductUploadReq = {
        name: this.productForm.value.name,
        price: this.productForm.value.price,
        description: this.productForm.value.description || '',
        category_id: this.productForm.value.category_id,
        discount: this.productForm.value.discount || 0,
        quantity: this.productForm.value.quantity,
        featureIds: this.productForm.value.featureIds || []
      };

      // Create product
      this.productService.uploadProduct(productData).subscribe({
        next: (response: {productId: number, message: string}) => {
          const productId = response.productId;
          
          // Upload images if any
          if (this.selectedFiles.length > 0) {
            this.uploadImages(productId);
          } else {
            this.toastService.showSuccess('Thành công', 'Tạo sản phẩm thành công');
            this.displayDialog = false;
            this.loadProducts();
          }
        },
        error: (error: any) => {
          console.error('Error creating product:', error);
          this.toastService.showError('Lỗi', 'Không thể tạo sản phẩm');
        }
      });
    } catch (error) {
      console.error('Error in saveProduct:', error);
    }
  }

  uploadImages(productId: number): void {
    this.isUploading = true;
    this.cdr.markForCheck();

    const formData = new FormData();
    this.selectedFiles.forEach(file => {
      formData.append('files', file);
    });

    this.productService.uploadImageProduct(formData, productId).subscribe({
      next: (response: {message: string}) => {
        this.isUploading = false;
        this.toastService.showSuccess('Thành công', 'Tạo sản phẩm và upload ảnh thành công');
        this.displayDialog = false;
        this.loadProducts();
        this.cdr.markForCheck();
      },
      error: (error: any) => {
        console.error('Error uploading images:', error);
        this.isUploading = false;
        this.toastService.showError('Lỗi', 'Sản phẩm đã tạo nhưng không thể upload ảnh');
        this.displayDialog = false;
        this.loadProducts();
        this.cdr.markForCheck();
      }
    });
  }

  deleteProduct(id: number): void {
    this.confirmationService.confirm({
      message: 'Bạn có chắc chắn muốn xóa sản phẩm này?',
      header: 'Xác nhận xóa',
      icon: 'pi pi-exclamation-triangle',
      accept: () => {
        this.productService.deleteProduct(id.toString()).subscribe({
          next: (response: any) => {
            this.toastService.showSuccess('Thành công', 'Xóa sản phẩm thành công');
            this.loadProducts();
          },
          error: (error: any) => {
            console.error('Error deleting product:', error);
            this.toastService.showError('Lỗi', 'Không thể xóa sản phẩm');
          }
        });
      }
    });
  }

  onPageChange(event: any): void {
    console.log('=== PAGE CHANGE EVENT ===', event);
    this.pageSize = event.rows;
    this.currentPage = event.page;
    // PrimeNG handles pagination automatically when lazy=false
  }

  getProductImage(product: ProductDto): string {
    // If product has a thumbnail, use it
    if (product.thumbnail && product.thumbnail.trim() !== '') {
      return `${this.apiImage}${product.thumbnail}`;
    }
    
    // If no thumbnail but has product_images, use the first one
    if (product.product_images && product.product_images.length > 0) {
      return `${this.apiImage}${product.product_images[0].image_url}`;
    }
    
    // Default image if no images available
    return 'assets/images/no-image.png';
  }

  getStockStatus(quantity: number): string {
    if (quantity === 0) return 'Hết hàng';
    if (quantity < 10) return 'Sắp hết';
    return 'Còn hàng';
  }

  getStockSeverity(quantity: number): string {
    if (quantity === 0) return 'danger';
    if (quantity < 10) return 'warning';
    return 'success';
  }

  formatPrice(price: number): string {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND'
    }).format(price);
  }

  getCategoryName(categoryId: number | null): string {
    if (!categoryId) return 'N/A';
    const category = this.categoriesOptions.find(cat => cat['value'] === categoryId);
    return category ? category['label'] : 'N/A';
  }

  generateProductDescription(): void {
    const productName = this.productForm.get('name')?.value;
    const categoryId = this.productForm.get('category_id')?.value;
    const featureIds = this.productForm.get('featureIds')?.value || [];

    if (!productName) {
      this.toastService.warn('Vui lòng nhập tên sản phẩm trước');
      return;
    }

    // Get category name
    const categoryName = this.getCategoryName(categoryId);

    // Get feature names
    const featureNames = featureIds
      .map((id: number) => this.featuresOptions.find(f => f['value'] === id)?.['label'])
      .filter((name: string | undefined) => name)
      .join(', ');

    this.isGeneratingDescription = true;

    this.aiService.generateProductDescription(
      productName,
      categoryName !== 'N/A' ? categoryName : undefined,
      featureNames || undefined
    ).pipe(
      finalize(() => {
        this.isGeneratingDescription = false;
        this.cdr.markForCheck();
      })
    ).subscribe({
      next: (response: { content: string }) => {
        this.productForm.patchValue({ description: response.content });
        this.toastService.success('KVK Intelligence đã tạo mô tả sản phẩm thành công!');
        this.cdr.markForCheck();
      },
      error: (error: any) => {
        console.error('Error generating product description:', error);
        this.toastService.showError('Lỗi', 'Không thể tạo mô tả sản phẩm. Vui lòng thử lại.');
      }
    });
  }
}

