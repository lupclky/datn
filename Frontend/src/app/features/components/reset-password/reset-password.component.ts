import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators, ValidationErrors, AbstractControl } from '@angular/forms';
import { Router, ActivatedRoute, RouterModule } from '@angular/router';
import { UserService } from '../../../core/services/user.service';
import { ToastService } from '../../../core/services/toast.service';
import { MessageService } from 'primeng/api';
import { ToastModule } from 'primeng/toast';
import { catchError, of, takeUntil } from 'rxjs';
import { BaseComponent } from '../../../core/commonComponent/base.component';

// PrimeNG Modules
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';

@Component({
  selector: 'app-reset-password',
  standalone: true,
  imports: [
    CommonModule, 
    ReactiveFormsModule, 
    RouterModule,
    ToastModule,
    ButtonModule,
    InputTextModule
  ],
  providers: [
    MessageService,
    ToastService
  ],
  templateUrl: './reset-password.component.html',
  styleUrl: './reset-password.component.scss'
})
export class ResetPasswordComponent extends BaseComponent implements OnInit {
  resetPasswordForm: FormGroup;
  token = '';
  isLoading = false;
  showNewPassword = false;
  showConfirmPassword = false;

  constructor(
    private fb: FormBuilder,
    private userService: UserService,
    private toastService: ToastService,
    private router: Router,
    private route: ActivatedRoute
  ) {
    super();
    this.resetPasswordForm = this.fb.group({
      newPassword: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', [Validators.required]]
    }, {
      validators: this.passwordMatchValidator
    });
  }

  ngOnInit(): void {
    this.route.queryParams.subscribe(params => {
      this.token = params['token'] || '';
      if (!this.token) {
        this.toastService.fail('Token đặt lại mật khẩu không hợp lệ.');
        this.router.navigate(['/auth-login']);
      }
    });
  }

  toggleNewPassword(): void {
    this.showNewPassword = !this.showNewPassword;
  }

  toggleConfirmPassword(): void {
    this.showConfirmPassword = !this.showConfirmPassword;
  }

  private passwordMatchValidator(group: AbstractControl): ValidationErrors | null {
    const newPassword = group.get('newPassword');
    const confirmPassword = group.get('confirmPassword');
    
    if (!newPassword || !confirmPassword) {
      return null;
    }
    
    if (newPassword.value !== confirmPassword.value) {
      confirmPassword.setErrors({ passwordMismatch: true });
      return { passwordMismatch: true };
    } else {
      if (confirmPassword.hasError('passwordMismatch')) {
        confirmPassword.setErrors(null);
      }
    }
    return null;
  }

  onSubmit(): void {
    if (this.resetPasswordForm.invalid) {
      this.resetPasswordForm.markAllAsTouched();
      this.toastService.fail('Vui lòng kiểm tra lại thông tin.');
      return;
    }

    const newPassword = this.resetPasswordForm.value.newPassword;
    const confirmPassword = this.resetPasswordForm.value.confirmPassword;

    if (newPassword !== confirmPassword) {
      this.toastService.fail('Mật khẩu xác nhận không khớp.');
      return;
    }

    if (newPassword.length < 6) {
      this.toastService.fail('Mật khẩu phải có ít nhất 6 ký tự.');
      return;
    }

    this.isLoading = true;
    this.userService.resetPassword(this.token, newPassword).pipe(
      catchError((error) => {
        this.isLoading = false;
        this.toastService.fail(error.error?.message || 'Đã xảy ra lỗi. Vui lòng thử lại.');
        return of();
      }),
      takeUntil(this.destroyed$)
    ).subscribe((response) => {
      if (response) {
        this.isLoading = false;
        this.toastService.success(response.message || 'Đặt lại mật khẩu thành công.');
        setTimeout(() => {
          this.router.navigate(['/auth-login']);
        }, 2000);
      }
    });
  }
} 