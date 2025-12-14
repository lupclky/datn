import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators, ValidationErrors, AbstractControl } from '@angular/forms';
import { RouterModule } from '@angular/router';
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
  selector: 'app-change-password',
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
  templateUrl: './change-password.component.html',
  styleUrl: './change-password.component.scss'
})
export class ChangePasswordComponent extends BaseComponent implements OnInit {
  changePasswordForm: FormGroup;
  isLoading = false;
  showCurrentPassword = false;
  showNewPassword = false;
  showConfirmPassword = false;

  constructor(
    private fb: FormBuilder,
    private userService: UserService,
    private toastService: ToastService
  ) {
    super();
    this.changePasswordForm = this.fb.group({
      currentPassword: ['', [Validators.required]],
      newPassword: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', [Validators.required]]
    }, {
      validators: this.passwordMatchValidator
    });
  }

  ngOnInit(): void {
  }

  toggleCurrentPassword(): void {
    this.showCurrentPassword = !this.showCurrentPassword;
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
    if (this.changePasswordForm.invalid) {
      this.changePasswordForm.markAllAsTouched();
      this.toastService.fail('Vui lòng kiểm tra lại thông tin.');
      return;
    }

    const currentPassword = this.changePasswordForm.value.currentPassword;
    const newPassword = this.changePasswordForm.value.newPassword;
    const confirmPassword = this.changePasswordForm.value.confirmPassword;

    if (newPassword !== confirmPassword) {
      this.toastService.fail('Mật khẩu mới và xác nhận mật khẩu không khớp.');
      return;
    }

    if (currentPassword === newPassword) {
      this.toastService.fail('Mật khẩu mới phải khác với mật khẩu hiện tại.');
      return;
    }

    this.isLoading = true;
    this.userService.changePassword(currentPassword, newPassword).pipe(
      catchError((error) => {
        this.isLoading = false;
        if (error.status === 400) {
          this.toastService.fail('Mật khẩu hiện tại không chính xác.');
        } else {
          this.toastService.fail(error.error?.message || 'Đã xảy ra lỗi. Vui lòng thử lại.');
        }
        return of();
      }),
      takeUntil(this.destroyed$)
    ).subscribe((response) => {
      if (response) {
        this.isLoading = false;
        this.toastService.success(response.message || 'Đổi mật khẩu thành công.');
        this.changePasswordForm.reset();
      }
    });
  }
} 