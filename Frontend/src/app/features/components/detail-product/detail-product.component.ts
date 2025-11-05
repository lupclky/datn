import { AfterViewInit, Component, OnInit } from '@angular/core';
import { BaseComponent } from '../../../core/commonComponent/base.component';
import { ProductService } from '../../../core/services/product.service';
import { ActivatedRoute, Router } from '@angular/router';
import { catchError, filter, finalize, of, switchMap, take, takeUntil, tap } from 'rxjs';
import { ProductDto } from '../../../core/dtos/product.dto';
import { GalleriaModule } from 'primeng/galleria';
import { InputNumberModule } from 'primeng/inputnumber';
import { FormBuilder, FormGroup, FormsModule, Validators, ReactiveFormsModule } from '@angular/forms';
import { CurrencyPipe } from '@angular/common';
import { ToastModule } from 'primeng/toast';
import { ConfirmationService, MenuItem, MessageService } from 'primeng/api';
import { ToastService } from '../../../core/services/toast.service';
import { DetailProductService } from '../../../core/services/detail-product.service';
import { CommonService } from '../../../core/services/common.service';
import { environment } from '../../../../environments/environment.development';
import { AllProductDto } from '../../../core/dtos/AllProduct.dto';
import { UserDto } from '../../../core/dtos/user.dto';
import { UserService } from '../../../core/services/user.service';
import { InputTextModule } from 'primeng/inputtext';
import { InputTextareaModule } from 'primeng/inputtextarea';
import { FileUpload, FileUploadModule } from 'primeng/fileupload';
import { ButtonModule } from 'primeng/button';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { DialogModule } from 'primeng/dialog';
import { LoadingService } from '../../../core/services/loading.service';
import { DropdownModule } from 'primeng/dropdown';
import { CardModule } from 'primeng/card';
import { CategoriesService } from '../../../core/services/categories.service';
import { CategoriesDto } from '../../../core/dtos/categories.dto';
import { RouterModule } from '@angular/router';
import { TabViewModule } from 'primeng/tabview';
import { ProductUploadReq } from '../../../core/requestType/UploadProducts';
import { ReviewService, Review, ReviewReplyRequest } from '../../../core/services/review.service';
import { RatingModule } from 'primeng/rating';
import { TooltipModule } from 'primeng/tooltip';
import { LockFeatureService } from '../../../core/services/lock-feature.service';
import { MultiSelectModule } from 'primeng/multiselect';
import { QuillModule } from 'ngx-quill';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { AiService } from '../../../core/services/ai.service';


@Component({
  selector: 'app-detail-product',
  standalone: true,
  imports: [
    GalleriaModule,
    InputNumberModule,
    FormsModule,
    CurrencyPipe,
    ToastModule,
    ReactiveFormsModule,
    InputTextModule,
    InputTextareaModule,
    FileUploadModule,
    ButtonModule,
    ConfirmDialogModule,
    DropdownModule,
    CardModule,
    RouterModule,
    TabViewModule,
    RatingModule,
    TooltipModule,
    MultiSelectModule,
    QuillModule,
    DialogModule
  ],
  templateUrl: './detail-product.component.html',
  styleUrl: './detail-product.component.scss'
})
export class DetailProductComponent extends BaseComponent implements OnInit,AfterViewInit {
  public productForm: FormGroup;
  public roleId: number = 100;
  public token: string | null = null; // Changed to public for template access
  private id !: string ;
  public mainProduct !: ProductDto;
  public responsiveOptions : any[] = [];
  public images : {id : number, image_url : string}[] = [];
  public relatedProducts: ProductDto[] = [];
  public quantity : number = 1;
  // Removed size selection for lock products
  public apiImage: string = environment.apiImage;
  public categoriesOptions: MenuItem[] = [];
  public featuresOptions: MenuItem[] = [];
  public selectedFeatures: number[] = [];
  private categoryId!: string;
  public categoryNameOfProduct!: string;
  public currentUserId: number = 0; // Add to compare with review owner
  
  // Reviews
  public reviews: Review[] = [];
  public averageRating: number = 0;
  public totalReviews: number = 0;
  public newReviewRating: number = 5;
  public newReviewComment: string = '';
  public isSubmittingReview: boolean = false;
  public hasUserReviewed: boolean = false;
  public accordionStates: { [key: number]: boolean } = {};
  public replyDialogVisible: boolean = false;
  public selectedReview: Review | null = null;
  public replyText: string = '';
  public isSubmittingReply: boolean = false;
  public isGeneratingDescription: boolean = false;
  public isDescriptionExpanded: boolean = false;
  public showExpandToggle: boolean = false;

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

  constructor(
    private readonly fb: FormBuilder,
    private productService : ProductService,
    private activatedRoute : ActivatedRoute,
    private router: Router,
    private readonly messageService: MessageService,
    private toastService : ToastService,
    private detailProductService: DetailProductService,
    private commonService: CommonService,
    private userService: UserService,
    private confirmationService: ConfirmationService,
    private loadingService: LoadingService,
    private categoriesService: CategoriesService,
    private reviewService: ReviewService,
    private lockFeatureService: LockFeatureService,
    private sanitizer: DomSanitizer,
    private aiService: AiService
  ) {
    super();
    if (typeof localStorage != 'undefined'){
      this.token = localStorage.getItem("token");
      const userInfor = JSON.parse(localStorage.getItem("userInfor") || '{"role_id": "0", "id": "0"}');
      this.roleId = parseInt(userInfor.role_id || '0');
      this.currentUserId = parseInt(userInfor.id || '0');
    }
    this.productForm = this.fb.group({
      productName: [, Validators.required],
      description: [, Validators.required],
      price:[, Validators.required],
      discount: [, Validators.required],
      quantity: [, Validators.required]
    })
  }
  ngAfterViewInit(): void {
    
  }

  ngOnInit(): void {
    if (this.token != null){
      this.userService.getInforUser(this.token).pipe(
        filter((userInfo: UserDto) => !!userInfo),
        tap((userInfo: UserDto) => {
          this.roleId = userInfo.role.id;
        }),
        takeUntil(this.destroyed$),
        catchError((err) => of(err))
      ).subscribe()
    }

    this.responsiveOptions = [
      {
        breakpoint: '1024px',
        numVisible: 5
    },
    {
        breakpoint: '768px',
        numVisible: 3
    },
    {
        breakpoint: '560px',
        numVisible: 1
    }
    ]

    this.id = this.activatedRoute.snapshot.paramMap.get('id') ?? '1';
    if (this.id != ":id"){
      this.productService.getProductById(this.id).pipe(
        filter((product : ProductDto) => !!product),
        tap((product : ProductDto) => {
          this.loadingService.loading = true;
          this.mainProduct = product;
          this.productForm.setValue({
            productName: product.name,
            description: product.description,
            price: product.price,
            discount: product.discount,
            quantity: product.quantity
          })
          this.categoryId = product.category_id?.toString() ?? '';
          this.images = product.product_images;
          // Set selected features
          if (product.features && product.features.length > 0) {
            this.selectedFeatures = product.features.map(f => f.id);
          }

          // Decide whether to show expand/collapse for description
          const plainTextLength = this.stripHtml(product.description || '').length;
          // Threshold: show toggle when description is long
          this.showExpandToggle = plainTextLength > 800;
          this.isDescriptionExpanded = false;
        }),
        switchMap(() => {
          return this.categoriesService.getCategoryById(parseInt(this.categoryId)).pipe(
            tap((category: CategoriesDto) => {
              this.categoryNameOfProduct = category.name;
            }),
            catchError((err) => {
              return of(err);
            })
          );
        }),
        catchError((err) => {
          return of(err);
        }),
        finalize(() => {
          this.loadingService.loading = false;
        })
      ).subscribe();

      this.productService.getRelatedProduct(this.id).pipe(
        filter((product : AllProductDto) => !!product),
        tap((product : AllProductDto) => {
          this.relatedProducts = product.products.filter(p => p.quantity > 0);
        }),
      ).subscribe();

      // Load reviews
      this.loadReviews();
    }

    this.categoriesService.getCategories().pipe(
      tap((categories) => {
        this.categoriesOptions = categories.map((item: CategoriesDto) => {
          return {
            label: item.name,
            value: item.id.toString()
          }
        })
      })
    ).subscribe();

    // Load features (only active ones for product assignment)
    this.lockFeatureService.getActiveFeatures().pipe(
      tap((features) => {
        this.featuresOptions = features.map((item) => {
          return {
            label: item.name,
            value: item.id
          }
        })
      })
    ).subscribe();
  }

  addToCart(){
    this.productService.addProductToCart({
      product_id: Number(this.id),
      quantity: this.quantity
    }).pipe(
      tap(() => {
        this.toastService.success("Thêm sản phẩm vào giỏ hàng thành công");
        this.detailProductService.setQuantity();
        this.commonService.intermediateObservable.next(true);
      }),
      catchError((error) => {
        this.toastService.fail("Thêm sản phẩm vào giỏ hàng thất bại");
        return of();
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  buyNow() {
    if (!this.token) {
      this.toastService.fail('Bạn phải đăng nhập để thực hiện chức năng này!');
      this.router.navigate(['/login']);
      return;
    }

    // Create temporary cart item data for immediate checkout
    const cartItems = [{
      id: Math.random(), // temporary id
      quantity: this.quantity,
      products: this.mainProduct
    }];

    // Store in localStorage and navigate to order page
    localStorage.setItem("productOrder", JSON.stringify(cartItems));
    this.router.navigate(['/order']);
  }

  goToDetail(id: number){
    window.location.href = `/detailProduct/${id}`;
  }

  onCategoryChange(event: any) {
    this.categoryId = event.value;
  }

  confirmDelete() {
    this.confirmationService.confirm({
        message: `Bạn có chắc chắn muốn xóa sản phẩm "${this.mainProduct?.name || 'này'}"? Hành động này không thể hoàn tác!`,
        header: 'Xác nhận xóa sản phẩm',
        icon: 'pi pi-exclamation-triangle',
        acceptIcon: "none",
        rejectIcon: "none",
        rejectButtonStyleClass: "p-button-text",
        acceptButtonStyleClass: "p-button-danger",
        accept: () => {
            this.deleteProduct();
        },
    });
  }

  deleteProduct(){
    this.productService.deleteProduct(this.mainProduct.id.toString()).pipe(
      tap(() => {
        this.toastService.success("Xóa sản phẩm thành công");
        // Đợi một chút để thông báo hiển thị trước khi chuyển trang
        setTimeout(() => {
          this.router.navigate(["/allProduct"]);
        }, 1500);
      }),
      catchError((err) => {
        // Attempt to parse the error response
        let errorMessage = "Xóa sản phẩm thất bại. Có thể sản phẩm này đã được đặt hàng.";
        if (err && err.error) {
          try {
            // If the error response is JSON with a 'message' property
            const errorResponse = JSON.parse(err.error);
            if (errorResponse.message) {
              errorMessage = errorResponse.message;
            }
          } catch (e) {
            // If the error response is just a string
            if (typeof err.error === 'string') {
              errorMessage = err.error;
            }
          }
        }
        this.toastService.fail(errorMessage);
        return of(err);
      })
    ).subscribe()
  }

  goBack(){
    this.router.navigate(["/"]);
  }

  trackByImageId(index: number, image: any): number {
    return image.id;
  }

  deleteImage(imageId: number): void {
    this.confirmationService.confirm({
      message: 'Bạn có chắc chắn muốn xóa vĩnh viễn ảnh này?',
      header: 'Xác nhận xóa ảnh',
      icon: 'pi pi-exclamation-triangle',
      accept: () => {
        this.loadingService.loading = true;
        this.productService.deleteProductImage(imageId).pipe(
          tap(() => {
            this.toastService.success('Đã xóa ảnh thành công.');
            this.images = this.images.filter(img => img.id !== imageId);
          }),
          catchError((err) => {
            this.toastService.fail('Xóa ảnh thất bại. Vui lòng thử lại.');
            console.error('Error deleting image:', err);
            return of(err);
          }),
          finalize(() => {
            this.loadingService.loading = false;
          })
        ).subscribe();
      }
    });
  }

  updateProductAdmin(fileUpload: FileUpload) {
    if (this.productForm.invalid) {
      this.toastService.fail("Vui lòng điền đầy đủ thông tin sản phẩm.");
      return;
    }

    this.loadingService.loading = true;

    const updatedProductData: ProductUploadReq = {
      name: this.productForm.value.productName,
      price: this.productForm.value.price,
      description: this.productForm.value.description,
      category_id: parseInt(this.categoryId, 10),
      discount: this.productForm.value.discount,
      quantity: this.productForm.value.quantity,
      featureIds: this.selectedFeatures
    };

    // Start the update process
    this.productService.updateProduct(updatedProductData, this.mainProduct.id).pipe(
      switchMap(() => {
        // After product update, handle image upload if necessary
        if (fileUpload && fileUpload.files.length > 0) {
          const formData = new FormData();
          fileUpload.files.forEach(file => {
            formData.append('files', file);
          });
          return this.productService.uploadImageProduct(formData, this.mainProduct.id);
        } else {
          // If no files to upload, just pass through
          return of(null);
        }
      }),
      tap(() => {
        // This will run after both product and images (if any) are updated successfully
        this.toastService.success('Cập nhật sản phẩm thành công!');
        fileUpload.clear();
        this.ngOnInit(); // Refresh component data
      }),
      catchError((err) => {
        const errorMessage = err.error?.message || 'Cập nhật sản phẩm thất bại. Vui lòng thử lại.';
        this.toastService.fail(errorMessage);
       return of(err); // Return observable to complete the stream
      }),
      finalize(() => {
        this.loadingService.loading = false;
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  loadReviews(): void {
    if (!this.id) return;
    
    // Load reviews
    this.reviewService.getReviewsByProduct(parseInt(this.id)).pipe(
      tap((reviews) => {
        this.reviews = reviews;
        // Check if current user has already reviewed
        if (this.currentUserId > 0) {
          this.hasUserReviewed = reviews.some(r => r.userId === this.currentUserId);
        }
      }),
      takeUntil(this.destroyed$)
    ).subscribe();

    // Load rating stats
    this.reviewService.getProductRatingStats(parseInt(this.id)).pipe(
      tap((stats) => {
        this.averageRating = stats.averageRating || 0;
        this.totalReviews = stats.totalReviews || 0;
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  submitReview(): void {
    if (!this.token) {
      this.toastService.fail('Vui lòng đăng nhập để đánh giá sản phẩm');
      return;
    }

    if (this.newReviewRating < 1 || this.newReviewRating > 5) {
      this.toastService.fail('Vui lòng chọn số sao từ 1 đến 5');
      return;
    }

    this.isSubmittingReview = true;

    this.reviewService.createReview({
      productId: parseInt(this.id),
      rating: this.newReviewRating,
      comment: this.newReviewComment
    }).pipe(
      tap(() => {
        this.toastService.success('Đánh giá của bạn đã được gửi thành công!');
        this.newReviewRating = 5;
        this.newReviewComment = '';
        this.loadReviews(); // Reload reviews
      }),
      catchError((err) => {
        const errorMessage = err.error?.error || err.error?.message || 'Không thể gửi đánh giá. Vui lòng thử lại.';
        this.toastService.fail(errorMessage);
        return of(err);
      }),
      finalize(() => {
        this.isSubmittingReview = false;
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  openReplyDialog(review: Review): void {
    if (!review.id) return;
    this.selectedReview = review;
    this.replyText = '';
    this.replyDialogVisible = true;
  }

  submitReply(): void {
    if (!this.selectedReview || !this.selectedReview.id) {
      this.toastService.fail('Không tìm thấy đánh giá');
      return;
    }

    if (!this.replyText.trim()) {
      this.toastService.fail('Vui lòng nhập nội dung phản hồi');
      return;
    }

    this.isSubmittingReply = true;

    const replyRequest: ReviewReplyRequest = {
      reviewId: this.selectedReview.id,
      reply: this.replyText.trim()
    };

    this.reviewService.replyToReview(replyRequest).pipe(
      tap(() => {
        this.toastService.success('Phản hồi đánh giá thành công!');
        this.replyDialogVisible = false;
        this.selectedReview = null;
        this.replyText = '';
        this.loadReviews(); // Reload reviews to show the reply
      }),
      catchError((err) => {
        const errorMessage = err.error?.error || err.error?.message || 'Không thể gửi phản hồi. Vui lòng thử lại.';
        this.toastService.fail(errorMessage);
        return of(err);
      }),
      finalize(() => {
        this.isSubmittingReply = false;
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  deleteReview(reviewId: number): void {
    console.log('deleteReview called with ID:', reviewId);
    
    if (!reviewId) {
      console.error('Review ID is undefined or null');
      this.toastService.fail('Lỗi: Không tìm thấy ID đánh giá');
      return;
    }

    console.log('About to call confirmationService.confirm');
    
    try {
      this.confirmationService.confirm({
        message: 'Bạn có chắc chắn muốn xóa đánh giá này?',
        header: 'Xác nhận xóa',
        icon: 'pi pi-exclamation-triangle',
        accept: () => {
          console.log('User confirmed deletion');
          this.reviewService.deleteReview(reviewId).pipe(
            tap(() => {
              console.log('Delete successful');
              this.toastService.success('Đã xóa đánh giá');
              this.hasUserReviewed = false; // Reset flag
              this.loadReviews(); // Reload reviews
            }),
            catchError((err) => {
              console.error('Delete review error:', err);
              const errorMessage = err.error?.error || err.error?.message || 'Không thể xóa đánh giá';
              this.toastService.fail(errorMessage);
              return of(err);
            }),
            takeUntil(this.destroyed$)
          ).subscribe();
        },
        reject: () => {
          console.log('User cancelled deletion');
        }
      });
      console.log('confirmationService.confirm called successfully');
    } catch (error) {
      console.error('Error calling confirmationService.confirm:', error);
    }
  }

  getStarArray(rating: number): number[] {
    return Array(5).fill(0).map((_, i) => i < rating ? 1 : 0);
  }

  getSafeHtml(content: string): SafeHtml {
    return this.sanitizer.bypassSecurityTrustHtml(content);
  }

  private stripHtml(html: string): string {
    if (!html) return '';
    return html.replace(/<[^>]*>/g, ' ').replace(/\s+/g, ' ').trim();
  }

  toggleDescription(): void {
    this.isDescriptionExpanded = !this.isDescriptionExpanded;
  }

  toggleAccordion(index: number): void {
    this.accordionStates[index] = !this.accordionStates[index];
  }

  getProductImageUrl(product: ProductDto): string {
    // If product has a thumbnail, use it
    if (product.thumbnail && product.thumbnail.trim() !== '' && product.thumbnail !== 'null') {
      return this.apiImage + product.thumbnail;
    }
    
    // If no thumbnail but has product_images, use the first one
    if (product.product_images && product.product_images.length > 0 && product.product_images[0]?.image_url) {
      return this.apiImage + product.product_images[0].image_url;
    }
    
    // Default image if no images available
    return 'assets/images/no-image.png';
  }

  generateProductDescription(): void {
    const productName = this.productForm.get('productName')?.value;
    const categoryId = this.mainProduct?.category_id;

    if (!productName) {
      this.toastService.warn('Vui lòng nhập tên sản phẩm trước');
      return;
    }

    // Get category name
    const categoryName = categoryId 
      ? this.categoriesOptions.find(cat => cat['value'] === categoryId.toString())?.['label'] 
      : undefined;

    // Get feature names
    const featureNames = this.selectedFeatures
      .map(id => this.featuresOptions.find(f => f['value'] === id)?.['label'])
      .filter(name => name)
      .join(', ');

    this.isGeneratingDescription = true;

    this.aiService.generateProductDescription(
      productName,
      categoryName,
      featureNames || undefined
    ).pipe(
      finalize(() => this.isGeneratingDescription = false)
    ).subscribe({
      next: (response: { content: string }) => {
        this.productForm.patchValue({ description: response.content });
        this.toastService.success('KVK Intelligence đã tạo mô tả sản phẩm thành công!');
      },
      error: (error: any) => {
        console.error('Error generating product description:', error);
        this.toastService.fail('Không thể tạo mô tả sản phẩm. Vui lòng thử lại.');
      }
    });
  }
}
