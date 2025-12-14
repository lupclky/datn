import { AfterViewInit, Component, Inject, PLATFORM_ID, OnInit } from '@angular/core';
import { BaseComponent } from '../../../../core/commonComponent/base.component';
import { FormBuilder, FormGroup, Validators, FormsModule, ReactiveFormsModule } from '@angular/forms';
import { ToastModule } from 'primeng/toast';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { CheckboxModule } from 'primeng/checkbox';
import { Router, RouterModule, ActivatedRoute } from '@angular/router';
import { MessageService } from 'primeng/api';
import { ToastService } from '../../../../core/services/toast.service';
import { Subject, catchError, delay, filter, of, switchMap, takeUntil, tap } from 'rxjs';
import { PasswordModule } from 'primeng/password';
import { UserService } from '../../../../core/services/user.service';
import { loginDetailDto } from '../../../../core/dtos/login.dto';
import { KeyFilterModule } from 'primeng/keyfilter';
import { BlockUIModule } from 'primeng/blockui';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { UserDto } from '../../../../core/dtos/user.dto';
import { isPlatformBrowser, CommonModule } from '@angular/common';
import { AccountMonitorService } from '../../../../core/services/account-monitor.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    ToastModule,
    ButtonModule,
    InputTextModule,
    CheckboxModule,
    RouterModule,
    PasswordModule,
    KeyFilterModule,
    BlockUIModule,
    ProgressSpinnerModule
  ],
  providers: [
    MessageService,
    ToastService
  ],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss'
})
export class LoginComponent extends BaseComponent implements OnInit, AfterViewInit {
  private token: string | null = null;
  public loginForm: FormGroup;
  public forgotPasswordForm: FormGroup;
  public formSubmitSubject = new Subject<void>();
  public formSubmit$ = this.formSubmitSubject.asObservable();
  public blockedUi: boolean = false;
  public showPassword = false;
  public showForgotPassword = false;
  public isForgotPasswordLoading = false;
  
  get userName() {
    return this.loginForm.get('userName');
  }

  get password() {
    return this.loginForm.get('password');
  }
  
  constructor(
    private readonly fb: FormBuilder,
    private readonly messageService: MessageService,
    private toastService: ToastService,
    private userSerivce: UserService,
    private router: Router,
    private route: ActivatedRoute,
    public accountMonitor: AccountMonitorService,
    @Inject(PLATFORM_ID) private platformId: Object
  ) {
    super();
    this.loginForm = this.fb.group({
      userName: [, Validators.required],
      password: [, Validators.required],
      rememberMe: [false]
    });
    this.forgotPasswordForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]]
    });
    if (isPlatformBrowser(this.platformId)) {
      console.log('LoginComponent initialized');
      console.log('Current token:', localStorage.getItem('token'));
    }
  }

  ngOnInit(): void {
    // Không cần xử lý query params nữa vì đã có modal global
    if (isPlatformBrowser(this.platformId)) {
      this.initializeGoogleSignIn();
    }
  }

  private initializeGoogleSignIn(): void {
    // Wait for Google Identity Services to load
    const checkGoogle = setInterval(() => {
      if (typeof (window as any).google !== 'undefined') {
        clearInterval(checkGoogle);
        this.setupGoogleButton();
      }
    }, 100);

    // Timeout after 5 seconds
    setTimeout(() => clearInterval(checkGoogle), 5000);
  }

  private setupGoogleButton(): void {
    const clientId = '483006774404-h1khmdglipffu6mbjcfs4crt2cpmghtv.apps.googleusercontent.com';
    
    (window as any).google.accounts.id.initialize({
      client_id: clientId,
      callback: (response: any) => {
        this.handleGoogleSignIn(response.credential);
      }
    });

    // Render hidden button for Google OAuth flow
    (window as any).google.accounts.id.renderButton(
      document.getElementById('google-signin-button'),
      {
        type: 'standard',
        theme: 'outline',
        size: 'large',
        text: 'signin_with',
        width: '100%',
        locale: 'vi'
      }
    );
  }

  triggerGoogleSignIn(): void {
    if (!isPlatformBrowser(this.platformId)) {
      return;
    }

    // Check if Google Identity Services is loaded
    if (typeof (window as any).google === 'undefined') {
      this.toastService.fail('Google Sign-In chưa sẵn sàng. Vui lòng thử lại sau.');
      return;
    }

    const clientId = '483006774404-h1khmdglipffu6mbjcfs4crt2cpmghtv.apps.googleusercontent.com';
    
    // Method 1: Try to click the hidden rendered button
    setTimeout(() => {
      const hiddenButton = document.getElementById('google-signin-button');
      if (hiddenButton) {
        // Try multiple selectors to find the clickable element
        const selectors = [
          'div[role="button"]',
          'div[id*="button"]',
          'iframe',
          'div'
        ];
        
        let clicked = false;
        for (const selector of selectors) {
          const element = hiddenButton.querySelector(selector) as HTMLElement;
          if (element) {
            try {
              element.click();
              clicked = true;
              break;
            } catch (e) {
              // Continue to next selector
            }
          }
        }
        
        if (!clicked) {
          // Fallback: Show One Tap
          this.showGoogleOneTap();
        }
      } else {
        // Fallback: Show One Tap
        this.showGoogleOneTap();
      }
    }, 200);
  }

  private showGoogleOneTap(): void {
    const clientId = '483006774404-h1khmdglipffu6mbjcfs4crt2cpmghtv.apps.googleusercontent.com';
    
    // Use One Tap prompt as fallback
    (window as any).google.accounts.id.prompt((notification: any) => {
      if (notification.isNotDisplayed() || notification.isSkippedMoment()) {
        // If One Tap is not available, try to render button again
        this.setupGoogleButton();
        setTimeout(() => {
          this.triggerGoogleSignIn();
        }, 500);
      }
    });
  }

  ngAfterViewInit(): void {
    this.formSubmit$.pipe(
      filter(() => {
        if (this.loginForm.invalid) {
          this.toastService.fail("Vui lòng kiểm tra lại thông tin");
          return false;
        }
        return true;
      }),
      switchMap(() => {
        console.log('Submitting login form...');
        return this.userSerivce.login({
          phone_number: this.loginForm.value.userName,
          password: this.loginForm.value.password
        }).pipe(
          tap((loginVal: loginDetailDto) => {
            if (isPlatformBrowser(this.platformId)) {
              console.log('Login successful');
              this.toastService.success(loginVal.message);
              console.log('Saving token to localStorage...');
              localStorage.setItem("token", loginVal.token);
              this.token = loginVal.token;
              console.log('Token saved:', this.token ? 'exists' : 'not found');
              this.blockUi();
            }
          }),
          delay(1000),
          switchMap(() => {
            console.log('Getting user info...');
            return this.userSerivce.getInforUser(this.token).pipe(
              tap((userInfor: UserDto) => {
                if (isPlatformBrowser(this.platformId)) {
                  console.log('Saving user info...');
                  localStorage.setItem("userInfor", JSON.stringify(userInfor));
                  console.log('User info saved');
                }
              })
            );
          }),
          tap(() => {
            if (isPlatformBrowser(this.platformId)) {
              console.log('Redirecting to home page...');
              window.location.href = '/Home';
            }
          }),
          catchError((error) => {
            console.log('--- ERROR CATCH ---');
            console.log('Status:', error.status);
            console.log('Error Object:', error.error);
            console.log('Error Message:', error.error?.message);
            
            const isBlocked = error.status === 400 && error.error?.message?.includes('Tài khoản của bạn đã bị khóa');
            console.log('Is Blocked Condition Met:', isBlocked);

            // Kiểm tra cụ thể nếu lỗi là do tài khoản bị khóa
            if (isBlocked) {
              // Hiển thị modal lớn thông báo tài khoản bị khóa
              this.accountMonitor.showBlockedModal();
            } else {
              // Hiển thị toast cho các lỗi đăng nhập khác
              this.toastService.fail(error.error?.message || 'Đăng nhập thất bại. Vui lòng thử lại.');
            }
            
            // Ngăn không cho observable tiếp tục và gây ra lỗi không cần thiết
            return of(); 
          })
        )
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  blockUi() {
    this.blockedUi = true;
    setTimeout(() => {
        this.blockedUi = false;
    }, 1000);
  }

  onSubmit() {
    console.log('Form submitted');
    this.formSubmitSubject.next();
  }

  togglePassword(): void {
    this.showPassword = !this.showPassword;
  }

  onLogin(): void {
    if (this.loginForm.valid) {
      this.formSubmitSubject.next();
    }
  }

  toggleForgotPassword(): void {
    this.showForgotPassword = !this.showForgotPassword;
    if (!this.showForgotPassword) {
      this.forgotPasswordForm.reset();
    }
  }

  onSubmitForgotPassword(): void {
    if (this.forgotPasswordForm.invalid) {
      this.toastService.fail('Vui lòng nhập địa chỉ email hợp lệ.');
      return;
    }

    this.isForgotPasswordLoading = true;
    const email = this.forgotPasswordForm.value.email;
    
    this.userSerivce.forgotPassword(email).pipe(
      tap((response) => {
        this.toastService.success(
          response.message || 
          'Gửi email thành công. Vui lòng kiểm tra email của bạn.'
        );
        this.forgotPasswordForm.reset();
        this.showForgotPassword = false;
      }),
      catchError((error) => {
        this.toastService.fail(
          error.error?.message || 
          'Đã xảy ra lỗi. Vui lòng thử lại.'
        );
        return of();
      }),
      takeUntil(this.destroyed$)
    ).subscribe(() => {
      this.isForgotPasswordLoading = false;
    });
  }


  private handleGoogleSignIn(credential: string): void {
    this.blockUi();
    this.userSerivce.loginWithGoogle(credential).pipe(
      switchMap((loginVal: loginDetailDto) => {
        if (isPlatformBrowser(this.platformId)) {
          console.log('Google login response:', loginVal);
          
          // Check if this is a new user
          if (loginVal.is_new_user) {
            // New user - redirect to register with Google info
            this.toastService.success('Vui lòng hoàn tất đăng ký với thông tin Google');
            
            // Get Google account ID from the credential (decode it)
            // We'll extract it from the token response if available
            // For now, store email and name - backend will link by email
            const googleInfo = {
              email: loginVal.google_email || '',
              fullname: loginVal.google_name || '',
              fromGoogle: true
            };
            sessionStorage.setItem('googleRegisterInfo', JSON.stringify(googleInfo));
            
            // Redirect to register page
            this.router.navigate(['/register'], { 
              queryParams: { 
                fromGoogle: 'true',
                email: loginVal.google_email || '',
                name: loginVal.google_name || ''
              }
            });
            return of(null); // Return empty to stop the chain
          }
          
          // Existing user - proceed with normal login
          console.log('Google login successful');
          this.toastService.success(loginVal.message);
          if (loginVal.token) {
            localStorage.setItem("token", loginVal.token);
            this.token = loginVal.token;
          }
          
          // Continue with getting user info
          if (loginVal.token) {
            return this.userSerivce.getInforUser(loginVal.token).pipe(
              delay(1000),
              tap((userInfor: UserDto) => {
                if (isPlatformBrowser(this.platformId)) {
                  localStorage.setItem("userInfor", JSON.stringify(userInfor));
                }
              })
            );
          }
        }
        return of(null);
      }),
      tap(() => {
        if (isPlatformBrowser(this.platformId)) {
          // Only redirect to home if we have a token (existing user)
          if (this.token) {
            window.location.href = '/Home';
          }
        }
      }),
      catchError((error) => {
        console.error('Google login error:', error);
        this.toastService.fail(error.error?.message || 'Đăng nhập Google thất bại. Vui lòng thử lại.');
        return of();
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }
}
